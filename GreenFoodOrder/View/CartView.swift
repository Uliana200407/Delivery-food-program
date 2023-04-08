
import SwiftUI
import SDWebImage
import SDWebImageSwiftUI
struct CartView: View {
    @ObservedObject var homeData: HomeViewModel
    @Environment (\.presentationMode) var present
    var body: some View {
        GeometryReader{ geometry in
     
            VStack{
                HStack(spacing: 20){
                    Button(action: {present.wrappedValue.dismiss()}){
                        Image(systemName: "chevron.left")
                            .font(.system(size: 26,weight: .heavy))
                            .foregroundColor(.green)
                        
                    }

                    Text("My cart")
                        .font(Font.system(size: 36, weight: .bold))
                        .multilineTextAlignment(.center)
                        .overlay {
                            LinearGradient(
                                colors: [.init("Color"), .orange, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .mask(
                                Text("My cart")
                                    .font(Font.system(size: 36, weight: .bold))
                                    .multilineTextAlignment(.center)
                            )
                        }
                    Spacer()
                }
                .padding()
                
                ScrollView(.vertical,showsIndicators: false){
                    
                    LazyVStack(spacing: 0){
                        
                        ForEach(homeData.cartItems){cart in
                            HStack(spacing: 15){
                                WebImage(url: URL(string: cart.item.dish_photo))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 130,height: 130)
                                    .cornerRadius(15)
                                VStack(alignment: .leading, spacing: 10){
                                    Text(cart.item.dish_name)
                                        .font(.callout)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    Text(cart.item.dish_description)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.init("Color"))
                                        .italic()
                                    HStack(spacing: 15){
                                        Text(homeData.getPrice(value: Float(truncating: cart.item.dish_price) ))
                                            .font(.callout)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                        Spacer(minLength: 0)
                                        Button(action: {
                                            if cart.amount > 1{
                                                homeData.cartItems[homeData.getIndex(item: cart.item, isCartIndex: true)].amount -= 1
                                            }
                                        }){
                                            Image(systemName: "minus")
                                                .font(.system(size: 16,weight: .heavy))
                                                .foregroundColor(.black)
                                        }
                                        Text("\(cart.amount)")
                                            .fontWeight(.heavy)
                                            .foregroundColor(.black)
                                            .padding(.vertical)
                                            .padding(.horizontal)
                                            .background(Color.black.opacity(0.06))
                                        Button(action: {
                                            homeData.cartItems[homeData.getIndex(item: cart.item, isCartIndex: true)].amount += 1
                                            
                                        })
                                        {
                                            Image(systemName: "plus")
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .contextMenu{
                                Button(action:{
                                    let index = homeData.getIndex(item: cart.item, isCartIndex: true)
                                    let itemIndex = homeData.getIndex(item: cart.item, isCartIndex: false)
                                    
                                    homeData.items[itemIndex].isInCart = false
                                    homeData.filteredData[itemIndex].isInCart = false
                                    homeData.cartItems .remove(at: index)
                                    
                                }){
                                    Text("Delete")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                        .background(Color.init("Color"))
                                        
                                }
                            }
                        }
                    }
                }
                VStack{
                    HStack{
                        Text("Total💚")
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Spacer()
                        Text(homeData.calculatePrice())
                            .font(.title)
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                    }
                    .padding([.top,.horizontal])
                    Button(action: homeData.updating){
                        Text(homeData.orderedDishes ? "Deny Order" : "Confirm the order")
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .frame(width: UIScreen.main.bounds.width - 15)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.init("Color")]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10)
                    }
                }
                Spacer(minLength: 0)
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            Spacer(minLength: 0)
            
        }
    }
}
