import SwiftUI

struct StoryActivityView: View {
    @Bindable var model: ChallengeSessionViewModel
    var body: some View {
        VStack(alignment:.leading,spacing:18) {
            PageTitle(text:"Make it memorable")
            Text(model.content.storyTerms.joined(separator:" · ")).font(.headline)
            QuestCard { Text("A guided example").font(.caption).foregroundStyle(AppTheme.muted); Text(model.content.story) }
            Text("Write your own story using all four concepts")
            AnswerField(text:$model.story,prompt:"Picture a scene and connect the four concepts…",multiline:true)
            Text("The keyword check only confirms that you used the target words. It does not assess conceptual understanding.").font(.caption).foregroundStyle(AppTheme.muted)
            QuestButton(title:"Hide my story & recall") { model.hideStory() }
        }
    }
}
struct LinkingActivityView: View {
    @Bindable var model: ChallengeSessionViewModel
    var body: some View {
        VStack(alignment:.leading,spacing:18) {
            PageTitle(text:"Make the connection")
            Text("Select the familiar analogy for each concept. Explain the link to yourself.").font(.subheadline)
            ForEach(0..<4) { i in
                QuestCard {
                    Text(model.content.links[i].term).font(.headline)
                    Picker("Choose an analogy",selection:Binding(get:{ model.groups[i,default: -1] },set:{ model.groups[i]=$0 })) {
                        Text("Choose an analogy").tag(-1)
                        ForEach([2,0,3,1],id:\.self) { k in Text(model.content.links[k].cue).tag(k) }
                    }.disabled(model.feedback != nil)
                }
            }
            if model.feedback == nil { QuestButton(title:"Check the links") { model.checkLinks() } }
        }
    }
}
