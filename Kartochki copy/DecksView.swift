//
//  DecksView.swift
//  Kartochki
//
//  Created by Darian Lee on 6/13/24.
//

import SwiftUI

struct DecksView: View {
    @Environment(AuthManager.self) var authManager
    @State var databaseManager: DatabaseManager = DatabaseManager()
    @State private var opacity1: Double = 0
    @State private var opacity2: Double = 0
    @State private var opacity3: Double = 0
    @State private var isEditDecksViewPresented: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    VStack {
                        if let pic = databaseManager.languages.randomElement() {
                            Image(pic)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: geometry.size.height * 0.45)
                                .frame(width: geometry.size.width + 7)
                                .clipped()
                                .edgesIgnoringSafeArea(.top)
                               
                            let message = databaseManager.getWelcomeMessage(language: pic)
                            let name = databaseManager.name
                            
                            Text("\(message) \(name)")
                                .foregroundColor(.white)
                        } else {
                            Text("No picture found")
                                .foregroundColor(.white)  
                        }
                        
                    }
                    .opacity(opacity1)
                    .onAppear {
                        withAnimation(Animation.easeOut(duration: 3).delay(2)) {
                            opacity1 = 1
                        }
                    }
                    
                    ScrollView {
                        ForEach(databaseManager.decks, id: \.self) { deck in
                            DeckRowView(deck: deck)
                                .padding(.vertical, 15)
                                .frame(width: geometry.size.width - 10)
                        }
                    }
                    .opacity(opacity2)
                    .onAppear {
                        withAnimation(Animation.easeOut(duration: 1).delay(1.5)) {
                            opacity2 = 1
                        }
                    }
                    .padding(.horizontal, 10)
                }
                
                HStack {
                    Button(action: {
                        authManager.signOut()
                    }) {
                        Text("Log Out")
                            .padding(15)
                            .font(.system(size: 14))
                            .bold()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.leading, 10)
                    
                    Spacer()
                    
                    Button(action: {
                        isEditDecksViewPresented.toggle()
                    }) {
                        Text("Edit")
                            .padding(15)
                            .font(.system(size: 14))
                            .bold()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.trailing, 10)
                }
                .opacity(opacity3)
                .onAppear {
                    withAnimation(Animation.easeOut(duration: 1).delay(1.5)) {
                        opacity3 = 1
                    }
                }
                .padding(.top, geometry.safeAreaInsets.top - 50)
                .frame(width: geometry.size.width - 10)
            }
        }
        .fullScreenCover(isPresented: $isEditDecksViewPresented) {
            EditDecksView()
               
        }
    }
}
