//
//  ContentView.swift
//  githubProj
//
//  Created by Nicholas Galen on 29/06/25.
//

// SwiftUI e o framework mais moderno da apple para desenvolvimento das UIs iOS (comparado ao UIKit), assim como o jetpack compose esta para o desenvolvimento via XML para android
import SwiftUI

// main view que mostra o formulario para buscar usuario no github e os dados retornados
struct ContentView: View {
    // referencia para o viewmodel injetado pelo ambiente
    @EnvironmentObject var userVM: UserViewModel
    // estado local para armazenar o texto digitado pelo usuario
    @State private var inputUsername: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // campo de texto para o usuario digitar o username do github
                TextField("enter github username", text: $inputUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .autocapitalization(.none)  // nao capitaliza automaticamente
                    .disableAutocorrection(true) // desabilita autocorrecao

                // botao para iniciar a busca
                Button(action: {
                    guard !inputUsername.isEmpty else { return }
                    userVM.fetchUserData(for: inputUsername)
                    UIApplication.shared.dismissKeyboard() // fecha teclado
                }) {
                    Text("search")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // se estiver carregando, mostra indicador
                if userVM.isLoading {
                    ProgressView("loading...")
                        .padding()
                }
                // se tiver erro, mostra mensagem em vermelho
                else if let error = userVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                // se usuario valido, mostra os dados
                else if !userVM.username.isEmpty {
                    VStack(spacing: 10) {
                        // mostra avatar do usuario com carregamento
                        AsyncImage(url: URL(string: userVM.avatarURL)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            case .failure:
                                Image(systemName: "person.crop.circle.badge.exclamationmark")
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }

                        // nome do usuario
                        Text(userVM.username)
                            .font(.title2)
                            .bold()

                        // hstack com seguidores, repositorios e estrelas
                        HStack(spacing: 30) {
                            VStack {
                                Text("\(userVM.followers)")
                                    .font(.headline)
                                Text("followers")
                                    .font(.subheadline)
                            }

                            VStack {
                                Text("\(userVM.publicRepos)")
                                    .font(.headline)
                                Text("repositories")
                                    .font(.subheadline)
                            }

                            VStack {
                                Text("\(userVM.totalStars)")
                                    .font(.headline)
                                Text("stars")
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                }

                Spacer() // ocupa espaco restante para empurrar conteudo pra cima
            }
            .navigationTitle("github user info") // titulo da navigation bar
        }
    }
}

// extensao para fechar o teclado ao tocar no botao buscar
extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
