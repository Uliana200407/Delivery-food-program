

import SwiftUI

struct Item : Identifiable{
    var id: String
    var dish_name: String
    var dish_photo: String
    var dish_description: String
    var dish_ingredients: String
    var dish_price: NSNumber
    var dish_rank: String
    var isInCart: Bool = false
}
