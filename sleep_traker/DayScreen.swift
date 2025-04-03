import SwiftUI

struct DayScreen: View {
    var body: some View {
        ZStack {
            // Fondo con imagen del sol
            Image("SolClock")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            
            // Contenido principal
            VStack(spacing: 20) {
                Text("Hora para despertarse")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(15)

                Image("SolClock")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)

                Text("Quiero despertarme a")
                    .font(.headline)
                    .foregroundColor(.white)

                HStack(spacing: 30) {
                    Text("Hora ▼")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(15)

                    Text("Minuto ▼")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(15)
                }
            }
            .padding()
        }
    }
}

#Preview {
    DayScreen()
}
