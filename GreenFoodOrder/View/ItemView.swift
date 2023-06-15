import SwiftUI
import SDWebImageSwiftUI

struct ItemView: View {
    @State private var isShowingDetail = false
       var item: Item

    var body: some View {
        VStack {
            // Photos
            WebImage(url: URL(string: item.dish_photo))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 268)
            
            Spacer(minLength: 0)
            
            // Dish names
            HStack(spacing: 2) {
                Text(item.dish_name)
                    .font(.title3)
                    .background(Color.white)
                    .border(Color.green)
                    .fontWeight(.heavy)
                    .foregroundColor(.black)
                
                Spacer(minLength: 0)
                
                // Ratings
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .foregroundColor(index <= Int(item.dish_rank) ?? 0 ? Color.green : .gray)
                }
            }
            
            // Dish ingredients
            HStack {
                Spacer(minLength: 0)
                Text(item.dish_ingredients)
                    .multilineTextAlignment(.leading)
                    .background(Color.white)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .border(Color.green)
                    .lineLimit(4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leadingLastTextBaseline)
                Spacer(minLength: 0)
            }
          


       

            Spacer()
            Button(action: {
                         isShowingDetail.toggle()
                     }) {
                         Text("Show Details🍴")
                             .foregroundColor(Color.white)
                             
                             .bold()
                     }
                     .sheet(isPresented: $isShowingDetail, onDismiss: {
                         // Optional: Code to run when modal is dismissed
                     }) {
                         DetailedView(item: item)
                     }
            
                 }
             }
         }
struct DetailedView: View {
    var item: Item
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            // Photos
            WebImage(url: URL(string: item.dish_photo))
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            // Dish name
            Text(item.dish_name)
                .font(.title)
                .fontWeight(.bold)
            
            // Ratings
            HStack {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .foregroundColor(index <= Int(item.dish_rank) ?? 0 ? Color.green : .gray)
                }
            }
            
            // Dish ingredients
            Text(item.dish_ingredients)
                .multilineTextAlignment(.center)
                .font(.body)
            
            HStack {
                // Dish price
                Text("＄Price: \(item.dish_price.stringValue)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                
                Spacer()
                
                
                
                // Dish calories
                Text("Calories: \(item.dish_cal.stringValue)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 20) 
            
            // Close button
            Button(action: {
                withAnimation(.spring()) {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("Return⏎")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
        }}}
