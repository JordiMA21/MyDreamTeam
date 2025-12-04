//
//  Gula
//
//  AlertConfiguration.swift
//
//  Created by Rudo Apps on 6/9/25
//

import SwiftUI

enum AlertStyle {
    case info(action: () -> Void)
    case error(acceptAction: () -> Void, cancelAction: () -> Void)
    case permissions
    case custom(buttons: any View)

    var buttons: some View {
        HStack {
            switch self {
            case .info(let action):
                Button("common_accept") {
                    action()
                }
            case .error(let acceptAction, let cancelAcction):
                Button("common_accept") {
                    acceptAction()
                }
                Button("common_cancel", role: .cancel) {
                    cancelAcction()
                }
            case .permissions:
                VStack {
                    Button("common_cancel", role: .cancel) {}
                    Button("common_goToSettings") {
                        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(appSettings)
                        }
                    }
                }
            case .custom(let buttons):
                AnyView(buttons)
            }
        }
    }
}

struct AlertModel {
    let title: String
    let message: String
    let style: AlertStyle

    init(title: String = "",
         message: String = "",
         style: AlertStyle = .info(action: {})) {
        self.title = title
        self.message = message
        self.style = style
    }
}
