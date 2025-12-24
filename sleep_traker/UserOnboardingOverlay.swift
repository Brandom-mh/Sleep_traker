import SwiftUI

struct UserOnboardingOverlay: View {
    @ObservedObject var progressModel: StarProgressModel
    @State private var nombreTemp: String = ""
    @State private var edadTemp: String = ""
    @State private var showOverlay: Bool = true
    @State private var animateIn: Bool = false

    var body: some View {
        if showOverlay && (progressModel.Nombre.isEmpty || progressModel.newUser == 0) {
            GeometryReader { geometry in
                let cardWidth = min(geometry.size.width * 0.85, 400)
                let horizontalPadding = geometry.size.width * 0.08

                ZStack {
                    Color.black.opacity(0.85)
                        .ignoresSafeArea()

                    VStack(spacing: 25) {
                        Text("Bienvenido")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        VStack(alignment: .leading, spacing: 15) {
                            Text("¿Cuál es tu nombre?")
                                .foregroundColor(.white)
                            TextField("Ingresa tu nombre", text: $nombreTemp)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            Text("¿Cuál es tu edad?")
                                .foregroundColor(.white)
                            TextField("Ingresa tu edad", text: $edadTemp)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        .padding(.horizontal, horizontalPadding)

                        Button(action: {
                            if !nombreTemp.isEmpty, let edadValor = Int(edadTemp), edadValor > 0 {
                                progressModel.Nombre = nombreTemp
                                progressModel.newUser = edadValor
                                progressModel.saveNombre()
                                progressModel.saveEdad()

                                withAnimation(.easeInOut(duration: 0.4)) {
                                    animateIn = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        showOverlay = false
                                    }
                                }
                            }
                        }) {
                            Text("Continuar")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, horizontalPadding * 1.3)
                    }
                    .padding()
                    .frame(maxWidth: cardWidth)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(20)
                    .scaleEffect(animateIn ? 1.0 : 0.7)
                    .opacity(animateIn ? 1 : 0)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.4)) {
                            animateIn = true
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .transition(.opacity)
        }
    }
}
