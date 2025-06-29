//
//  GitHubService.swift
//  githubProj
//
//  Created by Nicholas Galen on 29/06/25.
//

// Usamos o service para fazer a conexao e fetches dos dados pela URI e passar pro modelo.
import Foundation

// Service para buscar dados na API do github (nao vamos usar DTOs pois so fazemos requisicoes GET
class GitHubService {
    
    // URL base para chamadas à API do GitHub
    private let baseURL = "https://api.github.com/users/"
    
    // URLSession usada para realizar chamadas HTTP
    // Usamos URLSession.shared pois é a sessão padrão e suficiente para requisições simples
    private let session = URLSession.shared

    // Função para buscar os dados do usuário (nome, avatar, seguidores, etc)
    func fetchUser(username: String, completion: @escaping (Result<User, Error>) -> Void) {
        
        // Montar a uri com o nome do usuario
        let urlString = baseURL + username
        
        // Checar se a url e valida
        guard let url = URL(string: urlString) else {
            completion(.failure(ServiceError.invalidURL))
            return
        }

        // Inicia a requisição GET
        session.dataTask(with: url) { data, response, error in
            
            // Retornar erro em caso de falha no GET
            if let error = error {
                completion(.failure(error))
                return
            }

            // Garantir que dado veio na resposta
            guard let data = data else {
                completion(.failure(ServiceError.noData))
                return
            }

            // Traduz o JSON para o nosso modelo (struct)
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error)) // retornar parsing error se nao conseguir converter
            }
        }.resume()
    }

    // Fetch para buscar repositorios publicos do usuario
    func fetchRepositories(username: String, completion: @escaping (Result<[Repository], Error>) -> Void) {
        
        // Monta a uri para buscar os repos
        let urlString = baseURL + username + "/repos"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(ServiceError.invalidURL))
            return
        }

        // Faz a requisição GET
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(ServiceError.noData))
                return
            }

            // Decodifica o JSON em um array de Repository
            do {
                let repos = try JSONDecoder().decode([Repository].self, from: data)
                completion(.success(repos))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Enum de erros customizados para falhas especificas no servico
    enum ServiceError: Error {
        case invalidURL
        case noData
    }
}
