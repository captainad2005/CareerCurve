import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()
                
                VStack {
                    Image("CareerCurveLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .scaleEffect(size)
                        .opacity(opacity)
                        .overlay {
                            Circle()
                                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                                .blur(radius: 4)
                                .scaleEffect(size)
                        }
                }
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            self.size = 15
                            self.opacity = 0
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
} 