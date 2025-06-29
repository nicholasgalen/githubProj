//
//  UserViewmodel.swift
//  githubProj
//
//  Created by Nicholas Galen on 29/06/25.
//

// viewmodel na arquitetura MVVM trabalha com as regras de negocio e conectando o model (que recebe os valores via requisicao GET do service) com a view.
import Foundation
import Combine

// Framework Combine:
// Biblioteca da Apple para programação reativa e assíncrona.
// Permite observar mudanças em dados e reagir automaticamente,
//   útil para atualizar a UI sem código extra.
// @Published marca propriedades que disparam eventos quando mudam.
// ObservableObject permite que uma classe envie essas notificações para a View,
//   que pode escutar essas mudanças e atualizar automaticamente (ex: SwiftUI).
//
// Exemplo: quando 'followers' muda, a View que observa essa variável atualiza a interface.

class UserViewModel: ObservableObject {
    
    // Dados que serão observados pela View via Combine com o protocolo ObservableObject
    @Published var username: String = ""
    @Published var avatarURL: String = ""
    @Published var followers: Int = 0
    @Published var publicRepos: Int = 0
    @Published var totalStars: Int = 0
    
    // Estado de carregamento para mostrar loading spinner na UI
    @Published var isLoading: Bool = false
    
    // Mensagem de erro para mostrar para o usuário, se houver falha
    @Published var errorMessage: String?

    // Chama nosso servico para fazer a requisicao HTTP
    private let service = GitHubService()

    // Função que busca dados do usuário e atualiza os campos publicados
    func fetchUserData(for username: String) {
        isLoading = true
        errorMessage = nil
        totalStars = 0

        // Busca o usuário usando o Service
        service.fetchUser(username: username) { [weak self] result in
            // Como a chamada é assíncrona, voltamos para a thread principal para atualizar a UI
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    // Atualiza as propriedades publicadas com os dados do usuário
                    self?.username = user.login
                    self?.avatarURL = user.avatar_url
                    self?.followers = user.followers
                    self?.publicRepos = user.public_repos
                    
                    // Após carregar usuário, busca os repositórios para somar as estrelas
                    self?.fetchStars(for: username)
                    
                case .failure(let error):
                    // Em caso de erro, para loading e mostra mensagem
                    self?.isLoading = false
                    self?.errorMessage = "Erro ao buscar usuário: \(error.localizedDescription)"
                }
            }
        }
    }

    // Busca os repositórios e soma as estrelas para atualizar totalStars
    private func fetchStars(for username: String) {
        service.fetchRepositories(username: username) { [weak self] result in
            DispatchQueue.main.async {
                // Finaliza loading aqui, pois terminou a busca dos repositórios
                self?.isLoading = false
                
                switch result {
                case .success(let repos):
                    // Soma as estrelas de todos os repositórios públicos
                    let stars = repos.reduce(0) { $0 + $1.stargazers_count }
                    self?.totalStars = stars
                    
                case .failure(let error):
                    // Exibe mensagem de erro caso a requisição falhe
                    self?.errorMessage = "Erro ao buscar repositórios: \(error.localizedDescription)"
                }
            }
        }
    }
}
