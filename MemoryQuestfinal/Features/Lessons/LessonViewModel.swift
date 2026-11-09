import Foundation
import Observation

@Observable final class LessonViewModel {
    var step: Int
    var answer = "" { didSet { passed = false; feedback = nil } }
    var choice = -1 { didSet { passed = false; feedback = nil } }
    var passed = false
    var feedback: String?
    var hint = false
    var revealed = false
    init(step: Int) { self.step = step }
    func move(_ step: Int) { self.step = step; revealed = false }
    func resetPractice() { answer = ""; choice = -1; hint = false; revealed = false }
    func check(id: Int, subject: Subject) {
        passed = id == 0 ? Answer.normalise(answer) == (subject == .biology ? "ribosome" : "stack") : choice == [0,0,0,1,1][id]
        feedback = passed ? (subject == .biology ? ["Exactly. A ribosome reads mRNA and joins amino acids.","Yes. Nucleus, Ribosome, and Mitochondrion are cell structures.","Yes. A ribosome assembles a polypeptide from amino acids.","Yes. Day 4 comes next in this illustrative schedule.","Yes. An enzyme speeds a reaction without being consumed."][id] : ["Exactly. A stack uses last-in, first-out order.","Yes. Stack, Queue, and Array all organise collections.","Exactly. The last plate added is the first removed, just like LIFO.","Yes. Day 4 comes next in this illustrative schedule.","Yes. This includes reuse and a specific task, without losing accuracy."][id]) : "Try again. Use the hint to focus on the defining detail."
    }
}
