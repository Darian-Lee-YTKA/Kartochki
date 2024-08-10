//
//  CreateAccountView.swift
//  Kartochki
//
//  Created by Darian Lee on 6/4/24.
//
import SwiftUI

struct CreateAccountView: View {
    @Environment(AuthManager.self) var authManager
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    @State private var selection = 0
    @State private var selectedThemeIndex = 0
    @State private var selectedThemes: Set<Int> = []
    @State private var showLoginView = false
    @State private var showingAlert = false
    @State private var alertMessage: String = ""
    
    let errorTranslated = [
        "Error",            // English
        "Ошибка - (error)",           // Russian
        "Hata - (error)",             // Turkish
        "Erreur - (error)",           // French
        "错误 - (error)",               // Chinese
        "エラー - (error)",             // Japanese
        "Fehler - (error)",           // German
        "Errore - (error)",           // Italian

        "Erro - (error)",             // Portuguese
        "오류 - (error)",              // Korean
        "Błąd - (error)",             // Polish
   

    ]
    let themes = ["Arabic", "Chinese", "French", "German", "Hindi", "Italian", "Japanese", "Korean", "Persian", "Polish", "Portuguese", "Russian", "Spanish", "Turkish", "Ukrainian", "Urdu", "Vietnamese"]
    let citations = [
        "Russian": "Moscow Stock photos by Vecteezy (https://www.vecteezy.com/free-photos/moscow)",
        "Turkish": "Turkey Stock photos by Vecteezy (https://www.vecteezy.com/free-photos/turkey)",
        "Spanish": "Mexico Stock photos by Vecteezy (https://www.vecteezy.com/free-photos/mexico)",
        "French": "France Stock photos by Vecteezy (https://www.vecteezy.com/free-photos/france)",
        "Japanese": "Japan Stock photos by Vecteezy (https://www.vecteezy.com/free-photos/japan)",
        "Chinese": "Beijing Stock photos by Vecteezy (https://www.vecteezy.com/free-photos/beijing)",
        "German": "Austria Stock photos by Vecteezy (https://www.vecteezy.com/free-photos/austria)",
        "Italian": "Venice Stock photos by Vecteezy (https://www.vecteezy.com/free-photos/venice)",
        "Arabic": "Morocco Stock photos by Vecteezy (https://www.vecteezy.com/free-photos/morocco)",
        "Korean": "Seoul Stock photos by Vecteezy (https://www.vecteezy.com/free-photos/seoul)",
        "Hindi": "Architecture Stock photos by Vecteezy (https://www.vecteezy.com/free-photos/architecture)",
        "Urdu": "Pakistan Stock photos by Vecteezy (https://www.vecteezy.com/free-photos/pakistan)",
        "Vietnamese": "Vietnam Stock photos by Vecteezy (https://www.vecteezy.com/free-photos/vietnam)",
        "Polish": "Poland Stock photos by Vecteezy (https://www.vecteezy.com/free-photos/poland)",
        "Persian": "Iran Stock photos by Vecteezy (https://www.vecteezy.com/free-photos/iran)",
        "Ukrainian": "Ukraine Stock photos by Vecteezy (https://www.vecteezy.com/free-photos/ukraine)",
        "Portuguese": "Portugal Stock photos by Vecteezy (https://www.vecteezy.com/free-photos/portugal)"
    ]

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    Text("Welcome to Kartochki!")
                        .font(.title)
                        .fontWeight(.heavy)
                    Text("An app built by language lovers, for language lovers")
                        .font(.caption)

                    Spacer()
                    Spacer()

                    ZStack {
                        Color.red.opacity(0.15)
                            .ignoresSafeArea()
                        VStack {
                            ScrollView {
                                VStack {
                                    Color.black
                                        .edgesIgnoringSafeArea(.all)
                                    Spacer()
                                    Spacer()

                                    TextField("Name", text: $name)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.horizontal, geometry.size.width * 0.05)

                                    TextField("Email", text: $email)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.horizontal, geometry.size.width * 0.05)

                                    SecureField("Password", text: $password)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.horizontal, geometry.size.width * 0.05)

                                    Spacer()

                                    HStack {
                                        Text("Select your target languages:")
                                            .padding()
                                        List {
                                            ForEach(themes.indices, id: \.self) { index in
                                                HStack {
                                                    Text(themes[index])
                                                    Spacer()
                                                    if selectedThemes.contains(index) {
                                                        Image(systemName: "checkmark")
                                                            .foregroundColor(.red.opacity(0.4))
                                                    }
                                                }
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    if selectedThemes.contains(index) {
                                                        selectedThemes.remove(index)
                                                    } else {
                                                        selectedThemes.insert(index)
                                                    }
                                                }
                                            }
                                        }
                                        .frame(height: geometry.size.height * 0.18)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 5)
                                        .background(Color.red.opacity(0.3))
                                        .cornerRadius(8)
                                    }

                                    TabView(selection: $selection) {
                                        ForEach(themes.indices, id: \.self) { index in
                                            VStack {
                                                Spacer()
                                                Text(themes[index])
                                                Image(themes[index])
                                                    .resizable()
                                                    .scaledToFit()
                                                    .cornerRadius(10)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.black, lineWidth: 2)
                                                    )
                                                    .tag(index)
                                                    .padding()
                                                    .frame(height: geometry.size.width * 0.7)
                                                    .transition(.slide)
                                                    .animation(.easeInOut(duration: 1))

                                                if let caption = citations[themes[index]] {
                                                    Text(caption)
                                                        .font(.system(size: 7))
                                                } else {
                                                    Text("No caption available")
                                                        .font(.caption)
                                                }
                                            }
                                        }
                                    }
                                    .tabViewStyle(PageTabViewStyle())
                                    .frame(height: geometry.size.width * 0.8)
                                    .padding()
                                    .onAppear {
                                        let timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
                                            withAnimation {
                                                selection = (selection + 1) % themes.count
                                            }
                                        }
                                        timer.fire()
                                    }
                                }
                            }

                            Button(action: {
                                if name.isEmpty {
                                    alertMessage = "👤Please ensure your name is at least 1 character"
                                    showingAlert = true
                                }  else if !email.isValidEmail() {
                                    alertMessage = "📬Please provide a valid email address"
                                    showingAlert = true
                                } 
                                else if password.count < 6 {
                                    alertMessage = "🗝️Please ensure your password is at least 6 characters"
                                    showingAlert = true
                                }
                                else if selectedThemes.isEmpty {
                                    alertMessage = "🌏Please select at least one language"
                                    showingAlert = true
                                } else {
                                    authManager.signUp(email: email, password: password) { error in
                                        if let error = error {
                                            alertMessage = "Error: \(error.localizedDescription)"
                                            showingAlert = true
                                        } else {
                                            let selectedThemeNames = selectedThemes.map { themes[$0] }
                                            DatabaseManager().initializeNewUser(languages: selectedThemeNames, name: name, email: email) { error in
                                                if let error = error {
                                                    alertMessage = "Database error: \(error.localizedDescription)"
                                                    showingAlert = true
                                                } else {
                                                    print("Account created successfully")
                                                    print(authManager.user)
                                                }
                                            }
                                        }
                                    }
                                }
                            }) {
                                Text("Create Account")
                                    .font(.title2)
                                    .padding(geometry.size.width * 0.005)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal, geometry.size.width * 0.2)
                            .padding(.bottom, 2)
                            .alert(isPresented: $showingAlert) {
                                Alert(title: Text(errorTranslated.randomElement()!), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                            }

                            HStack {
                                Text("Already have an account?")
                                    .font(.caption)
                                Button(action: {
                                    showLoginView = true
                                }) {
                                    Text("Login")
                                        .font(.caption)
                                }
                                .fullScreenCover(isPresented: $showLoginView) {
                                    LoginView()
                                        .environment(authManager)
                                }
                            }
                        }
                    }
                }
                .navigationBarHidden(true)
            }
        }
    }
}

extension String {
    func isValidEmail() -> Bool {
        if self.count < 1{
            return false
        }
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
}



struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView()
            .environment(AuthManager())
    }
}
