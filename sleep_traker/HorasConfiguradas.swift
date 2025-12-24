//
//  HorasConfiguradas.swift
//  sleep_traker
//
//  Created by Emilio Contreras on 04/04/25.
//

import SwiftUI

struct HorasConfiguradas: View {
    @StateObject private var progressModel = StarProgressModel()
    var isNight: Bool = false
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var hora: String {
        let date = isNight ? progressModel.HoraAsignadaDespertar : progressModel.HoraAsignadaDormir
        return formatter.string(from: date)
    }

    var body: some View {
        GeometryReader { geometry in
            let iconSize = min(geometry.size.width * 0.2, 80)
            let horizontalPadding = geometry.size.width * 0.08

            VStack(spacing: 15) {
                Image(systemName: isNight ? "moon.fill" : "sun.max.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)

                Text(isNight ? "¡Hora de despertar confirmada!" : "¡Hora de dormir confirmada!")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)

                Text(!isNight ? "Hora para dormir: \(formatter.string(from: progressModel.HoraAsignadaDormir))" : "Hora para despertar: \(formatter.string(from: progressModel.HoraAsignadaDespertar))")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.top, 5)

                Text(isNight ? "Hora para dormir: \(formatter.string(from: progressModel.HoraAsignadaDormir))" : "Hora para despertar: \(formatter.string(from: progressModel.HoraAsignadaDespertar))")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: min(geometry.size.width * 0.85, 400))
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isNight ? Color(hex: "219EBC").opacity(0.9) : Color.orange.opacity(0.9))
                    .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
            )
            .padding(.horizontal, horizontalPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    HorasConfiguradas()
}
