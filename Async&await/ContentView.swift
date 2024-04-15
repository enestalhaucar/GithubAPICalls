//
//  ContentView.swift
//  Async&await
//
//  Created by Enes Talha Uçar  on 15.04.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var user : GithubUser?
    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { Image in
                Image
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundStyle(.gray)
                    
            }
            .frame(width: 120)

            
            
            
            Text(user?.login ?? "user placeholder")
                .bold()
                .font(.title3)
            
            HStack(spacing: 10) {
                Text( "\(user?.followers ?? 10) Followers")
                    .font(.caption)
                Text( "\(user?.following ?? 10) Followers")
                    .font(.caption)
            }
            
            Text(user?.bio ?? "Bio Placeholder")
                .padding()
            
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            }catch GHError.invalidData {
                print("invalidData")
            }catch GHError.invalidUrl {
                print("invalidUrl")
            }catch GHError.invalidResponse {
                print("invalidResponse")
            }catch {
                print("unexpectedError")
            }
        }
        
    }
    
    func getUser() async throws -> GithubUser {
        let endpoint = "https://api.github.com/users/enestalhaucar"
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidUrl
        }
        
        let (data,response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GithubUser.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
}


#Preview {
    ContentView()
}

struct GithubUser : Codable {
    let login: String
    let avatarUrl: String
    let bio: String
    let followers: Int
    let following : Int
    
}

enum GHError : Error {
    case invalidData
    case invalidResponse
    case invalidUrl
}


