//
//  CreateOrGetSuggestionsView.swift
//  Kartochki
//
//  Created by Darian Lee on 7/22/24.
//

import SwiftUI

struct CreateOrGetSuggestionsView: View {
    @State var isShowingCreateCard: Bool = false
    @State var isShowingGetSuggestions: Bool = false
    let pinkFullOpacity = Color(red: 255/255, green: 192/255, blue: 203/255)
    
    var language: String
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                isShowingCreateCard.toggle()
            }) {
                Text("Create card from scratch")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.black)
                    .foregroundColor(pinkFullOpacity)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            
            Text("or")
                .foregroundColor(.black)
                .padding(.bottom, 10)
            
            Button(action: {
                isShowingGetSuggestions.toggle()
            }) {
                Text("Get customized card ideas using AI")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.black)
                    .foregroundColor(pinkFullOpacity)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Image("kartochkilogoPink1")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 300)
                .padding(.vertical, 10)
            
        }
        .padding()
        .background(pinkFullOpacity)
        
        .edgesIgnoringSafeArea(.all)
        .fullScreenCover(isPresented: $isShowingCreateCard) {
            CardCreateView(translationLanguage: language, deck: language, inputLanguage: nil, front: nil)
                .environment(AuthManager())
        }
        .fullScreenCover(isPresented: $isShowingGetSuggestions) {
            GetSuggestions(language: language)
                .environment(AuthManager())
        }
    }
}

#Preview {
    CreateOrGetSuggestionsView(language: "English")
}

