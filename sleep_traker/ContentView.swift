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
            Text("Quiero acostarme a:")
            HStack{
                Button(action:{print("button1")}, label:
                        {Text("Hora")}).frame(width: 150, height: 100)
                Button(action:{print("button1")}, label:
                        {Text("Minuto")}).frame(width: 150, height: 100)
                
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
