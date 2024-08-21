//
//  EditGoalScreen.swift
//  Kartochki
//
//  Created by Darian Lee on 7/29/24.
//

import SwiftUI

struct EditGoalScreen: View {
    @Binding var language: String
    @State var databaseManager: DatabaseManager = DatabaseManager()
    @Environment(AuthManager.self) var authManager
    @State private var mode: String = "minutes"
    @State private var count: Int = 15
    @State private var showTimer: Bool = true
    
    @Binding var showingAlert: Bool
    @Binding var alertTitle: String
    @Binding var alertMessage: String
    
    @Binding var currentView:ViewType
    
    
    var body: some View {
        ZStack{
            Color.black
                            .edgesIgnoringSafeArea(.all)
            VStack {
                Text("Edit goal for deck: " + language)
                    .font(.title)
                
                HStack {
                    Text("I want to study")
                    
                    TextField("15", value: $count, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .frame(width: 40)
                        .padding(3)
                    
                        .background(Color.white)
                        .cornerRadius(5)
                    
                    Picker(selection: $mode, label: Text("").foregroundColor(.white)) {
                        Text("cards").tag("cards")
                        Text("minutes").tag("minutes")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    .cornerRadius(12)
                }
                .padding()
                
                if mode == "minutes" {
                    Toggle(showTimer ? "Show Timer" : "Show Timer", isOn: $showTimer)
                        .padding()
                    Text("If you choose to hide timer, you will still recieve a notification when you have completed your goal. However you will not see the timer on the screen.")
                        .font(.caption)
                }
                
                Button(action: {
                    if let deck = databaseManager.decks.first(where: { $0.name == language })
                    {
                        print(deck)
                        if mode == "cards" && count > deck.count{
                            alertTitle = "Love the ambition; small problem though"
                            alertMessage = "You only have \(deck.count) card(s) available in your current deck. Please pick a goal no higher than this amount"
                            showingAlert = true
                        }
                        if mode == "minutes" && count > 150{
                            
                            alertMessage = "Please select a time goal smnaller than 150 minutes (2.5 hours)"
                            alertTitle = "Love the ambition; small problem though"
                            showingAlert = true
                        }
                }
                        }){
                    Text("Done")
                }
                .padding()
                
                
            }
            .padding()
            .background(Color(UIColor(white: 0.85, alpha: 1.0)))
            .cornerRadius(12)
            .padding()
        }
        
        }
       
    }



