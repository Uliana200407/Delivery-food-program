import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = AuthenticationViewModel()

    var body: some View {
        if viewModel.isAuthenticated {
            NavigationView {
                Home()
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
            }
            .environment(\.managedObjectContext, viewContext)
        } else {
            AuthenticationView(viewModel: viewModel)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}

struct AuthenticationView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @State private var showAlert = false

    var body: some View {
        VStack {
            Text("AUTHORISATION🔏")
                .frame(alignment: .center)
                .font(.largeTitle)
                .bold()
            TextField("Phone number", text: $viewModel.phoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.numberPad)

            TextField("Name", text: $viewModel.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                if !viewModel.phoneNumber.isEmpty && !viewModel.name.isEmpty {
                    if isValidPhoneNumber(viewModel.phoneNumber) {
                        viewModel.authenticate()
                    } else {
                        showAlert = true
                    }
                }
            }) {
                Text("Authenticate")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                    .clipShape(Capsule())
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("❌Incorrect input❌"),
                    message: Text("Please, input correct the phone number!"),
                    dismissButton: .default(Text("Okay"))
                )
            }
        }
    }

 
        func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
            return phoneNumber.count >= 10
            
        }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
