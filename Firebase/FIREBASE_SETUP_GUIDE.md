# Firebase Setup Complete - MyDreamTeam

## ✅ Archivos Creados

He creado todos los archivos necesarios para interactuar con Firebase:

### 1. Configuración
- ✅ `MyDreamTeam/Shared/Configuration/ConfigFirebase.swift` - Configuración de Firebase

### 2. Entidades de Dominio
- ✅ `MyDreamTeam/Domain/Entities/UserEntity.swift` - Entidad de Usuario

### 3. DTOs (Data Transfer Objects)
- ✅ `MyDreamTeam/Data/DTOs/FirebaseUserDTO.swift` - DTO para Usuario con mappers

### 4. DataSources
- ✅ `MyDreamTeam/Data/DataSources/Firebase/UserFirestoreDataSource.swift` - Acceso a Firestore

### 5. Repositories
- ✅ `MyDreamTeam/Data/Repositories/UserRepository.swift` - Implementación de repositorio

### 6. UseCases
- ✅ `MyDreamTeam/Domain/UseCases/UserUseCase.swift` - Lógica de negocio de Usuario

### 7. DI Containers
- ✅ `MyDreamTeam/DI/Containers/Firebase/UserContainer.swift` - Inyección de dependencias

---

## 🚀 Próximos Pasos

### 1. Inicializar Firebase en tu App

En `MyDreamTeamApp.swift`, ya está o debes agregar:

```swift
import SwiftUI
import FirebaseCore

@main
struct MyDreamTeamApp: App {

    init() {
        FirebaseConfig.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            NavigatorRootView(root: HomeBuilder.build())
        }
    }
}
```

### 2. Crear Colecciones en Firestore

Ve a [Firebase Console](https://console.firebase.google.com/):

1. Selecciona tu proyecto
2. Ve a Firestore Database
3. Crea las colecciones según `FIREBASE_STRUCTURE.md`:
   - `users` (colección principal)
   - `leagues` (ligas fantasy)
   - `teams` (equipos reales)
   - `players` (jugadores)
   - `matches` (resultados)
   - Etc.

**Ejemplo para crear colección `users`:**
- Click "Create collection" → Nombre: `users`
- Click "Auto ID" para crear primer documento
- Agrega estos campos:
  ```
  uid: String
  email: String
  displayName: String
  profileImage: String (opcional)
  bio: String (opcional)
  createdAt: Timestamp
  updatedAt: Timestamp
  status: String ("active")
  ```

### 3. Configurar Security Rules

Ve a **Firestore → Rules** en Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios - solo el propietario puede escribir
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
      allow delete: if request.auth.uid == userId;
    }

    // Ligas - lectura pública, escritura autenticada
    match /leagues/{leagueId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if resource.data.createdBy == request.auth.uid;
    }

    // Equipos y Jugadores - solo lectura
    match /teams/{teamId} {
      allow read: if true;
      allow write: if false;
    }

    match /players/{playerId} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

**Publica las reglas:**
- Click "Publish"

### 4. Crear Datos de Ejemplo

Para probar el código, crea un usuario de ejemplo:

```swift
// Esto puedes ejecutar en un ViewModel o desde la consola
let exampleUser = UserEntity(
    id: "user123",
    uid: "firebase-uid-123",
    email: "test@example.com",
    displayName: "Test User",
    profileImage: nil,
    bio: "Test bio",
    createdAt: Date(),
    updatedAt: Date(),
    preferences: UserPreferences(
        favoriteTeam: "team1",
        favoriteLeagues: [],
        notifications: true,
        language: "es"
    ),
    stats: UserStats(
        leaguesCreated: 0,
        leaguesJoined: 0,
        totalPoints: 0,
        rank: 0
    ),
    status: "active"
)
```

O directamente en Firebase Console:
- Firestore → Collection `users` → Add Document
- Document ID: el UID del usuario
- Agrega los campos del UserEntity

### 5. Usar el Código en ViewModels

Ejemplo de cómo usar en un ViewModel:

```swift
@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: UserEntity?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let router: ProfileRouter
    private let useCase: UserUseCaseProtocol

    init(router: ProfileRouter, useCase: UserUseCaseProtocol) {
        self.router = router
        self.useCase = useCase
    }

    func loadCurrentUser() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                user = try await useCase.getCurrentUser()
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }

    func updateProfile(displayName: String, bio: String) {
        Task {
            do {
                try await useCase.updateUserProfile(displayName: displayName, bio: bio)
                user = try await useCase.getCurrentUser()
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }
}
```

### 6. Builder para Profile Screen

```swift
enum ProfileBuilder {
    static func build() -> some View {
        let router = ProfileRouter()
        let useCase = UserContainer.shared.makeUseCase()
        let viewModel = ProfileViewModel(router: router, useCase: useCase)
        return ProfileView(viewModel: viewModel)
    }
}
```

---

## 📋 Estructura de Archivos Creados

```
MyDreamTeam/
├── Shared/
│   └── Configuration/
│       └── ConfigFirebase.swift ✅
├── Domain/
│   ├── Entities/
│   │   └── UserEntity.swift ✅
│   └── UseCases/
│       └── UserUseCase.swift ✅
├── Data/
│   ├── DTOs/
│   │   └── FirebaseUserDTO.swift ✅
│   ├── DataSources/
│   │   └── Firebase/
│   │       └── UserFirestoreDataSource.swift ✅
│   └── Repositories/
│       └── UserRepository.swift ✅
└── DI/
    └── Containers/
        └── Firebase/
            └── UserContainer.swift ✅
```

---

## 🔧 Verificación de Setup

1. **Compila el proyecto:**
   ```bash
   xcodebuild -scheme MyDreamTeam -configuration Debug
   ```

2. **Verifica que GoogleService-Info.plist está en el proyecto**
   - Debe estar en la carpeta raíz
   - Debe estar añadido al target `MyDreamTeam`

3. **Comprueba que Firebase está inicializándose:**
   - Ejecuta la app
   - Abre la consola (Xcode → View → Debug Area → Console)
   - Deberías ver logs de Firebase inicializándose

4. **Prueba una escritura básica:**
   - Crea un test que escriba un usuario
   - Verifica en Firebase Console que aparece en Firestore

---

## 🎯 Qué Falta Implementar

Tengo creado el código para **Usuario**. Para completar la app necesitamos:

### Colecciones Faltantes (en orden de prioridad):

1. **Ligas Fantasy** (`leagues`, `leagueMembers`)
   - DTOs: `FirebaseLeagueDTO.swift`
   - DataSource: `LeagueFirestoreDataSource.swift`
   - Repository: `LeagueRepository.swift`
   - UseCase: `LeagueUseCase.swift`

2. **Equipos y Jugadores** (`teams`, `players`)
   - DTOs: `FirebaseTeamDTO.swift`, `FirebasePlayerDTO.swift`
   - DataSources
   - Repositories
   - UseCases

3. **Resultados de Partidos** (`matches`)
   - DTO: `FirebaseMatchDTO.swift`
   - DataSource, Repository, UseCase

4. **Tablón de Liga** (`leagueFeed`)
   - Para comentarios y eventos de la liga
   - DTOs, DataSources, Repositories, UseCases

5. **Mercado de Fichajes** (`transfers`)
   - DTOs, DataSources, Repositories, UseCases

6. **Realtime Database**
   - Para eventos deportivos en vivo
   - Listeners para partidos en directo

---

## 💡 Próximo Paso

**¿Quieres que genere el código para:**
- [ ] Ligas Fantasy
- [ ] Equipos y Jugadores
- [ ] Resultados y Mercado de Fichajes
- [ ] Tablón de Liga (Feed)
- [ ] Realtime Database para eventos

**¿Todo de una vez o paso a paso?**

---

## 📚 Documentos de Referencia

- `FIREBASE_STRUCTURE.md` - Estructura completa de Firestore
- `FIREBASE_SWIFT_SETUP.md` - Implementación detallada en Swift
- `FIREBASE_SETUP_GUIDE.md` - Este documento

---

## ⚠️ Notas Importantes

1. **Offline Persistence:**
   - Firestore guardará datos en caché localmente
   - Los cambios se sincronizarán cuando haya conexión

2. **Transacciones:**
   - Para operaciones que afecten múltiples documentos, usa transacciones
   - Ej: Cuando un usuario se une a una liga

3. **Security Rules:**
   - En desarrollo puedes usar reglas permisivas
   - Antes de producción, configura reglas restrictivas

4. **Backups:**
   - Firebase realiza backups automáticos
   - Puedes habilitar exportaciones periódicas

5. **Costos:**
   - Plan gratuito: 50k lecturas/día, 20k escrituras/día
   - Suficiente para desarrollo y pruebas

---

## 🆘 Si Tienes Problemas

**Error: "The caller does not have permission to execute the specified operation"**
- Verifica las Security Rules
- Asegúrate que `Auth.auth().currentUser` no es nil

**Error: "The connection to Firestore failed"**
- Verifica conectividad
- Comprueba que el `GoogleService-Info.plist` está correcto

**Error: "Cannot decode data"**
- Verifica que los campos en Firestore coinciden con el DTO
- Los tipos de datos deben ser iguales (String, Int, Date, etc.)

---

¡Firebase está listo para usar! 🎉
