//
//  ContentView.swift
//  TimesTables
//
//  Created by Ian Bailey on 19/9/2022.
//

import SwiftUI

struct ContentView: View {
    
    @State private var tablesSelection = 5
    
    var body: some View {
        VStack {
            Text("Select a times table to practice")
            Picker("Color Scheme", selection: $tablesSelection) {
                ForEach(2..<13) { i in
                    Image(systemName: "\(i).circle").tag(i)
                        .rotationEffect(Angle(degrees:90))
                }
                
            }
            .pickerStyle(WheelPickerStyle())
            .scaleEffect(2)
            .rotationEffect(Angle(degrees: -90))
            .frame(width:.infinity, height:80)
            .clipped()
            
            Text("5 x 3 = ?").font(.largeTitle)
            Divider()
            Text("InputArea")
            
            //num pad keyboard
            VStack {
                HStack {
                    Button("7️⃣"){}
                    Button("8️⃣"){}
                    Button("9️⃣"){}
                }
                HStack {
                    Button("4️⃣"){}
                    Button("5️⃣"){}
                    Button("6️⃣"){}
                }
                HStack {
                    Button("1️⃣"){}
                    Button("2️⃣"){}
                    Button("3️⃣"){}
                }
                HStack {
                    Button("0️⃣"){}
                    Button("🔙"){}
                    Button("↩️"){}
                }
            }    .font(.system(size: 60))
        }
        
        
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
