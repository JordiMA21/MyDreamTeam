import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAnalytics

// MARK: - Firebase Configuration

class FirebaseConfig {
    static let shared = FirebaseConfig()

    private init() {}

    // MARK: - Public Methods

    func configure() {
        FirebaseApp.configure()

        configureFirestore()
        configureAuth()
        configureAnalytics()
    }

    func getFirestore() -> Firestore {
        Firestore.firestore()
    }

    func getDatabase() -> Database {
        Database.database()
    }

    func getAuth() -> Auth {
        Auth.auth()
    }

    // MARK: - Private Configuration Methods

    private func configureFirestore() {
        let settings = FirestoreSettings()

        // Configure cache settings with unlimited size
        let cacheSettings = PersistentCacheSettings()
        settings.cacheSettings = cacheSettings

        Firestore.firestore().settings = settings
    }

    private func configureAuth() {
        // Set language code
        if let languageCode = Locale.current.language.languageCode {
            Auth.auth().languageCode = languageCode.identifier
        } else {
            Auth.auth().languageCode = "es"
        }

        // Enable persistence
        do {
            try Auth.auth().useUserAccessGroup("group.mydreamteam")
        } catch {
            print("Error configuring Auth: \(error.localizedDescription)")
        }
    }

    private func configureAnalytics() {
        Analytics.setAnalyticsCollectionEnabled(true)
        Analytics.setSessionTimeoutInterval(1800) // 30 minutes
    }
}
