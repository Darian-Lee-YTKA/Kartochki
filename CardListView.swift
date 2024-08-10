//
//  CardListView.swift
//  Kartochki
//
//  Created by Darian Lee on 7/21/24.
//

import SwiftUI

struct CardListView: View {
    var language: String
    @Environment(AuthManager.self) var authManager
    @State var databaseManager: DatabaseManager = DatabaseManager()
    @State private var isEditCardPresented: Bool = false
    @State private var selectedCard: Card = Card(front: "something went wrong", back: "something went wrong", dueDate: Date(), id: "123", oldInterval: 0)
    @State private var isAddCardPresented: Bool = false
    @State private var isDeckViewPresented: Bool = false
    @State private var PracticeViewsP: Bool = false
    @State var showingAlert = false
    @State var dueOrOverdueCards: [Card] = []
    
    let pinkFullOpacity = Color(red: 255/255, green: 192/255, blue: 203/255)
    @State private var searchText: String = ""
    @State private var filteredCards: [Card] = []
    
    
    
    init(language: String) {
        self.language = language
        databaseManager.getAllCardsInDeck(deckName: language)
    }
    

        var body: some View {
                GeometryReader { geometry in
                    VStack {
                        HStack {
                            
                            Button(action: {
                                isDeckViewPresented.toggle()
                            }) {
                                Image(systemName: "arrow.left")
                                    .resizable()
                                    .frame(width: 30, height: 20)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
//                            Button(action: {
//                                databaseManager.getAllCardsInDeck(deckName: language)
//                            }) {
//                                Text("Manual Refresh")
//                                    .foregroundColor(pinkFullOpacity)
//                            }
//                            Spacer()
                            
                            
                            Button(action: {
                               
                                PracticeViewsP.toggle()
                            })
                                {
                                Image(systemName: "bell")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(pinkFullOpacity)
                                    .padding(4)
                            }
                                
                            Button(action: {
                                isAddCardPresented.toggle()
                            }) {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(pinkFullOpacity)
                                    .padding(4)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        
                        VStack {
                            Text(selectedCard.front)
                              .foregroundColor(.black)
                            TextField("Search...", text: $searchText)
                                .foregroundColor(.white)
                                .padding(3.5)
                                .background(Color.white.opacity(0.2))
                                //.foregroundColor(.white)
                                .cornerRadius(8)
                                .padding(.horizontal)
                                .onChange(of: searchText) { oldValue, newValue in
                                    filteredCards = databaseManager.AllCards.filter { card in
                                        card.front.localizedCaseInsensitiveContains(newValue) ||
                                        card.back.localizedCaseInsensitiveContains(newValue)
                                    }
                                }
                            
                            ScrollView {
                                
                                ForEach(searchText.isEmpty ? databaseManager.AllCards : filteredCards, id: \.self) { card in
                                    Button(action: {
                                        selectedCard = card
                                        print("this was the card you selected!", selectedCard)
                                        isEditCardPresented.toggle()
                                    }) {
                                        CardListRow(card: card)
                                    }
                                }
                            }
                            .fullScreenCover(isPresented: $isEditCardPresented) {
                                
                                    EditCardView(language: language, existingCard: selectedCard)
                                    .environment(authManager)
                                    
                                
                            }
                            .background(Color.black)
                            .edgesIgnoringSafeArea(.all)
                        }
                        .background(Color.black)
                    }
                    .background(Color.black)
                    
                    .sheet(isPresented: $isAddCardPresented) {
                                CreateOrGetSuggestionsView(language: language)
                        
                            
                    }
                    .background(Color.black.edgesIgnoringSafeArea(.all))
                    .fullScreenCover(isPresented: $isDeckViewPresented) {
                        DecksView()
                            .environment(authManager)
                    }
                    .fullScreenCover(isPresented: $PracticeViewsP) {
                        ParentView(language: language)
                        
                            
                    }
                    
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("I have no idea why but..."), message: Text("For some reason xcode doesn't know what card you clicked. Was it not '" + (selectedCard.front) + "'"), dismissButton: .default(Text("OK")))
                    }
                }
            }
        
        }

struct CardListRow: View {
    
    var card: Card
    let pinkFullOpacity = Color(red: 255/255, green: 192/255, blue: 203/255)
    init(card: Card) {
        self.card = card
    }

    var body: some View {
            VStack(alignment: .leading, spacing: 2) { 
                Text(card.front)
                    .font(.body)
                    .foregroundColor(pinkFullOpacity)
                    .lineLimit(1)
                
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 1)
                
                Text(card.back)
                    .font(.body)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(7)
            
            
        
        }
    }

 


