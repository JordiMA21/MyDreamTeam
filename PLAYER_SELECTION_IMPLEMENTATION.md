# Player Selection - Guía de Implementación

## 📁 Estructura Completada

### Presentation Layer - PlayerSelection Feature
```
MyDreamTeam/Presentation/Screens/PlayerSelection/
├── PlayerSelectionView.swift          ✅ Vista principal con búsqueda, filtros y lista
├── PlayerSelectionViewModel.swift     ✅ Lógica de presentación (@ObservableObject)
├── PlayerSelectionRouter.swift        ✅ Navegación (extiende Router base)
├── PlayerSelectionBuilder.swift       ✅ Inyección de dependencias (enum con factory)
└── Components/
    └── PlayerCardView.swift           ✅ Componente reutilizable para cada jugador
```

---

## 🎯 Características Implementadas

### 1. **Búsqueda de Jugadores**
- ✅ Búsqueda por nombre en tiempo real
- ✅ Filtrado por posición (GK, DEF, MID, FWD)
- ✅ Solo muestra jugadores activos
- ✅ Ordena por valor de mercado (mayor a menor)

### 2. **Gestión de Presupuesto**
- ✅ Barra visual de presupuesto gastado (100€)
- ✅ Validación de presupuesto disponible
- ✅ Actualización en tiempo real
- ✅ Previene agregar jugadores sin presupuesto

### 3. **Selección de Jugadores**
- ✅ Agregar jugador al squad
- ✅ Remover jugador del squad
- ✅ Indicador visual de jugadores seleccionados
- ✅ Máximo 15 jugadores (11 principal + 4 banquillo)

### 4. **Comparación de Jugadores**
- ✅ Comparar estadísticas con otro jugador
- ✅ Botón de comparación solo si hay jugadores seleccionados
- ✅ Resumen de comparación

### 5. **Interfaz de Usuario**
- ✅ Diseño consistente con el proyecto
- ✅ Gradiente oscuro (tema dark)
- ✅ Componentes reutilizables
- ✅ Estados de carga
- ✅ Estado vacío con mensaje amigable

---

## 💻 Estructura del Código

### PlayerSelectionViewModel

Propiedades principales:
```swift
@Published var players: [PlayerEntity] = []              // Todos los jugadores de la posición
@Published var filteredPlayers: [PlayerEntity] = []     // Jugadores después de filtros/búsqueda
@Published var selectedPosition: String = "FWD"         // Posición actualmente seleccionada
@Published var searchText: String = ""                  // Texto de búsqueda
@Published var isLoading = false                        // Estado de carga
@Published var selectedPlayers: [PlayerEntity] = []     // Jugadores agregados al squad
@Published var remainingBudget: Double = 100.0          // Presupuesto disponible
```

Métodos principales:
```swift
loadPlayersByPosition()               // Carga jugadores de la posición seleccionada
applyFilters()                        // Aplica filtros de búsqueda
changePosition(_ newPosition)         // Cambia la posición seleccionada
addPlayerToSquad(_ player)            // Agrega jugador (valida presupuesto)
removePlayerFromSquad(_ player)       // Remueve jugador del squad
isPlayerSelected(_ player) -> Bool    // Verifica si está seleccionado
compareWithPlayer(_ player)           // Compara con jugador seleccionado
```

Propiedades computadas:
```swift
totalBudgetSpent: Double             // Dinero gastado
budgetPercentage: Double             // Porcentaje de presupuesto usado
canAddMorePlayers: Bool              // Si puede agregar más jugadores
```

### PlayerSelectionRouter

Hereda de `Router` (base class con métodos comunes):
```swift
class PlayerSelectionRouter: Router {
    func navigateToPlayerDetail(playerId: String)
    func navigateToComparison(comparison: PlayerComparisonResult)
    func navigateToTeamDetail(teamId: String)
    
    // Heredados de Router:
    // - showAlert(with: AppError)
    // - showToastWithCloseAction(with: String)
    // - dismiss()
}
```

### PlayerSelectionBuilder

Factory pattern para inyección de dependencias:
```swift
enum PlayerSelectionBuilder {
    static func build(squadId: String, season: Int) -> PlayerSelectionView {
        // Inyecta todas las dependencias
        let playerUseCase = PlayerContainer.shared.makeUseCase()
        let fantasyUseCase = FantasySquadContainer.shared.makeUseCase()
        let router = PlayerSelectionRouter()
        let viewModel = PlayerSelectionViewModel(...)
        return PlayerSelectionView(viewModel: viewModel)
    }
}
```

### PlayerSelectionView

Estructura SwiftUI con:
- Budget bar con progreso visual
- Filtros de posición (botones)
- Search bar con lógica de búsqueda
- Lista de jugadores usando `PlayerCardView`
- Estado de carga con `ProgressView`
- Estado vacío con mensaje amigable

### PlayerCardView (Componente Reutilizable)

Muestra cada jugador con:
- Nombre y equipo
- Número de jugador
- Estadísticas (goles, asistencias, rating)
- Valor de mercado
- Botón de agregar/remover
- Botón de comparación (opcional)

---

## 🔗 Integración con Otros Features

### Con FantasySquad
- Agrega jugadores directamente al squad
- Usa `FantasySquadUseCaseProtocol.addPlayer()`
- Usa `FantasySquadUseCaseProtocol.removePlayer()`

### Con Player UseCase
- Busca jugadores: `PlayerUseCaseProtocol.searchPlayers()`
- Obtiene por posición: `PlayerUseCaseProtocol.getAvailablePlayers()`
- Compara: `PlayerUseCaseProtocol.comparePlayerStats()`

### Navegación
- Usa `Navigator.shared` (sistema de navegación centralizado)
- Router extiende clase `Router` base
- Sigue patrón de navegación tipo-seguro con `Page`

---

## 🎨 Diseño Visual

### Colores Utilizados
- **Fondo**: Gradiente azul oscuro
- **Acentos**: Azul (`Color.blue`)
- **Éxito**: Verde (`Color.green`)
- **Datos**: Cian (goles), Verde (asistencias), Amarillo (rating)

### Componentes Visuales
- Barras de progreso animadas
- Badges para estadísticas
- Cards redondeadas con fondo semi-transparente
- Botones con iconos del sistema

---

## 📱 Flujo de Usuario

```
1. Usuario abre "Seleccionar Jugadores"
   ↓
2. Ve lista de delanteros (posición por defecto)
   ↓
3. Puede:
   - Cambiar posición (GK, DEF, MID, FWD)
   - Buscar por nombre
   - Ver presupuesto disponible
   ↓
4. Selecciona un jugador (click en +)
   ↓
5. Sistema valida:
   - ¿Ya está seleccionado?
   - ¿Hay presupuesto?
   - ¿Límite de jugadores?
   ↓
6. Jugador se agrega al squad en Firebase
   ↓
7. Presupuesto se actualiza
   ↓
8. Puede seguir seleccionando hasta llenar squad (11+4)
```

---

## 🔄 Ciclo de Datos

```
ViewModel.loadPlayersByPosition()
    ↓
PlayerUseCase.getAvailablePlayers(position, season)
    ↓
PlayerRepository.getPlayersByPosition()
    ↓
PlayerFirestoreDataSource.getPlayersByPosition()
    ↓
Firestore Query: whereField("position") && whereField("season")
    ↓
Mapeo DTO → Entity
    ↓
@Published var players actualizado
    ↓
View re-renderiza con nuevos datos
```

---

## 🧪 Ejemplo de Uso

### En otro ViewModel o Router

```swift
// Navegar a selección de jugadores
func navigateToPlayerSelection(squadId: String) {
    navigator.push(to: PlayerSelectionBuilder.build(squadId: squadId, season: 2024))
}
```

### Usando directamente en View

```swift
struct SomeView: View {
    var body: some View {
        NavigationLink(destination: PlayerSelectionBuilder.build(squadId: "squad123", season: 2024)) {
            Text("Seleccionar Jugadores")
        }
    }
}
```

---

## 🚀 Próximos Pasos

### Para completar la funcionalidad:

1. **Crear vista de Comparación de Jugadores**
   - Mostrar lado a lado estadísticas
   - Gráficos de comparación

2. **Agregar filtros avanzados**
   - Por rango de valor de mercado
   - Por equipo específico
   - Por nacionalidad

3. **Optimización de performance**
   - Paginación si hay muchos jugadores
   - Caché local de jugadores
   - Búsqueda debounced

4. **Integración con Squad Management**
   - Mostrar jugadores ya seleccionados en otra sección
   - Permitir reemplazo de jugadores
   - Historial de cambios

---

## ✅ Checklist de Calidad

- ✅ Sigue patrón MVVM
- ✅ Router inyectado en ViewModel (nunca en View)
- ✅ Componentes reutilizables (PlayerCardView)
- ✅ Error handling con AppError
- ✅ Async/await con @MainActor
- ✅ @Published properties para estado
- ✅ Validaciones antes de operaciones
- ✅ UI actualiza automáticamente con cambios de estado
- ✅ Interfaz consistente con proyecto
- ✅ Navegación centralizada vía Navigator

---

## 📚 Archivos Creados

1. **MyDreamTeam/Presentation/Screens/PlayerSelection/PlayerSelectionView.swift**
   - Vista principal con búsqueda, filtros y lista

2. **MyDreamTeam/Presentation/Screens/PlayerSelection/PlayerSelectionViewModel.swift**
   - Lógica de presentación y manejo de estado

3. **MyDreamTeam/Presentation/Screens/PlayerSelection/PlayerSelectionRouter.swift**
   - Rutas de navegación

4. **MyDreamTeam/Presentation/Screens/PlayerSelection/PlayerSelectionBuilder.swift**
   - Factory de inyección de dependencias

5. **MyDreamTeam/Presentation/Screens/PlayerSelection/Components/PlayerCardView.swift**
   - Componente reutilizable para mostrar cada jugador

---

¡PlayerSelection está completamente implementado! 🎉

Ahora tienes una interfaz completa para:
- Buscar jugadores
- Filtrar por posición
- Ver estadísticas
- Comparar jugadores
- Agregar/remover del squad
- Gestionar presupuesto

