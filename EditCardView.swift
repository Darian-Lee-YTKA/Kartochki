//
//  EditCardView.swift
//  Kartochki
//
//  Created by Darian Lee on 7/21/24.
//

import SwiftUI

struct EditCardView: View {
 
    @Environment(AuthManager.self) var authManager
    @State var databaseManager: DatabaseManager = DatabaseManager()
    @State var apiManager: ApiManager = ApiManager()
    @State var front: String = ""
    @State var back: String = ""
    @State var translationOutput: String = "Back"
    @State var translationLanguage: String = "English"
    @State var inputLanguage: String = "English"
    @State var showMoreInputLanguage: String = "Afrikaans"
    @State private var showMoreLanguagesPicker: Bool = false
    @State private var selectedMoreLanguage: String = "Afrikaans"
    @State var showingAlert = false
    @State var takeMeBack: Bool = false
    
    
    let language: String
    
    let pinkFullOpacity = Color(red: 255/255, green: 192/255, blue: 203/255)

    var existingCard: Card

    init(language: String, existingCard: Card) {
        self.language = language
        self.existingCard = existingCard
   
        self.front = existingCard.front
        self.back = existingCard.back
        print("in edit card view")
    }

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    takeMeBack.toggle()
                }) {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .frame(width: 30, height: 20)
                        .foregroundColor(.white)
                }

                Spacer()

                Button(action: {
                    
                    guard !front.isEmpty && !back.isEmpty else {
                            
                            showingAlert.toggle()
                            return
                        }
                    
                    
                    var editedCard = existingCard
                    editedCard.front = front
                    editedCard.back = back
                    databaseManager.editCardInDeck(deckName: language, editedCard: editedCard) { error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            print("success")
                            takeMeBack.toggle()
                        }
                    }
                }) {
                    Text("Update")
                        .foregroundColor(pinkFullOpacity)
                }
            }
            
            Text("Edit card in " + language)
                .font(.title)
                .padding()
                .foregroundColor(.white)
            
            TextField("Front text", text: $front, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onAppear {
                    front = existingCard.front
                    back = existingCard.back
                }

            if showMoreLanguagesPicker {
                MoreLanguagesPicker(selectedLanguage: $selectedMoreLanguage, selectedInputLanguage: $showMoreInputLanguage, userLanguages: databaseManager.languages + ["English"])
                    .padding()
            }

            HStack {
                Button(action: {
                    var langForAPI: String = "English"
                    var inputForAPI: String = "English"
                    print("hit button")
                    
                    if translationLanguage == "more" {
                        langForAPI = selectedMoreLanguage
                        inputForAPI = showMoreInputLanguage
                    } else {
                        langForAPI = translationLanguage
                        inputForAPI = inputLanguage
                    }
                    
                    Task {
                        do {
                            print("Pressed button")
                            back = try await apiManager.getTranslation(translationLanguage: langForAPI, inputText: front, inputLanguage: inputForAPI)
                        } catch {
                            
                            print("Error: \(error)")
                        }
                    }
                }) {
                    HStack {
                        Text("Translate back")
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(pinkFullOpacity)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                }
                

                Picker(selection: $translationLanguage, label: Text("Language")) {
                    Text("En to " + language).tag(language)
                    Text(language + " to En").tag("English")
                    Text("See more options").tag("more")
                }
                .tint(pinkFullOpacity)
                .onChange(of: translationLanguage) { oldValue, newValue in
                    if newValue == "more" {
                        showMoreLanguagesPicker = true
                    } else {
                        showMoreLanguagesPicker = false
                    }
                    if newValue == language {
                        inputLanguage = "English"
                        translationLanguage = language
                    }
                    if newValue == "English" {
                        inputLanguage = language
                        translationLanguage = "English"
                    }
                }
                .onAppear {
                    inputLanguage = "English"
                    translationLanguage = language
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal)
            }
            Button(action: {
                let temp = front
                front = back
                back = temp
                
                
            }){
                HStack{
                    Text("Swap")
                        .foregroundColor(pinkFullOpacity)
                    Image(systemName: "arrow.right.arrow.left")
                        .foregroundColor(pinkFullOpacity)
                }
            }
            .padding()
            
            TextField("Back text", text: $back, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .frame(minHeight: 50)
            
            Text("(Or type your own front and back in the box)")
                .foregroundColor(.white)
                .font(.caption)
            
            
            
            Spacer()
            
            Button(action: {
                databaseManager.deleteCard(deckName: language, deleteCard: existingCard){
                    error in 
                    if let error = error{
                        print("unable to delete")
                        print(error)
                    }
                    else{
                        print("success")
                    }
                }
            }) {
                HStack{
                    Text("Delete card")
                        .foregroundColor(.red)
                    Image(systemName: "minus.circle.fill")                }
                                    //.padding()
                                    //.background(Color.red)
                                    .foregroundColor(.red)
                                    //.cornerRadius(8)
                
            }
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("That's it...? 🙄"), message: Text("Your card is kind of boring, no offense. Please add some text to both fields. Your future self will thank you for it"), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $takeMeBack) {
            CardListView(language: language)
                .environment(authManager)
        }
    }
}


