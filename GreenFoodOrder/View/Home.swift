
import SwiftUI

struct Home: View {
    @StateObject var HomeModel = HomeViewModel()
    
    var body: some View {
        
        GeometryReader{ geometry in


            VStack(spacing: 7){

                    Spacer(minLength: 0)
                HStack(spacing: 30){

                    Button(action: {
                        withAnimation(.easeIn){HomeModel.MainMenu.toggle()}
                    }, label: {
                        
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .foregroundColor(Color.green)
                    })
                    Text(HomeModel.userLocation == nil ? "Locating... " : "📍Delivering to:")
                        .foregroundColor(Color.init("Color"))
                        .bold()
                    Text(HomeModel.userAddress)
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundColor(.green)
                    
                    Spacer(minLength: 0 )
                }
                
                .padding([.horizontal,.top])
                Divider()
                HStack(spacing: 15){
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                        .foregroundColor(Color.init("Color"))
                    TextField( " Search", text: $HomeModel.search)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.init("Color")]), startPoint: .leading, endPoint: .trailing))                        .foregroundColor(Color.black)
                        .fontWeight(.semibold)
                        .cornerRadius(10)

                    Image(systemName: "mic")
                        .renderingMode(.template)
                        .foregroundColor(Color.init("Color"))
                }
                
                .padding(.horizontal)
                .padding(.top,10)
                Divider()
                if HomeModel.items.isEmpty{
                    Spacer()
                    ProgressView()
                    Spacer()
                    
                }
                else{
                    ScrollView(.vertical, showsIndicators: false,content: {
                        
                        VStack(spacing:80) {
                            ForEach(HomeModel.filteredData){item in
                                
                                ZStack(alignment: Alignment(horizontal: .listRowSeparatorTrailing, vertical: .top), content: {
                                    ItemView(item:item)
                                    HStack{
                                        Button(action: {
                                            HomeModel.addingToCart(item: item)
                                        }, label: {
                                            Image(systemName: item.isInCart ? "checkmark" : "cart")
                                                .foregroundColor(.black)
                                                .padding(17.0)
                                                .background(item.isInCart ? Color.green : Color.init("Color"))
                                                .clipShape(Circle())
                                            
                                        })
                                    }
                                    .padding( .trailing ,5.0)
                                    .padding( .top,50 )
                                })
                                .frame(width: UIScreen.main.bounds.width - 15,
                                       height: UIScreen.main.bounds.height - 450)
                                Spacer(minLength: 0)
                            }
                        }
                        .padding(.top,40)
                    })
                }
            }
            //MainMenu
            HStack{
                
                MainMenu(homeData: HomeModel)
                .offset(x: HomeModel.MainMenu ? 0 : -UIScreen.main.bounds.width / 1.6)
                
            Spacer(minLength: 0 )
        }
                    .background(
                        Color.black.opacity(HomeModel.MainMenu ?  0.3 : 0).ignoresSafeArea()
                        .onTapGesture(perform: {
                            withAnimation(.easeIn){HomeModel.MainMenu.toggle()}
                            
                        })
                    )
            if HomeModel.noLocation{
                Text("Please enable settings locations in the tool service")
                    .foregroundColor(.black)
                    .frame(width: UIScreen.main.bounds.width - 100, height: 120)
                    .background(.white)
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .background(.black.opacity(0.3))
            }
        }
        
        .onAppear(perform: {
            HomeModel.locationManager.delegate = HomeModel
        })
        .onChange(of: HomeModel.search, perform: { value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                if value == HomeModel.search && HomeModel.search != "" {
                    HomeModel.filteringData()
                }
            }
            if HomeModel.search == ""{
                withAnimation(.linear ){
                    HomeModel.filteredData = HomeModel.items
                }
            }
        })
    }
}


