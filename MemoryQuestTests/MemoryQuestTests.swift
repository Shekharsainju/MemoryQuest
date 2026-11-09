import Foundation
import Testing
@testable import MemoryQuestfinal

@MainActor struct MemoryQuestTests {
    func store() -> ProgressStore {
        ProgressStore(url: FileManager.default.temporaryDirectory.appending(path: "MemoryQuest-\(UUID().uuidString)/progress.json"))
    }

    @Test func normalisationAndAliases() {
        let content = ContentRepository.computerScience
        #expect(Answer.correct("  BOOL  ", concept: content.terms[7]))
        #expect(Answer.correct("DATA   BASE", concept: content.terms[8]))
        #expect(!Answer.correct("", concept: content.terms[0]))
        #expect(Answer.correct("mRNA", concept: ContentRepository.biology.terms[8]))
    }

    @Test func lessonCheckInvalidatesWhenAnswerChanges() {
        let model = LessonViewModel(step: 3)
        model.answer = "Stack"
        model.check(id: 0, subject: .computerScience)
        #expect(model.passed)
        model.answer = "Queue"
        #expect(!model.passed)
        model.choice = 1
        model.check(id: 3, subject: .computerScience)
        #expect(model.passed)
        model.choice = 0
        #expect(!model.passed)
    }

    @Test func representativeScoringAndCompletionReward() {
        let persistence = store()
        let session = ChallengeSessionViewModel(id: 0, subject: .computerScience, difficulty: .medium, history: [])
        session.beginRecall()
        while !session.finished {
            session.answer = session.index == 0 ? session.deck[session.index].concept.term : "wrong"
            session.check()
            session.check() // A repeated check must not add another result.
            session.advance()
        }
        let attempt = session.finish(store: persistence)
        #expect(attempt?.score == 13)
        #expect(attempt?.results.count == 8)
        #expect(persistence.progress.buildings == [0])
        _ = session.finish(store: persistence)
        #expect(persistence.progress.attempts.count == 1)
    }

    @Test func subjectHistoryAndBuildingsStaySeparate() {
        let persistence = store()
        let result = QuestionResult(conceptID: "stack", term: "Stack", answer: "Queue", expected: "Stack", explanation: "", correct: false)
        let first = ChallengeAttempt(id: UUID(), challengeID: 0, subject: .computerScience, difficulty: .easy, date: Date().addingTimeInterval(-172800), duration: 12, results: [result], selfRated: false)
        #expect(persistence.record(first))
        var biology = first
        biology.id = UUID()
        biology.subject = .biology
        #expect(!persistence.record(biology))
        #expect(persistence.progress.buildings.count == 1)
        #expect(persistence.attempts(0, subject: .biology).count == 1)
        let review = ChallengeSessionViewModel(id: 6, subject: .biology, difficulty: .medium, history: [first])
        #expect(review.deck.allSatisfy { $0.sample })
        #expect(review.deck.allSatisfy { $0.concept.term != "Stack" })
    }

    @Test func savesAndRestoresProgress() throws {
        let url = FileManager.default.temporaryDirectory.appending(path: "MemoryQuest-\(UUID().uuidString)/progress.json")
        let first = ProgressStore(url: url)
        first.progress.name = "Wilson"
        first.progress.welcomed = true
        first.progress.completedLessons = [0, 3]
        first.progress.lessonSteps[2] = 3
        first.progress.subject = .biology
        first.save()
        let restored = ProgressStore(url: url)
        #expect(restored.progress.name == "Wilson")
        #expect(restored.progress.completedLessons == [0, 3])
        #expect(restored.progress.lessonSteps[2] == 3)
        #expect(restored.progress.subject == .biology)
        try Data("invalid JSON".utf8).write(to: url)
        let recovered = ProgressStore(url: url)
        #expect(!recovered.progress.welcomed)
        #expect(recovered.storageMessage != nil)
    }

    @Test func sequenceScoringAndBiologyChecklist() {
        let sequence = ChallengeSessionViewModel(id: 3, subject: .biology, difficulty: .hard, history: [])
        sequence.beginRecall()
        sequence.order = [0, 1, 2, 3, 5, 4]
        sequence.checkSequence()
        #expect(sequence.results.count == 6)
        #expect(sequence.results.filter(\.correct).count == 4)
        let robot = ChallengeSessionViewModel(id: 8, subject: .biology, difficulty: .medium, history: [])
        robot.index = 1
        robot.answer = "A ribosome reads mRNA and joins amino acids to build a protein."
        robot.check()
        #expect(robot.results.count == 3)
        #expect(robot.results.allSatisfy(\.correct))
    }

    @Test func rescueRetriesAndDelayedRecall() {
        let rescue = ChallengeSessionViewModel(id: 7, subject: .biology, difficulty: .medium, history: [])
        let count = rescue.deck.count
        for _ in 0..<count {
            rescue.answer = "wrong"
            rescue.check()
            rescue.advance()
        }
        #expect(rescue.retried)
        #expect(!rescue.finished)
        while !rescue.finished {
            rescue.answer = rescue.deck[rescue.index].concept.term
            rescue.check()
            rescue.advance()
        }
        #expect(rescue.rescued.count == count)
        #expect(rescue.results.count == count * 2)
        #expect(!rescue.results.contains(where: \.delayed))
        let result = QuestionResult(conceptID: "stack", term: "Stack", answer: "", expected: "Stack", explanation: "", correct: false)
        let prior = ChallengeAttempt(id: UUID(), challengeID: 0, subject: .computerScience, difficulty: .medium, date: Date().addingTimeInterval(-172800), duration: 1, results: [result], selfRated: false)
        let review = ChallengeSessionViewModel(id: 6, subject: .computerScience, difficulty: .hard, history: [prior])
        if let index = review.deck.firstIndex(where: { $0.concept.term == "Stack" }) {
            review.index = index
            review.answer = "stack"
            review.check()
            #expect(review.results.last?.delayed == true)
            #expect(review.results.last?.sample == false)
        } else { Issue.record("An earlier missed Stack should be prioritised.") }
    }
}
