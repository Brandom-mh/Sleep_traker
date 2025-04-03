//
//  vistaNoche.swift
//  sleep_traker
//
//  Created by Alumno on 03/04/25.
//

//
//  ContentView.swift
//  sleep_traker
//
//  Created by Alumno on 03/04/25.
//

import SwiftUI

struct vistaNoche: View {
    var body: some View {
        VStack (spacing:100){
                
            Image("clock")
            Text("Quiero acostarme a:").font(.system(size: 40, design: .rounded))
            HStack{
                botonNoche(nombre:"Hora", color: Color (hex: "8ECAE6"))
                botonNoche(nombre: "Minutos", color: Color(hex: "8ECAE6"))
               
            }
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct botonNoche: View {
    var nombre:String=""
    var color:Color
    var body: some View{
        
        HStack{
                Button(action:{print("button1")}, label:
                        {Text(nombre).foregroundColor(.white)
                    .font(.system(size: 40))})
                .frame(width: 150, height: 100)
                .background(color)
                .cornerRadius(30)
            
        }
    }
    
}

struct textosNoche {
    var info:String=""
    var body: some View{
        VStack{
            Text(info)
                .frame(width: 300,height: 150)
                .background(.blue)
                .bold()
                .cornerRadius(30)
                .padding()
                .font(.system(size: 40,design: .rounded))
            }
        }
}


#Preview {
    vistaNoche()
}
