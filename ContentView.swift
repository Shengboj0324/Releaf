import SwiftUI
import UIKit

struct ColorPalette {
    static let background = Color(red: 0.6, green: 0.75, blue: 0.65)
    static let topCard    = Color(red: 0.45, green: 0.6, blue: 0.35)
    static let cardBG     = Color(red: 0.90, green: 0.90, blue: 0.80)
    static let textMain   = Color.white
    static let textSub    = Color.white.opacity(0.9)
}



// MARK: - 3. Net Bag

struct BagOutlineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: w * 0.2, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.8, y: 0),
            control: CGPoint(x: w * 0.5, y: -h * 0.2)
        )
        path.addLine(to: CGPoint(x: w, y: h * 0.8))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: h * 0.8),
            control: CGPoint(x: w * 0.5, y: h * 1.1)
        )
        path.closeSubpath()
        return path
    }
}

struct BagNetLinesShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        
        // 3 "vertical" lines
        for i in 1..<4 {
            let x = w * (0.2 + 0.6 * CGFloat(i)/4.0)
            path.move(to: CGPoint(x: x, y: 0))
            let bottomX = x + (w * 0.8 - x) * 0.5
            path.addLine(to: CGPoint(x: bottomX, y: h * 0.8))
        }
        
        // 3 "horizontal" arcs
        for j in 1..<4 {
            let y = h * 0.8 * CGFloat(j)/4.0
            path.move(to: CGPoint(x: w * 0.2, y: y))
            path.addQuadCurve(
                to: CGPoint(x: w * 0.8, y: y),
                control: CGPoint(x: w * 0.5, y: y + h * 0.1)
            )
        }
        
        return path
    }
}

struct BlobIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.width
        let h = rect.height
        
        // A rough blob shape with four quad curves
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        
        // Top-right curve
        path.addQuadCurve(
            to: CGPoint(x: w, y: h * 0.5),
            control: CGPoint(x: w * 0.9, y: h * 0.0)
        )
        
        // Bottom-right curve
        path.addQuadCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control: CGPoint(x: w, y: h * 0.9)
        )
        
        // Bottom-left curve
        path.addQuadCurve(
            to: CGPoint(x: 0, y: h * 0.5),
            control: CGPoint(x: 0, y: h * 1.1)
        )
        
        // Top-left curve
        path.addQuadCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control: CGPoint(x: w * 0.1, y: h * 0.0)
        )
        
        path.closeSubpath()
        return path
    }
}

struct LittleBlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        
        // Start near top-left
        path.move(to: CGPoint(x: w * 0.3, y: 0))
        
        // Top-right curve
        path.addQuadCurve(
            to: CGPoint(x: w * 0.9, y: h * 0.3),
            control: CGPoint(x: w * 0.7, y: 0)
        )
        
        // Right-down curve
        path.addQuadCurve(
            to: CGPoint(x: w * 0.8, y: h * 0.8),
            control: CGPoint(x: w, y: h * 0.55)
        )
        
        // Bottom-left curve
        path.addQuadCurve(
            to: CGPoint(x: w * 0.2, y: h),
            control: CGPoint(x: w * 0.6, y: h * 1.0)
        )
        
        // Up-left curve
        path.addQuadCurve(
            to: CGPoint(x: 0, y: h * 0.4),
            control: CGPoint(x: 0, y: h * 1.2)
        )
        
        // Close top
        path.addQuadCurve(
            to: CGPoint(x: w * 0.3, y: 0),
            control: CGPoint(x: 0, y: 0)
        )
        
        path.closeSubpath()
        return path
    }
}

/// A view that draws the blob in black, plus two white eyes.
struct LittleBlobView: View {
    var body: some View {
        ZStack {
            // Blob outline in black
            LittleBlobShape()
                .fill(Color.black)
            
            // Two small white eyes. Adjust offsets as needed.
            Circle()
                .fill(Color.white)
                .frame(width: 5, height: 5)
                .offset(x: -6, y: -5) // left eye
            Circle()
                .fill(Color.white)
                .frame(width: 5, height: 5)
                .offset(x: 6, y: -5)  // right eye
        }
        // The overall icon size. Tweak as you like.
        .frame(width: 30, height: 30)
    }
}
/// A view combining a filled bag outline + separate net lines overlaid.
struct NetBagView: View {
    var body: some View {
        ZStack {
            BagOutlineShape()
                .fill(Color(red: 0.9, green: 0.15, blue: 0.1)) // Deep green
            BagNetLinesShape()
                .stroke(Color(red: 0.2, green: 0.65, blue: 0.7), lineWidth: 2)
        }
        .frame(width: 62, height: 60)
    }
}

struct BlobIconView: View {
    var body: some View {
        ZStack {
            // 1. The blob outline in black
            BlobIconShape()
                .fill(Color.black)
            
            // 2. Two small white eyes
            //    Adjust offsets to position them wherever looks best.
            Circle()
                .fill(Color.white)
                .frame(width: 5, height: 5)
                .offset(x: -6, y: -4) // left eye
            
            Circle()
                .fill(Color.white)
                .frame(width: 5, height: 5)
                .offset(x: 6, y: -4)  // right eye
        }
        .frame(width: 40, height: 40) // overall icon size
    }
}
// MARK: - 4. CameraView

/// A simple camera picker using UIImagePickerController (works on real devices).
struct CameraView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        init(_ parent: CameraView) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}




struct TopCardView: View {
    @Binding var searchText: String
    @Binding var showCamera: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            // 1. Green Rounded Rectangle
            RoundedRectangle(cornerRadius: 20)
                .fill(ColorPalette.topCard)
                .frame(height: 160)
            
            // 2. Net Bag vector image in the top-right
            HStack {
                Spacer()
                NetBagView()
                    // Adjust size as desired
                    .frame(width: 63, height: 80)
                    // Optionally add transparency so it doesn't overpower text
                    .opacity(0.55)
            }
            .padding(.top, 8)
            .padding(.trailing, 8)
            
            // 3. Text + Search + Camera overlay
            VStack(alignment: .leading, spacing: 7) {
                Text("Recycling Inspirations")
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(ColorPalette.textMain)
                
                Text("Separate garbage into mixed waste and recyclables at one touch")
                    .font(.subheadline)
                    .foregroundColor(ColorPalette.textSub)
                
                // Search box + camera button in one row
                HStack(spacing: 8) {
                    // Search box
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search", text: $searchText)
                            .disableAutocorrection(true)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 8)
                    .frame(height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ColorPalette.cardBG)
                    )
                    
                    // Camera button
                    Button {
                        showCamera = true
                    } label: {
                        Image(systemName: "camera.fill")
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(ColorPalette.cardBG)
                            )
                    }
                    .frame(height: 36)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        // 4. Match the same width as "Popular themes"
        .padding(.horizontal, 16)
    }
}

// MARK: - 6. Theme Card View

struct ThemeCardView<Icon: View>: View {
    let title: String
    let icon: Icon
    
    var body: some View {
        VStack(spacing: 8) {
            icon
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
        }
        .padding()
        .frame(width: 120, height: 120)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorPalette.cardBG)
        )
    }
}

struct OceanTrashView: View {
    var body: some View {
        ZStack {
            // Ocean background (wave-like shape)
            OceanShape()
                .fill(Color.blue.opacity(0.7))
            
            // Some “trash” shapes (bottles, boxes) floating
            // Adjust positions, sizes, colors to taste
            Group {
                // Bottle #1
                BottleShape()
                    .fill(Color.gray)
                    .frame(width: 8, height: 20)
                    .offset(x: -20, y: 10)
                
                // Box #1
                BoxShape()
                    .fill(Color.brown.opacity(0.8))
                    .frame(width: 12, height: 12)
                    .offset(x: 10, y: -5)
                
                // Bottle #2
                BottleShape()
                    .fill(Color.green.opacity(0.7))
                    .frame(width: 6, height: 14)
                    .offset(x: 20, y: 15)
                
                // Another box
                BoxShape()
                    .fill(Color.orange.opacity(0.8))
                    .frame(width: 10, height: 10)
                    .offset(x: -10, y: -12)
            }
        }
        // Overall frame for the icon
        .frame(width: 60, height: 60)
    }
}

/// A wavy ocean shape
struct OceanShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        
        // Start at bottom-left
        path.move(to: CGPoint(x: 0, y: h))
        
        // Curve up
        path.addQuadCurve(
            to: CGPoint(x: w * 0.3, y: h * 0.4),
            control: CGPoint(x: w * 0.1, y: h * 0.6)
        )
        
        // Next wave
        path.addQuadCurve(
            to: CGPoint(x: w * 0.7, y: h * 0.6),
            control: CGPoint(x: w * 0.5, y: h * 0.2)
        )
        
        // Final wave to top-right
        path.addQuadCurve(
            to: CGPoint(x: w, y: h * 0.3),
            control: CGPoint(x: w * 0.9, y: h * 0.9)
        )
        
        // Close at top-right
        path.addLine(to: CGPoint(x: w, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.closeSubpath()
        
        return path
    }
}

struct TrashBinView: View {
    var body: some View {
        ZStack {
            // The basket
            BasketShape()
                .fill(Color.brown.opacity(0.8))
            
            // Some cans/bottles poking out the top
            Group {
                BottleShape()
                    .fill(Color.green.opacity(0.7))
                    .frame(width: 10, height: 20)
                    .offset(x: 0, y: -20)
                
                CanShape()
                    .fill(Color.gray)
                    .frame(width: 14, height: 14)
                    .offset(x: 10, y: -15)
                
                BottleShape()
                    .fill(Color.blue.opacity(0.7))
                    .frame(width: 8, height: 16)
                    .offset(x: -10, y: -18)
            }
        }
        .frame(width: 60, height: 60)
    }
}

struct MergedThemeCardView<LeftIcon: View, RightIcon: View>: View {
    let leftTitle: String
    let leftIcon: LeftIcon
    let rightTitle: String
    let rightIcon: RightIcon
    
    var body: some View {
        HStack(spacing: 0) {
            // Left block
            VStack(spacing: 8) {
                leftIcon
                Text(leftTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            Divider() // a thin vertical divider between the two blocks
            
            // Right block
            VStack(spacing: 8) {
                rightIcon
                Text(rightTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .frame(width: 240, height: 120) // Adjust width/height as needed
        .background(RoundedRectangle(cornerRadius: 12).fill(ColorPalette.cardBG))
    }
}
/// A simple basket shape
struct BasketShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        
        // Basket outline
        path.move(to: CGPoint(x: w * 0.2, y: 0))
        path.addLine(to: CGPoint(x: w * 0.8, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: w, y: h * 0.7),
            control: CGPoint(x: w * 1.0, y: h * 0.3)
        )
        path.addLine(to: CGPoint(x: w * 0.9, y: h))
        path.addLine(to: CGPoint(x: w * 0.1, y: h))
        path.addLine(to: CGPoint(x: 0, y: h * 0.7))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.2, y: 0),
            control: CGPoint(x: 0, y: h * 0.3)
        )
        path.closeSubpath()
        return path
    }
}

/// A simple can shape
struct CanShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        
        // Oval top
        path.addEllipse(in: CGRect(x: 0, y: 0, width: w, height: h * 0.3))
        
        // Body rectangle
        path.move(to: CGPoint(x: 0, y: h * 0.15))
        path.addLine(to: CGPoint(x: 0, y: h * 0.8))
        path.addLine(to: CGPoint(x: w, y: h * 0.8))
        path.addLine(to: CGPoint(x: w, y: h * 0.15))
        path.closeSubpath()
        
        return path
    }
}

struct ZeroWasteSignView: View {
    var body: some View {
        ZStack {
            // Chalkboard
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.black)
                .frame(width: 50, height: 60)
            
            // Frame around it
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.brown, lineWidth: 4)
                .frame(width: 54, height: 64)
            
            // Text: "GO TO ZERO ZERO WASTE"
            // We'll approximate it with a smaller font
            VStack(spacing: 2) {
                Text("GO TO")
                Text("ZERO")
                Text("ZERO")
                Text("WASTE")
            }
            .font(.system(size: 6, weight: .bold))
            .foregroundColor(.white)
        }
        .frame(width: 60, height: 60)
    }
}

struct ForestRecycleView: View {
    var body: some View {
        ZStack {
            // Green forest canopy
            Circle()
                .fill(Color.green.opacity(0.7))
            
            // The recycle arrows in a lighter green
            RecycleArrowsShape()
                .fill(Color.green.opacity(1.0))
                .frame(width: 40, height: 40)
        }
        .frame(width: 60, height: 60)
    }
}

/// A shape with three arrows in a recycle-triangle arrangement
struct RecycleArrowsShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        
        // We'll draw 3 arrows in a triangle
        // Arrow 1
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addLine(to: CGPoint(x: w * 0.6, y: h * 0.15))
        path.addLine(to: CGPoint(x: w * 0.55, y: h * 0.15))
        path.addLine(to: CGPoint(x: w * 0.6, y: h * 0.25))
        path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.25))
        path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.05))
        path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.05))
        path.closeSubpath()
        
        // Arrow 2
        path.move(to: CGPoint(x: w * 0.85, y: h * 0.55))
        path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.55))
        path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.45))
        path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.45))
        path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.25))
        path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.4))
        path.closeSubpath()
        
        // Arrow 3
        path.move(to: CGPoint(x: w * 0.15, y: h * 0.55))
        path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.55))
        path.addLine(to: CGPoint(x: w * 0.25, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.65))
        path.addLine(to: CGPoint(x: w * 0.2, y: h * 0.85))
        path.addLine(to: CGPoint(x: w * 0.1, y: h * 0.7))
        path.closeSubpath()
        
        return path
    }
}

/// A simple bottle shape
struct BottleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        
        // Neck
        path.move(to: CGPoint(x: w * 0.4, y: 0))
        path.addLine(to: CGPoint(x: w * 0.6, y: 0))
        path.addLine(to: CGPoint(x: w * 0.6, y: h * 0.2))
        path.addLine(to: CGPoint(x: w * 0.4, y: h * 0.2))
        
        // Body
        path.addQuadCurve(
            to: CGPoint(x: w * 0.2, y: h),
            control: CGPoint(x: 0, y: h * 0.6)
        )
        path.addLine(to: CGPoint(x: w * 0.8, y: h))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.6, y: h * 0.2),
            control: CGPoint(x: w, y: h * 0.6)
        )
        
        path.closeSubpath()
        return path
    }
}

/// A simple box shape
struct BoxShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(CGRect(x: 0, y: 0, width: rect.width, height: rect.height))
        return path
    }
}

// MARK: - 7. HomeView (No progress bar)

struct HomeView: View {
    @State private var searchText = ""
    @State private var showCamera = false
    @State private var showingSearch = false
    @State private var selectedImage: String? = nil
    
    let popularThemeImageNames = ["recycle", "oceantrash", "zerowa", "forest"]
    var body: some View {
        ZStack {
            ColorPalette.background
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 0) {
                
                TopCardView(searchText: $searchText, showCamera: $showCamera)
                    .frame(height: 160)
                    .onTapGesture{
                        showingSearch = true
                    }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 6) {
                        
                        // "Popular themes" section title
                        HStack {
                            Text("Popular themes")
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 9)

                     
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                Image("recycle")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .clipped()
                                    .onTapGesture {
                                        print("Tapped imageName = recycle")
                                        selectedImage = "recycle"
                                        
                                    }
                                
                                Image("oceantrash")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .clipped()
                                    .onTapGesture {
                                        print("Tapped imageName = oceantrash")
                                        selectedImage = "oceantrash"
                                        
                                    }
                                
                                Image("zerowa")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .clipped()
                                    .onTapGesture {
                                        print("Tapped imageName = zerowa")
                                        selectedImage = "zerowa"
                                        
                                    }

                                Image("forest")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .clipped()
                                    .onTapGesture {
                                        print("Tapped imageName = forest")
                                        selectedImage = "forest"
                                        
                                    }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Another section title
                        HStack {
                            Text("Reclcying Tips")
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        }
                        .padding(.top,7)
                        .padding(.bottom,4)
                        .padding(.horizontal, 18)
                        

                        // Display one or more vector images
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ThemeCardView(title:"Ocean trash", icon:OceanTrashView())
                                ThemeCardView(title:"Trash bin", icon:TrashBinView())
                                ThemeCardView(title:"Zero waste", icon: ZeroWasteSignView())
                                ThemeCardView(title:"Forest", icon: ForestRecycleView())
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        HStack {
                            Text("Recycle and plant your own tree!")
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 18)
                        .padding(.top,9)
                        
                        Spacer().frame(height: 10)
                    }
                    .padding(.top, 8)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            Image("gebi")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 210, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .clipped()
                                .onTapGesture {
                                    print("Tapped imageName = gebi")
                                    selectedImage = "gebi"
                                    
                                }
                            
                            Image("texas")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 210, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .clipped()
                                .onTapGesture {
                                    print("Tapped imageName = texas")
                                    selectedImage = "texas"
                                    
                                }
                            
                            Image("hei")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 210, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .clipped()
                                .onTapGesture {
                                    print("Tapped imageName = hei")
                                    selectedImage = "hei"
                                    
                                }

                            Image("alashan")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 210, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .clipped()
                                .onTapGesture {
                                    print("Tapped imageName = alashan")
                                    selectedImage = "alashan"
                                    
                                }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                }
            }
        }
       
        // Camera sheet
        .sheet(isPresented: $showCamera) {
            CameraView()
        }
        .sheet(isPresented: $showingSearch) {
            NavigationView{
                SearchPageView()
            }
        }
    }
}




// MARK: - 8. Other Tabs (Trees, Discover, Profile)

// MARK: - 1. DiscoverView Section

struct DiscoverView: View {
    var body: some View {
        ZStack {
            ColorPalette.background
                .edgesIgnoringSafeArea(.all)
            Text("Discover Page")
                .font(.title)
                .foregroundColor(.black)
        }
    }
}
// MARK: -1. End of DiscoverView Section




// MARK: - 9. Bottom Bar with Magnification & Tab Switching

struct BottomBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            // Home (SF Symbol)
            BottomBarItem(
                iconType: .system("house.fill"),
                label: "Home",
                index: 0,
                selectedTab: $selectedTab
            )
            
            Spacer()
            
            BottomBarItem(
                iconType: .system("leaf.fill"),
                label: "Trees",
                index: 1,
                selectedTab: $selectedTab
            )
            
            Spacer()
            BottomBarItem(
                iconType: .blob,
                label: "Discover",
                index: 2,
                selectedTab: $selectedTab
            )
            
            Spacer()
            
            // Profile (SF Symbol)
            BottomBarItem(
                iconType: .system("person.fill"),
                label: "Profile",
                index: 3,
                selectedTab: $selectedTab
            )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 0)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        
    }
}

enum BottomBarIconType {
    case system(String)
    case blob
}

struct BottomBarItem: View {
    let iconType: BottomBarIconType
    let label: String
    let index: Int
    @Binding var selectedTab: Int
    
    @State private var isPressed = false
    
    var body: some View {
        Button {
            selectedTab = index
        } label: {
            VStack(spacing: 4) {
                switch iconType {
                case .system(let sfSymbolName):
                    Image(systemName: sfSymbolName)
                        .font(.system(size: 24))
                case .blob:
                    LittleBlobView()
                }
                
                Text(label)
                    .font(.caption)
            }
            .scaleEffect(isPressed ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            switch selectedTab {
            case 0:
                NavigationView {HomeView()}
            case 1:
                NavigationView {TreesView()}
            case 2:
                NavigationView {DiscoverView()}
            case 3:
                NavigationView {ProfileView()}
            default:
                NavigationView {HomeView()}
            }
            
            VStack {
                Spacer()
                BottomBar(selectedTab: $selectedTab)
            }
        }
        .navigationBarHidden(true)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
