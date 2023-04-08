
import SwiftUI
import SDWebImageSwiftUI
struct ItemView: View {
    var item: Item
    var body: some View {
        VStack{
            //Photos
            WebImage(url: URL(string: item.dish_photo))
                .resizable()
                .aspectRatio( contentMode: .fill)
                .frame(height: 268)


            Spacer(minLength: 0)
            
            //Dish names
            HStack(spacing: 2){
                Text(item.dish_name )
                    .font(/*@START_MENU_TOKEN@*/.title3/*@END_MENU_TOKEN@*/)
                    .background(.white)
                    .border(.green)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.black)
                Spacer(minLength: 0)

                
                //Ratings
                ForEach(1...5,id: \.self){index in
                    Image(systemName: "star.fill")
                        .foregroundColor(index <= Int(item.dish_rank) ?? 0 ?
                                         Color.green : .gray )

                }
            }
            //Dish ingredients
            HStack{
                Spacer(minLength: 0)
                Text(item.dish_ingredients)
                    .multilineTextAlignment(.leading)
                    .background(.white)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .border(.green)
                    .lineLimit(4)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .leadingLastTextBaseline)
                
                Spacer(minLength: 0)
            }
        }

    }
}

