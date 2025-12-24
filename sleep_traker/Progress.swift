//
//  Progress.swift
//  sleep_traker
//
//  Created by Emilio Contreras on 04/04/25.
//

import SwiftUI
@MainActor
class StarProgressModel: ObservableObject {
    @AppStorage("Nombre")  var Nombre: String = ""
    @AppStorage("Edad") var newUser: Int = 0

    
    @AppStorage("HoraAsignadaDormir") var HoraAsignadaDormir: Date = Date() {
        didSet { updateHoraAsignadaDormir()
           }
    }
    @AppStorage("HoraAsignadaDespertar") var HoraAsignadaDespertar: Date = Date(){
        didSet { updateHoraAsignadaDespertar() }
    }
    @AppStorage("UltimaHoraAmanecida") var UltimaHoraAmanecida: Date = Date() {
        didSet { updateUltimaHoraAmanecida() }
    }
    @AppStorage("ModoNight") var ModoNight: Bool = false
    
    @AppStorage("Relajacion") var Relajacion: Date = Date()
    
    @AppStorage("Tono") var tono: AlarmaEnum = .clasico
    
  
    
    
   /* @Published var tasks: [StudyTask] = [] {
        didSet { saveTasks() }
    }
    @Published var chunkingWords: [ChunkingWord] = [] {
        didSet { saveChunkingData() }
    }
    @Published var pomodorosProgress: [PomodorosProgress] = [] {
        didSet { savePomodorosProgress() }
    }
    @Published var lastPomodoroConfiguration: PomodoroConfiguration? {
        didSet { saveLastPomodoroConfiguration() }
    }
    private var lastAccessoryState: (hat: Bool, glasses: Bool, tie: Bool) = (false, false, false)
    
    private func updateAnyStarComplete() {
        DispatchQueue.main.async {
            let newValue = self.star1CompleteStudy || self.star2CompleteStudy || self.star3CompleteStudy || self.star4CompleteStudy ||
                           self.star1CompleteOrga || self.star2CompleteOrga || self.star3CompleteOrga || self.star4CompleteOrga ||
                           self.star1CompleteMemo || self.star2CompleteMemo || self.star3CompleteMemo

            let hatUnlocked = self.star1CompleteMemo
            let glassesUnlocked = self.star1CompleteStudy || self.star4CompleteStudy
            let tieUnlocked = self.star1CompleteOrga && self.star2CompleteOrga

            let newAccessoryState = "\(hatUnlocked)-\(glassesUnlocked)-\(tieUnlocked)"

            if newValue != self.anyStarComplete {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.anyStarComplete = newValue
                    self.showProgress = newValue
                    self.showItems = newValue // ✅ Ahora `showItems` se actualiza también
                    print("📦 showItems actualizado en updateAnyStarComplete: \(self.showItems)")
                }
            }

            if newAccessoryState != self.lastAccessoryStateStored {
                self.shakeProgress = true
                print("🎉 Nuevo accesorio desbloqueado → shakeProgress activado!")
                self.lastAccessoryStateStored = newAccessoryState
            }

            self.objectWillChange.send()
            self.updateAreRequiredStarsComplete()

            print("🔄 Estado actualizado: anyStarComplete: \(self.anyStarComplete), showProgress: \(self.showProgress), showItems: \(self.showItems)")
        }
    }*/
    
    init() {
        loadNombre()
        loadEdad()
        loadHoraAsignadaDormir()
        loadHoraAsignadaDespertar()
        loadModoNight()
        loadRelajacion()
        loadTono()
        loadUltimaHoraAmanecida()
    }

    func updateHoraAsignadaDormir() {
        saveHoraAsignadaDormir()
        print("🌙 HoraAsignadaDormir actualizada y guardada: \(HoraAsignadaDormir)")
    }

    func updateHoraAsignadaDespertar() {
        saveHoraAsignadaDespertar()
        print("⏰ HoraAsignadaDespertar actualizada y guardada: \(HoraAsignadaDespertar)")
    }

    func updateModoNight(_ nuevoEstado: Bool) {
        self.ModoNight = nuevoEstado
        saveModoNight()
        print("🌗 ModoNight actualizado: \(ModoNight)")
    }

    func updateRelajacion(_ nuevoValor: Date) {
        self.Relajacion = nuevoValor
        saveRelajacion()
        print("🧘 Relajacion actualizada: \(Relajacion)")
    }

    func updateTono(_ nuevoTono: AlarmaEnum) {
        self.tono = nuevoTono
        saveTono()
        print("🔔 Tono actualizado: \(tono)")
    }
    
    func updateUltimaHoraAmanecida() {
        self.UltimaHoraAmanecida = self.UltimaHoraAmanecida
        print("🌅 UltimaHoraAmanecida actualizada: \(UltimaHoraAmanecida)")
    }

    private func loadNombre() {
        if let nombre = UserDefaults.standard.string(forKey: "Nombre") {
            self.Nombre = nombre
        }
    }

    private func loadEdad() {
        self.newUser = UserDefaults.standard.integer(forKey: "Edad")
    }

    private func loadHoraAsignadaDormir() {
        if let data = UserDefaults.standard.object(forKey: "HoraAsignadaDormir") as? Data,
           let date = try? JSONDecoder().decode(Date.self, from: data) {
            self.HoraAsignadaDormir = date
        }
    }

    private func loadHoraAsignadaDespertar() {
        if let data = UserDefaults.standard.object(forKey: "HoraAsignadaDespertar") as? Data,
           let date = try? JSONDecoder().decode(Date.self, from: data) {
            self.HoraAsignadaDespertar = date
        }
    }

    private func loadModoNight() {
        self.ModoNight = UserDefaults.standard.bool(forKey: "ModoNight")
    }

    private func loadRelajacion() {
        if let data = UserDefaults.standard.object(forKey: "Relajacion") as? Data,
           let date = try? JSONDecoder().decode(Date.self, from: data) {
            self.Relajacion = date
        }
    }

    private func loadTono() {
        if let data = UserDefaults.standard.data(forKey: "Tono"),
           let tonoDecoded = try? JSONDecoder().decode(AlarmaEnum.self, from: data) {
            self.tono = tonoDecoded
        }
    }

     func loadUltimaHoraAmanecida() {
        if let data = UserDefaults.standard.object(forKey: "UltimaHoraAmanecida") as? Data,
           let date = try? JSONDecoder().decode(Date.self, from: data) {
            self.UltimaHoraAmanecida = date
        }
    }

     func saveNombre() {
        UserDefaults.standard.set(Nombre, forKey: "Nombre")
    }

     func saveEdad() {
        UserDefaults.standard.set(newUser, forKey: "Edad")
    }

     func saveHoraAsignadaDormir() {
        do {
            let data = try JSONEncoder().encode(HoraAsignadaDormir)
            UserDefaults.standard.set(data, forKey: "HoraAsignadaDormir")
        } catch {
            print("Error al guardar HoraAsignadaDormir:", error)
        }
    }

     func saveHoraAsignadaDespertar() {
        do {
            let data = try JSONEncoder().encode(HoraAsignadaDespertar)
            UserDefaults.standard.set(data, forKey: "HoraAsignadaDespertar")
        } catch {
            print("Error al guardar HoraAsignadaDespertar:", error)
        }
    }

     func saveModoNight() {
        UserDefaults.standard.set(ModoNight, forKey: "ModoNight")
    }

     func saveRelajacion() {
        do {
            let data = try JSONEncoder().encode(Relajacion)
            UserDefaults.standard.set(data, forKey: "Relajacion")
        } catch {
            print("Error al guardar Relajacion:", error)
        }
    }

    private func saveTono() {
        do {
            let data = try JSONEncoder().encode(tono)
            UserDefaults.standard.set(data, forKey: "Tono")
        } catch {
            print("Error al guardar tono:", error)
        }
    }

    private func saveUltimaHoraAmanecida() {
        do {
            let data = try JSONEncoder().encode(UltimaHoraAmanecida)
            UserDefaults.standard.set(data, forKey: "UltimaHoraAmanecida")
        } catch {
            print("Error al guardar UltimaHoraAmanecida:", error)
        }
    }
    
    func resetHorasAsignadas() {
        HoraAsignadaDormir = Date.distantPast
        HoraAsignadaDespertar = Date.distantPast
        saveHoraAsignadaDormir()
        saveHoraAsignadaDespertar()
        print("🗑️ Horas asignadas reseteadas")
    }

    func horasAsignadasExisten() -> Bool {
        let referencia = Date.distantPast
        return HoraAsignadaDormir != referencia || HoraAsignadaDespertar != referencia
    }
}
