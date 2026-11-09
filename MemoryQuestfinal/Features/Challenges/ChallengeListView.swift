import SwiftUI

struct ChallengeListView: View {
    @Environment(ProgressStore.self) private var store
    var body: some View {
        QuestPage {
            PageTitle(text:"Challenges")
            Text("A little practice brings your city to life.").font(.subheadline).foregroundStyle(AppTheme.muted)
            ForEach(ContentRepository.lessons) { lesson in
                HStack { Text("Lesson \(lesson.id+1) · \(lesson.short)").font(.title3.bold()); Spacer(); Text("\(store.progress.buildings.filter { $0/2 == lesson.id }.count)/2").font(.caption).padding(8).background(AppTheme.line,in:RoundedRectangle(cornerRadius:7)) }.padding(.top,12)
                ForEach(ContentRepository.challenges.filter { $0.l == lesson.id }) { challenge in ChallengeRow(challenge:challenge) }
            }
        }
    }
}
struct ChallengeRow: View {
    let challenge: Challenge
    @Environment(ProgressStore.self) private var store
    @Environment(AppState.self) private var app
    var body: some View {
        let locked = !store.progress.completedLessons.contains(challenge.l)
        let latest = store.attempts(challenge.id,subject:store.progress.subject).last
        Button { app.path.append(.challenge(challenge.id)) } label: {
            QuestCard {
                HStack(spacing:13) {
                    BuildingArt(id:challenge.id).frame(width:65,height:65).background(Color(hex:ContentRepository.lessons[challenge.l].soft),in:RoundedRectangle(cornerRadius:12))
                    VStack(alignment:.leading,spacing:6) {
                        Text(challenge.title).font(.headline)
                        Text(challenge.desc.replacingOccurrences(of:"CS",with:store.progress.subject == .biology ? "Biology" : "CS")).font(.subheadline).foregroundStyle(AppTheme.muted)
                        Text("\(locked ? "Complete lesson to start" : latest.map { "Replay · Last \($0.score)%" } ?? "Start · \(challenge.mins)") · \(challenge.building)").font(.caption).foregroundStyle(AppTheme.muted)
                    }
                    Spacer(minLength:0); Image(systemName:locked ? "lock" : "chevron.right")
                }
            }
        }.buttonStyle(.plain)
    }
}
struct ChallengeIntroView: View {
    let id: Int
    @Environment(ProgressStore.self) private var store
    @Environment(AppState.self) private var app
    @State private var difficulty = Difficulty.medium
    var body: some View {
        let c = ContentRepository.challenges[id]
        let attempts = store.attempts(id,subject:store.progress.subject)
        QuestPage {
            PageTitle(text:c.title)
            QuestCard {
                Text("Complete this challenge to build").font(.subheadline).foregroundStyle(AppTheme.muted).frame(maxWidth:.infinity)
                BuildingArt(id:id).frame(height:180)
                Text(c.building).font(.title.bold()).frame(maxWidth:.infinity)
                Text("\(c.mins) · \(ContentRepository.lessons[c.l].short)").font(.caption.weight(.semibold)).foregroundStyle(AppTheme.muted).frame(maxWidth:.infinity)
            }
            Text(c.instructions).font(.subheadline)
            SubjectPicker()
            if store.progress.completedLessons.contains(c.l) {
                Text("Choose difficulty").font(.title3.bold())
                Picker("Difficulty",selection:$difficulty) { ForEach(Difficulty.allCases) { Text($0.rawValue).tag($0) } }.pickerStyle(.segmented)
                Text(difficulty == .easy ? "Hints available. Recall decks use 8 terms." : difficulty == .hard ? "Hints hidden. Recall decks use 10 terms." : "Standard practice. Recall decks use 8 terms.").font(.caption).foregroundStyle(AppTheme.muted)
                QuestButton(title:attempts.isEmpty ? "Start" : "Replay challenge") { app.path.append(.session(id,store.progress.subject,difficulty)) }
            } else {
                Text("Start with Lesson \(c.l+1) to learn the strategy.").padding().background(Color(hex:ContentRepository.lessons[c.l].soft),in:RoundedRectangle(cornerRadius:12))
                QuestButton(title:"Learn \(ContentRepository.lessons[c.l].short)") { app.path.append(.lesson(c.l)) }
            }
            if let last = attempts.last {
                QuestButton(title:"Previous results",secondary:true) { app.path.append(.history(id)) }
                Text("Last: \(last.score)% · Best: \(attempts.map(\.score).max() ?? 0)%").font(.caption).foregroundStyle(AppTheme.muted).frame(maxWidth:.infinity)
            }
        }.navigationTitle("Challenge")
    }
}
