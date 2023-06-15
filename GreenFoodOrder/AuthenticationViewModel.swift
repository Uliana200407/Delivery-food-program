import Foundation
import FirebaseFirestore
import Firebase

class AuthenticationViewModel: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var name: String = ""
    @Published var isAuthenticated: Bool = false
    
    private let db = Firestore.firestore()
    
    func authenticate() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No authenticated user")
            return
        }
        
        let userData: [String: Any] = [
            "phoneNumber": phoneNumber,
            "name": name
        ]
        
        db.collection("UserInformation").document(currentUser.uid).setData(userData) { [weak self] error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                print("User data saved successfully")
                self?.isAuthenticated = true
            }
        }
    }
    
    func sendUser() {
        guard !phoneNumber.isEmpty, !name.isEmpty else {
            return
        }
        isAuthenticated = true

        let userData: [String: Any] = [
            "phoneNumber": phoneNumber,
            "name": name
            
        ]
        
        db.collection("UserInformation").addDocument(data: userData) { [weak self] error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("User added successfully.")
                self?.phoneNumber = ""
                self?.name = ""
                self?.isAuthenticated = true
            }
        }
    }
}
