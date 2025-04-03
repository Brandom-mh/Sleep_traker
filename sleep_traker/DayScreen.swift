import SwiftUI

struct DayScreen: View {
    @State private var selectedHour = 7
    @State private var selectedMinute = 30
    @State private var selectedCycle: Int? = nil

    @State private var showTimePicker = false
    @State private var showSleepOptions = false

    // Nueva variable para modo noche
    @State private var isNight = false

    @State private var currentDate = Date()
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

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
                    if !showSleepOptions {
                        Text(isNight ? "Hora para dormir" :"Hora para despertarse")
                            .font(.system(size: geometry.size.width * 0.06))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(15)
                        
                        // Toggle para cambiar modo noche
                        Toggle("Modo Noche", isOn: $isNight)
                            .padding(.horizontal)
                            .toggleStyle(SwitchToggleStyle(tint: .orange))
                    }

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

                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 4, height: geometry.size.width * 0.08)
                            .offset(y: -geometry.size.width * 0.04)
                            .rotationEffect(Angle.degrees(Double(minute) * 6))

                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 2, height: geometry.size.width * 0.09)
                            .offset(y: -geometry.size.width * 0.05)
                            .rotationEffect(Angle.degrees(Double(second) * 6))

                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                    }

                    if !showSleepOptions {
                        Text("Quiero despertarme a")
                            .font(.system(size: geometry.size.width * 0.05))
                            .foregroundColor(.white)

                        // Botón para abrir sheet de hora
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
                    }

                    // Botón "Ver opciones / Volver"
                    Button(action: {
                        withAnimation {
                            showSleepOptions.toggle()
                            if !showSleepOptions { selectedCycle = nil }
                        }
                    }) {
                        Text(showSleepOptions ? "Volver" : "Ver opciones")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.orange)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    .padding(.top, 10)

                    if showSleepOptions {
                        if let selected = selectedCycle {
                            VStack {
                                Button(action: {
                                    // Acción opcional al pulsar la opción seleccionada
                                }) {
                                    VStack {
                                        Text(calculateSleepTime(for: selected))
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)

                                        Text("Hora a la que debes dormir para\n\(selected) ciclo\(selected > 1 ? "s" : "")")
                                            .font(.caption)
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.center)

                                        VStack(spacing: 10) {
                                            Text("¿Confirmar hora de dormir a las \(calculateSleepTime(for: selected))?")
                                                .foregroundColor(.black)
                                                .multilineTextAlignment(.center)

                                            HStack(spacing: 20) {
                                                Button("Sí") {
                                                    // Acción de confirmación futura
                                                }
                                                .padding(.horizontal)
                                                .padding(.vertical, 8)
                                                .foregroundColor(.white)
                                                .background(Color.green)
                                                .cornerRadius(10)

                                                Button("No") {
                                                    withAnimation {
                                                        selectedCycle = nil
                                                    }
                                                }
                                                .padding(.horizontal)
                                                .padding(.vertical, 8)
                                                .foregroundColor(.white)
                                                .background(Color.red)
                                                .cornerRadius(10)
                                            }
                                        }
                                        .padding(.top)
                                    }
                                    .padding()
                                    .frame(maxWidth: geometry.size.width * 0.8)
                                    .background(Color.white)
                                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.orange, lineWidth: 2))
                                    .cornerRadius(15)
                                    .scaleEffect(1.15)
                                }
                                .transition(.opacity.combined(with: .scale))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .transition(.opacity.combined(with: .scale))
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                ForEach(1...6, id: \.self) { cycle in
                                    Button(action: {
                                        withAnimation {
                                            selectedCycle = cycle
                                        }
                                    }) {
                                        VStack {
                                            Text(calculateSleepTime(for: cycle))
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundColor(.black)

                                            Text("Hora a la que debes dormir para\n\(cycle) ciclo\(cycle > 1 ? "s" : "")")
                                                .font(.caption)
                                                .foregroundColor(.black)
                                                .multilineTextAlignment(.center)
                                        }
                                        .padding()
                                        .frame(maxWidth: geometry.size.width * 0.25)
                                        .background(Color.white)
                                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.orange, lineWidth: 2))
                                        .cornerRadius(15)
                                    }
                                    .transition(.opacity.combined(with: .scale))
                                }
                            }
                            .padding()
                            .transition(.opacity.combined(with: .scale))
                        }
                    }
                }
                .padding()
                .animation(.easeInOut(duration: 0.3), value: showSleepOptions)
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
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
                        withAnimation {
                            showTimePicker = false
                        }
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

    // Calcula la hora para dormir en base a los ciclos (90 mins cada uno)
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

struct MainView: View {
    var body: some View {
        TabView {
            DayScreen()
                .tabItem {
                    Image("tab_calendario")
                        .renderingMode(.original)
                    Text("Calendario")
                }
                .tag(0)
            
            Text("Cálculo de ciclo")
                .tabItem {
                    Image("tab_ciclo")
                        .renderingMode(.original)
                    Text("Cálculo de ciclo")
                }
                .tag(1)
        }
        .tabViewStyle(DefaultTabViewStyle()) // Fuerza el estilo clásico en iPhone
        .accentColor(.orange)
    }
}

#Preview {
    MainView()
}
