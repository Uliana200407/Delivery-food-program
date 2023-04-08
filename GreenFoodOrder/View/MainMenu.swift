
import SwiftUI
import MessageUI
import MapKit
import MediaPlayer
import CoreVideo
import AVKit
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
                                     Spacer(minLength: 0)
                    }
                }
            }
        }
    }

struct DetailView: View {
    var phoneNumber = "380677393876" //49.806698703333666, 30.10266722386009
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 49.806698703333666  , longitude: 30.10266722386009), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    var body: some View {
        VStack {
            Button(action: {
                let phone = "tel://"
                let phoneNumberformatted = phone + phoneNumber
                guard let url = URL(string: phoneNumberformatted) else { return }
                UIApplication.shared.open(url)
               }) {
               Text("📞Phone number:" + phoneNumber)
            }
        }
        .padding(.leading)
        .shadow(radius: 10)
        .font(.system(size:10))
        .fontWeight(.semibold)
        .frame(width: 200,height:17)
        .foregroundColor(.white)
        .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.yellow]), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(10)
    Spacer(minLength: 0)
        Map(coordinateRegion: $region)
                    .frame(width: 400, height: 300)
    }
}
struct MainMenu: View {
    @ObservedObject var homeData : HomeViewModel
    @State var selectedTag: String?
    @State private var isShowingDetailView = false

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
                       
                    HStack(spacing: 15){
                        NavigationView {
                            NavigationLink(destination: DetailView()) {
                                Text("💚Contact information")
                                    .shadow(radius: 21)
                                    .font(.system(size:18))
                                    .fontWeight(.semibold)
                                    .frame(width: 200,height: 50)
                                    .foregroundColor(.white)
                                    .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.init("Color")]), startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(10)
                            }
                            .padding()
                        }
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

