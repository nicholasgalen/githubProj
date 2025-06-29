//
//  User.swift
//  githubProj
//
//  Created by Nicholas Galen on 29/06/25.
//

import Foundation

// Decodable e um protocolo Swift para decodificar JSON para structs ou objetos
struct User: Decodable {
    let login: String
    let avatar_url: String
    let followers: Int
    let public_repos: Int
}
