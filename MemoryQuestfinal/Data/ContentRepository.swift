import Foundation

enum ContentRepository {
    static let lessons: [Lesson] = load("lessons")
    static let challenges: [Challenge] = load("challenges")
    static let computerScience: SubjectContent = load("computerScience")
    static let biology: SubjectContent = load("biology")
    static func content(_ subject: Subject) -> SubjectContent { subject == .biology ? biology : computerScience }
    private static func load<T: Decodable>(_ name: String) -> T {
        // Bundled educational data is validated during development; a missing resource is a packaging error.
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url), let value = try? JSONDecoder().decode(T.self, from: data) else {
            preconditionFailure("Missing or invalid bundled content: \(name)")
        }
        return value
    }
    static func page(lesson: Int, step: Int, subject: Subject) -> LessonPage {
        var page = lessons[lesson].pages[step]
        guard subject == .biology else { return page }
        page.blocks = nil
        // Biology examples use the same teaching sequence, with subject-specific mechanisms.
        let replacements = ["programming notes":"biology notes", "CS term":"Biology term", "tracing code":"tracing a biological process", "why an algorithm works":"how a cellular process works", "lecture heading":"lecture heading", "computer science":"biology"]
        for (a,b) in replacements { page.body = page.body.replacingOccurrences(of: a, with: b) }
        let bodies: [[Int: String]] = [
            [0:"You reread your biology notes and every word looks familiar. In a closed-book quiz, you cannot define a ribosome. Recognising a definition on a page is different from producing it from memory.\n\nRereading can help you understand material initially, but it does not show whether you can retrieve it independently. A small retrieval attempt makes the gaps visible.\n\nThink of a Biology term you saw this week. Could you explain it with your notes closed?",2:"Study this definition: A ribosome reads messenger RNA and joins amino acids into a polypeptide.\n\nmRNA arrives → Codons are read → Amino acids are joined.\n\nNow hide the definition. Which structure builds the polypeptide, and what instructions does it read?",3:"A structure reads messenger RNA and joins amino acids into a polypeptide. Type the name of this structure.\n\nTry to retrieve the term before using the hint. Checking a mistake is part of learning.",4:"Turn a lecture heading into a question: ‘What does a ribosome do?’ Close your notes, explain it, then compare.\n\n• Keep one idea per flashcard.\n• Say or type an answer before revealing it.\n• Record what was missing, then retrieve again later.\n• Mix easy and difficult questions.\n\nStudy → Hide → Retrieve → Check → Review Later.\n\nYour two challenges are Word Flash and Flip & Recall. Each completed challenge constructs one purple building."],
            [0:"Nucleus, Protein, Diffusion, Ribosome, Lipid, Osmosis, Mitochondrion, Active transport, Carbohydrate. Nine separate terms can feel unrelated.\n\nThey share meaningful properties. Which describe cell structures, molecules, or movement across membranes?",2:"Cell Structures\nNucleus · Ribosome · Mitochondrion\n\nBiomolecules\nProtein · Lipid · Carbohydrate\n\nTransport Processes\nDiffusion · Osmosis · Active transport\n\nA category cues a group; the individual mechanism still distinguishes each member.",3:"Which group consists entirely of cell structures? Select a group, then check your reasoning.",4:"Group concepts into cell structures, biomolecules, and transport processes. Close the page and reconstruct each group.\n\n• Use a label that explains the relationship.\n• Keep groups small enough to understand.\n• Split groups with unrelated roles.\n• Check the individual details.\n\nPractise with Sort & Remember and Code Breaker to build your blue district."],
            [0:"‘Nucleus’ and ‘Ribosome’ may seem like arbitrary labels. You already know archives and assembly workshops. A familiar experience can cue a new biological idea. Explain the specific connection to remember why it fits.",2:"Nucleus → an archive of instructions\n\nThe nucleus stores most DNA in a eukaryotic cell, like an archive stores instructions. A ribosome is like a workshop that reads mRNA and joins amino acids.\n\nWhere the analogy stops: a nucleus does not think or direct tasks consciously; ribosomes work through molecular interactions, not workers reading a paper recipe.",3:"Which analogy accurately captures a ribosome’s role? Think about the feature being shared.",4:"Choose a familiar example with a precise shared feature. Explain why it fits, state its limits, then retrieve the concept.\n\n" + biology.story + "\n\nTry Story Builder and Link the Concepts to add orange creative buildings."],
            [0:"You could define a ribosome yesterday, but today the definition is hazy. A successful answer immediately after study is different from recall after a delay. Return to questions across time; difficult retrieval shows what needs attention.",2:"Day 1 → Day 2 → Day 4 → Day 7\n\nRetrieve on each highlighted day. If you miss ‘Osmosis’ on Day 2, check water movement and review sooner. If you recall ‘Ribosome’ reliably, leave a longer gap.\n\nThese are illustrative intervals, not universal rules. Adjust them to difficulty, your timetable, and when you need the knowledge.",3:"In the example Day 1 → Day 2 → Day 4 → Day 7, you successfully retrieved ‘Ribosome’ on Day 2. Which day is next in this sample schedule?"],
            [0:"You recognise ‘Enzyme’ on a slide, but explaining it reveals a gap: what does a catalyst do? Explaining makes missing details visible. Applying the idea to a new situation checks whether you can use it beyond the original example.",1:"Close your notes and explain the idea simply. Include defining details. Notice where you hesitate. Check a reliable source, correct gaps, and apply the idea to an unfamiliar situation.\n\n‘An enzyme helps’ misses that it speeds a reaction without being consumed.",2:"Explain: Diffusion is net movement down a concentration gradient. Active transport moves substances against a gradient using energy.\n\nApply: A cell needs to accumulate ions against their gradient. Choose active transport because energy is required.\n\nWater moving across a selectively permeable membrane down its water-potential gradient is osmosis.",3:"Which explanation of an enzyme is useful and technically accurate?"]
        ]
        if let body = bodies[lesson][step] { page.body = body }
        if lesson == 2 && step == 2 { page.title = "A nucleus is like an archive" }
        return page
    }
}
