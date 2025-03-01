import SwiftUI
import UIKit


struct ColorPalette {
    static let background = Color(red: 0.65, green: 0.77, blue: 0.6)
    static let topCard    = Color(red: 0.45, green: 0.6, blue: 0.45)
    static let cardBG     = Color(red: 0.90, green: 0.90, blue: 0.80)
    static let textMain   = Color.white
    static let textSub    = Color.white.opacity(0.9)
}

struct SpoonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.2, y: rect.maxY - rect.height * 0.2))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.7, y: rect.minY + rect.height * 0.3))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.8, y: rect.minY + rect.height * 0.2))
        path.addArc(
            center: CGPoint(x: rect.minX + rect.width * 0.85, y: rect.minY + rect.height * 0.15),
            radius: rect.width * 0.15,
            startAngle: .degrees(0),
            endAngle: .degrees(360),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}


struct SpoonAndBallView: View {
    var body: some View {
        ZStack {
            SpoonShape()
                .fill(Color(red: 0.8, green: 0.65, blue: 0.4))
           
            Circle()
                .fill(Color(red: 1.0, green: 1.0, blue: 0.9))  
                .frame(width: 14, height: 14)
                .offset(x: 10, y: 10)
        }
        .frame(width: 60, height: 60)
        .rotationEffect(.degrees(-20))
    }
}



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
        // Bottom arc
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
       
        .frame(width: 30, height: 30)
    }
}

struct NetBagView: View {
    var body: some View {
        ZStack {
            BagOutlineShape()
                .fill(Color(red: 0.4, green: 0.55, blue: 0.4)) // Deep green
            BagNetLinesShape()
                .stroke(Color(red: 0.3, green: 0.45, blue: 0.3), lineWidth: 2)
        }
        .frame(width: 60, height: 60)
    }
}

struct BlobIconView: View {
    var body: some View {
        ZStack {
            // 1. The blob outline in black
            BlobIconShape()
                .fill(Color.black)
            
           
            Circle()
                .fill(Color.white)
                .frame(width: 5, height: 5)
                .offset(x: -6, y: -4) // left eye
            
            Circle()
                .fill(Color.white)
                .frame(width: 5, height: 5)
                .offset(x: 6, y: -4)  
        }
        .frame(width: 40, height: 40) 
    }
}



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
            
         
            RoundedRectangle(cornerRadius: 20)
                .fill(ColorPalette.topCard)
                .frame(height: 160)
            
           
            HStack {
                Spacer()
                NetBagView()
                 
                    .frame(width: 80, height: 80)
                    
                    .opacity(0.25)
            }
            .padding(.top, 8)
            .padding(.trailing, 8)
            
          
            VStack(alignment: .leading, spacing: 7) {
                Text("Recycling Inspirations")
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(ColorPalette.textMain)
                
                Text("Separate garbage into mixed waste and recyclables at one touch")
                    .font(.subheadline)
                    .foregroundColor(ColorPalette.textSub)
                
               
                HStack(spacing: 8) {
                 
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
        
        .padding(.horizontal, 16)
    }
}



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
      
            OceanShape()
                .fill(Color.blue.opacity(0.7))
            
        
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
       
        .frame(width: 60, height: 60)
    }
}

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
    
            BasketShape()
                .fill(Color.brown.opacity(0.8))
            

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

struct BasketShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height

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


struct RecycleArrowsShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        
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

struct BoxShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(CGRect(x: 0, y: 0, width: rect.width, height: rect.height))
        return path
    }
}


struct HomeView: View {
    @State private var searchText = ""
    @State private var showCamera = false
    
    
    var body: some View {
        ZStack {
            ColorPalette.background
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 0) {
                
                TopCardView(searchText: $searchText, showCamera: $showCamera)
                    .frame(height: 160)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 6) {
                        
                        HStack {
                            Text("Popular themes")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            .padding(.horizontal, 13)
                        }
                        .padding(.horizontal, 6)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                            }
                            .padding(.horizontal, 16)
                        }
                  
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ThemeCardView(title: "Eco friendly", icon: SpoonAndBallView())
                                ThemeCardView(title: "Tools", icon: NetBagView())
                                ThemeCardView(title: "Eco friendly", icon: SpoonAndBallView())
                                ThemeCardView(title: "Tools", icon: NetBagView())
                            }
                            .padding(.horizontal, 16)
                        
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    
                                }
                                .padding(.horizontal, 16)
                            }
                            
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
                        .padding(.top,9)
                        .padding(.horizontal, 18)
                        

                 
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
                            Text("Where we are")
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 18)
                        .padding(.top,9)
             
                        Spacer().frame(height: 80) 
                    }
                    .padding(.top, 8)
                }
            }
        }
        // Camera sheet
        .sheet(isPresented: $showCamera) {
            CameraView()
        }
    }
}



struct TreesView: View {
    var body: some View {
        ZStack {
            ColorPalette.background
                .edgesIgnoringSafeArea(.all)
            Text("Trees Page")
                .font(.title)
                .foregroundColor(.black)
        }
    }
}

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



// MARK: - 1. Profile View
struct ProfileView: View {
    var body: some View {
        ZStack {
            // Match the HomeView background color
            ColorPalette.background
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                  
                    UserInfoSection()
                    CardsSection()
                    MenuListSection()
                    Spacer().frame(height: 24)
                }
                .padding(.top, 16)
            }
        }
    }
}


struct UserInfoSection: View {
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            
            // Left side: user info
            VStack(alignment: .leading, spacing: 4) {
                // Name
                Text("Your Username")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
            
                HStack(spacing: 8) {
                    // Star rating
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 14))
                        Text("4.84")
                            .foregroundColor(.black)
                            .font(.subheadline)
                    }
                    
              
                    Text("Status")
                        .foregroundColor(.black)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
            }
            
            Spacer()
            

            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white.opacity(0.8))
                        .padding(8)
                )
        }
        .padding(.horizontal, 16)
    }
}


struct CardsSection: View {
    var body: some View {
        VStack(spacing: 12) {
            
            // Card 1: Uber balances
            CardView(
                title: "Number of Tress planted",
                subtitle: "0",
                icon: nil
            )
            
            
            // Card 3: Estimated CO2 saved
            CardView(
                title: "Estimated CO₂ saved",
                subtitle: "0 g",
                icon: AnyView(GreenLeavesView().frame(width: 24, height: 24))
            )
        }
        .padding(.horizontal, 16)
    }
}


struct CardView: View {
    let title: String
    let subtitle: String
    let icon: AnyView?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundColor(.black)
                    .font(.subheadline)
                Text(subtitle)
                    .foregroundColor(.black)
                    .font(.headline)
            }
            Spacer()
            
            if let icon = icon {
                icon
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}

// MARK: - 4. Menu List Section
struct MenuListSection: View {
    var body: some View {
        VStack(spacing: 1) {
            ExpandableMenuItem(
                iconName: "person.2.fill",
                label: "Accomplishments",
                details: "Manage your achievements and rewards"
            )
            ExpandableMenuItem(
                iconName: "gearshape.fill",
                label: "Settings",
                details: "Update your preferences and account settings"
            )
            ExpandableMenuItem(
                iconName: "gift.fill",
                label: "Make a Donation",
                details: "Contribute meaningfully to our cause for Environmental Protection"
            )
        }
        .padding(.top, 8)
    }
}
struct ExpandableMenuItem: View {
    let iconName: String
    let label: String
    let details: String  
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // The main row
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .foregroundColor(.black)
                        .font(.body)
                
                    if isExpanded {
                        Text(details)
                            .foregroundColor(.black)
                            .font(.caption)
                            .transition(.opacity)
                    }
                }
                
                Spacer()
                
             
                Image(systemName: isExpanded ? "chevron.up" : "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle()) 
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            
            Divider()
                .background(Color.gray.opacity(0.5))
        }
        .padding(.horizontal, 16)
    }
}



// MARK: - 5. Green Leaves Vector Icon
struct GreenLeavesView: View {
    var body: some View {
        ZStack {
            // Left leaf
            LeafShape()
                .rotation(Angle(degrees: 30))
            // Right leaf
            LeafShape()
                .rotation(Angle(degrees: -30))
                .offset(x: 6, y: 2)
        }
        .foregroundColor(.green)
    }
}

/// A simple leaf shape
struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        
        // Start at bottom
        path.move(to: CGPoint(x: w * 0.5, y: h))
        
        // Curve up to top
        path.addQuadCurve(
            to: CGPoint(x: 0, y: 0),
            control: CGPoint(x: 0, y: h * 0.5)
        )
        
        // Curve back down
        path.addQuadCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control: CGPoint(x: w, y: h * 0.5)
        )
        
        path.closeSubpath()
        return path
    }
}

// MARK: - 6. Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .preferredColorScheme(.dark)
    }
}

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
                HomeView()
            case 1:
                TreesView()
            case 2:
                DiscoverView()
            case 3:
                ProfileView()
            default: HomeView()
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
