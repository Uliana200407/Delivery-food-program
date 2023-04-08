

import SwiftUI
import CoreLocation
import Firebase
class HomeViewModel:NSObject ,ObservableObject, CLLocationManagerDelegate{
    
    @Published var locationManager = CLLocationManager()
    @Published var search = ""
    //Location details
    @Published var userLocation : CLLocation!
    @Published var userAddress = ""
    @Published var noLocation = false
    @Published var MainMenu = false
    @Published var items: [Item] = [] //item data
    @Published var filteredData: [Item] = [] //searching data
    @Published var cartItems : [Cart ] = [] //cart data
    @Published var orderedDishes = false
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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        self.userLocation = locations.last //reading user location
        self.extractLoc()
        self.login()
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
                return Item(id: id, dish_name: name, dish_photo: photo, dish_description: description, dish_ingredients: ingredients, dish_price: price, dish_rank: rank)
            })
            self.filteredData = self.items
        }
    }
    func filteringData(){
        withAnimation(.linear){
            self.filteredData = self.items.filter{
                return $0.dish_name.lowercased().contains(self.search.lowercased()) //searching some information
            }
        }
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
    func updating(){
        let db = Firestore.firestore()
        if orderedDishes{
            orderedDishes = false
            db.collection("Users").document(Auth.auth().currentUser!.uid).delete{
                (err) in
                if err != nil{
                    self.orderedDishes = true
                }
            }
            return
        }
        var data : [[String: Any]] = []
        cartItems.forEach{(cart) in
            data.append([
                "dish_name" : cart.item.dish_name,
                "dish_amount" : cart.amount,
                "dish_price" : cart.item.dish_price

            ])
        }
        orderedDishes = true
        db.collection("Users").document(Auth.auth().currentUser!.uid).setData([
            "ordered_dishes" : data,
            "total sum" : calculatePrice(),
            "userLocation" : GeoPoint(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        ]) { (err) in
            if err != nil{
                self.orderedDishes = false
                return
            }
            print("success")
        }
    }
}
