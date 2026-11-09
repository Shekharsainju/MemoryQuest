import SwiftUI

struct GroupingActivityView: View {
    @Bindable var model: ChallengeSessionViewModel
    var body: some View {
        VStack(alignment:.leading,spacing:18) {
            PageTitle(text:"Give every term a home")
            Text("Group by meaning. You will retrieve these groups after checking.").font(.subheadline)
            QuestCard {
                ForEach(0..<9) { i in
                    VStack(alignment:.leading) {
                        Text(model.content.groups[i/3][i%3]).font(.headline)
                        Picker("Category",selection:Binding(get:{ model.groups[i,default: -1] },set:{ model.groups[i]=$0 })) {
                            Text("Choose category").tag(-1)
                            ForEach(0..<3) { category in Text(model.content.categories[category]).tag(category) }
                        }.disabled(model.feedback != nil)
                    }
                    Divider()
                }
            }
            if model.feedback == nil { QuestButton(title:"Check my groups") { model.checkGroups() } }
        }
    }
}
struct SequenceActivityView: View {
    @Bindable var model: ChallengeSessionViewModel
    var body: some View {
        VStack(alignment:.leading,spacing:18) {
            PageTitle(text:"Rebuild the process")
            Text("Select the operations in order. Think ‘\(model.content.chunks.joined(separator:" → "))’.").font(.subheadline)
            QuestCard {
                if model.order.isEmpty { Text("Your sequence will appear here.").foregroundStyle(AppTheme.muted) }
                ForEach(Array(model.order.enumerated()),id:\.element) { i,selection in Text("\(i+1). \(model.content.sequence[selection])") }
            }
            ForEach([3,0,5,2,1,4],id:\.self) { i in
                QuestButton(title:model.content.sequence[i],secondary:true,disabled:model.order.contains(i) || model.feedback != nil) { model.order.append(i) }
            }
            if model.feedback == nil {
                QuestButton(title:"Undo last step",secondary:true,disabled:model.order.isEmpty) { _ = model.order.popLast() }
                QuestButton(title:"Check sequence",disabled:model.order.count != 6) { model.checkSequence() }
            }
        }
    }
}
