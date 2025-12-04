# Equipos y Jugadores - Guía de Implementación

## 📁 Archivos Creados

### Entidades de Dominio
- ✅ `MyDreamTeam/Domain/Entities/TeamEntity.swift` - Entidades de Equipo, Colores, Estadísticas y Jugador
- ✅ Incluye `PlayerEntity`, `PlayerStatsEntity`, `TeamEntity`, `TeamColorsEntity`, `TeamStatsEntity`

### DTOs
- ✅ `MyDreamTeam/Data/DTOs/FirebaseTeamDTO.swift` - DTOs con mappers bidireccionales
- ✅ `MyDreamTeam/Data/DTOs/FirebasePlayerDTO.swift` - DTOs con mappers bidireccionales

### DataSources
- ✅ `MyDreamTeam/Data/DataSources/Firebase/PlayerFirestoreDataSource.swift` - Acceso a Firestore para Jugadores
- ✅ `MyDreamTeam/Data/DataSources/Firebase/TeamFirestoreDataSource.swift` - Acceso a Firestore para Equipos

### Repositories
- ✅ `MyDreamTeam/Data/Repositories/PlayerRepository.swift` - Orquestación de datos de Jugadores
- ✅ `MyDreamTeam/Data/Repositories/TeamRepository.swift` - Orquestación de datos de Equipos

### UseCases
- ✅ `MyDreamTeam/Domain/UseCases/PlayerUseCase.swift` - Lógica de negocio para Jugadores
- ✅ `MyDreamTeam/Domain/UseCases/TeamUseCase.swift` - Lógica de negocio para Equipos

### DI Containers
- ✅ `MyDreamTeam/DI/Containers/Firebase/PlayerContainer.swift` - Inyección de dependencias
- ✅ `MyDreamTeam/DI/Containers/Firebase/TeamContainer.swift` - Inyección de dependencias

---

## 🎯 Funcionalidades Implementadas

### 1. **Obtener Jugador Individual**
✅ Obtener datos completos de un jugador
✅ Incluir estadísticas
✅ Observación en tiempo real

### 2. **Búsqueda de Jugadores**
✅ Buscar por nombre (firstName + lastName)
✅ Filtrar por posición (GK, DEF, MID, FWD)
✅ Obtener jugadores de un equipo específico
✅ Obtener todos los jugadores de una temporada
✅ Filtrar solo jugadores activos

### 3. **Comparar Jugadores**
✅ Comparar estadísticas entre jugadores
✅ Determinar mejor opción basado en:
  - Goles por partido
  - Asistencias por partido
  - Rating promedio
  - Valor de mercado

### 4. **Obtener Equipos**
✅ Obtener datos completos del equipo
✅ Incluir estadísticas de temporada
✅ Obtener equipos por liga
✅ Obtener equipos de una temporada

### 5. **Búsqueda de Equipos**
✅ Buscar por nombre
✅ Buscar por país
✅ Obtener ranking por puntos
✅ Obtener equipo líder de la liga

### 6. **Observación en Tiempo Real**
✅ Observar cambios en jugadores en vivo
✅ Observar cambios en equipos en vivo

---

## 💻 Ejemplos de Uso

### 1. Buscar Jugadores para Seleccionar en Squad

```swift
@MainActor
final class PlayerSelectionViewModel: ObservableObject {
    @Published var availablePlayers: [PlayerEntity] = []
    @Published var filteredPlayers: [PlayerEntity] = []
    @Published var selectedPosition: String = "FWD"
    @Published var isLoading = false

    private let router: PlayerSelectionRouter
    private let useCase: PlayerUseCaseProtocol
    private let season: Int

    init(router: PlayerSelectionRouter, season: Int) {
        self.router = router
        self.useCase = PlayerContainer.shared.makeUseCase()
        self.season = season
    }

    func loadPlayersByPosition() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                availablePlayers = try await useCase.getAvailablePlayers(
                    for: selectedPosition,
                    season: season
                )
                filteredPlayers = availablePlayers
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }

    func searchPlayers(_ query: String) {
        Task {
            do {
                let results = try await useCase.searchPlayers(query: query, season: season)
                // Filter only the position we're selecting for
                filteredPlayers = results.filter { $0.position == selectedPosition && $0.isActive }
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }
}
```

### 2. Comparar Dos Jugadores

```swift
@MainActor
final class PlayerComparisonViewModel: ObservableObject {
    @Published var player1: PlayerEntity?
    @Published var player2: PlayerEntity?
    @Published var comparison: PlayerComparisonResult?

    private let router: PlayerComparisonRouter
    private let useCase: PlayerUseCaseProtocol

    init(router: PlayerComparisonRouter, player1Id: String, player2Id: String) {
        self.router = router
        self.useCase = PlayerContainer.shared.makeUseCase()
        loadPlayers(player1Id: player1Id, player2Id: player2Id)
    }

    func loadPlayers(player1Id: String, player2Id: String) {
        Task {
            do {
                player1 = try await useCase.getPlayer(playerId: player1Id)
                player2 = try await useCase.getPlayer(playerId: player2Id)

                if let p1 = player1, let p2 = player2 {
                    comparison = useCase.comparePlayerStats(p1, p2)
                }
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }
}
```

### 3. Ver Equipo y Sus Jugadores

```swift
@MainActor
final class TeamDetailViewModel: ObservableObject {
    @Published var team: TeamEntity?
    @Published var teamPlayers: [PlayerEntity] = []
    @Published var isLoading = false

    private let router: TeamDetailRouter
    private let teamUseCase: TeamUseCaseProtocol
    private let playerUseCase: PlayerUseCaseProtocol
    private let teamId: String
    private let season: Int

    init(router: TeamDetailRouter, teamId: String, season: Int) {
        self.router = router
        self.teamUseCase = TeamContainer.shared.makeUseCase()
        self.playerUseCase = PlayerContainer.shared.makeUseCase()
        self.teamId = teamId
        self.season = season
    }

    func loadTeamData() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                team = try await teamUseCase.getTeam(teamId: teamId)
                teamPlayers = try await playerUseCase.getTeamPlayers(
                    teamId: teamId,
                    season: season
                )
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }

    func observeTeam() {
        _ = teamUseCase.observeTeam(teamId: teamId) { [weak self] result in
            switch result {
            case .success(let updatedTeam):
                self?.team = updatedTeam
            case .failure(let error):
                self?.router.showAlert(with: error)
            }
        }
    }
}
```

### 4. Ver Ranking de Equipos

```swift
@MainActor
final class LeagueStandingsViewModel: ObservableObject {
    @Published var teams: [TeamEntity] = []
    @Published var isLoading = false

    private let router: LeagueStandingsRouter
    private let useCase: TeamUseCaseProtocol
    private let league: String
    private let season: Int

    init(router: LeagueStandingsRouter, league: String, season: Int) {
        self.router = router
        self.useCase = TeamContainer.shared.makeUseCase()
        self.league = league
        self.season = season
    }

    func loadStandings() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                teams = try await useCase.getRankedTeams(by: league, season: season)
            } catch let error as AppError {
                router.showAlert(with: error)
            }
        }
    }

    func getLeader() -> TeamEntity? {
        teams.first
    }
}
```

### 5. Builder para Player Selection Screen

```swift
enum PlayerSelectionBuilder {
    static func build(season: Int) -> some View {
        let router = PlayerSelectionRouter()
        let viewModel = PlayerSelectionViewModel(router: router, season: season)
        return PlayerSelectionView(viewModel: viewModel)
    }
}
```

### 6. Builder para Team Detail Screen

```swift
enum TeamDetailBuilder {
    static func build(teamId: String, season: Int) -> some View {
        let router = TeamDetailRouter()
        let viewModel = TeamDetailViewModel(router: router, teamId: teamId, season: season)
        return TeamDetailView(viewModel: viewModel)
    }
}
```

---

## 📊 Estructura en Firestore

```
Firestore Database
├── teams/
│   ├── {teamId}
│   │   ├── id: String (auto)
│   │   ├── name: String
│   │   ├── country: String
│   │   ├── city: String
│   │   ├── founded: Int
│   │   ├── league: String (Premier League, La Liga, etc.)
│   │   ├── coach: String?
│   │   ├── stadium: String?
│   │   ├── logo: String? (URL)
│   │   ├── colors: Object
│   │   │   ├── primary: String (hex color)
│   │   │   └── secondary: String? (hex color)
│   │   ├── season: Int
│   │   └── stats: Object
│   │       ├── played: Int
│   │       ├── won: Int
│   │       ├── drawn: Int
│   │       ├── lost: Int
│   │       ├── goalsFor: Int
│   │       ├── goalsAgainst: Int
│   │       ├── points: Int
│   │       └── position: Int
│
└── players/
    ├── {playerId}
    │   ├── id: String (auto)
    │   ├── firstName: String
    │   ├── lastName: String
    │   ├── nationality: String
    │   ├── dateOfBirth: Timestamp
    │   ├── position: String (GK, DEF, MID, FWD)
    │   ├── number: Int
    │   ├── height: Double?
    │   ├── weight: Double?
    │   ├── foot: String? (left, right, both)
    │   ├── currentTeamId: String
    │   ├── currentTeamName: String?
    │   ├── status: String (active, injured, suspended, loaned)
    │   ├── season: Int
    │   ├── photo: String? (URL)
    │   ├── marketValue: Double (€)
    │   └── stats: Object
    │       ├── played: Int
    │       ├── goals: Int
    │       ├── assists: Int
    │       ├── yellowCards: Int
    │       ├── redCards: Int
    │       ├── cleanSheets: Int
    │       ├── minutes: Int
    │       └── averageRating: Double
```

---

## 🔑 Características Clave

### Player Entity
- **Propiedades Computadas**:
  - `displayName`: Nombre completo formateado
  - `age`: Edad calculada desde dateOfBirth
  - `isActive`: Booleano si status == "active"
  - `goalsPerGame`: Goles / Partidos jugados
  - `assistsPerGame`: Asistencias / Partidos jugados

### Team Entity
- **Propiedades Computadas**:
  - `displayName`: Nombre del equipo + país
  - `goalDifference`: goalsFor - goalsAgainst
  - `winPercentage`: (won / played) * 100
  - `isLeading`: Verifica si position == 1

### Player Comparison
Compara dos jugadores en base a:
- Goles por partido (más alto = mejor)
- Asistencias por partido (más alto = mejor)
- Rating promedio (más alto = mejor)
- Valor de mercado (informativo)

Determina un "ganador" basado en el mejor desempeño general.

---

## ✅ Validaciones Implementadas

### Búsqueda de Jugadores
1. **Búsqueda de texto**: Busca en firstName y lastName
2. **Filtro por posición**: GK, DEF, MID, FWD
3. **Filtro por equipo**: teamId
4. **Filtro por status**: Solo "active" en getAvailablePlayers()
5. **Temporada**: Filtra por season

### Búsqueda de Equipos
1. **Por liga**: Filtra por competition/league name
2. **Búsqueda de texto**: Por nombre o país
3. **Ranking**: Ordena por puntos y diferencia de goles
4. **Temporada**: Filtra por season

---

## 🔐 Security Rules para Teams y Players

```javascript
match /teams/{teamId} {
  allow read: if true; // Datos públicos
  allow write: if false; // Solo administrador (backend)
}

match /players/{playerId} {
  allow read: if true; // Datos públicos
  allow write: if false; // Solo administrador (backend)
}
```

---

## 🚀 Flujo Típico de Usuario - Seleccionar Squad

```
1. Usuario entra en "Crear Equipo"
   ↓
2. Selecciona liga
   ↓
3. Ve pantalla de "Seleccionar Equipo"
   ↓
4. Accede a "Agregar Jugadores"
   ↓
5. Puede:
   - Buscar por nombre
   - Filtrar por posición
   - Ver equipo actual
   - Comparar dos jugadores
   ↓
6. Selecciona jugador
   ↓
7. Jugador se agrega al squad (validando presupuesto)
   ↓
8. Repite hasta completar 11 jugadores + 4 banquillo
   ↓
9. Selecciona capitán y vicecapitán
   ↓
10. Squad completado
```

---

## 💡 Integraciones Necesarias

### Para Funcionar Completamente, Necesitas:

1. **Seed Data (Población de Firestore)**
   - Importar lista de equipos reales (20-30 por liga)
   - Importar lista de jugadores reales (300-500 por liga)
   - Incluir estadísticas de temporada actual
   - Incluir fotos/logos desde URLs públicas

2. **Actualización Periódica de Estadísticas**
   - Actualizar stats después de cada jornada
   - Actualizar ranking de equipos
   - Actualizar posición en tabla

3. **Búsqueda Optimizada**
   - Implementar índices de Firestore para búsquedas rápidas
   - Considerar Algolia para búsqueda full-text avanzada

4. **Cache Local**
   - Almacenar lista de equipos/jugadores localmente
   - Sincronizar con Firestore periódicamente

---

## 🧪 Testing

Para probar el código:

```swift
// Crear PlayerEntity de ejemplo
let examplePlayer = PlayerEntity(
    id: "player123",
    firstName: "Lionel",
    lastName: "Messi",
    nationality: "Argentina",
    dateOfBirth: Date(timeIntervalSince1970: 315532800), // 1980-06-24
    position: "FWD",
    number: 7,
    height: 1.70,
    weight: 72,
    foot: "left",
    currentTeamId: "inter123",
    currentTeamName: "Inter Miami CF",
    status: "active",
    season: 2024,
    stats: PlayerStatsEntity(
        played: 34,
        goals: 15,
        assists: 8,
        yellowCards: 2,
        redCards: 0,
        cleanSheets: 0,
        minutes: 2856,
        averageRating: 8.5
    ),
    photo: URL(string: "https://example.com/messi.jpg"),
    marketValue: 35.0
)

// Crear TeamEntity de ejemplo
let exampleTeam = TeamEntity(
    id: "team123",
    name: "Real Madrid",
    country: "Spain",
    city: "Madrid",
    founded: 1902,
    league: "La Liga",
    coach: "Carlo Ancelotti",
    stadium: "Santiago Bernabéu",
    logo: URL(string: "https://example.com/real-madrid.png"),
    colors: TeamColorsEntity(primary: "#FFFFFF", secondary: "#FFB81C"),
    season: 2024,
    stats: TeamStatsEntity(
        played: 20,
        won: 14,
        drawn: 4,
        lost: 2,
        goalsFor: 48,
        goalsAgainst: 18,
        points: 46,
        position: 1
    )
)

// Usar en ViewModel
let useCase = PlayerContainer.shared.makeUseCase()
let comparison = useCase.comparePlayerStats(examplePlayer, anotherPlayer)
print(comparison.comparison.summary) // "Lionel Messi is the better choice"
```

---

## 🎯 Próximos Pasos

Para completar la funcionalidad de Teams y Players:

1. **Crear Views para Selección de Jugadores** (SwiftUI)
2. **Crear Views para Detalles de Equipo** (SwiftUI)
3. **Implementar búsqueda con filtros avanzados**
4. **Agregar caché local para mejor performance**
5. **Implementar notificaciones cuando cambien estadísticas**

---

## 📚 Índices Recomendados en Firestore

### Para optimizar búsquedas:

```
players:
- Index: position, season, status
- Index: currentTeamId, season
- Index: season, marketValue DESC

teams:
- Index: league, season, position
- Index: season, stats.points DESC
```

---

¡Teams y Players está completamente implementado! 🎉

El siguiente paso puede ser:
- **Crear Views para la selección de jugadores**
- **Implementar búsqueda avanzada con filtros**
- **Agregar observación en tiempo real de cambios**
- **Integrar con FantasySquad para agregar jugadores**

