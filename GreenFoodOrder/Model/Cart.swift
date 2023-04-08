

import SwiftUI

struct Cart: Identifiable {
    var id = UUID().uuidString
    var item: Item
    var amount: Int
}
