//
//  CardCreateView.swift
//  Kartochki
//
//  Created by Darian Lee on 7/16/24.
//

import SwiftUI

struct CardCreateView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(AuthManager.self) var authManager
    @State var databaseManager: DatabaseManager = DatabaseManager()
    @State var apiManager: ApiManager = ApiManager()
    @State var front: String = ""
    @State var back: String = ""
    @State var translationOutput: String = "Back"
    @State var translationLanguage: String
    @State var inputLanguage: String = "English"
    @State var showMoreInputLanguage: String = "Afrikaans"
    @State private var showMoreLanguagesPicker: Bool = false
    @State private var selectedMoreLanguage: String = "Afrikaans"
    @State var showingAlert = false
    let pinkFullOpacity = Color(red: 255/255, green: 192/255, blue: 203/255)
    var deck: Deck
    
    var body: some View {
        VStack {
            Text("Add card to " + deck.name)
                .font(.title)
                .padding()
                .foregroundColor(.white)
            
            TextField("Front", text: $front, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            if showMoreLanguagesPicker {
                MoreLanguagesPicker(selectedLanguage: $selectedMoreLanguage, selectedInputLanguage: $showMoreInputLanguage, userLanguages: databaseManager.languages + ["English"])
                    .padding()
            }
            HStack {
                Button(action: {
                    var langForAPI: String = "English"
                    var inputForAPI: String = "English"
                    print("hit button")
                    
                    if translationLanguage == "more"{
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
                            showingAlert.toggle()
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
                    
                    Text("En to " + deck.name).tag(deck.name)
                    Text(deck.name + " to En").tag("English")
                    Text("See more options").tag("more")
                }
                .tint(pinkFullOpacity)
                .onChange(of: translationLanguage) { newValue in
                    if newValue == "more" {
                        showMoreLanguagesPicker = true
                    } else {
                        showMoreLanguagesPicker = false
                    }
                    if newValue == deck.name{
                        inputLanguage = "English"}
                    if newValue == "English" {
                        inputLanguage = deck.name
                    }
                        
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal)
            }
            .padding()
            
            
            
            TextField("Back", text: $back, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .frame(minHeight: 50)
            
            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Translation Error"), message: Text("We were unable to translate your sentence. This usually happens when the user's input is too long."), dismissButton: .default(Text("OK")))
        }
    }
}

struct MoreLanguagesPicker: View {
    @Binding var selectedLanguage: String
    @Binding var selectedInputLanguage: String
    let userLanguages: [String]
    let additionalLanguages = [
        "Afrikaans", "Arabic", "Bengali", "Chinese", "Dutch", "English", "French",
        "German", "Greek", "Hebrew", "Hindi", "Indonesian", "Italian", "Japanese",
        "Korean", "Malay", "Persian", "Polish", "Portuguese", "Romanian", "Russian",
        "Spanish", "Swahili", "Swedish", "Tamil", "Thai", "Turkish", "Ukrainian",
        "Urdu", "Vietnamese", "Zulu"
    ]
    let pinkFullOpacity = Color(red: 255/255, green: 192/255, blue: 203/255)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25.0)
                .fill(Color.black.opacity(0.85))
                .shadow(color: Color.white.opacity(1), radius: 5, x: 10, y: 10)
                .frame(height: 120)
            
            VStack {
                HStack{
                    Text("From ")
                    
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                    
                    Picker(selection: $selectedInputLanguage, label: Text("Language")) {
                                    Group {
                                        Text("_____ SAVED _____").font(.headline)
                                        ForEach(userLanguages, id: \.self) { language in
                                            Text(language)
                                                .foregroundColor(.white)
                                                .tag(language)
                                        }
                                    }
                                    
                                    Group {
                                        Text("__________________").font(.headline)
                                        ForEach(additionalLanguages, id: \.self) { language in
                                            Text(language)
                                                .foregroundColor(.white)
                                                .tag(language)
                                        }
                                    }
                                }
                    
                    
                    
                    .tint(pinkFullOpacity)
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                }
                HStack{
                    Text("To ")
                    
                        .bold()
                        .foregroundColor(.white) // Set text color to white
                        .padding()
                    
                    Picker(selection: $selectedLanguage, label: Text("Language")) {
                        Group {
                            Text("_____ SAVED _____").font(.headline)
                            ForEach(userLanguages, id: \.self) { language in
                                Text(language)
                                    .foregroundColor(.white)
                                    .tag(language)
                            }
                        }
                        
                        Group {
                            Text("_____________").font(.headline)
                            ForEach(additionalLanguages, id: \.self) { language in
                                Text(language)
                                    .foregroundColor(.white)
                                    .tag(language)
                            }
                        }
                    }
                    
                    
                    
                    .tint(pinkFullOpacity)
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                }
            }
        }
        .padding()
    }
}

struct CardCreateView_Previews: PreviewProvider {
    static var previews: some View {
        CardCreateView(translationLanguage: "Polish", deck: Deck(name: "Polish", cards: []))
            .environment(AuthManager())
    }
}

