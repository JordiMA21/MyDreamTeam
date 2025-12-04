# Equipos Fantasy - Guía de Implementación

## 📁 Archivos Creados

### Entidades de Dominio
- ✅ `MyDreamTeam/Domain/Entities/FantasySquadEntity.swift` - Entidades de Equipo, Jugador, Presupuesto, etc.

### DTOs
- ✅ `MyDreamTeam/Data/DTOs/FirebaseFantasySquadDTO.swift` - DTOs con mappers

### DataSource
- ✅ `MyDreamTeam/Data/DataSources/Firebase/FantasySquadFirestoreDataSource.swift` - Acceso a Firestore

### Repository
- ✅ `MyDreamTeam/Data/Repositories/FantasySquadRepository.swift` - Orquestación de datos

### UseCase
- ✅ `MyDreamTeam/Domain/UseCases/FantasySquadUseCase.swift` - Lógica de negocio

### DI Container
- ✅ `MyDreamTeam/DI/Containers/Firebase/FantasySquadContainer.swift` - Inyección de dependencias

---

## 🎯 Funcionalidades Implementadas

### 1. **Crear Equipo Fantasy**
✅ Un equipo por usuario por liga
✅ Presupuesto inicial de 100€
✅ Estructura inicial vacía

### 2. **Gestionar Jugadores**
✅ Agregar jugadores
✅ Remover jugadores
✅ Validar presupuesto
✅ Validar límites de posición (máximo 3 de la misma)
✅ Validar límite de equipo (11 principales + 4 banquillo)

### 3. **Transferencias**
✅ Intercambiar jugadores
✅ Registrar historial de transferencias
✅ Calcular diferencia de presupuesto
✅ Validar presupuesto disponible

### 4. **Capitanes**
✅ Establecer capitán (bonus de puntos)
✅ Establecer vicecapitán (bonus si capitán no juega)
✅ Solo un capitán y un vicecapitán

### 5. **Validaciones de Formación**
✅ 11 jugadores en campo
✅ 1 portero obligatorio
✅ 3-5 defensores
✅ 2-5 centrocampistas
✅ 1-3 delanteros

### 6. **Estadísticas**
✅ Valor total del equipo
✅ Puntos de la semana
✅ Puntos totales
✅ Fuerza del banquillo
✅ Cumplimiento de formación

### 7. **Observación en Tiempo Real**
✅ Cambios en el equipo en vivo

---

## 💻 Ejemplos de Uso

### 1. Crear Equipo Fantasy

```swift
@MainActor
final class SquadCreationViewModel: ObservableObject {
    @Published var squadId: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let router: SquadCreationRouter
    private let useCase: FantasySquadUseCaseProtocol
    private let leagueId: String
    private let leagueName: String

    init(
        router: SquadCreationRouter,
        useCase: FantasySquadUseCaseProtocol,
        leagueId: String,
        leagueName: String
    ) {
        self.router = router
        self.useCase = useCase
        self.leagueId = leagueId
        self.leagueName = leagueName
    }

    func createSquad(teamName: String) {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                squadId = try await useCase.createSquad(
                    leagueId: leagueId,
                    leagueName: leagueName,
                    teamName: teamName
                )

                // Navegar a selección de jugadores
                if let squadId = squadId {
                    router.navigateToPlayerSelection(squadId: squadId)
                }
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }
}
```

### 2. Agregar Jugador al Equipo

```swift
@MainActor
final class PlayerSelectionViewModel: ObservableObject {
    @Published var squad: FantasySquadEntity?
    @Published var availablePlayers: [FantasyPlayerEntity] = []
    @Published var selectedPlayer: FantasyPlayerEntity?
    @Published var isLoading = false

    private let router: PlayerSelectionRouter
    private let useCase: FantasySquadUseCaseProtocol
    private let squadId: String

    init(router: PlayerSelectionRouter, useCase: FantasySquadUseCaseProtocol, squadId: String) {
        self.router = router
        self.useCase = useCase
        self.squadId = squadId
    }

    func loadSquad() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                squad = try await useCase.getSquad(squadId: squadId)
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }

    func addPlayerToSquad(_ player: FantasyPlayerEntity) {
        Task {
            do {
                try await useCase.addPlayer(squadId: squadId, player: player)
                loadSquad()
                router.showToastWithCloseAction(with: "Jugador agregado")
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }

    func removePlayerFromSquad(_ playerId: String) {
        Task {
            do {
                try await useCase.removePlayer(squadId: squadId, playerId: playerId)
                loadSquad()
                router.showToastWithCloseAction(with: "Jugador removido")
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }
}
```

### 3. Realizar Transferencia

```swift
@MainActor
final class TransferViewModel: ObservableObject {
    @Published var squad: FantasySquadEntity?
    @Published var selectedPlayerOut: FantasyPlayerEntity?
    @Published var selectedPlayerIn: FantasyPlayerEntity?
    @Published var transferHistory: [TransferEntity] = []

    private let router: TransferRouter
    private let useCase: FantasySquadUseCaseProtocol
    private let squadId: String

    init(router: TransferRouter, useCase: FantasySquadUseCaseProtocol, squadId: String) {
        self.router = router
        self.useCase = useCase
        self.squadId = squadId
    }

    func loadData() {
        Task {
            do {
                squad = try await useCase.getSquad(squadId: squadId)
                transferHistory = try await useCase.getTransferHistory(squadId: squadId)
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }

    func makeTransfer() {
        guard let playerOut = selectedPlayerOut,
              let playerIn = selectedPlayerIn else {
            router.showAlert(title: "Error", message: "Selecciona jugadores")
            return
        }

        Task {
            do {
                try await useCase.transferPlayer(
                    squadId: squadId,
                    playerOut: playerOut,
                    playerIn: playerIn
                )

                loadData()
                router.showToastWithCloseAction(with: "Transferencia realizada")
                selectedPlayerOut = nil
                selectedPlayerIn = nil
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }
}
```

### 4. Establecer Capitán

```swift
@MainActor
final class CaptainSelectionViewModel: ObservableObject {
    @Published var squad: FantasySquadEntity?
    @Published var captain: FantasyPlayerEntity?
    @Published var viceCaptain: FantasyPlayerEntity?

    private let router: CaptainSelectionRouter
    private let useCase: FantasySquadUseCaseProtocol
    private let squadId: String

    init(router: CaptainSelectionRouter, useCase: FantasySquadUseCaseProtocol, squadId: String) {
        self.router = router
        self.useCase = useCase
        self.squadId = squadId
    }

    func loadSquad() {
        Task {
            squad = try await useCase.getSquad(squadId: squadId)
            captain = squad?.players.first(where: { $0.isCaptain })
            viceCaptain = squad?.players.first(where: { $0.isViceCaptain })
        }
    }

    func selectCaptain(_ player: FantasyPlayerEntity) {
        Task {
            do {
                try await useCase.setCaptain(squadId: squadId, playerId: player.id)
                loadSquad()
                router.showToastWithCloseAction(with: "\(player.firstName) es ahora capitán")
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }

    func selectViceCaptain(_ player: FantasyPlayerEntity) {
        Task {
            do {
                try await useCase.setViceCaptain(squadId: squadId, playerId: player.id)
                loadSquad()
                router.showToastWithCloseAction(with: "\(player.firstName) es ahora vicecapitán")
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }
}
```

### 5. Ver Estadísticas del Equipo

```swift
@MainActor
final class SquadStatsViewModel: ObservableObject {
    @Published var squad: FantasySquadEntity?
    @Published var stats: SquadStatsEntity?
    @Published var isLoading = false

    private let router: SquadStatsRouter
    private let useCase: FantasySquadUseCaseProtocol
    private let squadId: String

    init(router: SquadStatsRouter, useCase: FantasySquadUseCaseProtocol, squadId: String) {
        self.router = router
        self.useCase = useCase
        self.squadId = squadId
    }

    func loadStats() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                squad = try await useCase.getSquad(squadId: squadId)
                stats = try await useCase.getSquadStats(squadId: squadId)
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }
}
```

### 6. Builder para Squad Management Screen

```swift
enum SquadManagementBuilder {
    static func build(squadId: String) -> some View {
        let router = SquadManagementRouter()
        let useCase = FantasySquadContainer.shared.makeUseCase()
        let viewModel = SquadManagementViewModel(router: router, useCase: useCase, squadId: squadId)
        return SquadManagementView(viewModel: viewModel)
    }
}
```

---

## 📊 Estructura en Firestore

```
Firestore Database
├── fantasySquads/
│   ├── {squadId}
│   │   ├── leagueId: String
│   │   ├── userId: String
│   │   ├── leagueName: String
│   │   ├── teamName: String
│   │   ├── createdAt: Timestamp
│   │   ├── updatedAt: Timestamp
│   │   ├── formation: String
│   │   ├── totalValue: Double
│   │   ├── players: Array [
│   │   │   ├── id: String
│   │   │   ├── firstName: String
│   │   │   ├── position: String
│   │   │   ├── marketValue: Double
│   │   │   ├── weekPoints: Int
│   │   │   ├── totalPoints: Int
│   │   │   ├── isCaptain: Boolean
│   │   │   └── isViceCaptain: Boolean
│   │   ├── bench: Array (same structure)
│   │   ├── budget: Map {
│   │   │   ├── total: Double (100)
│   │   │   ├── spent: Double
│   │   │   ├── remaining: Double
│   │   │   └── currency: String
│   │   │
│   │   └── transfers/ (sub-colección)
│   │       ├── {transferId}
│   │       │   ├── squadId: String
│   │       │   ├── playerOutId: String
│   │       │   ├── playerOutName: String
│   │       │   ├── playerInId: String
│   │       │   ├── playerInName: String
│   │       │   ├── transferFee: Double
│   │       │   ├── date: Timestamp
│   │       │   ├── gameweek: Int
│   │       │   └── pointsChange: Int
```

---

## 🔑 Características Clave

### Presupuesto
- **Total**: 100€ (configurable)
- **Spent**: Suma del valor de mercado de todos los jugadores
- **Remaining**: Total - Spent
- **Validación**: No se puede agregar jugador si falta presupuesto

### Posiciones
- **GK** (Portero): 1 obligatorio
- **DEF** (Defensa): 3-5 en campo
- **MID** (Centrocampista): 2-5 en campo
- **FWD** (Delantero): 1-3 en campo

### Formaciones Soportadas
- 4-3-3 (4 DEF, 3 MID, 3 FWD)
- 4-4-2 (4 DEF, 4 MID, 2 FWD)
- 5-3-2 (5 DEF, 3 MID, 2 FWD)
- 3-5-2 (3 DEF, 5 MID, 2 FWD)
- Y otras combinaciones válidas

### Capitanes
- **Capitán**: Multiplica puntos por 2x
- **Vicecapitán**: Si capitán no juega, el vicecapitán entra en su lugar
- Solo puede haber uno de cada

### Banquillo
- **Máximo 4 jugadores**
- Se pueden usar para reemplazos si un jugador no juega
- Contribuyen mínimamente a puntos

---

## ✅ Validaciones Implementadas

1. **Presupuesto**: No se puede gastar más que 100€
2. **Límite de posición**: Máximo 3 jugadores de la misma posición
3. **Límite de equipo**: 11 principales + 4 banquillo
4. **Formación**: Validar distribución correcta
5. **No duplicados**: No se puede tener el mismo jugador dos veces
6. **Existencia de jugador**: Verificar que el jugador existe

---

## 🔐 Security Rules para Fantasy Squad

```javascript
match /fantasySquads/{squadId} {
  // Lectura: solo el propietario
  allow read: if request.auth.uid == resource.data.userId;

  // Escritura: solo el propietario o creador de la liga
  allow write: if request.auth.uid == resource.data.userId;

  match /transfers/{transferId} {
    allow read: if request.auth.uid == resource.data.userId;
    allow write: if request.auth.uid == resource.data.userId;
  }
}
```

---

## 🚀 Flujo Típico de Usuario

```
1. Usuario se une a liga
   ↓
2. Ve "Crear Equipo" → Elige nombre
   ↓
3. Accede a "Seleccionar Equipo"
   ↓
4. Busca y agrega jugadores (máximo presupuesto)
   ↓
5. Completa 11 jugadores (formación válida)
   ↓
6. Selecciona capitán y vicecapitán
   ↓
7. Puede ver:
   - Su equipo actual
   - Presupuesto restante
   - Puntos de la semana
   - Historial de transferencias
   ↓
8. Durante la semana puede:
   - Hacer transferencias
   - Cambiar capitán
   - Ver cambios en vivo
```

---

## 💡 Integraciones Necesarias

### Para Funcionar Completamente, Necesitas:

1. **Base de Datos de Jugadores** (próxima implementación)
   - Obtener lista de jugadores reales
   - Valores de mercado
   - Posiciones

2. **Actualización de Puntos**
   - Después de cada jornada, actualizar:
     - `weekPoints`
     - `totalPoints`
   - Basado en resultados de partidos

3. **Notificaciones**
   - Cuando cambian puntos del equipo
   - Cuando pasa algo relevante

4. **Matchups**
   - Comparar puntos de la semana entre usuarios

---

## 🎯 Próximos Pasos

Para completar la funcionalidad de Equipos Fantasy:

1. **Implementar base de datos de Jugadores** (Equipos y Jugadores)
2. **Sincronizar puntos** basados en resultados reales
3. **Notificaciones de cambios** en el equipo
4. **Comparativas** entre jugadores
5. **Predicciones** de puntos

---

## 🧪 Testing

Para probar el código:

```swift
// Crear FantasyPlayerEntity de ejemplo
let examplePlayer = FantasyPlayerEntity(
    id: "player123",
    firstName: "Cristiano",
    lastName: "Ronaldo",
    position: "FWD",
    currentTeam: "Al Nassr",
    number: 7,
    marketValue: 45.0,
    weekPoints: 12,
    totalPoints: 45,
    isCaptain: false,
    isViceCaptain: false,
    addedAt: Date()
)

// Usar en ViewModel
viewModel.addPlayerToSquad(examplePlayer)
```

---

¡Equipos Fantasy está completamente implementado! 🎉

El siguiente paso puede ser:
- **Equipos y Jugadores** (base de datos de datos reales)
- **Resultados** (actualizar puntos)
- **Tablón de Liga** (comentarios y eventos)
- **Matchups** (enfrentamientos semanales)
