//
//  NetworkManager.swift
//  DeepSeekAI
//
//  Created by Ahmet Bostancıklıoğlu on 29.01.2025.
//

import Foundation

class NetworkManager: ObservableObject {
    @Published var data: String = "Loading..."
    
    func fetchData() {
        guard let url = URL(string: "https://api.deepseek.com/chat/completions") else {
            self.data = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.data = "Error: \(error.localizedDescription)"
                }
                return
            }
            
            if let data = data, let result = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.data = result
                }
            } else {
                DispatchQueue.main.async {
                    self.data = "No data received"
                }
            }
        }.resume()
    }
}
