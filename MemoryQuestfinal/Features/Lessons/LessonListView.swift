import SwiftUI

struct LessonListView: View {
    @Environment(ProgressStore.self) private var store
    @Environment(AppState.self) private var app
    var body: some View {
        QuestPage {
            PageTitle(text:"Lessons")
            Text("Learn a strategy. Try it. Make it yours.").font(.subheadline).foregroundStyle(AppTheme.muted)
            ForEach(ContentRepository.lessons) { lesson in
                Button { app.path.append(.lesson(lesson.id)) } label: {
                    QuestCard {
                        HStack(spacing:14) {
                            LessonIcon(lesson:lesson)
                            VStack(alignment:.leading,spacing:7) {
                                Text("Lesson \(lesson.id+1) · 4–6 min").font(.caption).foregroundStyle(AppTheme.muted)
                                Text(lesson.short).font(.headline)
                                Text(lesson.desc).font(.subheadline).foregroundStyle(AppTheme.muted)
                                Text("\(store.progress.completedLessons.contains(lesson.id) ? "✓ Lesson complete" : (store.progress.lessonSteps[lesson.id,default:0] > 0 ? "In progress" : "Not started")) · \(store.progress.buildings.filter { $0/2 == lesson.id }.count)/2 buildings").font(.caption).foregroundStyle(store.progress.completedLessons.contains(lesson.id) ? AppTheme.coral : AppTheme.muted)
                            }
                            Spacer(minLength:0); Image(systemName:"chevron.right")
                        }
                    }
                }.buttonStyle(.plain)
            }
        }
    }
}
struct LessonIcon: View {
    let lesson: Lesson
    var body: some View { Image(systemName:lesson.symbol).font(.system(size:28)).foregroundStyle(Color(hex:lesson.deep)).frame(width:64,height:70).background(Color(hex:lesson.soft),in:RoundedRectangle(cornerRadius:12)).accessibilityHidden(true) }
}
struct LessonIntroView: View {
    let id: Int
    @Environment(ProgressStore.self) private var store
    @Environment(AppState.self) private var app
    var body: some View {
        let lesson = ContentRepository.lessons[id]
        QuestPage {
            HStack { Spacer(); LessonIcon(lesson:lesson); Spacer() }
            PageTitle(text:lesson.title)
            Text("4–6 minutes · Five short steps · Your own pace").font(.caption).foregroundStyle(AppTheme.muted)
            SubjectPicker()
            QuestCard { ForEach(Array(lesson.pages.enumerated()),id:\.offset) { i,page in HStack(alignment:.top) { Text(String(format:"%02d",i+1)).foregroundStyle(AppTheme.muted); Text(page.title) }; if i != 4 { Divider() } } }
            QuestButton(title:store.progress.completedLessons.contains(id) ? "Review lesson" : (store.progress.lessonSteps[id,default:0] > 0 ? "Continue lesson" : "Start lesson")) { app.path.append(.reader(id)) }
            Text("Build this district").font(.headline)
            ForEach(ContentRepository.challenges.filter { $0.l == id }) { c in Text("\(c.title) → \(c.building)").font(.subheadline) }
        }.navigationTitle("Lesson \(id+1)")
    }
}
