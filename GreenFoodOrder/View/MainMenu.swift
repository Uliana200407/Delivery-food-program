import SwiftUI
import MessageUI
import MapKit
import MediaPlayer
import CoreVideo
import AVKit
import FirebaseFirestore
import FortuneWheel

struct DiscountsDetails: View{
    @State var player = AVPlayer(url: URL(string: "https://joy1.videvo.net/videvo_files/video/free/2016-12/large_watermarked/FoodPack1_14_Videvo_preview.mp4")!) // 1

    var body: some View {
        
        VideoPlayer(player: player)
            .frame(width: 400,
                   height: 200,
                   alignment: .center)

        ScrollView(.vertical,showsIndicators: false){
            LazyVStack(spacing: 0){
                Text("Looking for a place to enjoy delicious and healthy food? Look no further than our healthy café! We offer a variety of options to satisfy your cravings while helping you maintain a balanced diet.So come visit us and see for yourself why our healthy café is the perfect place for anyone looking to maintain a healthy lifestyle without sacrificing taste or variety.🥬")
                    .padding()
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                .multilineTextAlignment(.leading)}
                         ZStack {
                            
                                 VStack(alignment: .center) {
                                     
                                     Image("Image 3").resizable()
                                         .frame(width: UIScreen.main.bounds.width - 30,height: 300)
                                         .padding()
                                     Image("Image 4").resizable()
                                         .frame(width: UIScreen.main.bounds.width - 30,height: 300)
                                         .padding()
                                     Image("Image 6").resizable()
                                         .frame(width: UIScreen.main.bounds.width - 30,height: 300)
                                         .padding()
                                     Image("Image 5").resizable()
                                         .frame(width: UIScreen.main.bounds.width - 30,height: 300)
                                         .padding()
                                     Spacer(minLength: 0)
                    }
                }
            }
        }
    }
import SwiftUI

struct Fortunes: View {
    @State private var isFullScreen = false
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedIndex = 0
    @State private var isWheelSpinning = false
    @State private var responseText = ""
    @State private var phoneNumber = ""
    @State private var name = ""
    @State private var errorMessage = ""

    var players = ["Oops🚫", "Free Pizza🍕", "-15%", "-5%", "Oops🚫", "-10%", "Oops🚫", "Free dessert🧁", "Oops🚫"]
    let rotationDegree: Double = 360 * 24 // 24 hours
    let db = Firestore.firestore()

    var body: some View {
        ZStack {
            VStack {
                Text("Try your luck🍀")
                    .frame(alignment: .center)
                    .font(.largeTitle)
                TextField("Enter your name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(Color.green)
                    .padding()
                TextField("Enter your phone", text: $phoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(Color.green)
                    .padding()

                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()

                FortuneWheel(titles: players, size: isFullScreen ? UIScreen.main.bounds.size.width : 320, onSpinEnd: { index in
                    if !isWheelSpinning && validatePhoneNumber() && !name.isEmpty {
                        selectedIndex = index
                        responseText = players[index]
                        isWheelSpinning = true

                        let resultData: [String: Any] = [
                            "selected_index": selectedIndex,
                            "result_text": responseText,
                            "timestamp": getCurrentTime(),
                            "phoneNumber": phoneNumber,
                            "name": name,
                        ]

                        db.collection("DiscountsInformation").addDocument(data: resultData) { error in
                            if let error = error {
                                print("Error adding document: \(error)")
                            } else {
                                print("Result added successfully.")
                                phoneNumber = ""
                                name = ""
                                errorMessage = ""
                            }
                        }
                    } else {
                        errorMessage = "Please enter a valid phone number and name."
                    }
                })

                Text(responseText)
                    .font(.caption)
                    .padding()
            }

            VStack {
                Spacer()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back")
                        .frame(alignment: .bottomLeading)
                        .font(.callout)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .edgesIgnoringSafeArea(isFullScreen ? .all : [])
        .navigationBarHidden(isFullScreen)
        .navigationBarTitle("", displayMode: .inline)
        .onTapGesture {
            isFullScreen.toggle()
        }
    }

    func getCurrentTime() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: currentDate)
    }

    func validatePhoneNumber() -> Bool {
        let characterSet = CharacterSet.decimalDigits
        if phoneNumber.rangeOfCharacter(from: characterSet.inverted) != nil || phoneNumber.count < 10 {
            return false
        }
        return true
    }
}


struct FeedbackView: View {
    @State private var feedbackText = ""
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var errorMessage = ""
    @State private var isPhoneNumberValid = true
    @Environment(\.presentationMode) var presentationMode
    
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            Text("Feedback🖋")
                .font(.title)
                .bold()
                .padding()
            
            TextField("Enter your name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(Color.black)
                .padding()
            
            TextField("Enter your phone number", text: $phoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(isPhoneNumberValid ? Color.black : Color.red) // Зміна кольору тексту при неправильному вводі
                .padding()
            
            Text(errorMessage)
                .foregroundColor(.red)
                .padding()
            Text("Enter your massage here:")
                .bold()
                .frame(alignment: .leading)
            TextField("Enter your feedback", text: $feedbackText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(Color.black)
                .padding()
            
            HStack {
                Button(action: sendFeedback) {
                    Text("Send")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                        .clipShape(Capsule())
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color("Color"))
                        .cornerRadius(10)
                        .clipShape(Capsule())
                }
                .padding()
            }
        }
        .onChange(of: phoneNumber) { newValue in
            isPhoneNumberValid = isValidPhoneNumber(newValue)
        }
    }
    
    private func sendFeedback() {
        guard !feedbackText.isEmpty, !name.isEmpty, isPhoneNumberValid else {
            errorMessage = "Invalid phone number"
            return
        }
        
        let feedbackData: [String: Any] = [
            "feedbackText": feedbackText,
            "name": name,
            "phoneNumber": phoneNumber,
            "timestamp": Date()
        ]
        
        db.collection("Feedbacks").addDocument(data: feedbackData) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Feedback added successfully.")
                feedbackText = ""
                name = ""
                phoneNumber = ""
                errorMessage = ""
                isPhoneNumberValid = true
            }
        }
    }
    
    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneNumberRegex = "^\\d{10}$" // Перевірка, що номер складається з 10 цифр
        
        let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        return phoneNumberPredicate.evaluate(with: phoneNumber)
    }
}



import MapKit


struct DetailView: View {
    var phoneNumber = "380975493876"
    var instagramAccount = "your_instagram_account"
    var facebookAccount = "your_facebook_account"
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 49.806698703333666, longitude: 30.10266722386009), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    let phone = "tel://"
                    let phoneNumberformatted = phone + phoneNumber
                    guard let url = URL(string: phoneNumberformatted) else { return }
                    UIApplication.shared.open(url)
                }) {
                    Text("📞Call manager")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.yellow]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(10)
                }
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        // Handle Instagram button tap
                        guard let url = URL(string: "https://www.instagram.com/\(instagramAccount)") else { return }
                        UIApplication.shared.open(url)
                    }) {
                        Image(systemName: "message.badge.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.green)

                            .padding()
                    }
                    
                    Button(action: {
                        // Handle Facebook button tap
                        guard let url = URL(string: "https://www.facebook.com/\(facebookAccount)") else { return }
                        UIApplication.shared.open(url)
                    }) {
                        Image(systemName: "ellipsis.bubble.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.green)
                            .padding()
                    }
                    
                    Spacer()
                }
                
                Map(coordinateRegion: $region)
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: 300)
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title)
                    .foregroundColor(.green)
            })
        }
    }
}




struct MainMenu: View {
    @State private var isPresented = false
    @ObservedObject var homeData : HomeViewModel
    @State var selectedTag: String?
    @State private var isShowingDetailView = false
    @State private var isFeedbackPresented = false
    @State private var isDetailViewPresented = false
        @State private var isFortunesPresented = false

    var body: some View {
                VStack{
                    
                    NavigationLink(destination: CartView(homeData: homeData)){
                        HStack(spacing: 15){
                            Image(systemName: "cart")
                                .font(.title)
                                .foregroundColor(.green)
                            
                            Text("Cart")
                                .fontWeight(.bold )
                                .foregroundColor(.black)
                            Spacer(minLength: 0)
                        }
                        .padding()
                    }
                    HStack(spacing: 15){
                        Button(action: {
                            if let url = URL(string: "https://www.instagram.com/greenhousefoodss/") {
                                UIApplication.shared.open(url)
                                
                            }
                            
                        }) {
                            Text("💚Our instagram")
                                .shadow(radius: 21)
                                .font(.system(size:18))
                                .fontWeight(.semibold)
                                .frame(width: 200,height: 50)
                                .foregroundColor(.white)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.init("Color")]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(10)
                            Spacer(minLength: 0)
                            
                        }
                        .padding()
                    }

                        HStack(spacing: 15){
                            Button(action: {
                                self.selectedTag = "xx"
                                    
                            }, label: {
                                Text("💚Discounts")
                                
                                    .font(.system(size:18))
                                    .fontWeight(.semibold)
                                    .frame(width: 200,height: 50)
                                    .foregroundColor(.white)
                                    .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.init("Color")]), startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(10)
                            })
                            
                            .background(
                                NavigationLink(
                                    destination:
                                    DiscountsDetails(),
                                    tag: "xx",
                                    selection: $selectedTag,
                                    label: { EmptyView() }
                                )
                            )}
                       
                    HStack(spacing: 15) {
                               Button(action: {
                                   isDetailViewPresented.toggle()
                               }) {
                                   Text("💚Contact data")
                                       .shadow(radius: 21)
                                       .font(.system(size:18))
                                       .fontWeight(.semibold)
                                       .frame(width: 200,height: 50)
                                       .foregroundColor(.white)
                                       .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.init("Color")]), startPoint: .leading, endPoint: .trailing))
                                       .cornerRadius(10)
                               }
                               .fullScreenCover(isPresented: $isDetailViewPresented) {
                                   DetailView()
                               }
                               .padding()
                           }
                    
                    HStack(spacing: 15) {
                               Button(action: {
                                   isFortunesPresented.toggle()
                               }) {
                                   Text("💚Fortune")
                                       .shadow(radius: 21)
                                       .font(.system(size:18))
                                       .fontWeight(.semibold)
                                       .frame(width: 200,height: 50)
                                       .foregroundColor(.white)
                                       .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.init("Color")]), startPoint: .leading, endPoint: .trailing))
                                       .cornerRadius(10)
                               }
                               .fullScreenCover(isPresented: $isFortunesPresented) {
                                   Fortunes()
                               }
                               .padding()
                           }
                    
                    VStack(spacing: 15) {
                                Button(action: {
                                    isFeedbackPresented.toggle()
                                }) {
                                    Text("💚Feedbacks")
                                        .shadow(radius: 21)
                                        .font(.system(size: 18))
                                        .fontWeight(.semibold)
                                        .frame(width: 200, height: 50)
                                        .foregroundColor(.white)
                                        .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.init("Color")]), startPoint: .leading, endPoint: .trailing))
                                        .cornerRadius(10)
                                }
                                .padding()
                            }
                            .fullScreenCover(isPresented: $isFeedbackPresented) {
                                FeedbackView()
                            }
                    
                    Spacer()
                    HStack{
                        Spacer()
                        Text("@GreenHouse 2023")
                            .fontWeight(.bold)
                            .foregroundColor(.green )
                    }
                    .padding(10)
                }
            
                .padding([.top,.trailing])
                .frame(width: UIScreen.main.bounds.width / 1.6)
                .background(Color.white.ignoresSafeArea())
            }
        }

