// URLSettingsView.swift
struct URLSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedURL: String
    @State private var customURL: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let predefinedURLs = [
        "http://192.168.18.96:8000/api/",
        "http://192.168.18.87:8000/api/",
        "http://192.168.18.88:8000/api/",
        "http://192.168.18.31:8000/api/",
        "http://192.168.1.37:8000/api/"
    ]
    
    init() {
        _selectedURL = State(initialValue: BaseURL.url.absoluteString)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Predefined URLs")) {
                    ForEach(predefinedURLs, id: \.self) { url in
                        HStack {
                            Text(url)
                            Spacer()
                            if selectedURL == url {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedURL = url
                        }
                    }
                }
                
                Section(header: Text("Custom URL")) {
                    TextField("Enter custom URL", text: $customURL)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                    
                    Button("Use Custom URL") {
                        if let _ = URL(string: customURL) {
                            selectedURL = customURL
                        } else {
                            alertMessage = "Invalid URL format"
                            showAlert = true
                        }
                    }
                }
                
                Section {
                    Button("Save") {
                        saveURL()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("API URL Settings")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    dismiss()
                }
            )
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveURL() {
        // Here you would implement the logic to save the URL
        // This is a simplified example - you'll need to adapt this
        // to your actual storage mechanism
        if let url = URL(string: selectedURL) {
            // You might want to use UserDefaults or another persistence method
            UserDefaults.standard.set(url.absoluteString, forKey: "BaseURL")
            dismiss()
        } else {
            alertMessage = "Invalid URL format"
            showAlert = true
        }
    }
}