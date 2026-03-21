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
        
        // V60 Default: Bloom (fast 20%) → Slow pour (80%)
        let v60Template = PourTemplate(context: context)
        v60Template.id = UUID()
        v60Template.name = "V60 Default"
        v60Template.brewMethod = "V60"
        v60Template.isBuiltIn = true
        
        let v60Stage1 = TemplateStage(context: context)
        v60Stage1.id = UUID()
        v60Stage1.type = "fast"
        v60Stage1.waterPercentage = 20.0
        v60Stage1.orderIndex = 0
        v60Stage1.template = v60Template
        
        let v60Stage2 = TemplateStage(context: context)
        v60Stage2.id = UUID()
        v60Stage2.type = "slow"
        v60Stage2.waterPercentage = 80.0
        v60Stage2.orderIndex = 1
        v60Stage2.template = v60Template
        
        // Orea V4 Default: Fast bloom (20%) → Slow pour (40%) → Fast pour (40%)
        let oreaTemplate = PourTemplate(context: context)
        oreaTemplate.id = UUID()
        oreaTemplate.name = "Orea V4 Default"
        oreaTemplate.brewMethod = "Orea V4"
        oreaTemplate.isBuiltIn = true
        
        let oreaStage1 = TemplateStage(context: context)
        oreaStage1.id = UUID()
        oreaStage1.type = "fast"
        oreaStage1.waterPercentage = 20.0
        oreaStage1.orderIndex = 0
        oreaStage1.template = oreaTemplate
        
        let oreaStage2 = TemplateStage(context: context)
        oreaStage2.id = UUID()
        oreaStage2.type = "slow"
        oreaStage2.waterPercentage = 40.0
        oreaStage2.orderIndex = 1
        oreaStage2.template = oreaTemplate
        
        let oreaStage3 = TemplateStage(context: context)
        oreaStage3.id = UUID()
        oreaStage3.type = "fast"
        oreaStage3.waterPercentage = 40.0
        oreaStage3.orderIndex = 2
        oreaStage3.template = oreaTemplate
        
        do {
            try context.save()
        } catch {
            print("Failed to seed pour templates: \(error)")
        }
    }
}
