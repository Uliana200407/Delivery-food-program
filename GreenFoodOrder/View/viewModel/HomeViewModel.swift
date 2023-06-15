
import SwiftUI
import CoreLocation
import Firebase
import FirebaseFirestore
import FirebaseAuth
class HomeViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var isSortingAscending = true
    @Published var isSortingAscendingPrice = true
    @Published var userCoordinates: CLLocationCoordinate2D?
    @Published var locationManager = CLLocationManager()
    @Published var search = ""
    @Published var phoneNumber = ""
    @Published var name = ""
    @Published var userLocation: CLLocation!
    @Published var userAddress = ""
    @Published var noLocation = false
    @Published var MainMenu = false
    @Published var items: [Item] = [] //item data
    @Published var filteredData: [Item] = [] //searching data
    @Published var cartItems: [Cart] = [] //cart data
    @Published var showVerificationCodeInput = false
    @Published var isAuthenticated = false
    @Published var isShowingAuthentication = false
    @Published var isShowingMainView = false
    
    @Published var userName: String = ""
    @Published var userPhone: String = ""
    
    @Published var orderedDishes = false
    var db = Firestore.firestore()
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus{
        case .authorizedWhenInUse:
            print("You have been authorized")
            manager.requestLocation()
            self.noLocation = false
            
        case.denied:
            print("You have been denied")
            self.noLocation = true
        default:
            print("Not defined")
            self.noLocation = false
            
            //Direct call
            locationManager.requestWhenInUseAuthorization()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userLocation = locations.last //reading user location
        self.userCoordinates = userLocation.coordinate
        self.extractLoc()
        self.login()
    }
    
    func authenticate(phoneNumber: String, name: String, userName: String, userPhone: String) {
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] (verificationID, error) in
            if let error = error {
                print("Error verifying phone number: \(error.localizedDescription)")
                return
            }
            
            self?.phoneNumber = phoneNumber
            self?.name = name
            self?.userName = userName
            self?.userPhone = userPhone
            
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            UserDefaults.standard.set(userName, forKey: "userName")
            UserDefaults.standard.set(userPhone, forKey: "userPhone")
            
            self?.showVerificationCodeInput = true
        }
    }
    
    func signInWithVerificationCode(verificationCode: String) {
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
            print("Verification ID not found.")
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                return
            }
            
            // Successful authentication
            print("User is authenticated: \(authResult?.user.uid ?? "")")
            
            // Save user data in Firestore
            guard let uid = authResult?.user.uid else {
                return
            }
            
            let userData: [String: Any] = [
                "phone": self?.phoneNumber ?? "",
                "name": self?.name ?? ""
                // Add other user fields as needed
            ]
            
            self?.db.collection("UserInformation").document(uid).setData(userData) { error in
                if let error = error {
                    print("Error saving user data: \(error.localizedDescription)")
                } else {
                    print("User data saved successfully")
                    self?.isAuthenticated = true
                }
            
        }
    }
}
  
    
    private func fetchData() {
        db.collection("Users").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching data from Firestore: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            for document in documents {
                let data = document.data()
                
            }
        }
    }
    
    func extractLoc(){
        CLGeocoder().reverseGeocodeLocation(self.userLocation) { (res,err) in
            guard let safeData = res else{return}
            var adress = ""
            
            adress += safeData.first?.name ?? ""
            adress += ", "
            adress += safeData.first?.locality ?? ""
            self.userAddress = adress
        }
    }
    func login(){ //anonymus login
        Auth.auth().signInAnonymously{(res,err) in
            if err != nil{
                print(err!.localizedDescription )
                return
            }
            print("Success = \(res! .user.uid )")
            
            self.fetchingData()
        }
    }
    func fetchingData(){ //adding data from firebase
        let db = Firestore.firestore()
        
        db.collection("Items").getDocuments { (snap,err) in
            
            guard let itemData = snap else{return}
            
            self.items = itemData.documents.compactMap({ (doc) -> Item? in
                let id  = doc.documentID
                let name = doc.get("dish_name") as! String
                let photo = doc.get("dish_photo") as! String
                let description = doc.get("dish_description") as! String
                let ingredients = doc.get("dish_ingredients") as! String
                let price = doc.get("dish_price") as! NSNumber
                let rank = doc.get("dish_rank") as! String
                let calories = doc.get("dish_cal") as! NSNumber
                
                return Item(id: id, dish_name: name, dish_photo: photo, dish_description: description, dish_ingredients: ingredients, dish_price: price, dish_rank: rank, dish_cal: calories)
            })
            self.filteredData = self.items
            
        }
    }
    func filteringData(){
        withAnimation(.linear){
            self.filteredData = self.items.filter{
                return $0.dish_name.lowercased().contains(self.search.lowercased())
                //searching some information
            }
        }
    }
    var sortedData: [Item] {
        if isSortingAscending {
            return filteredData.sorted { $0.dish_name < $1.dish_name }
        } else {
            return filteredData.sorted { $0.dish_name > $1.dish_name }
        }
    }
    func toggleSorting() {
        isSortingAscending.toggle()
    }
    var sortedByPriceData: [Item] {
        if isSortingAscendingPrice {
            return filteredData.sorted { item1, item2 in
                guard let price1 = item1.dish_price as? NSNumber,
                      let price2 = item2.dish_price as? NSNumber else {
                    return false
                }
                return price1.doubleValue < price2.doubleValue
            }
        } else {
            return filteredData.sorted { item1, item2 in
                guard let price1 = item1.dish_price as? NSNumber,
                      let price2 = item2.dish_price as? NSNumber else {
                    return false
                }
                return price1.doubleValue > price2.doubleValue
            }
        }
    }
    func toggleSorting2() {
        isSortingAscendingPrice.toggle()
    }
    
    func addingToCart(item: Item){
        self.items[getIndex(item: item, isCartIndex: false)].isInCart = !item.isInCart // check for adding
        let filterndex = self.filteredData.firstIndex{(item1) -> Bool in
            
            return item.id == item1.id
        } ?? 0
        self.filteredData[filterndex].isInCart = !item.isInCart // updating filtered Data, also for search
        if item.isInCart {
            self.cartItems.remove(at: getIndex(item: item, isCartIndex: true)) //remove
            return
            
        }
        self.cartItems.append(Cart(item: item, amount: 1))// adding dishes
    }
    func getIndex(item: Item, isCartIndex: Bool) -> Int{
        let index = self.items.firstIndex{ (item1) -> Bool in
            return item.id == item1.id
        } ?? 0
        let cartIndex = self.cartItems.firstIndex{ (item1) -> Bool in
            return item.id == item1.item.id
        } ?? 0
        return isCartIndex ? cartIndex : index
    }
    func calculatePrice()->String{
        var price : Float = 0
        cartItems.forEach{(item) in
            price += Float(item.amount) * Float(truncating: item.item.dish_price)
        }
        return getPrice(value: price)
    }
    func getPrice(value: Float)->String{
        let format = NumberFormatter()
        format.numberStyle = .currency
        return format.string(from: NSNumber(value: value)) ?? ""
    }
    func updating() {
        let db = Firestore.firestore()
        if orderedDishes {
            orderedDishes = false
            db.collection("Users").document(Auth.auth().currentUser!.uid).delete { (err) in
                if err != nil {
                    self.orderedDishes = true
                }
            }
            return
        }
        
        var data: [[String: Any]] = []
        cartItems.forEach { (cart) in
            data.append([
                "dish_name": cart.item.dish_name,
                "dish_amount": cart.amount,
                "dish_price": cart.item.dish_price
            ])
        }
        
        orderedDishes = true
        let userLocation = GeoPoint(latitude: self.userLocation.coordinate.latitude, longitude: self.userLocation.coordinate.longitude)
        
        let currentDate = Date() // Поточна дата та час
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let orderTimestamp = dateFormatter.string(from: currentDate)
        
        db.collection("Users").document(Auth.auth().currentUser!.uid).setData([
            "ordered_dishes": data,
            "total_sum": calculatePrice(),
            "userLocation": userLocation,
            "order_timestamp": orderTimestamp // Додано поле з часом замовлення
        ]) { (err) in
            if err != nil {
                self.orderedDishes = false
                return
            }
            print("success")
            
            // Запис замовлення у файл
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Unable to access documents directory")
                return
            }
            
            let fileURL = documentsDirectory.appendingPathComponent("orders.txt")
            
            var orderData = "User Order: \(data)"
            
            if let coordinates = self.userCoordinates {
                let latitude = coordinates.latitude
                let longitude = coordinates.longitude
                orderData += "\nCoordinates: latitude=\(latitude), longitude=\(longitude)"
            }
            
            orderData += "\nOrder time: \(orderTimestamp)" // Додано час замовлення
            
            do {
                try orderData.write(to: fileURL, atomically: true, encoding: .utf8)
                print("Order data written successfully to \(fileURL.path)")
            } catch {
                print("Error writing order data: \(error.localizedDescription)")
            }
        }
    }
    }
