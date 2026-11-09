import SwiftUI

private struct ArtShape: Decodable {
    let kind, fill, stroke, path: String
    let width, opacity: Double
    let values, matrix: [Double]
    func drawing() -> Path {
        var p = Path()
        if kind == "polygon" {
            for i in stride(from: 0, to: values.count - 1, by: 2) {
                let point = CGPoint(x: values[i], y: values[i+1])
                if i == 0 { p.move(to: point) } else { p.addLine(to: point) }
            }
            p.closeSubpath()
        } else if kind == "ellipse" || kind == "circle" {
            p.addEllipse(in: CGRect(x: values[0]-values[2], y: values[1]-values[3], width: values[2]*2, height: values[3]*2))
        } else {
            let pattern = "[MLHVZmlhvz]|-?[0-9]*\\.?[0-9]+"
            let regex = try? NSRegularExpression(pattern: pattern)
            let ns = path as NSString
            let tokens = regex?.matches(in: path, range: NSRange(location: 0, length: ns.length)).map { ns.substring(with: $0.range) } ?? []
            var i = 0, command = "M"; var point = CGPoint.zero
            while i < tokens.count {
                if Double(tokens[i]) == nil { command = tokens[i]; i += 1; if command.uppercased() == "Z" { p.closeSubpath(); continue } }
                guard i < tokens.count, let x = Double(tokens[i]) else { break }
                let relative = command == command.lowercased()
                switch command.uppercased() {
                case "M", "L":
                    guard i+1 < tokens.count, let y = Double(tokens[i+1]) else { break }
                    point = CGPoint(x: x + (relative ? point.x : 0), y: y + (relative ? point.y : 0))
                    if command.uppercased() == "M" { p.move(to: point); command = relative ? "l" : "L" } else { p.addLine(to: point) }; i += 2
                case "H": point.x = x + (relative ? point.x : 0); p.addLine(to: point); i += 1
                case "V": point.y = x + (relative ? point.y : 0); p.addLine(to: point); i += 1
                default: i += 1
                }
            }
        }
        return p.applying(CGAffineTransform(a: matrix[0], b: matrix[1], c: matrix[2], d: matrix[3], tx: matrix[4], ty: matrix[5]))
    }
}
private enum BuildingGeometry {
    static let shapes: [[ArtShape]] = (0...10).map { id in
        guard let url = Bundle.main.url(forResource: id == 10 ? "empty" : "building\(id)", withExtension: "json"), let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([ArtShape].self, from: data)) ?? []
    }
}
struct BuildingArt: View {
    let id: Int
    var empty = false
    var body: some View {
        Canvas { context, size in
            let scale = min(size.width / 160, size.height / 172)
            context.translateBy(x: (size.width - 160*scale)/2, y: (size.height-172*scale)/2)
            context.scaleBy(x: scale, y: scale)
            for shape in BuildingGeometry.shapes[empty ? 10 : id] {
                var layer = context; layer.opacity = shape.opacity
                let path = shape.drawing()
                if shape.fill != "none" { layer.fill(path, with: .color(Color(hex: shape.fill))) }
                if shape.stroke != "none" { layer.stroke(path, with: .color(Color(hex: shape.stroke)), lineWidth: shape.width) }
            }
        }.accessibilityHidden(true)
    }
}
struct CityIllustration: View {
    let buildings: Set<Int>
    var select: (Int) -> Void = { _ in }
    private let slots: [(Double, Double)] = [(0,0),(1.3,0),(3.1,0),(4.4,0),(0,1.4),(4.4,1.4),(0,3.4),(1.3,3.4),(3.1,3.4),(4.4,3.4)]
    var body: some View {
        GeometryReader { proxy in
            let s = proxy.size.width / 600
            ZStack(alignment: .topLeading) {
                Canvas { context, _ in
                    context.scaleBy(x: s, y: s)
                    func point(_ u: Double, _ v: Double) -> CGPoint { CGPoint(x: 300+(u-v)*44, y: 89+(u+v)*25) }
                    func polygon(_ u: Double, _ v: Double, _ a: Double, _ b: Double, _ color: String) {
                        var path = Path(); path.addLines([point(u,v),point(a,v),point(a,b),point(u,b)]); path.closeSubpath(); context.fill(path, with: .color(Color(hex: color)))
                    }
                    polygon(-0.8,-0.8,5.4,4.5,"f0f4eb")
                    polygon(2.05,-0.8,2.85,4.5,"b6b7b1"); polygon(-0.8,2.1,5.4,2.9,"b6b7b1")
                    polygon(2.13,-0.8,2.77,4.5,"4b4c4c"); polygon(-0.8,2.18,5.4,2.82,"4b4c4c")
                    for i in stride(from: -0.65, to: 5.1, by: 0.65) {
                        var path = Path()
                        if i < 4.2 { path.move(to: point(2.45,min(i,4.2))); path.addLine(to: point(2.45,min(i+0.24,4.45))) }
                        path.move(to: point(i,2.5)); path.addLine(to: point(i+0.24,2.5)); context.stroke(path, with: .color(Color(hex:"a6a7a2")), lineWidth: 2)
                    }
                    let trees: [(Double,Double)] = [(-0.4,0.1),(-0.45,1.35),(0.15,4.08),(1.9,4.13),(4.45,-0.45),(5.05,0.65),(5,3.8),(3.15,-0.4),(-0.35,3.55)]
                    for (i,t) in trees.enumerated() {
                        let p=point(t.0,t.1); let h=Double(29+i%3*8)
                        var path=Path(); path.addLines([CGPoint(x:p.x-11,y:p.y),CGPoint(x:p.x,y:p.y-h),CGPoint(x:p.x+11,y:p.y)]);path.closeSubpath();context.fill(path,with:.color(Color(hex:"bfe7a5")))
                        var second=Path();second.addLines([CGPoint(x:p.x+7,y:p.y+3),CGPoint(x:p.x+15,y:p.y-h+11),CGPoint(x:p.x+23,y:p.y+3)]);second.closeSubpath();context.fill(second,with:.color(Color(hex:"a9df95")))
                    }
                }
                ForEach(ContentRepository.challenges) { c in
                    let slot = slots[c.id]
                    let x = 300+(slot.0-slot.1)*44, y = 89+(slot.0+slot.1)*25
                    Button { select(c.id) } label: { BuildingArt(id:c.id,empty:!buildings.contains(c.id)).frame(width:90*s,height:100.8*s) }
                        .buttonStyle(.plain).position(x:x*s,y:(y-30.24)*s).zIndex(y)
                        .accessibilityLabel("\(buildings.contains(c.id) ? "Open" : "Preview locked") \(c.building)")
                }
            }
        }.aspectRatio(600/420,contentMode:.fit)
    }
}
