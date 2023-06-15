import SwiftUI
 
struct Home: View {
    @ObservedObject var homeModel = HomeViewModel() 
    @State private var isSortingAscending = true
    @State private var isSortingAscendingPrice = true
    @State private var isSortingDropdownVisible = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 7) {
                Spacer(minLength: 0)
                HStack(spacing: 30) {
                    Button(action: {
                        withAnimation(.easeIn) {
                            homeModel.MainMenu.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .foregroundColor(Color.green)
                    }
                    Text(homeModel.userLocation == nil ? "Locating... " : "📍Delivering to:")
                        .foregroundColor(Color("Color"))
                        .bold()
                    Text(homeModel.userAddress)
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundColor(.green)
                    
                    Spacer(minLength: 0 )
                }
                .padding([.horizontal,.top])
                Divider()
                HStack(spacing: 15) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                        .foregroundColor(Color("Color"))
                    TextField(" Search", text: $homeModel.search)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.init("Color")]), startPoint: .leading, endPoint: .trailing))                        .foregroundColor(Color.black)
                        .fontWeight(.semibold)
                        .cornerRadius(10)

                    Image(systemName: "mic")
                        .renderingMode(.template)
                        .foregroundColor(Color("Color"))
                }
                .padding(.horizontal)
                .padding(.top,10)
                Divider()
                    .padding(.horizontal, 10)
                VStack {
                    HStack(spacing: 10) {
                        Button(action: {
                            homeModel.toggleSorting2()
                        }) {
                            Text(homeModel.isSortingAscendingPrice ? "PriceMax" : "PriceMin")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.green)
                                .clipShape(Capsule())
                        }
                        
                        Button(action: {
                            homeModel.toggleSorting()
                        }) {
                            Text(homeModel.isSortingAscending ? "SortA" : "SortRA")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.green)
                                .clipShape(Capsule())
                        }
                    }
                

                    if isSortingDropdownVisible {
                        ScrollView(.vertical) {
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(homeModel.sortedByPriceData) { item in
                                    // Відображення даних для кожного елемента
                                    HStack {
                                        Text(item.dish_name)
                                            .font(.system(size: 12))
                                            .fontWeight(.bold)
                                        Spacer()
                                        Text("\(item.dish_price)")
                                            .font(.system(size: 12))
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.green)
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(Color.white)
                            .cornerRadius(5)
                            .shadow(radius: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray, lineWidth: 0.5)
                            )
                            .padding(.horizontal, 10)
                        }
                        .frame(height: 150)
                    }
                    
                    Button(action: {
                        isSortingDropdownVisible.toggle()
                    }) {
                        Text(homeModel.isSortingAscendingPrice ? "▼" : "▲")
                            .font(.system(size: 10))
                            .frame(width: 20, height: 20)
                            .background(Color("Color"))

                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    .padding(.top, 10)
                }

                
                
                if homeModel.items.isEmpty {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 80) {
                            ForEach(homeModel.sortedData) { item in
                                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                                    ItemView(item:item)
                                    HStack{
                                        Button(action: {
                                            homeModel.addingToCart(item: item)
                                        }) {
                                            Image(systemName: item.isInCart ? "checkmark" : "cart")
                                                .foregroundColor(.black)
                                                .padding(17.0)
                                                .background(item.isInCart ? Color.green : Color("Color"))
                                                .clipShape(Circle())
                                        }
                                    }
                                    .padding(.trailing ,5.0)
                                    .padding(.top,50 )
                                }
                                .frame(width: UIScreen.main.bounds.width - 15,
                                       height: UIScreen.main.bounds.height - 450)
                                Spacer(minLength: 0)
                            }
                        }
                        .padding(.top,40)
                    }
                    .environmentObject(homeModel)
                }
            }
            
            HStack {
                MainMenu(homeData: homeModel)
                    .offset(x: homeModel.MainMenu ? 0 : -UIScreen.main.bounds.width / 1.6)
                
                Spacer(minLength: 0)
            }
            .background(
                Color.black.opacity(homeModel.MainMenu ?  0.3 : 0).ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeIn){
                            homeModel.MainMenu.toggle()
                        }
                    }
            )
            
            if homeModel.noLocation {
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
        .onAppear {
            homeModel.locationManager.delegate = homeModel
        }
        .onChange(of: homeModel.search) { value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                if value == homeModel.search && homeModel.search != "" {
                    homeModel.filteringData()
                }
            }
            if homeModel.search == "" {
                withAnimation(.linear ){
                    homeModel.filteredData = homeModel.items
                }
            }
        }
    }
}
