//
//  GetSuggestions.swift
//  Kartochki
//
//  Created by Darian Lee on 7/22/24.
//

import SwiftUI

struct GetSuggestions: View {
    @State var text: String = ""
    @State var difficulty: String = "beginner"
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var generatedSentence: String = ""
    @State private var CreateCardIsPresented: Bool = false
 
    @State var successAlertIsPresented: Bool = false
    let pinkFullOpacity = Color(red: 255/255, green: 192/255, blue: 203/255)
    var language: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Enter a word or short phrase in \(language) or English and select a difficulty level. Our models will output a sentence which uses this word in context in your target language.")
                .foregroundColor(.white)
                .padding(.bottom, 20)
            
            TextField("Enter word...", text: $text)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .foregroundColor(.black)
            
            Picker(selection: $difficulty, label: Text("Difficulty").foregroundColor(.white)) {
                Text("Beginner").tag("beginner")
                Text("Intermediate").tag("intermediate")
                Text("Advanced").tag("advanced")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(pinkFullOpacity)
            .cornerRadius(12)
            Spacer()
            Button(action: {
                let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
                print(words)
                if words.isEmpty {
                    print("no text entered")
                    alertMessage = "Please enter at least one word and then try again 🙂"
                    showingAlert.toggle()
                } else if words.count > 3 {
                    print("The text contains more than three words.")
                    alertMessage = "Please keep your requests under 3 words to keep computational costs down. We appreciate your understanding 🙂"
                    showingAlert.toggle()
                } else {
                    Task{
                        await fetchExampleSentence()
                    }
                    print("Valid input: \(words)")
                }
            }) {
                Text("Get Sentence")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(pinkFullOpacity)
                    .foregroundColor(.black)
                    .cornerRadius(12)
            }
            
 
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Uh oh!"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $successAlertIsPresented) {
                   Alert(title: Text("🤩 Success 🤩"), message: Text("Sentence generated successfully!"), dismissButton: .default(Text("OK")) {
                       CreateCardIsPresented.toggle()
                   })
               }
        .fullScreenCover(isPresented: $CreateCardIsPresented) {
            
            CardCreateView(translationLanguage: "English", deck: language, inputLanguage: language, front: generatedSentence)
                .environment(AuthManager())
                
            
        }
        
        
    }
    private func fetchExampleSentence() async {
            let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
            print(words)
            if words.isEmpty {
                alertMessage = "Please enter at least one word and then try again 🙂"
                showingAlert = true
                return
            }
            if words.count > 3 {
                alertMessage = "Please keep your requests under 3 words to keep computational costs down. We appreciate your understanding 🙂"
                showingAlert = true
                return
            }
            
            do {
                let sentence = try await ApiManager().getExampleSentence(language: language, inputText: text, difficulty: difficulty)
                
                if sentence == "Error" || sentence == "Empty" {
                    alertMessage = "We were unable to get a sentence at this time. Please ensure that you are inputting a valid word or phrase in " + language
                    showingAlert = true
                }
                else{
                    generatedSentence = sentence
                    print("😾😾😾", sentence)
                    successAlertIsPresented.toggle()
                    
                }
                
            } catch {
                alertMessage = "An error occurred while fetching the sentence. Please try again."
                showingAlert = true
            }
        }
    
}



#Preview {
    GetSuggestions(language: "Spanish")
}
