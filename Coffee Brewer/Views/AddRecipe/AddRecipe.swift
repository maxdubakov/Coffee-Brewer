import SwiftUI
import CoreData

struct AddRecipe: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var selectedTab: MainView.Tab
    
    @ObservedObject var viewModel: AddRecipeViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    RecipeHeaderView(
                        title: viewModel.headerTitle,
                        subtitle: viewModel.headerSubtitle
                    )
                    
                    RecipeFormView(
                        formData: $viewModel.formData,
                        brewMath: $viewModel.brewMath,
                        focusedField: $viewModel.focusedField
                    )
                    
                    RecipeContinueButton(
                        title: viewModel.continueButtonTitle,
                        action: viewModel.validateAndContinue
                    )
                }
                .padding(.top, 10)
            }
            .scrollDismissesKeyboard(.immediately)
            .background(BrewerColors.background)
            .alert(isPresented: $viewModel.showValidationAlert) {
                Alert(
                    title: Text("Incomplete Information"),
                    message: Text(viewModel.validationMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .overlay {  
                if viewModel.isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: BrewerColors.caramel))
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    let viewModel = AddRecipeViewModel(
        selectedRoaster: nil,
        context: context,
    )
    
    @State var navigationPath = NavigationPath()
    
    return NavigationStack {
        AddRecipe(
            selectedTab: .constant(.add),
            viewModel: viewModel,
            navigationPath: $navigationPath
        )
    }
    .environment(\.managedObjectContext, context)
    .background(BrewerColors.background)
}
