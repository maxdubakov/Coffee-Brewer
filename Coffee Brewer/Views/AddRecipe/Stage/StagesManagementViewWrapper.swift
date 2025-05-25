import SwiftUI
import CoreData

struct StagesManagementViewWrapper: View {
    @State private var formData: RecipeFormData
    let brewMath: BrewMathViewModel
    @Binding var selectedTab: MainView.Tab
    let context: NSManagedObjectContext
    let existingRecipeID: NSManagedObjectID?
    let onFormDataUpdate: (RecipeFormData) -> Void
    let onSaveComplete: (() -> Void)?
    
    init(initialFormData: RecipeFormData,
         brewMath: BrewMathViewModel,
         selectedTab: Binding<MainView.Tab>,
         context: NSManagedObjectContext,
         existingRecipeID: NSManagedObjectID?,
         onFormDataUpdate: @escaping (RecipeFormData) -> Void,
         onSaveComplete: (() -> Void)? = nil) {
        
        self._formData = State(initialValue: initialFormData)
        self.brewMath = brewMath
        self._selectedTab = selectedTab
        self.context = context
        self.existingRecipeID = existingRecipeID
        self.onFormDataUpdate = onFormDataUpdate
        self.onSaveComplete = onSaveComplete
    }
    
    var body: some View {
        StagesManagementView(
            formData: $formData,
            brewMath: brewMath,
            selectedTab: $selectedTab,
            context: context,
            existingRecipeID: existingRecipeID,
            onSaveComplete: onSaveComplete
        )
        .onChange(of: formData) { _, newValue in
            onFormDataUpdate(newValue)
        }
    }
}