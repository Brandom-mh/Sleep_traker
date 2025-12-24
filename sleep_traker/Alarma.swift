import SwiftUI
import AVFoundation
import UIKit

// MARK: - Audio Player (Global)
var reproductor: AVAudioPlayer?

func reproducirTono(nombre: String) {
    if let url = Bundle.main.url(forResource: nombre, withExtension: "mp3") {
        do {
            reproductor = try AVAudioPlayer(contentsOf: url)
            reproductor?.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                reproductor?.stop()
            }
        } catch {
            print("Error al reproducir el sonido \(nombre): \(error.localizedDescription)")
        }
    }
}

func detenerTono() {
    reproductor?.stop()
    reproductor = nil
}

// MARK: - Waveform View (Audio Visualizer)
struct WaveformView: View {
    let isAnimating: Bool
    let barCount: Int
    let color: Color

    init(isAnimating: Bool, barCount: Int = 5, color: Color = .orange) {
        self.isAnimating = isAnimating
        self.barCount = barCount
        self.color = color
    }

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { index in
                WaveformBar(
                    isAnimating: isAnimating,
                    delay: Double(index) * 0.1,
                    color: color
                )
            }
        }
    }
}

struct WaveformBar: View {
    let isAnimating: Bool
    let delay: Double
    let color: Color

    @State private var height: CGFloat = 0.3

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 4, height: isAnimating ? height * 20 : 6)
            .animation(
                isAnimating ?
                    Animation.easeInOut(duration: 0.4)
                        .repeatForever(autoreverses: true)
                        .delay(delay) : .default,
                value: isAnimating
            )
            .onAppear {
                if isAnimating {
                    height = CGFloat.random(in: 0.5...1.0)
                }
            }
            .onChange(of: isAnimating) { _, newValue in
                if newValue {
                    height = CGFloat.random(in: 0.5...1.0)
                }
            }
    }
}

// MARK: - Circular Time Slider
struct CircularTimeSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double

    @State private var isDragging = false

    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)

    init(value: Binding<Double>, range: ClosedRange<Double> = 5...59, step: Double = 1) {
        self._value = value
        self.range = range
        self.step = step
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = size * 0.38
            let lineWidth: CGFloat = size * 0.06

            ZStack {
                // Background track
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: lineWidth)
                    .frame(width: radius * 2, height: radius * 2)

                // Progress arc
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            colors: [Color.orange, Color.orange.opacity(0.6)],
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .frame(width: radius * 2, height: radius * 2)
                    .rotationEffect(.degrees(-90))

                // Tick marks every 5 minutes
                ForEach(0..<12, id: \.self) { index in
                    let tickAngle = Double(index) * 30 - 90
                    let tickRadius = radius + lineWidth / 2 + 8
                    let x = cos(tickAngle * .pi / 180) * tickRadius
                    let y = sin(tickAngle * .pi / 180) * tickRadius

                    Circle()
                        .fill(Color.white.opacity(index <= Int(progress * 12) ? 0.8 : 0.3))
                        .frame(width: 4, height: 4)
                        .offset(x: x, y: y)
                }

                // Knob
                Circle()
                    .fill(Color.white)
                    .frame(width: lineWidth + 8, height: lineWidth + 8)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .offset(x: knobOffset(radius: radius).x, y: knobOffset(radius: radius).y)
                    .scaleEffect(isDragging ? 1.15 : 1.0)
                    .animation(.spring(response: 0.3), value: isDragging)

                // Center display
                VStack(spacing: 2) {
                    Text("\(Int(value))")
                        .font(.system(size: size * 0.18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("min")
                        .font(.system(size: size * 0.07, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }

                // Label at bottom
                Text("Tiempo de relajacion")
                    .font(.system(size: size * 0.055, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .offset(y: radius + lineWidth + 25)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        isDragging = true
                        let vector = CGVector(
                            dx: gesture.location.x - center.x,
                            dy: gesture.location.y - center.y
                        )
                        let angle = atan2(vector.dy, vector.dx) + .pi / 2
                        let normalizedAngle = angle < 0 ? angle + 2 * .pi : angle
                        let newProgress = normalizedAngle / (2 * .pi)
                        let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * newProgress
                        let clampedValue = min(max(newValue, range.lowerBound), range.upperBound)
                        let steppedValue = (clampedValue / step).rounded() * step

                        // Haptic feedback every 5 minutes
                        if Int(steppedValue) % 5 == 0 && Int(value) % 5 != 0 {
                            lightFeedback.impactOccurred()
                        }

                        value = steppedValue
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
        }
    }

    private var progress: CGFloat {
        CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
    }

    private func knobOffset(radius: CGFloat) -> CGPoint {
        let angle = progress * 2 * .pi - .pi / 2
        return CGPoint(
            x: cos(angle) * radius,
            y: sin(angle) * radius
        )
    }
}

// MARK: - Tone Preview Card
struct TonePreviewCard: View {
    let toneName: String
    let isSelected: Bool
    let isPlaying: Bool
    let onTap: () -> Void
    let onPlayToggle: () -> Void

    private let mediumFeedback = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        Button(action: {
            mediumFeedback.impactOccurred()
            onTap()
        }) {
            HStack(spacing: 12) {
                // Music icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.orange : Color.white.opacity(0.2))
                        .frame(width: 36, height: 36)

                    Image(systemName: "music.note")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                }

                // Tone name and waveform
                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    if isPlaying {
                        WaveformView(isAnimating: true, barCount: 8, color: .orange)
                            .frame(height: 12)
                    } else {
                        WaveformView(isAnimating: false, barCount: 8, color: .white.opacity(0.3))
                            .frame(height: 12)
                    }
                }

                Spacer()

                // Play button
                Button(action: {
                    onPlayToggle()
                }) {
                    ZStack {
                        Circle()
                            .fill(isPlaying ? Color.orange : Color.white.opacity(0.15))
                            .frame(width: 36, height: 36)

                        Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                }

                // Checkmark for selected
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(isSelected ? 0.15 : 0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.orange.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var displayName: String {
        switch toneName {
        case "Alarma Jungle": return "Jungle"
        case "Chiptune Alarm Clock": return "Chiptune"
        case "Sonido de alarma lofi": return "Lo-Fi"
        default: return toneName
        }
    }
}

// MARK: - Main Alarma View
struct Alarma: View {
    @State private var tiempoRelajacion: Double = 30
    @State private var tonoSeleccionado = "Alarma Jungle"
    @State private var tonoReproduciendo: String? = nil
    @State private var appearAnimation = false

    let tonos = ["Alarma Jungle", "Chiptune Alarm Clock", "Sonido de alarma lofi"]

    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.height < 600

            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [
                        Color(hex: "0D1B2A"),
                        Color(hex: "1B263B"),
                        Color(hex: "415A77")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Decorative circles
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: geometry.size.width * 0.8)
                    .blur(radius: 60)
                    .offset(x: -geometry.size.width * 0.3, y: -geometry.size.height * 0.2)

                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: geometry.size.width * 0.6)
                    .blur(radius: 50)
                    .offset(x: geometry.size.width * 0.3, y: geometry.size.height * 0.3)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: isCompact ? 16 : 24) {
                        // Title
                        VStack(spacing: 4) {
                            Text("Configura tu Alarma")
                                .font(.system(size: geometry.size.width * 0.065, weight: .bold))
                                .foregroundColor(.white)

                            Text("Personaliza como quieres despertar")
                                .font(.system(size: geometry.size.width * 0.035))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, geometry.safeAreaInsets.top > 0 ? 10 : 20)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)

                        // Circular Slider Card
                        VStack {
                            CircularTimeSlider(value: $tiempoRelajacion, range: 5...59)
                                .frame(height: isCompact ? geometry.size.height * 0.28 : geometry.size.height * 0.32)
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 10)
                        .glassCard()
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 30)

                        // Tone Selector Card
                        VStack(spacing: 14) {
                            HStack {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(.orange)
                                Text("Elige tu tono")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                            }

                            ForEach(tonos, id: \.self) { tono in
                                TonePreviewCard(
                                    toneName: tono,
                                    isSelected: tonoSeleccionado == tono,
                                    isPlaying: tonoReproduciendo == tono,
                                    onTap: {
                                        tonoSeleccionado = tono
                                    },
                                    onPlayToggle: {
                                        togglePlayTono(tono)
                                    }
                                )
                            }
                        }
                        .padding(16)
                        .glassCard()
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 40)

                        // Decorative clock
                        if !isCompact {
                            AnimatedClockView(size: geometry.size.width * 0.12)
                                .opacity(0.4)
                                .padding(.top, 10)
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appearAnimation = true
            }
        }
        .onDisappear {
            detenerTono()
            tonoReproduciendo = nil
        }
    }

    private func togglePlayTono(_ tono: String) {
        if tonoReproduciendo == tono {
            detenerTono()
            tonoReproduciendo = nil
        } else {
            detenerTono()
            tonoReproduciendo = tono
            reproducirTono(nombre: tono)

            // Auto-stop after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if tonoReproduciendo == tono {
                    tonoReproduciendo = nil
                }
            }
        }
    }
}

#Preview {
    Alarma()
}

// MARK: - Animated Clock View
struct AnimatedClockView: View {
    var size: CGFloat? = nil

    @State private var currentFrame = 0
    let totalFrames = 241
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        Image(String(format: "Reloj_%05d", currentFrame))
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .onReceive(timer) { _ in
                currentFrame = (currentFrame + 1) % totalFrames
            }
    }
}
