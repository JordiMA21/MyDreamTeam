import Foundation

struct AuthenticatedUser {
    let id: String
    let email: String
    let displayName: String
    let photoURL: URL?
    let isEmailVerified: Bool
    let createdAt: Date
}
