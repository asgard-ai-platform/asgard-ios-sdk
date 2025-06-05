import SwiftUI
import AsgardCore

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Basic Implementation")) {
                    NavigationLink("Custom Chat View") {
                        CustomChatView()
                    }
                }
                
                Section(header: Text("UI Components")) {
                    NavigationLink("Present Chat") {
                        PresentChatView()
                    }
                }
            }
            .navigationTitle("Asgard SDK Demo")
        }
    }
}

