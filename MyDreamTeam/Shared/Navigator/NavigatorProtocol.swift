//
//  NavigatorProtocol.swift
//  Gula
//
//  Created by Adrián Prieto Villena on 21/7/25.
//

import SwiftUI

protocol NavigatorProtocol: NavigatorManagerProtocol, ModalPresenterProtocol {
    // MARK: - Properties
    var path: [Page] { get set }
    var root: Page? { get }
    // MARK: - Methods
    func initialize(root view: any View)
}

protocol NavigatorManagerProtocol {
    // MARK: - Properties
    var sheet: Page? { get set }
    var fullOverSheet: Page? { get set }
    var nestedSheet: Page? { get set }
    var tabIndex: Int { get set }
    var tabBadges: [TabItem: Int] { get set }
    var fullOverNestedSheet: Page? { get set }
    var isEnabledBackGesture: Bool { get set }

    // MARK: - Methods
    func push(to view: any View)
    func pushAndRemovePrevious(to view: any View)
    func dismiss()
    func dismissSheet()
    func dismissFullOverScreen()
    func dismissAll()
    func replaceRoot(to view: any View)
    func present(view: any View)
    func presentCustomConfirmationDialog(from config: ConfirmationDialogConfig)
    func changeTab(index: Int)
}

protocol ModalPresenterProtocol {
    // MARK: - Properties
    var toastConfig: ToastConfig? { get set }
    var alertModel: AlertModel { get }
    var confirmationDialogConfig: ConfirmationDialogConfig? { get }
    var fullOverScreenConfig: FullOverScreenConfig? { get }
    var isPresentingAlert: Bool { get set }
    var isPresentingConfirmationDialog: Bool { get set }
    var isPresentingFullOverScreen: Bool { get set }

    // MARK: - Methods
    func showAlert(alertModel: AlertModel)
    func showToast(from toast: ToastConfig)
    func presentFullOverScreen(view: any View)
    func dismissToast()
}

