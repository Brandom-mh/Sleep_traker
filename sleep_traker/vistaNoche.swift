import SwiftUI

// MARK: - Vista principal

struct vistaNoche: View {
    @State private var activarAlarma = false
    @State private var mostrarOpciones = true
    @State private var mostrarRecomendaciones = false

    @State private var selectedHour = 7
    @State private var selectedMinute = 30

    var body: some View {
        ZStack {
            Image("fondoNoche")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 50) {
                if !mostrarRecomendaciones {
                    ToggleNoche(titulo: "", estado: $activarAlarma)
                    
                    textosNoche(info: "Hora para acostarse")
                }
                    Image("clock")

                    Text("Quiero despertarme a:")
                        .font(.system(size: 30, design: .rounded))
                        .foregroundColor(.white)
                if !mostrarRecomendaciones {
                    TimePickerButton(
                        selectedHour: $selectedHour,
                        selectedMinute: $selectedMinute,
                        titulo: "",
                        color: Color(hex: "8ECAE6")
                    )
                }

                Button(action: {
                    withAnimation {
                        mostrarRecomendaciones.toggle()
                    }
                }) {
                    Text(mostrarRecomendaciones ? "Volver" : "Mostrar Opciones")
                        .foregroundColor(.black)
                        .font(.system(size: 30))
                        .frame(width: 250, height: 100)
                        .background(Color.white)
                        .cornerRadius(30)
                        .padding(.bottom)
                }

                if mostrarRecomendaciones {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(1...6, id: \.self) { cycle in
                            VStack {
                                Text(calculateSleepTime(for: cycle))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)

                                Text("Hora para dormir si quieres\n\(cycle) ciclo\(cycle > 1 ? "s" : "")")
                                    .font(.caption)
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color(hex: "8ECAE6"), lineWidth: 2)
                            )
                            .cornerRadius(15)
                        }
                    }
                    .padding()
                }

                Spacer()
            }.frame(width: 1000)
            .padding()
        }
        
    }

    // MARK: - Cálculo de hora ideal para dormir según número de ciclos
    func calculateSleepTime(for cycles: Int) -> String {
        let wakeUpDate = Calendar.current.date(bySettingHour: selectedHour, minute: selectedMinute, second: 0, of: Date()) ?? Date()
        let totalMinutes = -90 * cycles
        if let sleepDate = Calendar.current.date(byAdding: .minute, value: totalMinutes, to: wakeUpDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: sleepDate)
        }
        return "--:--"
    }
}

// MARK: - Botón selector de hora

struct TimePickerButton: View {
    @Binding var selectedHour: Int
    @Binding var selectedMinute: Int

    var titulo: String = ""
    var color: Color = .orange

    @State private var showPicker = false

    let hours = Array(0...23)
    let minutes = Array(0...59)

    var body: some View {
        VStack {
            Button(action: {
                showPicker = true
            }) {
                Text("\(titulo)\(String(format: "%02d", selectedHour)) \(String(format: "%02d", selectedMinute))")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 250, height: 80)
                    .background(color)
                    .cornerRadius(15)
            }
        }
        .sheet(isPresented: $showPicker) {
            VStack(spacing: 20) {
                Text("Selecciona la hora de despertar")
                    .font(.headline)

                HStack {
                    Picker("Hora", selection: $selectedHour) {
                        ForEach(hours, id: \.self) { hour in
                            Text(String(format: "%02d", hour)).tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                    .clipped()

                    Picker("Minuto", selection: $selectedMinute) {
                        ForEach(minutes, id: \.self) { minute in
                            Text(String(format: "%02d", minute)).tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                    .clipped()
                }

                Button("Aceptar") {
                    showPicker = false
                }
                .padding()
                .foregroundColor(.white)
                .background(color)
                .cornerRadius(15)
            }
            .presentationDetents([.medium])
            .padding()
        }
    }
}

// MARK: - Toggle personalizado

struct ToggleNoche: View {
    var titulo: String = "Activar"
    @Binding var estado: Bool

    var body: some View {
        VStack(spacing: 10) {
            Text(titulo)
                .font(.title)
                .foregroundColor(.white)

            Toggle("", isOn: $estado)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .scaleEffect(2)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Texto decorado

struct textosNoche: View {
    var info: String = ""

    var body: some View {
        VStack {
            Text(info)
                .frame(width: 400, height: 150)
                .background(Color(hex: "8ECAE6"))
                .bold()
                .cornerRadius(30)
                .padding()
                .foregroundColor(.white)
                .font(.system(size: 40, design: .rounded))
        }
    }
}

// MARK: - Preview

#Preview {
    vistaNoche()
}
