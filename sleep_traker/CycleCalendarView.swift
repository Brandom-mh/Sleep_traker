import SwiftUI

struct CycleCalendarView: View {
    let dias = ["1", "2", "3", "4", "5"]
    
    // Simulación: niveles por celda (3: ideal, 2: aceptable, 1: emergencia, 0: no cumplido)
    let ciclosCumplidos: [[Int]] = [
        [3, 2, 1, 0, 0],
        [3, 2, 1, 0, 0],
        [3, 2, 1, 0, 0],
        [3, 2, 1, 0, 0],
        [3, 2, 0, 0, 0]
    ]
    
    // Fechas ficticias (hoy y los 24 días anteriores)
    let fechas: [String] = {
        let calendar = Calendar.current
        let today = Date()
        return (0..<25).map {
            let date = calendar.date(byAdding: .day, value: -$0, to: today)!
            let day = Calendar.current.component(.day, from: date)
            return "\(day)"
        }.reversed()
    }()
    
    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.width < 400
            let titleSize = min(geometry.size.width * 0.07, 28)
            let subtitleSize = min(geometry.size.width * 0.045, 18)
            let cellHeight = max(geometry.size.height * 0.055, 40)
            let legendSize = min(geometry.size.width * 0.07, 30)

            VStack(spacing: geometry.size.height * 0.02) {
                Text("Calendario de ciclos")
                    .font(.system(size: titleSize, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)

                Text("Racha de ciclo ideal")
                    .font(.system(size: subtitleSize, design: .rounded))
                    .foregroundColor(.gray)

                Text("3 días")
                    .font(.system(size: subtitleSize * 0.9, design: .rounded))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)

                // Grid de 5x5 con fecha y color
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: geometry.size.width * 0.02), count: 5), spacing: geometry.size.height * 0.012) {
                    ForEach(0..<5) { row in
                        ForEach(0..<5) { column in
                            let index = row * 5 + column
                            let ciclo = ciclosCumplidos[row][column]
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(colorForLevel(ciclo))
                                    .frame(height: cellHeight)

                                Text(fechas[index])
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .padding(4)
                            }
                        }
                    }
                }
                .padding(.top, 10)

                // Leyenda - stack vertical en pantallas pequeñas
                if isCompact {
                    VStack(spacing: 12) {
                        legend(color: Color(hex: "#023E8A"), text: "Ciclo ideal", size: legendSize)
                        legend(color: Color(hex: "#48CAE4"), text: "Ciclo aceptable", size: legendSize)
                        legend(color: Color(hex: "#CAF0F8"), text: "Ciclo emergencia", size: legendSize)
                    }
                    .padding(.top, 15)
                } else {
                    HStack(spacing: geometry.size.width * 0.06) {
                        legend(color: Color(hex: "#023E8A"), text: "Ciclo ideal", size: legendSize)
                        legend(color: Color(hex: "#48CAE4"), text: "Ciclo aceptable", size: legendSize)
                        legend(color: Color(hex: "#CAF0F8"), text: "Ciclo emergencia", size: legendSize)
                    }
                    .padding(.top, 20)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 3: return Color(hex: "#023E8A")  // Ideal
        case 2: return Color(hex: "#48CAE4")  // Aceptable
        case 1: return Color(hex: "#CAF0F8")  // Emergencia
        default: return Color.gray.opacity(0.3)  // No cumplido
        }
    }
    
    func legend(color: Color, text: String, size: CGFloat = 30) -> some View {
        VStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 5)
                .fill(color)
                .frame(width: size, height: size)
            Text("Cumpliste con tu\n\(text)")
                .font(.system(size: size * 0.4))
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    CycleCalendarView()
}

