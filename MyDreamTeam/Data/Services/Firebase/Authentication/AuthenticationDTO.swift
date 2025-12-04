import Foundation
import FirebaseAuth

struct AuthUserDTO {
    let id: String
    let email: String?
    let displayName: String?
    let photoURL: URL?
    let isEmailVerified: Bool
    let createdDate: Date

    init(from user: User) {
        self.id = user.uid
        self.email = user.email
        self.displayName = user.displayName
        self.photoURL = user.photoURL
        self.isEmailVerified = user.isEmailVerified
        self.createdDate = user.metadata.creationDate ?? Date()
    }
}

extension AuthUserDTO {
    func toDomain() -> AuthenticatedUser {
        AuthenticatedUser(
            id: id,
            email: email ?? "",
            displayName: displayName ?? "",
            photoURL: photoURL,
            isEmailVerified: isEmailVerified,
            createdAt: createdDate
        )
    }
}
