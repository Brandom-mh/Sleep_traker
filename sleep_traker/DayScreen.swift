import SwiftUI
import UIKit
struct DayScreen: View {
    @State private var selectedHour = 7
    @State private var selectedMinute = 30
    @State private var isPM = true
    @State private var selectedCycle: Int? = nil
    @StateObject private var progressModel = StarProgressModel()
    @State private var showTimePicker = false
    @State private var showSleepOptions = false
    @State private var mostrarConfiguracionAlarma = false // agrégalo arriba en tu View
    @State private var notificationOffset: CGFloat = -1000
    @State private var mostrarNotificacionConfirmacion = false

    // Nueva variable para modo noche
    @State private var isNight = false

    @State private var currentDate = Date()
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    let hours = Array(1...12)
    let minutes = Array(0...59)

    var calendar: Calendar { Calendar.current }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(isNight ? "fondoNoche" : "SolClock")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

             

                VStack(spacing: geometry.size.height * 0.012) {
                    // Spacer para respetar el safe area superior (Dynamic Island/Notch)
                    Spacer()
                        .frame(height: geometry.safeAreaInsets.top > 50 ? geometry.safeAreaInsets.top * 0.3 : 0)

                    if !showSleepOptions {
                        Text(isNight ? "Hora para dormir" : "Hora para despertar")
                            .font(.system(size: geometry.size.width * 0.055))
                            .fontWeight(.bold)
                            .foregroundColor(isNight ? Color.white : Color.black)
                            .padding(.horizontal)

                        // Toggle para cambiar modo noche
                        Toggle(isNight ? "Modo Dormir" : "Modo Despertar", isOn: $isNight)
                            .padding(.horizontal, 8)
                            .foregroundColor(isNight ? Color.white : Color.black)
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "219EBC")))
                            .font(.system(size: geometry.size.width * 0.035).bold())
                            .frame(width: geometry.size.width * 0.55)
                    }
                    
                  
                    
                    // Reloj análogo - tamaño reducido para iPhone
                    ZStack {
                        let clockSize = min(geometry.size.width * 0.55, geometry.size.height * 0.32)

                        Image(isNight ? "LunaReloj" : "RelojDia")
                            .resizable()
                            .scaledToFit()
                            .frame(width: clockSize, height: clockSize)
                            .offset(
                                x: isNight ? -clockSize * 0.17 : 0,
                                y: isNight ? clockSize * 0.002 : 0
                            )

                        let hour = calendar.component(.hour, from: currentDate)
                        let minute = calendar.component(.minute, from: currentDate)
                        let second = calendar.component(.second, from: currentDate)

                        // Manecilla de hora
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 5, height: clockSize * 0.1)
                            .offset(y: -clockSize * 0.06)
                            .rotationEffect(Angle.degrees(Double(hour % 12) * 30 + Double(minute) * 0.5))

                        // Manecilla de minuto
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 3, height: clockSize * 0.16)
                            .offset(y: -clockSize * 0.08)
                            .rotationEffect(Angle.degrees(Double(minute) * 6))

                        // Manecilla de segundo
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 2, height: clockSize * 0.18)
                            .offset(y: -clockSize * 0.1)
                            .rotationEffect(Angle.degrees(Double(second) * 6))

                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                    }
                   
                    if !showSleepOptions  {
                        Text(isNight ? "Selecciona la hora para dormir" : "Selecciona la hora a despertar")
                            .font(.system(size: geometry.size.width * 0.042))
                            .foregroundColor(isNight ? Color.white : Color.black)

                        // Botón para abrir sheet de hora
                        Button(action: {
                            showTimePicker = true
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(isNight ? Color(hex: "219EBC") : Color.orange)
                                    .shadow(color: .black.opacity(0.3), radius: 6, x: 3, y: 4)

                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.white.opacity(0.8), lineWidth: 2)

                                Text("\(String(format: "%02d", selectedHour)) : \(String(format: "%02d", selectedMinute))")
                                    .font(.system(size: geometry.size.width * 0.06, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .frame(width: geometry.size.width * 0.48, height: geometry.size.height * 0.06)
                            .scaleEffect(showTimePicker ? 0.97 : 1.0)
                            .animation(.easeInOut(duration: 0.15), value: showTimePicker)
                        }

                        if !showSleepOptions && progressModel.horasAsignadasExisten() {
                            VStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .frame(width: 22, height: 22)
                                    .foregroundColor(.green)

                                Text("¡Tienes una hora asignada!")
                                    .font(.system(size: geometry.size.width * 0.038, weight: .semibold))
                                    .foregroundColor(.white)

                                Text("🛌 Hora de dormir: \(progressModel.HoraAsignadaDormir.formatted(date: .omitted, time: .shortened))")
                                    .font(.system(size: geometry.size.width * 0.032))
                                    .foregroundColor(.white.opacity(0.85))

                                Text("⏰ Hora de despertar: \(progressModel.HoraAsignadaDespertar.formatted(date: .omitted, time: .shortened))")
                                    .font(.system(size: geometry.size.width * 0.032))
                                    .foregroundColor(.white.opacity(0.85))
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.3))
                            )
                        }
                    } else{
                        Text("\(String(format: "%02d", selectedHour)) : \(String(format: "%02d", selectedMinute))")
                            .font(.system(size: geometry.size.width * 0.09))
                            .foregroundColor(isNight ? Color.white : Color.black)
                            .padding()
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)

                        Text(isNight ? "Selecciona la opción para despertar" : "Selecciona la opción para dormir")
                            .font(.system(size: geometry.size.width * 0.035))
                            .foregroundColor(isNight ? Color.white : Color.black)
                            .multilineTextAlignment(.center)
                            .frame(width: geometry.size.width * 0.5)
                            .shadow(color: .black.opacity(0.25), radius: 2, x: 1, y: 1)
                    }

                    // Botón "Ver opciones / Volver"
                    Button(action: {
                        withAnimation {
                            showSleepOptions.toggle()
                            if !showSleepOptions { selectedCycle = nil }
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(isNight ? Color(hex: "219EBC") : Color.orange)
                                .shadow(color: .black.opacity(0.4), radius: 6, x: 3, y: 3)

                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.6), lineWidth: 1)

                            Text(showSleepOptions ? "Volver" : "CALCULAR CICLOS")
                                .font(.system(size: geometry.size.width * 0.042, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .frame(width: geometry.size.width * 0.52, height: geometry.size.height * 0.055)
                        .scaleEffect(showSleepOptions ? 1.02 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: showSleepOptions)
                    }
                    .padding(.top, 5)

                    if showSleepOptions {
                        Group {
                        if let selected = selectedCycle {
                            VStack {
                                Button(action: {
                                    // Acción opcional al pulsar la opción seleccionada
                                }) {
                                    VStack {
                                        Text(formatHour12(calculateSleepTime(for: selected)))
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)

                                        Text(isNight ? "Hora a la que debes despertar para\n\(selected) ciclo\(selected > 1 ? "s" : "")" :"Hora a la que debes dormir para\n\(selected) ciclo\(selected > 1 ? "s" : "")")
                                            .font(.caption)
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.center)
                                        
                                        Button(action: {
                                              mostrarConfiguracionAlarma = true
                                          }) {
                                              Text("Configura tu alarma")
                                                  .font(.subheadline)
                                                  .foregroundColor(.white)
                                                  .padding(.horizontal, 20)
                                                  .padding(.vertical, 10)
                                                  .background(Color.teal)
                                                  .cornerRadius(10)
                                                  .shadow(radius: 3)
                                          }
                                          .padding(.top, 5)
                                          .sheet(isPresented: $mostrarConfiguracionAlarma) {
                                              Alarma() // Asegúrate de que `Alarma` esté en el mismo archivo o importado correctamente
                                          }
                                        
                                        VStack(spacing: 10) {
                                            Text(isNight ? "¿Confirmar hora de despertar a las \(calculateSleepTime(for: selected))?" : "¿Confirmar hora de dormir a las \(calculateSleepTime(for: selected))?")
                                                .foregroundColor(.black)
                                                .multilineTextAlignment(.center)

                                            HStack(spacing: 20) {
                                                Button("Sí") {
                                                    withAnimation {
                                                        showSleepOptions = false
                                                        selectedCycle = nil
 
                                                        let calendar = Calendar.current
                                                        let now = Date()
                                                        let selectedHour24 = isPM ? (selectedHour == 12 ? 12 : selectedHour + 12) : (selectedHour == 12 ? 0 : selectedHour)
                                                        let horaBase = calendar.date(bySettingHour: selectedHour24, minute: selectedMinute, second: 0, of: now) ?? now
                                                        if isNight {
                                                            progressModel.HoraAsignadaDormir = horaBase
                                                            progressModel.saveHoraAsignadaDormir()
                                                        } else {
                                                            progressModel.HoraAsignadaDespertar = horaBase
                                                            progressModel.saveHoraAsignadaDespertar()
                                                        }
                                                        let selectedDate = horaBase
 
                                                        let minutosCiclo = duracionCiclo(edad: progressModel.newUser)
                                                        let minutosTotales = minutosCiclo * selected
 
                                                        let resultado: Date
 
                                                        if isNight {
                                                            // Dormir ahora → calcular hora de despertar
                                                            resultado = calendar.date(byAdding: .minute, value: minutosTotales, to: selectedDate) ?? selectedDate
                                                            progressModel.HoraAsignadaDespertar = resultado
                                                            progressModel.saveHoraAsignadaDespertar()
                                                        } else {
                                                            // Despertar a esa hora → calcular hora de dormir
                                                            resultado = calendar.date(byAdding: .minute, value: -minutosTotales, to: selectedDate) ?? selectedDate
                                                            progressModel.HoraAsignadaDormir = resultado
                                                            progressModel.saveHoraAsignadaDormir()
                                                        }
 
                                                        mostrarNotificacionConfirmacion = true
                                                    }
 
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                                        withAnimation {
                                                            notificationOffset = -geometry.size.height
                                                        }
                                                    }
                                                }
                                                .padding(.horizontal)
                                                .padding(.vertical, 8)
                                                .foregroundColor(.white)
                                                .background(Color(hex: "#0171E2"))
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
                            let gridSpacing: CGFloat = 8

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3),
                                      spacing: gridSpacing) {
                                ForEach((1...6).reversed(), id: \.self) { cycle in
                                    let canSleep = {
                                        if isNight { return true }
                                        let now = Date()
                                        let targetHour = isPM ? (selectedHour % 12) + 12 : selectedHour % 12
                                        guard var targetDate = Calendar.current.date(bySettingHour: targetHour, minute: selectedMinute, second: 0, of: now) else {
                                            return true
                                        }
                                        if targetDate < now {
                                            targetDate = Calendar.current.date(byAdding: .day, value: 1, to: targetDate) ?? targetDate
                                        }
                                        let minutesLeft = Int(targetDate.timeIntervalSince(now) / 60)
                                        return minutesLeft >= cycle * 90
                                    }()

                                    Button(action: {
                                        if canSleep {
                                            withAnimation {
                                                selectedCycle = cycle
                                            }
                                        }
                                    }) {
                                        VStack(spacing: 2) {
                                            Text(formatHour12(calculateSleepTime(for: cycle)))
                                                .font(.system(size: geometry.size.width * 0.028, weight: .bold))
                                                .foregroundColor(.black)
                                                .minimumScaleFactor(0.6)
                                                .lineLimit(1)

                                            Text(isNight ? "Hora a la que\nte despiertas" : "Hora a la que\ndebes dormir")
                                                .font(.system(size: geometry.size.width * 0.018))
                                                .foregroundColor(.black.opacity(0.7))
                                                .multilineTextAlignment(.center)
                                                .lineLimit(2)
                                                .minimumScaleFactor(0.7)

                                            Text("\(cycle) ciclo\(cycle > 1 ? "s" : "")")
                                                .font(.system(size: geometry.size.width * 0.02, weight: .medium))
                                                .foregroundColor(.black)
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 6)
                                        .frame(height: geometry.size.height * 0.1)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .opacity(isNight || canSleep ? 1 : 0.4)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(
                                                    cycle <= 3 ? Color.red :
                                                    cycle <= 5 ? Color.yellow :
                                                    Color.green,
                                                    lineWidth: 3
                                                )
                                        )
                                    }
                                    .disabled(!isNight && !canSleep)
                                    .transition(.opacity.combined(with: .scale))
                                }
                            }
                            .transition(.opacity.combined(with: .scale))
                        }
                        if !isNight && (1...6).reversed().allSatisfy({ cycle in
                            let now = Date()
                            let targetHour = isPM ? (selectedHour % 12) + 12 : selectedHour % 12
                            guard var targetDate = Calendar.current.date(bySettingHour: targetHour, minute: selectedMinute, second: 0, of: now) else { return false }
                            if targetDate < now {
                                targetDate = Calendar.current.date(byAdding: .day, value: 1, to: targetDate) ?? targetDate
                            }
                            let minutesLeft = Int(targetDate.timeIntervalSince(now) / 60)
                            return minutesLeft < cycle * 90
                        }) {
                            Text("Todas las opciones aplican para el siguiente día.")
                                .font(.footnote)
                                .foregroundColor(.white)
                                .padding(.top)
                        }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Spacer para safe area inferior
                    Spacer()
                        .frame(height: max(geometry.safeAreaInsets.bottom, 10))
                }
                .animation(.easeInOut(duration: 0.3), value: showSleepOptions)
                .animation(.easeInOut(duration: 0.3), value: isNight) // Animación para el toggle
                VStack(spacing: 15) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    Text(isNight ? "¡Hora de despertar confirmada!" : "¡Hora de dormir confirmada!")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 20)
                }
                
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isNight ? Color(hex: "219EBC").opacity(0.9) : Color.orange.opacity(0.9))
                        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 10)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.8), lineWidth: 1)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.horizontal, 30)
                .offset(y: notificationOffset)
                .animation(.easeInOut(duration: 0.5), value: notificationOffset)
            }
            .onChange(of: mostrarNotificacionConfirmacion) { nuevoValor in
                if nuevoValor {
                    withAnimation {
                        notificationOffset = -geometry.size.height * 0.45
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation {
                            notificationOffset = -geometry.size.height
                        }
                        mostrarNotificacionConfirmacion = false
                    }
                }
            }            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            .onReceive(timer) { input in
                currentDate = input
            }
            .sheet(isPresented: $showTimePicker) {
                GeometryReader { sheetGeometry in
                    let pickerWidth = min(sheetGeometry.size.width * 0.25, 100)
                    let ampmWidth = min(sheetGeometry.size.width * 0.2, 80)

                    VStack(spacing: 20) {
                        Text(isNight ? "Selecciona la hora de dormir" : "Selecciona la hora de despertar")
                            .font(.headline)

                        HStack {
                            Picker("Hora", selection: $selectedHour) {
                                ForEach(hours, id: \.self) { hour in
                                    Text(String(format: "%02d", hour)).tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: pickerWidth)
                            .clipped()

                            Text(":")
                                .font(.title)

                            Picker("Minuto", selection: $selectedMinute) {
                                ForEach(minutes, id: \.self) { minute in
                                    Text(String(format: "%02d", minute)).tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: pickerWidth)
                            .clipped()
                        }

                        Picker("AM/PM", selection: $isPM) {
                            Text("AM").tag(false)
                            Text("PM").tag(true)
                        }
                        .pickerStyle(.wheel)
                        .frame(width: ampmWidth)
                        .clipped()

                        Button("Aceptar") {
                            withAnimation {
                                showTimePicker = false
                            }
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(isNight ? Color(hex: "219EBC") : Color.orange)
                        .cornerRadius(15)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                }
                .presentationDetents([.medium])
            }
        }
        .overlay(UserOnboardingOverlay(progressModel: progressModel))
    }

    // Calcula la hora en base a los ciclos (90 mins cada uno)
    // Si isNight es false, se resta para saber cuándo ir a dormir (dado el tiempo de despertar)
    // Si isNight es true, se suma para saber cuándo despertar (dado el tiempo de dormir)
    func amPmSuffix(for cycles: Int) -> String {
        let hourIn24 = isPM ? (selectedHour == 12 ? 12 : selectedHour + 12) : (selectedHour == 12 ? 0 : selectedHour)
        let baseDate = Calendar.current.date(bySettingHour: hourIn24, minute: selectedMinute, second: 0, of: Date()) ?? Date()
        let totalMinutes = (isNight ? 90 : -90) * cycles
        if let newDate = Calendar.current.date(byAdding: .minute, value: totalMinutes, to: baseDate) {
            let hour = Calendar.current.component(.hour, from: newDate)
            return hour < 12 ? "AM" : "PM"
        }
        return ""
    }
    func calculateSleepTime(for cycles: Int) -> String {
    let cycleDuration = duracionCiclo(edad: progressModel.newUser)
    let hourIn24 = isPM ? (selectedHour == 12 ? 12 : selectedHour + 12) : (selectedHour == 12 ? 0 : selectedHour)
    let baseDate = Calendar.current.date(bySettingHour: hourIn24, minute: selectedMinute, second: 0, of: Date()) ?? Date()
    let totalMinutes = (isNight ? cycleDuration : -cycleDuration) * cycles
    if let newDate = Calendar.current.date(byAdding: .minute, value: totalMinutes, to: baseDate) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: newDate)
    }
    return "--:--"
}

    func duracionCiclo(edad: Int) -> Int {
        switch edad {
        case 0...1:
            return 50
        case 2...12:
            return 65
        case 13...18:
            return 85
        case 19...64:
            return 90
        case 65...:
            return 85
        default:
            return 90
        }
    }
    
    func formatHour12(_ timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let date = formatter.date(from: timeString) else { return timeString }
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

struct VibrationEffect: ViewModifier {
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                    withAnimation(Animation.linear(duration: 0.1).repeatCount(3, autoreverses: true)) {
                        offset = 2
                    }

                    // Resetear después de la animación
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        offset = 0
                    }
                }
            }
    }
}

struct MainView: View {
    var body: some View {
        DayScreen()
    }
}

#Preview {
    MainView()
}

