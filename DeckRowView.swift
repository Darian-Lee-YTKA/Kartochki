//
//  DeckRowView.swift
//  Kartochki
//
//  Created by Darian Lee on 6/14/24.
//

import SwiftUI

struct DeckRowView: View {
    @State var databaseManager: DatabaseManager = DatabaseManager()
    @State var showingAlert = false
    @State private var isCardCreatePresented: Bool = false
    
    let veryLightGrey = Color(red: 0.85, green: 0.85, blue: 0.85)
    
    var edit: Bool = false
    var inLanguages: Bool = false
  
    var deck: DeckData
    init(deck: DeckData, edit: Bool = false, inLanguages: Bool = false){
        
        self.deck = deck
        self.edit = edit
        self.inLanguages = inLanguages
        self.databaseManager.getLanguages()
        //databaseManager.getOverdueCards(deckName: deck.name)
        self.databaseManager.getDeckData()
        
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Text(deck.emoji)
                    .font(.system(size: 45))
                    .multilineTextAlignment(.leading)
                
                VStack(alignment: .leading) {
                    Text(deck.name)
                        .bold()
                    HStack{
                        Text("due: \(databaseManager.dueCount),")
                            .foregroundColor(Color(red: 0.8, green: 0.1, blue: 0.1))
                        Text("total:  \(deck.count)")
                    }
                    .font(.system(size: 15))
                    
                }
                
                Spacer()
                
                if !edit {
                    Button(action: {
                        isCardCreatePresented.toggle()
                    }) {
                        Image(systemName: "arrow.right")
                            .padding()
                    }
                }
                
                if edit && inLanguages {
                    Button(action: {
                        showingAlert = true
                        
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.red)
                        
                        
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(
                            title: Text("😧⁉️ Are you sure? ⁉️😧"),
                            message: Text("Deleting this language will delete all the flashcards associated with it. This action CANNOT be undone."),
                            primaryButton: .destructive(Text("Delete forever")) {
                                print("🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈🏳️‍🌈 we are trying to delete: ", deck.name)
                                databaseManager.deleteLanguageAndDeck(language: deck.name) { error in
                                    if let error = error {
                                        
                                        print("Error deleting language and deck: \(error.localizedDescription)")
                                    } else {
                                        
                                        print("Successfully deleted language and deck")
                                        databaseManager.getLanguages()
                                        databaseManager.getDeckData()
                                    }
                                }
                                
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                
                if edit && !inLanguages {
                    Button(action: {
                        let language = deck.name
                        databaseManager.setLanguages(languages: [language]) { error in
                            if let error = error {
                                print("Error adding room: \(error.localizedDescription)")
                            }
                        }
                        
                        databaseManager.createDeck(language: language){ error in
                            if let error = error {
                                print("Error adding room: \(error.localizedDescription)")
                            }
                            
                            
                        }
                        databaseManager.getLanguages()
                        databaseManager.getDeckData()
                        
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 30))
                        
                        
                    }
                }
            }
            .padding()
            .background(veryLightGrey)
            .frame(width: geometry.size.width * 0.9, height: 80, alignment: .topLeading)
            .cornerRadius(20)
            .frame(width: geometry.size.width - 2, alignment: .center)
        }
        .padding(.vertical, 20)
//        .fullScreenCover(isPresented: $isCardCreatePresented) {
//            CardCreateView(translationLanguage: self.deck.name, deck: self.deck)
//        }
        
        .fullScreenCover(isPresented: $isCardCreatePresented) {
            CardListView(language: self.deck.name)
                .environment(AuthManager())
        }
        .onAppear {
            databaseManager.fetchDueNumber(language: deck.name)
        }
        
        
    }
}


struct DeckRowView_Previews: PreviewProvider {
    static var previews: some View {
     
        let sampleDeck = DeckData(name: "Spanish", count: 20, dueCount: 5)
        
       
        DeckRowView(deck: sampleDeck, edit: false, inLanguages: true)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
