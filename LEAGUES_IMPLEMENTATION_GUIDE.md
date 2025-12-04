# Ligas Fantasy - Guía de Implementación

## 📁 Archivos Creados

### Entidades de Dominio
- ✅ `MyDreamTeam/Domain/Entities/LeagueEntity.swift` - Entidades de Liga y Miembro

### DTOs (Data Transfer Objects)
- ✅ `MyDreamTeam/Data/DTOs/FirebaseLeagueDTO.swift` - DTO de Liga con mappers
- ✅ `MyDreamTeam/Data/DTOs/FirebaseLeagueMemberDTO.swift` - DTO de Miembro con mappers

### DataSources
- ✅ `MyDreamTeam/Data/DataSources/Firebase/LeagueFirestoreDataSource.swift` - Acceso a colección `leagues`
- ✅ `MyDreamTeam/Data/DataSources/Firebase/LeagueMemberFirestoreDataSource.swift` - Acceso a sub-colección `members`

### Repository
- ✅ `MyDreamTeam/Data/Repositories/LeagueRepository.swift` - Orquestación de DataSources

### UseCase
- ✅ `MyDreamTeam/Domain/UseCases/LeagueUseCase.swift` - Lógica de negocio de Ligas

### DI Container
- ✅ `MyDreamTeam/DI/Containers/Firebase/LeagueContainer.swift` - Inyección de dependencias

---

## 🎯 Funcionalidades Implementadas

### 1. **Crear Liga**
- Usuario puede crear una liga
- Se convierte automáticamente en miembro
- La liga comienza en estado "active"
- Duración de 9 meses

### 2. **Unirse a Liga**
- Usuario puede unirse a ligas públicas
- Verifica que no es ya miembro
- Verifica que la liga no está llena
- Inicializa stats del miembro en 0

### 3. **Abandonar Liga**
- Usuario puede abandonar una liga
- El creador NO puede abandonar (debe eliminar la liga)

### 4. **Ver Ligas**
- Ver ligas que creó
- Ver ligas a las que se unió (múltiples ligas)
- Ver ligas públicas
- Buscar ligas por nombre

### 5. **Ver Ranking**
- Obtener miembros de una liga ordenados por puntos

### 6. **Actualizar Datos**
- Cambiar nombre del equipo
- Actualizar puntos y estadísticas
- Gestionar transferencias

---

## 💻 Ejemplos de Uso

### 1. Crear una Liga

```swift
@MainActor
final class CreateLeagueViewModel: ObservableObject {
    @Published var leagueName = ""
    @Published var description = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let router: CreateLeagueRouter
    private let useCase: LeagueUseCaseProtocol

    init(router: CreateLeagueRouter, useCase: LeagueUseCaseProtocol) {
        self.router = router
        self.useCase = useCase
    }

    func createLeague() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                let scoringRules = ScoringRulesEntity(
                    goalScore: 5,
                    assistScore: 3,
                    cleanSheetScore: 4,
                    yellowCardScore: -1,
                    redCardScore: -3
                )

                let leagueId = try await useCase.createLeague(
                    name: leagueName,
                    description: description,
                    season: 2024,
                    scoringRules: scoringRules
                )

                // Navegar a la liga creada
                router.navigateToLeagueDetail(leagueId: leagueId)
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }
}
```

### 2. Ver Ligas del Usuario (Múltiples)

```swift
@MainActor
final class MyLeaguesViewModel: ObservableObject {
    @Published var joinedLeagues: [LeagueEntity] = []
    @Published var createdLeagues: [LeagueEntity] = []
    @Published var isLoading = false

    private let router: MyLeaguesRouter
    private let useCase: LeagueUseCaseProtocol

    init(router: MyLeaguesRouter, useCase: LeagueUseCaseProtocol) {
        self.router = router
        self.useCase = useCase
    }

    func loadUserLeagues() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                // Cargar ligas a las que se unió
                joinedLeagues = try await useCase.getUserJoinedLeagues()

                // Cargar ligas que creó
                createdLeagues = try await useCase.getUserCreatedLeagues()
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }

    func didSelectLeague(_ league: LeagueEntity) {
        router.navigateToLeagueDetail(leagueId: league.id)
    }

    func didTapLeave(league: LeagueEntity) {
        Task {
            do {
                try await useCase.leaveLeague(leagueId: league.id)
                // Recargar ligas
                loadUserLeagues()
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }
}
```

### 3. Vista de Ligas Públicas

```swift
@MainActor
final class BrowseLeaguesViewModel: ObservableObject {
    @Published var publicLeagues: [LeagueEntity] = []
    @Published var searchQuery = ""
    @Published var isLoading = false

    private let router: BrowseLeaguesRouter
    private let useCase: LeagueUseCaseProtocol

    init(router: BrowseLeaguesRouter, useCase: LeagueUseCaseProtocol) {
        self.router = router
        self.useCase = useCase
    }

    func loadPublicLeagues() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                publicLeagues = try await useCase.getPublicLeagues(season: 2024)
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }

    func search(query: String) {
        Task {
            do {
                if query.isEmpty {
                    publicLeagues = try await useCase.getPublicLeagues(season: 2024)
                } else {
                    publicLeagues = try await useCase.searchLeagues(query: query)
                }
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }

    func joinLeague(_ league: LeagueEntity, teamName: String) {
        Task {
            do {
                try await useCase.joinLeague(leagueId: league.id, teamName: teamName)
                router.showToastWithCloseAction(with: "¡Te has unido a \(league.name)!")
                loadPublicLeagues()
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }
}
```

### 4. Detalle de Liga con Ranking

```swift
@MainActor
final class LeagueDetailViewModel: ObservableObject {
    @Published var league: LeagueEntity?
    @Published var ranking: [LeagueMemberEntity] = []
    @Published var isUserMember = false
    @Published var isLoading = false

    private let router: LeagueDetailRouter
    private let useCase: LeagueUseCaseProtocol
    private let leagueId: String

    init(router: LeagueDetailRouter, useCase: LeagueUseCaseProtocol, leagueId: String) {
        self.router = router
        self.useCase = useCase
        self.leagueId = leagueId
    }

    func loadLeagueData() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                league = try await useCase.getLeague(leagueId: leagueId)
                ranking = try await useCase.getLeagueRanking(leagueId: leagueId)
                isUserMember = try await useCase.isUserMemberOfLeague(leagueId: leagueId)
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }

    func leaveLeague() {
        Task {
            do {
                try await useCase.leaveLeague(leagueId: leagueId)
                router.showToastWithCloseAction(with: "Has abandonado la liga")
                router.dismiss()
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }
}
```

### 5. Builder para Create League Screen

```swift
enum CreateLeagueBuilder {
    static func build() -> some View {
        let router = CreateLeagueRouter()
        let useCase = LeagueContainer.shared.makeUseCase()
        let viewModel = CreateLeagueViewModel(router: router, useCase: useCase)
        return CreateLeagueView(viewModel: viewModel)
    }
}
```

---

## 📊 Estructura en Firestore

```
Firestore Database
├── leagues/
│   ├── {leagueId}
│   │   ├── name: String
│   │   ├── description: String
│   │   ├── createdBy: String (userId)
│   │   ├── createdAt: Timestamp
│   │   ├── season: Int
│   │   ├── status: String
│   │   ├── totalPlayers: Int
│   │   ├── scoringRules: Map
│   │   ├── settings: Map
│   │   └── members/
│   │       ├── {userId}
│   │       │   ├── leagueId: String
│   │       │   ├── userId: String
│   │       │   ├── teamName: String
│   │       │   ├── joinedAt: Timestamp
│   │       │   ├── totalPoints: Int
│   │       │   ├── rank: Int
│   │       │   ├── status: String
│   │       │   └── squad: [playerIds]
```

---

## 🔑 Características Clave

### 1. **Multiple Leagues por Usuario**
✅ Un usuario puede estar en VARIAS ligas simultáneamente
✅ Cada liga tiene su propio ranking independiente
✅ Cada usuario tiene un equipo diferente en cada liga

### 2. **Scoring Personalizable**
✅ Goles, asistencias, limpias son configurables
✅ Reglas de sanciones (amarillas, rojas)
✅ Posibilidad de custom scoring

### 3. **Transferencias**
✅ Límite de 2 transferencias iniciales
✅ Se reponen cada jornada (implementar luego)
✅ Deadline de transferencia configurable

### 4. **Validaciones**
✅ No duplicar membresía
✅ Validar que la liga no está llena
✅ Solo creador puede eliminar
✅ El creador no puede abandonar

---

## 🔐 Security Rules para Ligas

```javascript
// En Firebase Console → Firestore Rules

match /leagues/{leagueId} {
  allow read: if true; // Público
  allow create: if request.auth != null;
  allow update, delete: if resource.data.createdBy == request.auth.uid;

  match /members/{userId} {
    allow read: if true; // Los rankings son públicos
    allow write: if request.auth.uid == userId ||
                   get(/databases/$(database)/documents/leagues/$(leagueId)).data.createdBy == request.auth.uid;
  }
}
```

---

## 📋 Flujo Típico de Usuario

```
1. Usuario abre app
   ↓
2. Ve "Browse Leagues" → Carga ligas públicas
   ↓
3. Puede:
   a) Crear liga nueva → Se une automáticamente
   b) Unirse a liga existente → Elige nombre del equipo
   c) Ver sus ligas → Muestra creadas + unidas
   ↓
4. En cada liga puede:
   - Ver ranking
   - Ver su equipo
   - Cambiar nombre del equipo
   - Abandonar liga (salvo si es creador)
   ↓
5. Después (próximas implementaciones):
   - Ver tablón (feed)
   - Gestionar equipo (próximos pasos)
   - Ver matchups
   - Recibir notificaciones
```

---

## ✅ Testing

Para probar el código:

```swift
// En un test o preview
let scoringRules = ScoringRulesEntity(
    goalScore: 5,
    assistScore: 3,
    cleanSheetScore: 4,
    yellowCardScore: -1,
    redCardScore: -3
)

let mockUseCase = MockLeagueUseCase()
let mockRouter = MockLeagueRouter()
let viewModel = CreateLeagueViewModel(router: mockRouter, useCase: mockUseCase)

// Luego:
viewModel.leagueName = "Test League"
viewModel.createLeague()
```

---

## 🚀 Próximos Pasos

Para completar Ligas Fantasy, falta:

1. **League Feed / Tablón** - Posts y comentarios en la liga
2. **Team Management** - Seleccionar y gestionar equipo fantasy
3. **Matchups** - Enfrentamientos semanales entre usuarios
4. **Notifications** - Alertas cuando pasa algo en la liga
5. **Statistics** - Más stats detalladas por usuario

¿Cuál quieres implementar siguiente?

---

## 🔧 Troubleshooting

**Error: "Ya eres miembro de esta liga"**
- Significa que intentas unirte a una liga en la que ya estás
- Solución: Verifica la lista de tus ligas antes de unirte

**Error: "La liga está llena"**
- La liga alcanzó el máximo de jugadores (20)
- Solución: Busca otra liga

**Error: "El creador no puede abandonar"**
- Si creaste la liga, debes eliminarla en su lugar
- Solución: Ve a "Mis Ligas Creadas" y elimina desde ahí

---

¡Ligas Fantasy está listo para usar! 🎉
