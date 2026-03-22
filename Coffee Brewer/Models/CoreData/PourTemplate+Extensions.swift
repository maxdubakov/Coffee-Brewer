import Foundation
import CoreData

extension PourTemplate {
    var stagesArray: [TemplateStage] {
        let set = stages as? Set<TemplateStage> ?? []
        return set.sorted {
            $0.orderIndex < $1.orderIndex
        }
    }
    
    /// Creates concrete stages for a brew based on this template and a given water amount
    func createStages(for brew: Brew, waterAmount: Int16, context: NSManagedObjectContext) {
        for templateStage in stagesArray {
            let stage = Stage(context: context)
            stage.id = UUID()
            stage.type = templateStage.type
            stage.waterAmount = Int16(Double(waterAmount) * templateStage.waterPercentage / 100.0)
            stage.orderIndex = templateStage.orderIndex
            stage.brew = brew
        }
    }
    
    /// Seeds built-in pour templates if they don't exist
    static func seedBuiltInTemplates(in context: NSManagedObjectContext) {
        let request: NSFetchRequest<PourTemplate> = PourTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "isBuiltIn == YES")
        
        let existingCount = (try? context.count(for: request)) ?? 0
        guard existingCount == 0 else { return }
        
        // V60: fast bloom (26.14%) → slow pour (39.22%) → slow pour (34.64%)
        let v60Template = PourTemplate(context: context)
        v60Template.id = UUID()
        v60Template.name = "V60"
        v60Template.brewMethod = "V60"
        v60Template.isBuiltIn = true
        
        let v60Stage1 = TemplateStage(context: context)
        v60Stage1.id = UUID()
        v60Stage1.type = "fast"
        v60Stage1.waterPercentage = 26.14
        v60Stage1.orderIndex = 0
        v60Stage1.template = v60Template
        
        let v60Stage2 = TemplateStage(context: context)
        v60Stage2.id = UUID()
        v60Stage2.type = "slow"
        v60Stage2.waterPercentage = 39.22
        v60Stage2.orderIndex = 1
        v60Stage2.template = v60Template
        
        let v60Stage3 = TemplateStage(context: context)
        v60Stage3.id = UUID()
        v60Stage3.type = "slow"
        v60Stage3.waterPercentage = 34.64
        v60Stage3.orderIndex = 2
        v60Stage3.template = v60Template
        
        // Orea V4: fast bloom (26.14%) → slow (22.88%) → fast (26.14%) → slow (24.84%)
        let oreaTemplate = PourTemplate(context: context)
        oreaTemplate.id = UUID()
        oreaTemplate.name = "Orea V4"
        oreaTemplate.brewMethod = "Orea V4"
        oreaTemplate.isBuiltIn = true
        
        let oreaStage1 = TemplateStage(context: context)
        oreaStage1.id = UUID()
        oreaStage1.type = "fast"
        oreaStage1.waterPercentage = 26.14
        oreaStage1.orderIndex = 0
        oreaStage1.template = oreaTemplate
        
        let oreaStage2 = TemplateStage(context: context)
        oreaStage2.id = UUID()
        oreaStage2.type = "slow"
        oreaStage2.waterPercentage = 22.88
        oreaStage2.orderIndex = 1
        oreaStage2.template = oreaTemplate
        
        let oreaStage3 = TemplateStage(context: context)
        oreaStage3.id = UUID()
        oreaStage3.type = "fast"
        oreaStage3.waterPercentage = 26.14
        oreaStage3.orderIndex = 2
        oreaStage3.template = oreaTemplate
        
        let oreaStage4 = TemplateStage(context: context)
        oreaStage4.id = UUID()
        oreaStage4.type = "slow"
        oreaStage4.waterPercentage = 24.84
        oreaStage4.orderIndex = 3
        oreaStage4.template = oreaTemplate
        
        do {
            try context.save()
        } catch {
            print("Failed to seed pour templates: \(error)")
        }
    }
}
