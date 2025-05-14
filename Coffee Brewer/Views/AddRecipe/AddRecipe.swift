import SwiftUI
import CoreData

struct AddRecipe: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    // Form fields
    @StateObject private var viewModel: RecipeFormViewModel
    
    // Reference to an existing roaster if editing an existing recipe
    var existingRoaster: Roaster?
    
    init(existingRoaster: Roaster? = nil, context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: RecipeFormViewModel(context: context, existingRoaster: existingRoaster))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Add Recipe")
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 0) {
                        SecondaryHeader(title: "General")
                            .padding(.bottom, 10)
                        
                        FormTextField(title: "Recipe Name", text: $viewModel.form.recipeName)
                        
                        ExpandableNumberField(
                            title: "Coffee (grams)",
                            value: $viewModel.form.coffeeGrams,
                            range: Array(8...40),
                            formatter: { "\($0)g" }
                        )
                        
                        ExpandableNumberField(
                            title: "Ratio",
                            value: $viewModel.form.ratio,
                            range: Array(10...20),
                            formatter: { "1:\($0)" }
                        )
                        
                        ExpandableNumberField(
                            title: "Water Temperature",
                            value: $viewModel.form.waterTemperature,
                            range: Array(80...99),
                            formatter: { "\($0)°C" }
                        )
                    }
                    .padding(.bottom, 20)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        SecondaryHeader(title: "Grinder")
                            .padding(.bottom, 10)
                        
                        FormTextField(title: "Grinder Name", text: $viewModel.form.grinderName)
                        
                        ExpandableNumberField(
                            title: "Grind Size",
                            value: $viewModel.form.grindSize,
                            range: Array(0...100),
                            formatter: { "\($0)" }
                        )
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 18, bottom: 28, trailing: 18))
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                    viewModel.saveRecipe {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Save")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(EdgeInsets(top: 14.5, leading: 16, bottom: 14.5, trailing: 16))
                        .background(BrewerColors.coffee)
                        .cornerRadius(48)
                }
            }
            .padding(18)
        }
    }
}

#Preview {
    GlobalBackground {
        AddRecipe(context: PersistenceController.preview.container.viewContext)
    }
}
