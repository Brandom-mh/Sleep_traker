//
//  ContentView.swift
//  sleep_traker
//
//  Created by Alumno on 03/04/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Button("Hora de acostares"){
                print("button action")
            }.frame(width: 200, height: 150)
            Image("clock")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
