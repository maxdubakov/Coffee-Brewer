import SwiftUI
import CoreData

struct History: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    
    // MARK: - State
    @StateObject private var viewModel = HistoryViewModel()
    @State private var showChartSelector = false
    @State private var isEditingCharts = false
    @State private var selectedCharts = Set<NSManagedObjectID>()
    @State private var showDeleteAlert = false
    @State private var chartRowHeight: CGFloat = 0
    
    // MARK: - Fetch Request
    @FetchRequest(
        entity: Brew.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Brew.date, ascending: false)],
        animation: .default
    ) private var brews: FetchedResults<Brew>
    
    var body: some View {
        GlobalBackground {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack(alignment: .top) {
                    PageTitleH1("Analytics", subtitle: "Discover patters in your brews")
                    
                    Spacer()
                    
                    Button(action: {
                        showChartSelector = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(BrewerColors.chartPrimary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                
                if brews.isEmpty {
                    emptyStateView
                } else {
                    analyticsView
                }
            }
            .sheet(isPresented: $showChartSelector) {
                ChartSelectorView(viewModel: viewModel)
            }
            .sheet(item: $viewModel.selectedChart) { chart in
                ChartSelectorView(viewModel: viewModel, editingChart: chart)
            }
            .alert("Delete Charts", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteSelectedCharts()
                }
            } message: {
                Text("Are you sure you want to delete \(selectedCharts.count) chart\(selectedCharts.count == 1 ? "" : "s")? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        CenteredContent(verticalOffset: -50) {
            VStack(spacing: 16) {
                SVGIcon("empty.chart", size: 60, color: BrewerColors.caramel)
                
                Text("No brews yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(BrewerColors.textPrimary)
                
                Text("Your brewing history will appear here")
                    .font(.subheadline)
                    .foregroundColor(BrewerColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Analytics View
    private var analyticsView: some View {
        ScrollView {
            LazyVStack(spacing: 32) {
                // Statistics Overview Cards
                statsOverviewSection
                
                // Charts Section
                if !viewModel.charts.isEmpty {
                    chartsSection
                }
                
                recentActivitySection
                
                // Add extra space at bottom for tab bar
                Color.clear.frame(height: 100)
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - Minimalistic Stats Overview Section
    private var statsOverviewSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Clean 2x2 stats table
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    // Total Brews
                    StatCell(
                        value: "\(brews.count)",
                        description: "Total Brews"
                    )
                    
                    // Divider
                    Rectangle()
                        .fill(BrewerColors.divider)
                        .frame(width: 1)
                    
                    // Average Rating
                    StatCell(
                        value: String(format: "%.1f", averageRating),
                        description: "Average Rating"
                    )
                }
                
                // Horizontal divider
                Rectangle()
                    .fill(BrewerColors.divider)
                    .frame(height: 1)
                
                HStack(spacing: 0) {
                    // This Week
                    StatCell(
                        value: "\(brewsThisWeek)",
                        description: "This Week"
                    )
                    
                    // Divider
                    Rectangle()
                        .fill(BrewerColors.divider)
                        .frame(width: 1)
                    
                    // Weekly Average Rating
                    StatCell(
                        value: String(format: "%.1f", weeklyAverageRating),
                        description: "This Week Avg"
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Charts Section
    private var chartsSection: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Charts")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(BrewerColors.textPrimary)
                    
                    Spacer()
                    
                    if !viewModel.charts.isEmpty {
                        Button(action: {
                            withAnimation {
                                if isEditingCharts && !selectedCharts.isEmpty {
                                    // Show delete confirmation alert
                                    showDeleteAlert = true
                                } else {
                                    // Toggle edit mode
                                    isEditingCharts.toggle()
                                    if !isEditingCharts {
                                        selectedCharts.removeAll()
                                    }
                                }
                            }
                        }) {
                            if isEditingCharts && !selectedCharts.isEmpty {
                                Text("Delete (\(selectedCharts.count))")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.red)
                            } else {
                                Text(isEditingCharts ? "Done" : "Edit")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(BrewerColors.chartPrimary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Show all charts as minimized cards with navigation
                if isEditingCharts {
                    // Edit mode with selection
                    List(selection: $selectedCharts) {
                        ForEach(viewModel.charts, id: \.objectID) { chart in
                            MiniChartRow(
                                chart: chart,
                                brews: Array(brews),
                                viewModel: viewModel
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        }
                        .onMove(perform: viewModel.moveChart)
                    }
                    .listStyle(PlainListStyle())
                    .frame(width: geometry.size.width)
                    .frame(minHeight: calculateListHeight(chartCount: viewModel.charts.count, width: geometry.size.width))
                    .scrollDisabled(true) // Disable scrolling since parent ScrollView handles it
                    .environment(\.editMode, .constant(.active))
                    .padding(.bottom, 20) // Add padding to prevent last chart from being cut off
                } else {
                    // Normal mode
                    List {
                        ForEach(viewModel.charts, id: \.id) { chart in
                            MiniChartRow(
                                chart: chart,
                                brews: Array(brews),
                                viewModel: viewModel
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
                        }
                        .onMove(perform: viewModel.moveChart)
                    }
                    .listStyle(PlainListStyle())
                    .frame(width: geometry.size.width)
                    .frame(minHeight: calculateListHeight(chartCount: viewModel.charts.count, width: geometry.size.width))
                    .scrollDisabled(true) // Disable scrolling since parent ScrollView handles it
                    .padding(.bottom, 20) // Add padding to prevent last chart from being cut off
                }
            }
        }
        .frame(minHeight: CGFloat(viewModel.charts.count * 200))
    }
    
    // Helper function to calculate proper list height based on chart dimensions
    private func calculateListHeight(chartCount: Int, width: CGFloat) -> CGFloat {
        // Calculate chart height based on width using the aspect ratio from chart views
        let chartPadding: CGFloat = 32 // 16 top + 16 bottom from list row insets
        let chartContentPadding: CGFloat = 32 // padding inside MiniChartRow
        let titleHeight: CGFloat = 30 // approximate height for title and chevron
        
        // Width minus horizontal paddings
        let effectiveWidth = width - 32 // 16 padding on each side from MiniChartRow
        
        // Calculate chart height based on aspect ratio (3.0 for minimized charts)
        let chartHeight = effectiveWidth / 3.0
        
        // Total height per chart row
        let rowHeight = chartHeight + titleHeight + chartPadding + chartContentPadding
        
        return CGFloat(chartCount) * rowHeight
    }
    
    // MARK: - Chart Deletion Methods
    private func deleteSelectedCharts() {
        for chartID in selectedCharts {
            if let chart = viewModel.charts.first(where: { $0.objectID == chartID }) {
                viewModel.removeChart(chart)
            }
        }
        selectedCharts.removeAll()
        isEditingCharts = false
    }
    
    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Recent Activity")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(BrewerColors.textPrimary)
                .padding(.horizontal)
            
            // Grouped brews by roaster
            let groupedBrews = groupBrewsByRoaster()
            
            // Scrollable brew list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(groupedBrews, id: \.roasterName) { group in
                        VStack(alignment: .leading, spacing: 12) {
                            // Roaster header
                            HStack {
                                Text(group.roasterName)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(BrewerColors.cream)
                                
                                Spacer()
                                
                                Text("\(group.brews.count) brew\(group.brews.count == 1 ? "" : "s")")
                                    .font(.system(size: 14))
                                    .foregroundColor(BrewerColors.textSecondary)
                            }
                            .padding(.horizontal)
                            
                            // Brews for this roaster
                            VStack(spacing: 12) {
                                ForEach(group.brews, id: \.id) { brew in
                                    RecentBrewRow(brew: brew)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 16)
            }
            .frame(maxHeight: 600) // Increased height for grouped view
            
            // See All in Library link
            if brews.count > 20 {
                Button(action: {
                    navigationCoordinator.navigateToLibraryBrews()
                }) {
                    HStack {
                        Text("See All in Library")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(BrewerColors.caramel)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(BrewerColors.caramel)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // Helper to group brews by roaster
    private func groupBrewsByRoaster() -> [(roasterName: String, brews: [Brew])] {
        let recentBrews = Array(brews.prefix(20))
        
        // Group by roaster name
        let grouped = Dictionary(grouping: recentBrews) { brew in
            brew.roasterName ?? "Unknown Roaster"
        }
        
        // Convert to array and sort by most recent brew date
        return grouped.map { (roasterName: $0.key, brews: $0.value) }
            .sorted { group1, group2 in
                let date1 = group1.brews.first?.date ?? Date.distantPast
                let date2 = group2.brews.first?.date ?? Date.distantPast
                return date1 > date2
            }
    }
    
    
    // MARK: - Computed Properties
    private var averageRating: Double {
        let ratings = brews.map { Double($0.rating) }.filter { $0 > 0 }
        guard !ratings.isEmpty else { return 0.0 }
        return ratings.reduce(0, +) / Double(ratings.count)
    }
    
    private var brewsThisWeek: Int {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        return brews.filter { brew in
            guard let date = brew.date else { return false }
            return date >= oneWeekAgo
        }.count
    }
    
    private var weeklyAverageRating: Double {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        
        let weeklyBrews = brews.filter { brew in
            guard let date = brew.date else { return false }
            return date >= oneWeekAgo
        }
        
        let ratings = weeklyBrews.map { Double($0.rating) }.filter { $0 > 0 }
        guard !ratings.isEmpty else { return 0.0 }
        
        return ratings.reduce(0, +) / Double(ratings.count)
    }
}

// MARK: - Mini Chart Row Component
struct MiniChartRow: View {
    @ObservedObject var chart: Chart
    let brews: [Brew]
    let viewModel: HistoryViewModel
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    
    private var chartConfiguration: ChartConfiguration? {
        chart.toChartConfiguration()
    }
    
    var body: some View {
        Button(action: {
            navigationCoordinator.navigateToChartDetail(chart: chart)
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Title and Chevron
                HStack {
                    Text(chart.title ?? "Chart")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(BrewerColors.textPrimary)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(BrewerColors.textSecondary)
                }
                
                // Minimized Chart
                if let configuration = chartConfiguration {
                    Group {
                        switch configuration.chartType {
                        case .barChart:
                            BarChartView(
                                brews: brews,
                                xAxis: configuration.xAxis.createAxis()!,
                                yAxis: configuration.yAxis.createAxis()!,
                                color: configuration.color?.toColor() ?? BrewerColors.chartPrimary,
                                isMinimized: true
                            )
                        case .timeSeries:
                            TimeSeriesChart(
                                brews: brews,
                                xAxis: configuration.xAxis.createAxis()!,
                                yAxis: configuration.yAxis.createAxis()!,
                                color: configuration.color?.toColor() ?? BrewerColors.chartPrimary,
                                isMinimized: true
                            )
                        case .scatterPlot:
                            ScatterPlotChart(
                                brews: brews,
                                xAxis: configuration.xAxis.createAxis()!,
                                yAxis: configuration.yAxis.createAxis()!,
                                color: configuration.color?.toColor() ?? BrewerColors.chartPrimary
                                // Note: ScatterPlotChart minimized mode not yet implemented
                            )
                        }
                    }
                }
            }
            .padding(16)
            .background(BrewerColors.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
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

// MARK: - Minimalistic Stat Cell Component
struct StatCell: View {
    let value: String
    let description: String
    let isText: Bool
    
    init(value: String, description: String, isText: Bool = false) {
        self.value = value
        self.description = description
        self.isText = isText
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Large statistic value
            Text(value)
                .font(isText ? .title2 : .largeTitle)
                .fontWeight(.bold)
                .foregroundColor(BrewerColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            // Description text
            Text(description)
                .font(.caption)
                .foregroundColor(BrewerColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .contentShape(Rectangle())
    }
}

// MARK: - Recent Brew Row Component
struct RecentBrewRow: View {
    let brew: Brew
    
    private var timeAgo: String {
        guard let date = brew.date else { return "Unknown" }
        return date.timeAgoDescription()
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Visual accent - V60 image with background
            ZStack {
                Circle()
                    .fill(BrewerColors.caramel.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image("V60")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                    .foregroundColor(BrewerColors.caramel)
            }
            
            // Brew Info - cleaner layout
            VStack(alignment: .leading, spacing: 6) {
                // Primary info
                HStack(alignment: .center, spacing: 8) {
                    Text(brew.recipeName ?? "Untitled Brew")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                        .lineLimit(1)
                    
                    if brew.rating > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11))
                                .foregroundColor(BrewerColors.caramel)
                            Text("\(brew.rating)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(BrewerColors.caramel)
                        }
                    }
                }

                Text(timeAgo)
                    .font(.system(size: 13))
                    .foregroundColor(BrewerColors.textSecondary.opacity(0.8))
                
            }
            
            Spacer()
            
            // Subtle chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(BrewerColors.textSecondary.opacity(0.3))
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(BrewerColors.cardBackground.opacity(0.5))
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Compact Brew Card Component
struct CompactBrewCard: View {
    @ObservedObject var brew: Brew
    
    private var recipeName: String {
        if let recipe = brew.recipe {
            return recipe.name ?? "Unknown Recipe"
        } else {
            return brew.recipeName ?? "Deleted Recipe"
        }
    }
    
    private var roasterName: String {
        if let recipe = brew.recipe {
            return recipe.roaster?.name ?? "Unknown"
        } else {
            return brew.roasterName ?? "Unknown"
        }
    }
    
    private var ratingStars: String {
        let rating = Int(brew.rating)
        return String(repeating: "★", count: rating)
    }
    
    private var daysSince: String {
        guard let date = brew.date else { return "" }
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        return days == 0 ? "Today" : "\(days)d ago"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with date
            HStack {
                Text(daysSince)
                    .font(.caption)
                    .foregroundColor(BrewerColors.textSecondary)
                
                Spacer()
                
                if brew.rating > 0 {
                    Text(ratingStars)
                        .font(.caption)
                        .foregroundColor(BrewerColors.caramel)
                }
            }
            
            // Recipe info
            VStack(alignment: .leading, spacing: 4) {
                Text(recipeName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(BrewerColors.textPrimary)
                    .lineLimit(2)
                
                Text(roasterName)
                    .font(.caption)
                    .foregroundColor(BrewerColors.textSecondary)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .frame(width: 140, height: 90)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(BrewerColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(BrewerColors.divider, lineWidth: 0.5)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
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
