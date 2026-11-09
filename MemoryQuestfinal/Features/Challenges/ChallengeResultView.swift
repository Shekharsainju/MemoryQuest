import SwiftUI

struct ChallengeResultView: View {
    let attemptID: UUID
    @Environment(ProgressStore.self) private var store
    @Environment(AppState.self) private var app
    @State private var review = false
    var body: some View {
        if let attempt=store.progress.attempts.first(where:{ $0.id == attemptID }) {
            let isNew=store.progress.attempts.first(where:{ $0.challengeID == attempt.challengeID })?.id == attemptID
            QuestPage {
                Image(systemName:"trophy.fill").font(.system(size:64)).foregroundStyle(.yellow).frame(maxWidth:.infinity).padding(.top,20)
                PageTitle(text:"Challenge Complete!")
                Text(ContentRepository.challenges[attempt.challengeID].title).foregroundStyle(AppTheme.muted)
                Text("\(attempt.subject.title) · \(attempt.difficulty.rawValue)").font(.caption)
                QuestCard {
                    MetricRow(title:"Time",value:"\(attempt.duration/60)m \(attempt.duration%60)s")
                    MetricRow(title:attempt.selfRated ? "Self-reported recall" : attempt.challengeID == 8 ? "Checklist coverage" : "Accuracy",value:"\(attempt.score)%")
                    MetricRow(title:attempt.selfRated ? "Cards recalled" : "Correct checks",value:"\(attempt.results.filter(\.correct).count)/\(attempt.results.count)")
                    MetricRow(title:"Building",value:isNew ? "Unlocked" : "Already constructed")
                }
                Text(attempt.score == 100 ? "You recalled every checked idea in this attempt. Try again after a delay." : "You have useful clues for what to practise next. Your \(ContentRepository.challenges[attempt.challengeID].building) is earned through completion.").font(.subheadline).foregroundStyle(AppTheme.muted)
                if attempt.results.contains(where:\.delayed) { Text("\(attempt.results.filter { $0.delayed && $0.correct }.count)/\(attempt.results.filter(\.delayed).count) concepts retrieved after at least a day.").font(.subheadline) }
                QuestButton(title:review ? "Hide answer review" : "Review answers",secondary:true) { review.toggle() }
                if review { AttemptAnswersView(results:attempt.results) }
                QuestButton(title:"Continue") { app.path.append(.reward(attemptID,isNew)) }
            }.navigationBarBackButtonHidden()
        }
    }
}
struct MetricRow: View {
    let title, value: String
    var body: some View { HStack(alignment:.top) { Text(title).foregroundStyle(AppTheme.muted); Spacer(); Text(value).fontWeight(.semibold).multilineTextAlignment(.trailing) }; Divider() }
}
struct AttemptAnswersView: View {
    let results: [QuestionResult]
    var body: some View {
        ForEach(results) { result in
            QuestCard {
                Label(result.term,systemImage:result.correct ? "checkmark.circle" : "arrow.clockwise").font(.headline).foregroundStyle(result.correct ? Color.green : Color.orange)
                Text("Your response: \(result.answer)").font(.subheadline).foregroundStyle(AppTheme.muted)
                Text("Correct idea: \(result.expected)").font(.subheadline)
                if !result.explanation.isEmpty { Text(result.explanation).font(.subheadline).foregroundStyle(AppTheme.muted) }
                if result.sample { Text("Sample history prompt").font(.caption) }
            }
        }
    }
}
