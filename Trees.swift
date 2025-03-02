import SwiftUI

// A stylized "TreesView" that splits the trunk and canopy into separate shapes.
// The trunk's height is adjustable with a state variable (trunkHeight).
// The canopy remains the same size. Both sit above a hypothetical bottom bar.
struct TreesView: View {
    // The trunk’s adjustable height
    @State private var trunkHeight: CGFloat = 200
    
    // Suppose your bottom bar is ~80 points tall
    let bottomBarHeight: CGFloat = 80
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1) Background color
                Color(red: 0.85, green: 0.85, blue: 0.75)
                    .edgesIgnoringSafeArea(.all)
                
                // 2) Vertical layout: trunk + canopy
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Trunk: width ~20% of screen, height is trunkHeight (adjustable)
                    TrunkShape()
                        .fill(Color.brown)
                        .frame(width: geo.size.width * 0.2, height: trunkHeight)
                    
                    // Canopy: a circle shape, ~50% of screen width, 30% tall
                    CanopyShape()
                        .fill(Color.green)
                        .frame(width: geo.size.width * 0.5,
                               height: geo.size.width * 0.3)
                        .offset(y: -geo.size.width * 0.1)
                    // offset canopy slightly so it overlaps trunk top nicely
                    
                    // Space for the bottom bar
                    Spacer().frame(height: bottomBarHeight)
                }
            }
        }
        .navigationBarTitle("Trees", displayMode: .inline)
    }
}

// MARK: - TrunkShape
/// A stylized trunk: narrower at top, wider at bottom. The height is adjustable via the .frame.
struct TrunkShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        
        var path = Path()
        
        // We'll define a shape narrower at the top (30% -> 70%) and wider at the bottom (10% -> 90%).
        // Top left
        path.move(to: CGPoint(x: w * 0.30, y: 0))
        // Top right
        path.addLine(to: CGPoint(x: w * 0.70, y: 0))
        // Bottom right
        path.addLine(to: CGPoint(x: w * 0.90, y: h))
        // Bottom left
        path.addLine(to: CGPoint(x: w * 0.10, y: h))
        
        path.closeSubpath()
        return path
    }
}

// MARK: - CanopyShape
/// A simple elliptical/circular shape for the canopy.
struct CanopyShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path(ellipseIn: rect)
    }
}

// MARK: - Preview
struct TreesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TreesView()
        }
    }
}
