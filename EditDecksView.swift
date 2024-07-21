//
//  EditDecksView.swift
//  Kartochki
//
//  Created by Darian Lee on 7/16/24.
//

import SwiftUI

struct EditDecksView: View {
    @Environment(AuthManager.self) var authManager
    @State var databaseManager: DatabaseManager = DatabaseManager()
    @State private var isDecksViewPresented: Bool = false
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                Text("Edit decks")
                    .bold()
                    .foregroundColor(.white)
                
                Button(action: {
                    isDecksViewPresented.toggle()
                }){
                    Text("Baсk")
                }
                
                
                
                
                
                .frame(maxWidth: .infinity, alignment: .leading)
                
                GeometryReader { geometry in
                    ScrollView {
                        VStack {
                            ForEach(databaseManager.decks, id: \.self) { deck in
                                DeckRowView(deck: deck, edit: true, inLanguages: true)
                                    .padding(.vertical, 15)
                                    .frame(width: geometry.size.width - 10)
                                
                            }
                            Spacer()
                            ForEach(databaseManager.nonLanguages, id: \.self) { nonlanguage in
                                DeckRowView(deck: DeckData(name: nonlanguage, count: 0), edit: true, inLanguages: false)
                                    .padding(.vertical, 15)
                                    .frame(width: geometry.size.width - 10)
                                
                            }
                        }
                        .frame(width: geometry.size.width)
                    }
                }
                .padding(.horizontal, 5)
                
            }
        }
        .fullScreenCover(isPresented: $isDecksViewPresented) {
            DecksView()
            
                
        }
        
    }
}

#Preview {
    EditDecksView()
        .environment(AuthManager())
}

