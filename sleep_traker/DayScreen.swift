import SwiftUI

struct DayScreen: View {
    @State private var selectedHour = 7
    @State private var selectedMinute = 30

    @State private var showTimePicker = false

    @State private var currentDate = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    let hours = Array(0...23)
    let minutes = Array(0...59)

    var calendar: Calendar { Calendar.current }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("SolClock")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Hora para despertarse")
                        .font(.system(size: geometry.size.width * 0.06))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(15)

                    // Reloj análogo
                    ZStack {
                        Image("RelojDia")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.5)

                        let hour = calendar.component(.hour, from: currentDate)
                        let minute = calendar.component(.minute, from: currentDate)
                        let second = calendar.component(.second, from: currentDate)

                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 6, height: geometry.size.width * 0.05)
                            .offset(y: -geometry.size.width * 0.03)
                            .rotationEffect(Angle.degrees(Double(hour % 12) * 30 + Double(minute) * 0.5))
                            .animation(.easeInOut(duration: 0.2), value: hour + minute)

                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 4, height: geometry.size.width * 0.08)
                            .offset(y: -geometry.size.width * 0.04)
                            .rotationEffect(Angle.degrees(Double(minute) * 6))
                            .animation(.easeInOut(duration: 0.2), value: minute)

                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 2, height: geometry.size.width * 0.09)
                            .offset(y: -geometry.size.width * 0.05)
                            .rotationEffect(Angle.degrees(Double(second) * 6))
                            .animation(.linear(duration: 0.1), value: second)

                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                    }

                    Text("Quiero despertarme a")
                        .font(.system(size: geometry.size.width * 0.05))
                        .foregroundColor(.white)

                    // Botón para abrir sheet
                    Button(action: {
                        showTimePicker = true
                    }) {
                        Text("\(String(format: "%02d", selectedHour)) : \(String(format: "%02d", selectedMinute))")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(15)
                    }

                    Button(action: {
                        print("⏰ Hora seleccionada: \(selectedHour):\(selectedMinute)")
                    }) {
                        Text("Ver opciones")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.orange)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            .onReceive(timer) { input in
                currentDate = input
            }
            .sheet(isPresented: $showTimePicker) {
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

                        Text(":")
                            .font(.title)

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
                        showTimePicker = false
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.orange)
                    .cornerRadius(15)
                }
                .presentationDetents([.medium])
                .padding()
            }
        }
    }
}

#Preview {
    DayScreen()
}
