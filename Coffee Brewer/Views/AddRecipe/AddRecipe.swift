import SwiftUI
import CoreData

struct AddRecipe: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    // Form fields
    @State private var roasterName: String = ""
    @State private var recipeName: String = ""
    @State private var coffeeGrams: String = "18"
    @State private var ratio: String = "15"
    @State private var waterTemperature: String = "93"
    @State private var grinderName: String = ""
    @State private var grindSize: String = ""
    
    // Reference to an existing roaster if editing an existing recipe
    var existingRoaster: Roaster?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading) {
                Text("Add Recipe")
                    .font(.custom("Domine", size: 28, relativeTo: .title).bold())
                    .foregroundColor(BrewerColors.textPrimary)
                    .padding(EdgeInsets(top: 28, leading: 18, bottom: 4, trailing: 18))
            }
            
            // Roaster Selection
            VStack(alignment: .leading) {
                HStack(spacing: 8) {
                    TextField("Roaster Name", text: $roasterName)
                        .font(.custom("Outfit", size: 17, relativeTo: .body).weight(.light))
                        .foregroundColor(BrewerColors.textPrimary)
                        .padding(EdgeInsets(top: 10.5, leading: 13, bottom: 10.5, trailing: 13))
                        .background(BrewerColors.inputBackground)
                        .cornerRadius(178)
                }
                .padding(18)
            }
            .background(BrewerColors.background)
            
            // Form Fields
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // General Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("General")
                            .font(.custom("Outfit", size: 17, relativeTo: .body))
                            .foregroundColor(BrewerColors.textPrimary)
                            .padding(EdgeInsets(top: 7, leading: 0, bottom: 7, trailing: 0))
                        
                        // Recipe Name Field
                        FormTextField(title: "Recipe Name", text: $recipeName)
                        
                        // Coffee Grams Field
                        ExpandableNumberField(
                            title: "Coffee (grams)",
                            value: $coffeeGrams,
                            range: Array(8...40),
                            formatter: { "\($0)g" }
                        )
                        
                        // Ratio Field
                        ExpandableNumberField(
                            title: "Ratio",
                            value: $ratio,
                            range: Array(10...20),
                            formatter: { "1:\($0)" }
                        )
                        
                        // Water Temperature Field
                        FormTextField(title: "Water Temperature", text: $waterTemperature, keyboardType: .numberPad)
                    }
                    
                    // Grinder Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Grinder")
                            .font(.custom("Outfit", size: 17, relativeTo: .body))
                            .foregroundColor(BrewerColors.textPrimary)
                            .padding(EdgeInsets(top: 7, leading: 0, bottom: 7, trailing: 0))
                        
                        // Grinder Name Field
                        FormTextField(title: "Grinder Name", text: $grinderName)
                        
                        // Grind Size Field
                        FormTextField(title: "Grind Size", text: $grindSize)
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 18, bottom: 28, trailing: 18))
            }
            .background(BrewerColors.background)
            
            Spacer()
            
            // Save Button
            HStack {
                Button(action: saveRecipe) {
                    Text("Save")
                        .font(.custom("Outfit", size: 17, relativeTo: .body).weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(EdgeInsets(top: 14.5, leading: 16, bottom: 14.5, trailing: 16))
                        .background(BrewerColors.coffee)
                        .cornerRadius(48)
                }
            }
            .padding(18)
            .background(BrewerColors.background)
        }
        .background(BrewerColors.background)
        .onAppear {
            // Pre-fill roaster name if editing
            if let existingRoaster = existingRoaster {
                roasterName = existingRoaster.name ?? ""
            }
        }
    }
    
    private func saveRecipe() {
        withAnimation {
            // Find or create the roaster
            let roaster: Roaster
            
            if let existingRoaster = existingRoaster {
                roaster = existingRoaster
            } else {
                // Look for an existing roaster with the same name
                let fetchRequest: NSFetchRequest<Roaster> = Roaster.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "name == %@", roasterName)
                
                do {
                    let results = try viewContext.fetch(fetchRequest)
                    if let existingRoaster = results.first {
                        roaster = existingRoaster
                    } else {
                        // Create a new roaster if none exists
                        let newRoaster = Roaster(context: viewContext)
                        newRoaster.name = roasterName
                        roaster = newRoaster
                    }
                } catch {
                    // If fetch fails, create a new roaster
                    let newRoaster = Roaster(context: viewContext)
                    newRoaster.name = roasterName
                    roaster = newRoaster
                }
            }
            
            // Create the new recipe
            let newRecipe = Recipe(context: viewContext)
            newRecipe.name = recipeName
            newRecipe.grams = Int16(coffeeGrams) ?? 18
            newRecipe.lastBrewedAt = Date()
            newRecipe.roaster = roaster
            
            // Save the changes
            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                print("Error saving recipe: \(error)")
            }
        }
    }
}

#Preview {
    AddRecipe()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
