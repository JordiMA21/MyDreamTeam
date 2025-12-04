# Arquitectura de MyDreamTeam

Una guía sencilla sobre cómo está organizado el proyecto y cómo las diferentes partes trabajan juntas.

## Índice
1. [¿Por qué esta arquitectura?](#por-qué-esta-arquitectura)
2. [Las 4 capas principales](#las-4-capas-principales)
3. [El flujo de datos](#el-flujo-de-datos)
4. [El Sistema de Navegación](#el-sistema-de-navegación)
5. [Inyección de Dependencias](#inyección-de-dependencias)
6. [Ejemplos prácticos](#ejemplos-prácticos)

---

## ¿Por qué esta arquitectura?

La arquitectura está diseñada para:

- **Separación de responsabilidades**: Cada parte hace una sola cosa bien
- **Testabilidad**: Es fácil escribir tests porque todo está desacoplado
- **Mantenimiento**: Cambios en una capa no rompen las otras
- **Escalabilidad**: Añadir nuevas funcionalidades es sencillo y predecible

---

## Las 4 capas principales

El proyecto está dividido en 4 capas bien definidas:

```
┌─────────────────────────────────────────┐
│       PRESENTATION (UI)                 │
│  (Vistas, ViewModels, Routers)         │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│       DOMAIN (Lógica de negocio)        │
│  (UseCases, Entidades, Protocolos)     │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│       DATA (Acceso a datos)             │
│  (Repositorios, DataSources, DTOs)     │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│       INFRASTRUCTURE (Servicios)        │
│  (Networking, Navigator, Config)        │
└─────────────────────────────────────────┘
```

Vamos a explicar cada capa:

### 1. **Presentation Layer** 📱
**Ubicación**: `/MyDreamTeam/Presentation`

Es la capa más visual. Contiene todo lo que el usuario ve y con lo que interactúa.

**Componentes principales**:

#### **View** (Vista)
- Solo muestra información del ViewModel
- Llama métodos del ViewModel cuando el usuario interactúa
- **NUNCA** contiene lógica de negocio

```swift
struct EstablishmentView: View {
    @StateObject var viewModel: EstablishmentViewModel

    var body: some View {
        List(viewModel.establishments) { establishment in
            Text(establishment.name)
                .onTapGesture {
                    // Llamamos método del ViewModel
                    viewModel.didSelectEstablishment(establishment)
                }
        }
    }
}
```

#### **ViewModel** (Controlador)
- Contiene `@Published var` que la Vista observa
- Contiene toda la lógica de la pantalla
- Tiene inyectado un Router para navegar
- Usa UseCase para obtener datos

```swift
class EstablishmentViewModel: ObservableObject {
    @Published var establishments: [Establishment] = []
    @Published var isLoading = false

    private let router: EstablishmentRouter
    private let useCase: EstablishmentUseCaseProtocol

    init(router: EstablishmentRouter, useCase: EstablishmentUseCaseProtocol) {
        self.router = router
        self.useCase = useCase
    }

    @MainActor
    func loadEstablishments() {
        Task {
            do {
                let data = try await useCase.getEstablishments(service: .delivery, coordinates: nil)
                self.establishments = data
            } catch {
                router.showAlert(with: error, action: {})
            }
        }
    }

    func didSelectEstablishment(_ establishment: Establishment) {
        // Navigamos usando el Router
        router.navigateToDetail(id: establishment.id)
    }
}
```

#### **Router** (Navegación)
- Gestiona toda la navegación de la pantalla
- Extiende de `Router` base
- Recibe el Navigator singleton
- Tiene métodos como `showAlert()`, `dismiss()`, etc.

```swift
class EstablishmentRouter: Router {
    func navigateToDetail(id: Int) {
        // DetailBuilder construye la siguiente pantalla
        navigator.push(to: DetailBuilder.build(id: id))
    }

    func goToEmptyView() {
        navigator.presentSheet(EmptyViewBuilder.build())
    }
}
```

#### **Builder** (Factory)
- Factory pattern para crear las vistas con todas sus dependencias
- Evita que las vistas se encarguen de crear sus dependencias

```swift
class EstablishmentBuilder {
    static func build(with serviceType: ServiceType) -> some View {
        let router = EstablishmentRouter()
        let useCase = EstablishmentSelectionContainer.makeUseCase()
        let viewModel = EstablishmentViewModel(
            router: router,
            useCase: useCase
        )
        return EstablishmentView(viewModel: viewModel)
    }
}
```

---

### 2. **Domain Layer** 🧠
**Ubicación**: `/MyDreamTeam/Domain`

Es el corazón del negocio. Contiene toda la lógica de negocio sin dependencias externas.

**Componentes principales**:

#### **Entidades** (Entity)
- Modelos que representan objetos de negocio
- Son los datos puros, sin nada de networking o frameworks

```swift
struct Establishment {
    let id: Int
    let name: String
    let image: String
    let coordinates: Coordinates
}

struct City {
    let id: Int
    let name: String
    let establishments: [Establishment]
}
```

#### **Protocolos de Repositorio**
- Define qué datos necesita la lógica de negocio
- El Domain NO sabe cómo se obtienen los datos

```swift
protocol EstablishmentRepositoryProtocol {
    func getCities(service: ServiceType, coordinates: Coordinates?) async throws -> [City]
    func getEstablishments(service: ServiceType, coordinates: Coordinates?) async throws -> [Establishment]
    func isListedByCity() async throws -> Bool
}
```

#### **UseCase** (Caso de uso)
- Orquesta la lógica de negocio
- Usa los Repositorios para obtener datos
- Aplica las reglas de negocio

```swift
protocol EstablishmentUseCaseProtocol {
    func isListedByCity() async throws -> Bool
    func getCities(service: ServiceType, coordinates: Coordinates?) async throws -> [City]
    func getEstablishments(service: ServiceType, coordinates: Coordinates?) async throws -> [Establishment]
}

class EstablishmentUseCase: EstablishmentUseCaseProtocol {
    private let repository: EstablishmentRepositoryProtocol

    init(repository: EstablishmentRepositoryProtocol) {
        self.repository = repository
    }

    func getCities(service: ServiceType, coordinates: Coordinates?) async throws -> [City] {
        // Lógica de negocio aquí
        return try await repository.getCities(service: service, coordinates: coordinates)
    }
}
```

**¿Por qué dos archivos para cada UseCase?**
- `EstablishmentUseCaseProtocol.swift`: Define la interfaz
- `EstablishmentUseCase.swift`: La implementación

Así el ViewModel solo depende del protocolo, no de la implementación.

---

### 3. **Data Layer** 💾
**Ubicación**: `/MyDreamTeam/Data`

Obtiene los datos de cualquier fuente (API, base de datos local, etc.)

**Componentes principales**:

#### **DataSource** (Fuente de datos)
- Comunicación directa con APIs
- No hace transformaciones, solo obtiene datos

```swift
class EstablishmentRemoteDataSource {
    private let network: NetworkProtocol

    init(network: NetworkProtocol) {
        self.network = network
    }

    func getCities(service: ServiceType, coordinates: Coordinates?) async throws -> [CityDTO] {
        // Llamada directa a la API
        return try await network.request(endpoint: .getCities)
    }
}
```

#### **DTO** (Data Transfer Object)
- Modelos que vienen de la API
- Tienen exactamente la estructura del JSON que retorna la API

```swift
struct CityDTO: Decodable {
    let id: Int
    let name: String
    let establishments: [EstablishmentDTO]
}

struct EstablishmentDTO: Decodable {
    let id: Int
    let name: String
    let image: String
}
```

#### **Repository** (Implementación)
- Implementa el protocolo del Domain
- Usa el DataSource para obtener datos
- **Transforma DTOs a Entidades**
- Maneja errores y los transforma a AppError

```swift
class EstablishmentRepository: EstablishmentRepositoryProtocol {
    private let dataSource: EstablishmentRemoteDataSource
    private let errorHandler: ErrorHandlerManager

    init(dataSource: EstablishmentRemoteDataSource, errorHandler: ErrorHandlerManager) {
        self.dataSource = dataSource
        self.errorHandler = errorHandler
    }

    func getCities(service: ServiceType, coordinates: Coordinates?) async throws -> [City] {
        do {
            // 1. Obtener DTOs del DataSource
            let citiesDTO = try await dataSource.getCities(service: service, coordinates: coordinates)

            // 2. Transformar DTOs a Entidades
            return citiesDTO.map { dtoToEntity($0) }
        } catch {
            // 3. Transformar error a AppError
            throw errorHandler.transform(error)
        }
    }

    private func dtoToEntity(_ dto: CityDTO) -> City {
        City(
            id: dto.id,
            name: dto.name,
            establishments: dto.establishments.map { dtoToEntity($0) }
        )
    }
}
```

---

### 4. **Infrastructure / Shared** 🔧
**Ubicación**: `/MyDreamTeam/Shared`

Servicios compartidos que usa toda la app.

**Componentes principales**:

#### **Navigator** (Sistema de navegación)
- Singleton que gestiona toda la navegación
- Centraliza el estado de navegación
- Manejo de pilas, sheets, full-screen modals, alertas y toasts

```swift
@Observable
class Navigator: NavigatorProtocol {
    private(set) var root: Page?
    var path = [Page]()           // Pila de navegación
    var sheet: Page?              // Sheet actual
    var fullOverSheet: Page?      // Full-screen modal
    var toastConfig: ToastConfig? // Toast actual
    var alertModel: AlertModel = AlertModel() // Alerta

    static var shared = Navigator()

    // Métodos principales
    func push(to view: any View) {
        path.append(Page(from: view))
    }

    func dismissSheet() {
        sheet = nil
    }

    func showAlert(alertModel: AlertModel) {
        self.alertModel = alertModel
        isPresentingAlert = true
    }
}
```

#### **Config** (Configuración global)
- URLs de APIs
- Claves
- Constantes de la app

```swift
class Config {
    static let baseURL = "https://api.mydreamteam.com"
    static let appName = "MyDreamTeam"
    static let shared = Config()

    var network: NetworkProtocol {
        return ConfigTripleA.shared.network
    }
}
```

#### **Error Handler** (Manejo de errores)
- Transforma errores de red a AppError
- Centraliza el manejo de errores

```swift
class ErrorHandlerManager {
    func transform(_ error: Error) -> AppError {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .noInternet:
                return .noInternet
            case .badCredentials:
                return .badCredentials
            default:
                return .generalError
            }
        }
        return .customError(message: error.localizedDescription)
    }
}
```

---

## El flujo de datos

Cuando el usuario interactúa con la app, los datos fluyen así:

```
┌─────────────────────────────────────────────────────────────┐
│  1️⃣ Usuario toca un botón en la Vista                       │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  2️⃣ Vista llama método del ViewModel                        │
│     viewModel.didSelectEstablishment(establishment)         │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  3️⃣ ViewModel usa el UseCase para obtener datos             │
│     let cities = try await useCase.getCities(...)          │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  4️⃣ UseCase usa el Repositorio                              │
│     return try await repository.getCities(...)             │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  5️⃣ Repositorio usa el DataSource para llamar la API       │
│     let dtos = try await dataSource.getCities(...)         │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  6️⃣ DataSource hace la petición HTTP                        │
│     network.request(endpoint: .getCities)                  │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  7️⃣ Respuesta vuelve transformada en cada capa              │
│     DTO → Entity → Published var → View re-renderiza       │
└─────────────────────────────────────────────────────────────┘
```

**Lo importante**: Los datos siempre fluyen en la misma dirección (de abajo a arriba).

---

## El Sistema de Navegación

En lugar de usar SwiftUI's `NavigationStack` por todas partes, usamos un sistema centralizado.

### ¿Cómo funciona?

```swift
// 1. En el Router, definimos métodos de navegación
class EstablishmentRouter: Router {
    func navigateToDetail(id: Int) {
        // El Router construye la siguiente vista usando Builder
        navigator.push(to: DetailBuilder.build(id: id))
    }

    func showError(_ error: AppError) {
        // El Router base tiene métodos para mostrar alertas
        showAlert(with: error, action: { })
    }
}

// 2. En el ViewModel, usamos el Router
class EstablishmentViewModel: ObservableObject {
    private let router: EstablishmentRouter

    func didSelectEstablishment(_ establishment: Establishment) {
        router.navigateToDetail(id: establishment.id)
    }

    func loadData() {
        Task {
            do {
                let data = try await useCase.getEstablishments(...)
                self.establishments = data
            } catch {
                router.showAlert(with: error, action: {})
            }
        }
    }
}

// 3. La Vista NUNCA recibe el Router, solo llama métodos del ViewModel
struct EstablishmentView: View {
    @StateObject var viewModel: EstablishmentViewModel

    var body: some View {
        List(viewModel.establishments) { establishment in
            Text(establishment.name)
                .onTapGesture {
                    // Llamamos al ViewModel, NO al Router
                    viewModel.didSelectEstablishment(establishment)
                }
        }
    }
}
```

### Tipos de navegación soportados

```swift
// 1. Push (agregar a la pila de navegación)
navigator.push(to: DetailBuilder.build(id: id))

// 2. Reemplazar pantalla actual
navigator.pushAndRemovePrevious(to: NewBuilder.build())

// 3. Ir atrás
navigator.dismiss()

// 4. Mostrar sheet (modal)
navigator.present(view: SheetBuilder.build())

// 5. Mostrar full-screen modal
navigator.presentFullOverScreen(view: FullScreenBuilder.build())

// 6. Mostrar alerta
router.showAlert(title: "Título", message: "Mensaje", action: { })

// 7. Mostrar toast
router.showToastWithCloseAction(with: "Mensaje", closeAction: { })

// 8. Cambiar tab
navigator.changeTab(index: 2)

// 9. Mostrar diálogo de confirmación
navigator.presentCustomConfirmationDialog(from: config)
```

---

## Inyección de Dependencias

El proyecto usa el patrón **Builder** y **Container** para inyectar dependencias.

### ¿Por qué?

En lugar de que una vista cree sus propias dependencias:
```swift
// ❌ MAL - La vista crea sus dependencias
struct EstablishmentView: View {
    var viewModel = EstablishmentViewModel() // ¿De dónde viene useCase? ¿Router?
}
```

Usamos Builders que construyen la vista completa:
```swift
// ✅ BIEN - Builder construye todo
class EstablishmentBuilder {
    static func build(with serviceType: ServiceType) -> some View {
        let router = EstablishmentRouter()
        let useCase = EstablishmentSelectionContainer.makeUseCase()
        let viewModel = EstablishmentViewModel(router: router, useCase: useCase)
        return EstablishmentView(viewModel: viewModel)
    }
}
```

### Contenedor (Container)

El Container centraliza la creación de todas las dependencias de un feature:

```swift
class EstablishmentSelectionContainer {
    // Factory method que construye todo el árbol de dependencias
    static func makeUseCase() -> EstablishmentUseCase {
        // 1. Crear ErrorHandler
        let errorHandler = ErrorHandlerManager()

        // 2. Obtener Network del Config
        let network = Config.shared.network

        // 3. Crear DataSource con el Network
        let dataSource = EstablishmentRemoteDataSource(network: network)

        // 4. Crear Repository con DataSource y ErrorHandler
        let repository = EstablishmentRepository(
            dataSource: dataSource,
            errorHandler: errorHandler
        )

        // 5. Crear y retornar UseCase con el Repository
        return EstablishmentUseCase(repository: repository)
    }
}
```

**Ventajas**:
- Fácil de testear (mockeamos Container)
- Todas las dependencias en un lugar
- Cambios en dependencias solo requieren cambios en el Container

---

## Ejemplos prácticos

Veamos cómo todo funciona junto en casos reales:

### Ejemplo 1: Cargar datos al abrir una pantalla

**Paso a paso**:

```swift
// 1. Vista se renderiza
struct EstablishmentView: View {
    @StateObject var viewModel: EstablishmentViewModel

    var body: some View {
        List(viewModel.establishments) { establishment in
            Text(establishment.name)
        }
        .onAppear {
            // 2. Cuando aparece, pedimos al ViewModel que cargue datos
            viewModel.loadCitiesOrEstablishments()
        }
    }
}

// 3. ViewModel carga los datos
class EstablishmentViewModel: ObservableObject {
    @Published var establishments: [Establishment] = []

    @MainActor
    func loadCitiesOrEstablishments() {
        Task {
            do {
                // 4. UseCase obtiene los datos
                self.establishments = try await establishmentUseCase
                    .getEstablishments(service: .delivery, coordinates: nil)
            } catch {
                // 5. Si hay error, mostramos alerta
                router.showAlert(with: error, action: {})
            }
        }
    }
}

// 6. UseCase delega al Repository
class EstablishmentUseCase: EstablishmentUseCaseProtocol {
    func getEstablishments(service: ServiceType, coordinates: Coordinates?) async throws -> [Establishment] {
        return try await repository.getEstablishments(service: service, coordinates: coordinates)
    }
}

// 7. Repository obtiene DTOs del DataSource
class EstablishmentRepository: EstablishmentRepositoryProtocol {
    func getEstablishments(service: ServiceType, coordinates: Coordinates?) async throws -> [Establishment] {
        let dtos = try await dataSource.getEstablishments(service: service, coordinates: coordinates)
        return dtos.map { dtoToEntity($0) }
    }
}

// 8. DataSource hace la llamada a la API
class EstablishmentRemoteDataSource {
    func getEstablishments(service: ServiceType, coordinates: Coordinates?) async throws -> [EstablishmentDTO] {
        return try await network.request(endpoint: .getEstablishments)
    }
}

// 9. La respuesta vuelve atrás:
//    [EstablishmentDTO] → [Establishment] → @Published var
//    Automáticamente la Vista se re-renderiza con los nuevos datos
```

**Resultado**: La Vista muestra los restaurantes.

---

### Ejemplo 2: Navegar a detalle al tocar un item

```swift
// 1. Usuario toca un restaurante
struct EstablishmentView: View {
    @StateObject var viewModel: EstablishmentViewModel

    var body: some View {
        ForEach(viewModel.establishments) { establishment in
            Text(establishment.name)
                .onTapGesture {
                    // 2. Llamamos al ViewModel
                    viewModel.didSelectEstablishment(establishment)
                }
        }
    }
}

// 3. ViewModel navega usando el Router
class EstablishmentViewModel: ObservableObject {
    func didSelectEstablishment(_ establishment: Establishment) {
        router.navigateToDetail(id: establishment.id)
    }
}

// 4. Router crea la siguiente pantalla
class EstablishmentRouter: Router {
    func navigateToDetail(id: Int) {
        // DetailBuilder construye la pantalla de detalle con todas sus dependencias
        navigator.push(to: DetailBuilder.build(id: id))
    }
}

// 5. DetailBuilder construye la vista con sus dependencias
class DetailBuilder {
    static func build(id: Int) -> some View {
        let router = DetailRouter()
        let useCase = DetailContainer.makeUseCase(id: id)
        let viewModel = DetailViewModel(router: router, useCase: useCase)
        return DetailView(viewModel: viewModel)
    }
}

// 6. Navigator agrega la nueva vista a la pila de navegación
// Automáticamente SwiftUI muestra la nueva pantalla
```

**Resultado**: Navegamos a la pantalla de detalle.

---

### Ejemplo 3: Mostrar alerta de error

```swift
// 1. UseCase obtiene un error de la API
class EstablishmentUseCase: EstablishmentUseCaseProtocol {
    func getEstablishments(...) async throws -> [Establishment] {
        // Simulamos error
        throw NetworkError.noInternet
    }
}

// 2. Repository transforma el error a AppError
class EstablishmentRepository: EstablishmentRepositoryProtocol {
    func getEstablishments(...) async throws -> [Establishment] {
        do {
            return try await dataSource.getEstablishments(...)
        } catch {
            throw errorHandler.transform(error) // NetworkError → AppError
        }
    }
}

// 3. ViewModel captura el error
class EstablishmentViewModel: ObservableObject {
    @MainActor
    func loadEstablishments() {
        Task {
            do {
                self.establishments = try await useCase.getEstablishments(...)
            } catch {
                // 4. Pasa el error al Router
                router.showAlert(with: error, action: {})
            }
        }
    }
}

// 5. Router base transforma AppError a AlertModel
class Router {
    func showAlert(with error: Error, action: @escaping () -> Void = {}) {
        guard let error = error as? any DetailErrorProtocol else { return }
        let model = AlertModel(
            title: error.title,      // Ej: "No Internet"
            message: error.message,  // Ej: "Revisa tu conexión"
            style: .error(acceptAction: action, cancelAction: {})
        )
        navigator.showAlert(alertModel: model)
    }
}

// 6. Navigator muestra la alerta
// 7. Usuario ve alerta con el mensaje del error
```

**Resultado**: Se muestra una alerta elegante al usuario.

---

## Resumen de reglas clave

Para que todo esto funcione correctamente, hay algunas reglas importantes:

| Regla | Ejemplo |
|-------|---------|
| **Router en ViewModel, NO en View** | ViewModel tiene `router`, Vista solo llama métodos del ViewModel |
| **Vistas son "tontas"** | Vista solo muestra datos y llama métodos del ViewModel |
| **Protocol-first** | Repositorios, UseCases, DataSources usan protocolos |
| **DTOs en Data Layer** | Solo la capa Data conoce los DTOs de la API |
| **Errores transformados en Repository** | NetworkError → AppError en la capa Data |
| **Builders para DI** | Nunca crees ViewModel directamente en la Vista |
| **Navigator es Singleton** | `Navigator.shared` accesible desde cualquier parte |
| **ServiceType en Data Layer** | Si necesitas saber si es delivery/takeaway, lo maneja el Repository |

---

## Estructura de carpetas

```
MyDreamTeam/
│
├── Presentation/                    # UI Layer
│   ├── Screens/
│   │   ├── Establishment/
│   │   │   ├── EstablishmentView.swift
│   │   │   ├── EstablishmentViewModel.swift
│   │   │   ├── EstablishmentRouter.swift
│   │   │   └── EstablishmentBuilder.swift
│   │   ├── Player/
│   │   ├── Team/
│   │   └── Lineup/
│   ├── Shared/
│   │   └── Components/              # Componentes reutilizables
│   └── App/                         # App root
│
├── Domain/                          # Business Logic
│   ├── Entities/                    # Modelos de negocio
│   │   └── Establishment.swift
│   ├── Repositories/                # Protocolos
│   │   └── EstablishmentRepositoryProtocol.swift
│   └── Usecases/                    # Orquestación de lógica
│       ├── EstablishmentUseCaseProtocol.swift
│       └── EstablishmentUseCase.swift
│
├── Data/                            # Data Access
│   ├── Repositories/                # Implementación
│   │   └── EstablishmentRepository.swift
│   ├── Datasources/
│   │   └── EstablishmentRemoteDataSource.swift
│   └── DTOs/                        # Modelos de API
│       └── EstablishmentDTO.swift
│
├── DI/                              # Dependency Injection
│   └── Containers/
│       ├── Establishment/
│       │   └── EstablishmentSelectionContainer.swift
│       ├── Player/
│       ├── Team/
│       └── Lineup/
│
└── Shared/                          # Services & Infrastructure
    ├── Navigator/                   # Sistema de navegación
    │   ├── Navigator.swift
    │   ├── NavigatorProtocol.swift
    │   └── Components/
    │       ├── Router.swift
    │       ├── Page.swift
    │       └── ...
    ├── Configuration/               # Config global
    │   ├── Config.swift
    │   └── ConfigTripleA.swift
    ├── Error/                       # Manejo de errores
    │   └── ErrorHandlerManager.swift
    └── Utilities/                   # Utilidades compartidas
```

---

## Analogía simple

Imagina que la app es un restaurante:

- **View** = El mesero. Toma pedidos del cliente y los pasa a la cocina. Trae la comida y la sirve.
- **ViewModel** = El jefe de cocina. Coordina todo lo que pasa en cocina. Decide qué hacer con cada pedido.
- **UseCase** = El sous chef. Sabe cómo preparar cada plato (lógica de negocio).
- **Repository** = El proveedor. Consigue los ingredientes de donde sea necesario.
- **DataSource** = El camión del proveedor. Va a buscar los ingredientes.
- **Router** = El gerente del restaurante. Decide cómo están organizadas las cosas.
- **Navigator** = El libro de reservas central. Todos saben dónde está y qué está pasando.

Todo funciona mejor cuando cada uno hace su trabajo sin meterse en el de los demás.

---

## Conclusión

Esta arquitectura puede parecer compleja al principio, pero es muy poderosa:

✅ **Es mantenible**: Cambios en un lugar no rompen todo
✅ **Es testeable**: Todo está desacoplado
✅ **Es escalable**: Agregar features es predecible
✅ **Es clara**: Cada cosa está en su lugar

La clave es entender que los datos fluyen en una dirección y cada capa tiene una responsabilidad clara.
