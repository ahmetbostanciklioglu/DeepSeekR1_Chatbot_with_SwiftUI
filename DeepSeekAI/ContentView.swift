import SwiftUI

import AIProxy

struct ContentView: View {
    @State private var streamedResponse = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    Text("What are some fun things to do in New York?")
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    
                    if !streamedResponse.isEmpty || isLoading {
                        Text(streamedResponse)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            
            if isLoading {
                ProgressView()
                    .padding()
            }
        }
        .task {
            await streamResponse()
        }
    }
    
    private func streamResponse() async {
        isLoading = true
        
        let togetherAIService = AIProxy.togetherAIService(
            partialKey: "v2|755dd24f|PsB9auLr7vgqygYV",
            serviceURL: "https://api.aiproxy.pro/510ec838/88cb56b5"
        )
        
        do {
            let requestBody = TogetherAIChatCompletionRequestBody(
                messages: [TogetherAIMessage(content: "What are some fun things to do in New York?", role: .user)],
                model: "deepseek-ai/DeepSeek-R1"
            )
            
            let stream = try await togetherAIService.streamingChatCompletionRequest(body: requestBody)
            
            for try await chunk in stream {
                if let content = chunk.choices.first?.delta.content {
                    // Update the UI with the new content
                    await MainActor.run {
                        streamedResponse += content
                    }
                }
            }
        } catch AIProxyError.unsuccessfulRequest(let statusCode, let responseBody) {
            print("Received \(statusCode) status code with response body: \(responseBody)")
            await MainActor.run {
                streamedResponse = "Error: Failed to get response from the server."
            }
        } catch {
            print("Could not create TogetherAI streaming chat completion: \(error.localizedDescription)")
            await MainActor.run {
                streamedResponse = "Error: \(error.localizedDescription)"
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
}
#Preview {
    ContentView()
}
