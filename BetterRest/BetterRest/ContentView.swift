//
//  ContentView.swift
//  BetterRest
//
//  Created by Lékan Mabayoje on 2/16/21.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp: Date = defaultWakeTime
    @State private var sleepAmount: Double = 8.0
    @State private var coffeeAmount: Int = 1
    let coffeeRange: ClosedRange<Int> = 1...20
    
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    
    func calculateBedtime() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            let model: SleepCalculator = try SleepCalculator(configuration: MLModelConfiguration())
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            
            let convertedSleepTime = dateFormatter.string(from: sleepTime)
            alertMessage = "Your ideal beadtime is \(convertedSleepTime)"
            alertTitle = "Ideal bedtime"
            
        } catch {
            alertTitle = "System Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
        }
        
        showingAlert = true
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("When would you like to wake up?")) {
                    DatePicker("Enter a time", selection: $wakeUp, displayedComponents: [.hourAndMinute])
                }
                
                Section(header: Text("Desired amount of sleep")) {
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25 ) {
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                }
                
                Section(header: Text("Daily coffee intake")) {
//                    Stepper(value: $coffeeAmount, in: 1...20) {
//                        if coffeeAmount == 1 {
//                            Text("1 cup")
//                        } else {
//                            Text("\(coffeeAmount) cups")
//                        }
//                    }
                    Picker("How many cups", selection: $coffeeAmount) {
                        ForEach(coffeeRange, id: \.self) { amount in
                            if amount == 1 {
                                Text("\(amount) cup")
                            } else {
                                Text("\(amount) cups")
                            }
                        }
                    }
                }
            }
            .navigationTitle("BetterRest")
            .navigationBarItems(trailing:
                Button(action: calculateBedtime) {
                    Text("Calculate")
                }
            )
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}