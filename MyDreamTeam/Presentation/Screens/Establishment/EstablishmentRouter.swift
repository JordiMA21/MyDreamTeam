//
//  EstablishmentRouter.swift
//  Gula
//
//  Created by Eduard on 6/8/25.
//

import SwiftUI

class EstablishmentRouter: Router {
    func goToEmptyView() {
        let view = EmptyView()
        navigator.push(to: view)
    }
}
