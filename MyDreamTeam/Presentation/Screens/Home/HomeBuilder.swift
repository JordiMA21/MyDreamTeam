import SwiftUI

class HomeBuilder {
    static func build() -> some View {
        let router = HomeRouter()
        let viewModel = HomeViewModel(router: router)
        return HomeView(viewModel: viewModel)
    }
}
