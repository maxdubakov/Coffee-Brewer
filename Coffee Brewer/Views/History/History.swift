import SwiftUI
import CoreData

struct History: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - State
    @StateObject private var viewModel = HistoryViewModel()
    @State private var showChartSelector = false
    @State private var draggedChart: Chart?
    
    // MARK: - Fetch Request
    @FetchRequest(
        entity: Brew.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Brew.date, ascending: false)],
        animation: .default
    ) private var brews: FetchedResults<Brew>
    
    var body: some View {
        GlobalBackground {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        PageTitleH1("Analytics")
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        Button(action: {
                            showChartSelector = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(BrewerColors.chartPrimary)
                        }
                        .padding(.trailing)
                    }
                    .padding(.top, 8)
                    
                    if brews.isEmpty {
                        emptyStateView
                    } else {
                        analyticsView
                    }
                }
            }
            .sheet(isPresented: $showChartSelector) {
                ChartSelectorView(viewModel: viewModel)
            }
            .sheet(item: $viewModel.selectedChart) { chart in
                ChartSelectorView(viewModel: viewModel, editingChart: chart)
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "cup.and.saucer")
                    .font(.system(size: 60))
                    .foregroundColor(BrewerColors.caramel.opacity(0.6))
                
                Text("No brews yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(BrewerColors.textPrimary)
                
                Text("Your brewing history will appear here")
                    .font(.subheadline)
                    .foregroundColor(BrewerColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Analytics View
    private var analyticsView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Chart widgets
                ForEach(viewModel.charts, id: \.id) { chart in
                    ChartRow(
                        chart: chart,
                        viewModel: viewModel,
                        brews: Array(brews)
                    )
                    .onDrag {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        self.draggedChart = chart
                        return NSItemProvider(object: (chart.id?.uuidString ?? "") as NSString)
                    }
                    .onDrop(of: [.text], delegate: ChartDropDelegate(
                        chart: chart,
                        charts: $viewModel.charts,
                        draggedChart: $draggedChart,
                        viewModel: viewModel
                    ))
                }
                
                // Recent brews section
                if !brews.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("RECENT BREWS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(BrewerColors.textPrimary)
                            .tracking(1.5)
                            .padding(.horizontal, 18)
                            .padding(.top, 24)
                        
                        ForEach(brews.prefix(5), id: \.self) { brew in
                            BrewHistoryCard(brew: brew)
                                .padding(.horizontal, 18)
                        }
                    }
                }
                
                // Add extra space at bottom for tab bar
                Spacer().frame(height: 100)
            }
            .padding(.top, 8)
        }
        .onDrop(of: [.text], isTargeted: nil) { providers in
            // Global drop zone to reset dragging state if dropped outside specific areas
            draggedChart = nil
            return false
        }
    }
}

// MARK: - Chart Row Component
struct ChartRow: View {
    @ObservedObject var chart: Chart
    let viewModel: HistoryViewModel
    let brews: [Brew]
    @State private var localConfiguration: ChartConfiguration?
    
    var body: some View {
        if let configuration = localConfiguration ?? chart.toChartConfiguration() {
            FlexibleChartWidget(
                configuration: Binding(
                    get: {
                        localConfiguration ?? configuration
                    },
                    set: { newValue in
                        localConfiguration = newValue
                        // Debounce Core Data updates
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if chart.isExpanded != newValue.isExpanded {
                                chart.isExpanded = newValue.isExpanded
                                viewModel.updateChart(chart)
                            }
                        }
                    }
                ),
                brews: brews,
                onRemove: {
                    withAnimation {
                        viewModel.removeChart(chart)
                    }
                },
                onConfigure: {
                    viewModel.selectedChart = chart
                }
            )
            .onAppear {
                localConfiguration = chart.toChartConfiguration()
            }
            .onChange(of: chart.updatedAt) { _, _ in
                // Refresh local configuration when chart is updated
                localConfiguration = chart.toChartConfiguration()
            }
            .onChange(of: chart.title) { _, _ in
                // Refresh when title changes
                localConfiguration = chart.toChartConfiguration()
            }
            .onChange(of: chart.xAxisId) { _, _ in
                // Refresh when axes change
                localConfiguration = chart.toChartConfiguration()
            }
            .onChange(of: chart.yAxisId) { _, _ in
                // Refresh when axes change
                localConfiguration = chart.toChartConfiguration()
            }
        }
    }
}

// MARK: - Brew History Card Component
struct BrewHistoryCard: View {
    // MARK: - Properties
    @ObservedObject var brew: Brew
    
    // MARK: - Computed Properties
    private var brewDate: String {
        guard let date = brew.date else { return "Unknown date" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private var ratingStars: String {
        let rating = Int(brew.rating)
        return String(repeating: "★", count: rating) + String(repeating: "☆", count: 5 - rating)
    }
    
    private var recipeName: String {
        // Use snapshot data if recipe is deleted
        if let recipe = brew.recipe {
            return recipe.name ?? "Unknown Recipe"
        } else {
            return brew.recipeName ?? "Deleted Recipe"
        }
    }
    
    private var roasterName: String {
        // Use snapshot data if recipe is deleted
        if let recipe = brew.recipe {
            return recipe.roaster?.name ?? "Unknown Roaster"
        } else {
            return brew.roasterName ?? "Unknown Roaster"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with date and rating
            HStack {
                Text(brewDate)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(BrewerColors.textSecondary)
                
                Spacer()
                
                if brew.rating > 0 {
                    Text(ratingStars)
                        .font(.system(size: 14))
                        .foregroundColor(BrewerColors.caramel)
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            
            // Recipe name and roaster
            Text(recipeName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(BrewerColors.textPrimary)
                .padding(.top, 12)
                .padding(.horizontal, 16)
            
            Text(roasterName)
                .font(.system(size: 14))
                .foregroundColor(BrewerColors.textSecondary)
                .padding(.top, 4)
                .padding(.horizontal, 16)
            
            // Recipe details in small format
            HStack(spacing: 12) {
                // Use recipe data if available, otherwise use snapshot
                let grams = brew.recipe?.grams ?? brew.recipeGrams
                let waterAmount = brew.recipe?.waterAmount ?? brew.recipeWaterAmount
                let temperature = brew.recipe?.temperature ?? brew.recipeTemperature
                
                RecipeDetailTag(
                    icon: "scalemass",
                    value: "\(grams)g",
                    color: BrewerColors.caramel
                )
                
                RecipeDetailTag(
                    icon: "drop",
                    value: "\(waterAmount)ml",
                    color: BrewerColors.caramel
                )
                
                RecipeDetailTag(
                    icon: "thermometer",
                    value: "\(Int(temperature))°C",
                    color: BrewerColors.caramel
                )
                
                RecipeDetailTag(
                    icon: "timer",
                    value: "\(Int(brew.actualDurationSeconds))s",
                    color: BrewerColors.caramel
                )
            }
            .padding(.top, 12)
            .padding(.horizontal, 16)
            
            // Notes if available
            if let notes = brew.notes, !notes.isEmpty {
                Text(notes)
                    .font(.system(size: 14))
                    .foregroundColor(BrewerColors.textPrimary.opacity(0.8))
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .lineLimit(3)
            } else {
                Spacer(minLength: 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(BrewerColors.surface.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(BrewerColors.divider, lineWidth: 1)
                )
        )
    }
}

// Small tag for recipe details
struct RecipeDetailTag: View {
    var icon: String
    var value: String
    var color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(BrewerColors.textPrimary)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(BrewerColors.background.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(color.opacity(0.2), lineWidth: 0.5)
                )
        )
    }
}

// MARK: - Drop Delegate
struct ChartDropDelegate: DropDelegate {
    let chart: Chart
    @Binding var charts: [Chart]
    @Binding var draggedChart: Chart?
    let viewModel: HistoryViewModel
    
    func performDrop(info: DropInfo) -> Bool {
        let successFeedback = UINotificationFeedbackGenerator()
        successFeedback.notificationOccurred(.success)
        draggedChart = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedChart = self.draggedChart,
              draggedChart.id != chart.id else {
            return
        }
        
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        
        guard let from = charts.firstIndex(where: { $0.id == draggedChart.id }),
              let to = charts.firstIndex(where: { $0.id == chart.id }) else {
            return
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            charts.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            
            // Update Core Data with new order
            for (index, chart) in charts.enumerated() {
                chart.sortOrder = Int32(charts.count - index)
            }
            viewModel.saveContext()
        }
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    // Create some sample brews for the preview
    let createSampleBrew = { (recipeName: String, rating: Int16, date: Date, notes: String?) in
        let brew = Brew(context: context)
        brew.id = UUID()
        
        // Find or create a recipe
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", recipeName)
        fetchRequest.fetchLimit = 1
        
        let recipes = try? context.fetch(fetchRequest)
        let recipe = recipes?.first ?? Recipe(context: context)
        
        if recipes?.first == nil {
            recipe.name = recipeName
            recipe.grams = 18
            recipe.waterAmount = 250
            recipe.temperature = 94
            
            // Create a roaster if needed
            let roaster = Roaster(context: context)
            roaster.id = UUID()
            roaster.name = "Sample Roaster"
            recipe.roaster = roaster
        }
        
        brew.recipe = recipe
        brew.rating = rating
        brew.date = date
        brew.notes = notes
        
        return brew
    }
    
    // Create sample brews with different dates
    let calendar = Calendar.current
    let today = Date()
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
    let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
    
    let _ = createSampleBrew(
        "Ethiopian Pour Over",
        5,
        today,
        "Wonderful fruity notes with a hint of blueberry. Very balanced with a clean finish."
    )
    
    let _ = createSampleBrew(
        "Colombia Espresso",
        3,
        yesterday,
        "A bit too bitter, might need to adjust the grind size next time."
    )
    
    let _ = createSampleBrew(
        "Kenya Light Roast",
        4,
        twoDaysAgo,
        nil
    )
    
    return History()
        .environment(\.managedObjectContext, context)
}
