import SwiftUI

struct WakeUpScreen: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                // Fondo vibrante para despertar
                Image("fondoNoche")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                        .frame(height: geometry.size.height * 0.1)
                    // Reloj animado con tamaño responsivo
                    AnimatedClockView(size: min(geometry.size.width * 0.65, geometry.size.height * 0.35))
                        .scaledToFit()
                    
                    Spacer()
                        .frame(height: geometry.size.height * 0.05)
                    
                    
                    Text("¡Hora de despertar!")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                        .frame(height: geometry.size.height * 0.01)
                    
                    Button(action: {
                        // Aquí puedes detener el sonido también
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                                .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)

                            Text("DETENER\nALARMA")
                                .multilineTextAlignment(.center)
                                .font(.system(size: geometry.size.width * 0.06, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
}
#Preview {
    WakeUpScreen()
}
