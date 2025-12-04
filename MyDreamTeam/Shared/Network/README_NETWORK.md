# Capa de Network - Guía Completa

## 📚 Índice

1. [Introducción](#introducción)
2. [Arquitectura](#arquitectura)
3. [Componentes](#componentes)
4. [Cómo Usar](#cómo-usar)
5. [Ejemplos Prácticos](#ejemplos-prácticos)
6. [Autenticación](#autenticación)
7. [Logging](#logging)
8. [Manejo de Errores](#manejo-de-errores)
9. [Testing](#testing)

---

## 📖 Introducción

La capa de Network es el sistema centralizado de todas las llamadas HTTP de la aplicación. Está inspirado en la arquitectura de [TripleA](https://github.com/fsalom/TripleA), pero implementado completamente de forma local sin dependencias externas.

### Características principales

✅ Async/Await nativo (iOS 13+)
✅ Autenticación OAuth2 integrada
✅ Logging configurable para debugging
✅ Manejo robusto de errores
✅ Fácil de testear (inyección de dependencias)
✅ Separación clara de responsabilidades

---

## 🏗️ Arquitectura

La capa de Network sigue estos principios:

### Principio 1: Separación de Responsabilidades

```
┌─────────────────────────────────────────┐
│          Presentation Layer             │
│   (Views, ViewModels)                   │
└────────────────┬────────────────────────┘
                 │
┌─────────────────────────────────────────┐
│          Domain Layer                   │
│   (Usecases, Repositories)              │
└────────────────┬────────────────────────┘
                 │
┌─────────────────────────────────────────┐
│          Data Layer                     │
│   (Datasources - ← AQUÍ USAMOS NETWORK) │
└────────────────┬────────────────────────┘
                 │
┌─────────────────────────────────────────┐
│          Network Layer (NUEVO)          │
│   (Endpoints, Network, AuthManager)     │
└─────────────────────────────────────────┘
```

### Principio 2: Centralización

Todas las llamadas HTTP pasan por la clase `Network`. Esto permite:
- Logging centralizado
- Manejo uniforme de errores
- Inyección de tokens automática
- Testing más fácil

---

## 🔧 Componentes

### 1. Endpoint Protocol

**Archivo:** `Core/Endpoint.swift`

Define cómo se estructura una petición HTTP.

```swift
protocol Endpoint {
    var path: String { get }              // "/users"
    var method: HTTPMethod { get }        // .get, .post, etc
    var parameters: [String: Any]? { get } // Body para POST/PUT
    var headers: [String: String]? { get } // Headers específicos
    var contentType: ContentType { get }  // application/json, etc
    var queryParameters: [String: String]? { get } // Query string
}
```

**Por qué:** Permite definir endpoints de forma declarativa y tipada.

```swift
enum UserEndpoint: Endpoint {
    case list(page: Int)
    case detail(id: Int)
    case create(name: String, email: String)

    var path: String {
        switch self {
        case .list:
            return "/users"
        case let .detail(id):
            return "/users/\(id)"
        case .create:
            return "/users"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .list, .detail:
            return .get
        case .create:
            return .post
        }
    }

    // ...
}
```

### 2. Network Class

**Archivo:** `Core/Network.swift`

Gestor centralizado de todas las peticiones HTTP.

```swift
class Network {
    // Realiza una petición y decodifica la respuesta
    func request<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type
    ) async throws -> T

    // Realiza una petición sin esperar respuesta
    func requestVoid(endpoint: Endpoint) async throws

    // Descarga archivos
    func downloadFile(endpoint: Endpoint, to destination: URL) async throws
}
```

**Responsabilidades:**
- Construir URLRequest desde Endpoint
- Realizar la petición HTTP
- Validar respuestas (status codes)
- Decodificar JSON
- Inyectar tokens automáticamente
- Loguear peticiones/respuestas

### 3. AuthManager Class

**Archivo:** `Authentication/AuthManager.swift`

Gestiona tokens y renovación automática.

```swift
class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool
    @Published var currentToken: String?

    func login(username: String, password: String) async throws
    func logout()
    func refreshToken() async throws
    func isTokenValid() -> Bool
}
```

**Características:**
- Almacena tokens en UserDefaults (TokenStore)
- Publica cambios de autenticación (@Published)
- Maneja renovación de tokens
- Inyecta automáticamente Authorization header

### 4. NetworkLogger Class

**Archivo:** `Core/NetworkLogger.swift`

Logging configurable para debugging.

```swift
class NetworkLogger {
    var isEnabled: Bool = true
    var logLevel: LogLevel = .info

    enum LogLevel {
        case verbose  // Todo
        case debug    // Completo con headers/body
        case info     // Solo URLs y status codes
        case warning  // Solo warnings y errores
        case error    // Solo errores
        case none     // Desactivado
    }
}
```

**Características:**
- 5 niveles de logging
- Oculta tokens y credenciales (sanitización)
- Pretty-prints JSON
- Emoji decorativos para fácil lectura

---

## 🚀 Cómo Usar

### Paso 1: Definir un Endpoint

```swift
enum ProductEndpoint: Endpoint {
    case list(page: Int = 1)
    case detail(id: Int)

    var path: String {
        switch self {
        case .list:
            return "/products"
        case let .detail(id):
            return "/products/\(id)"
        }
    }

    var method: HTTPMethod {
        return .get
    }

    var queryParameters: [String: String]? {
        switch self {
        case let .list(page):
            return ["page": String(page)]
        default:
            return nil
        }
    }
}
```

### Paso 2: Crear un DTO (Data Transfer Object)

```swift
struct ProductDTO: Codable, Identifiable {
    let id: Int
    let name: String
    let price: Double

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
    }
}
```

### Paso 3: Crear un Datasource

```swift
class ProductRemoteDataSource {
    private let network: Network

    init(network: Network = Network.shared) {
        self.network = network
    }

    func getProducts(page: Int) async throws -> [ProductDTO] {
        let endpoint = ProductEndpoint.list(page: page)
        return try await network.request(
            endpoint: endpoint,
            responseType: [ProductDTO].self
        )
    }

    func getProduct(id: Int) async throws -> ProductDTO {
        let endpoint = ProductEndpoint.detail(id: id)
        return try await network.request(
            endpoint: endpoint,
            responseType: ProductDTO.self
        )
    }
}
```

### Paso 4: Usar en Repository

```swift
class ProductRepositoryImpl: ProductRepository {
    private let remoteDatasource: ProductRemoteDataSource

    func getProducts(page: Int) async throws -> [Product] {
        let dtos = try await remoteDatasource.getProducts(page: page)
        return dtos.map { $0.toDomain() }
    }
}
```

### Paso 5: Usar en ViewModel

```swift
@MainActor
class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let getProductsUseCase: GetProductsUseCase

    func loadProducts() {
        isLoading = true

        Task {
            do {
                self.products = try await getProductsUseCase.execute(page: 1)
            } catch {
                self.errorMessage = (error as? NetworkError)?.errorDescription ?? "Error"
            }
            self.isLoading = false
        }
    }
}
```

---

## 💡 Ejemplos Prácticos

### Ejemplo 1: GET Simple

```swift
// Endpoint
enum UserEndpoint: Endpoint {
    case list

    var path: String { "/users" }
    var method: HTTPMethod { .get }
    var parameters: [String: Any]? { nil }
}

// Uso
let users: [UserDTO] = try await Network.shared.request(
    endpoint: UserEndpoint.list,
    responseType: [UserDTO].self
)
```

### Ejemplo 2: GET con Query Parameters

```swift
// Endpoint
enum SearchEndpoint: Endpoint {
    case search(query: String, limit: Int)

    var path: String { "/search" }
    var method: HTTPMethod { .get }

    var queryParameters: [String: String]? {
        switch self {
        case let .search(query, limit):
            return ["q": query, "limit": String(limit)]
        }
    }
}

// Uso
let results: [SearchResultDTO] = try await Network.shared.request(
    endpoint: SearchEndpoint.search(query: "iPhone", limit: 10),
    responseType: [SearchResultDTO].self
)
```

### Ejemplo 3: POST con Body

```swift
// Endpoint
enum AuthEndpoint: Endpoint {
    case login(username: String, password: String)

    var path: String { "/auth/login" }
    var method: HTTPMethod { .post }

    var parameters: [String: Any]? {
        switch self {
        case let .login(username, password):
            return [
                "username": username,
                "password": password,
                "grant_type": "password"
            ]
        }
    }
}

// Uso
let response: AuthResponse = try await Network.shared.request(
    endpoint: AuthEndpoint.login(username: "user", password: "pass"),
    responseType: AuthResponse.self
)
```

### Ejemplo 4: DELETE (sin respuesta)

```swift
// Endpoint
enum UserEndpoint: Endpoint {
    case delete(id: Int)

    var path: String {
        switch self {
        case let .delete(id):
            return "/users/\(id)"
        }
    }
    var method: HTTPMethod { .delete }
}

// Uso
try await Network.shared.requestVoid(endpoint: UserEndpoint.delete(id: 1))
```

### Ejemplo 5: Descarga de Archivos

```swift
let endpoint = FileEndpoint.download(fileName: "document.pdf")
let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("document.pdf")

try await Network.shared.downloadFile(endpoint: endpoint, to: destinationURL)
```

---

## 🔐 Autenticación

### Configuración Inicial

```swift
// En AppDelegate o al iniciar la app
let authConfig = AuthConfig(
    clientId: "tu_client_id",
    clientSecret: "tu_client_secret",
    grantType: .password
)

let authManager = AuthManager(
    network: Network.shared,
    config: authConfig
)

Network.shared.setAuthManager(authManager)
```

### Login

```swift
@MainActor
class LoginViewModel: ObservableObject {
    @Published var isAuthenticated = false

    let authManager: AuthManager

    func login(username: String, password: String) {
        Task {
            do {
                try await authManager.login(username: username, password: password)
                self.isAuthenticated = true
            } catch let error as AuthError {
                print(error.errorDescription ?? "Login failed")
            }
        }
    }
}
```

### Logout

```swift
authManager.logout()
```

### Renovación Automática

Network inyecta automáticamente el token:

```swift
// Network.swift
if let token = authManager?.currentToken {
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
}
```

Si recibe 401, podrías implementar renovación automática:

```swift
// En Network.swift (opcional)
if httpResponse.statusCode == 401 {
    try await authManager?.refreshToken()
    // Reintentar petición
}
```

---

## 📊 Logging

### Configuración

```swift
let logger = NetworkLogger()
logger.isEnabled = true
logger.logLevel = .debug

let network = Network(logger: logger)
```

### Niveles de Log

**Verbose:**
```
📤 ─────────────────────────────────────────
REQUEST: GET https://api.example.com/users
HEADERS:
  Content-Type: application/json
  Authorization: [HIDDEN]
─────────────────────────────────────────

📥 ─────────────────────────────────────────
RESPONSE: ✅ 200
DATA:
[
  {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  }
]
─────────────────────────────────────────
```

**Info:**
```
📤 GET https://api.example.com/users
📥 ✅ 200
```

---

## ⚠️ Manejo de Errores

### Tipos de Errores

```swift
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case unauthorized              // 401
    case forbidden                 // 403
    case notFound                  // 404
    case serverError(Int)          // 5xx
    case httpError(Int)            // Otros
    case noInternet
    case timeout
    case unknown(Error)
}
```

### Manejo en ViewModel

```swift
@MainActor
class UserListViewModel: ObservableObject {
    @Published var errorMessage: String?

    func loadUsers() {
        Task {
            do {
                // hacer llamada
            } catch let error as NetworkError {
                self.errorMessage = error.errorDescription
            } catch {
                self.errorMessage = "Error desconocido"
            }
        }
    }
}
```

### Manejo en Datasource

```swift
func getUsers() async throws -> [UserDTO] {
    do {
        return try await network.request(
            endpoint: UserEndpoint.list,
            responseType: [UserDTO].self
        )
    } catch let error as NetworkError {
        // Convertir a AppError si es necesario
        throw errorHandler.transform(error)
    }
}
```

---

## 🧪 Testing

### Mock de Network

```swift
class MockNetwork: Network {
    var mockResponse: Any?
    var shouldFail: Bool = false

    override func request<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type
    ) async throws -> T {
        if shouldFail {
            throw NetworkError.unknown(NSError())
        }
        return mockResponse as! T
    }
}
```

### Test de Datasource

```swift
@MainActor
class UserRemoteDataSourceTests: XCTestCase {
    var datasource: UserRemoteDataSource!
    var mockNetwork: MockNetwork!

    override func setUp() {
        super.setUp()
        mockNetwork = MockNetwork()
        datasource = UserRemoteDataSource(network: mockNetwork)
    }

    func testGetUsersSuccess() async throws {
        // Arrange
        let expectedUsers = [
            UserDTO(id: 1, name: "John", email: "john@example.com", avatar: nil, createdAt: nil)
        ]
        mockNetwork.mockResponse = expectedUsers

        // Act
        let users = try await datasource.getUsers(page: 1)

        // Assert
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users.first?.name, "John")
    }
}
```

---

## 📋 Checklist de Implementación

Cuando implementes un nuevo endpoint:

- [ ] Definir Endpoint enum
- [ ] Crear DTO(s) Codable
- [ ] Implementar RemoteDataSource
- [ ] Agregar a Repository
- [ ] Crear UseCase
- [ ] Usar en ViewModel
- [ ] Testear con MockNetwork
- [ ] Verificar logs en debug

---

## 🎯 Resumen

| Componente | Responsabilidad |
|---|---|
| **Endpoint** | Definir estructura de petición |
| **Network** | Ejecutar peticiones HTTP |
| **AuthManager** | Gestionar autenticación |
| **RemoteDataSource** | Acceder a la API |
| **Repository** | Implementar interfaz del Domain |
| **ViewModel** | Presentar datos en UI |

El flujo completo:

```
ViewModel
    ↓
UseCase
    ↓
Repository
    ↓
RemoteDataSource  ← Usa Network aquí
    ↓
Network  ← Ejecuta petición HTTP
    ↓
Endpoint  ← Define estructura
    ↓
URLSession
    ↓
API
```

---

## 🔗 Referencias

- [Inspirado en TripleA](https://github.com/fsalom/TripleA)
- [URLSession Documentation](https://developer.apple.com/documentation/foundation/urlsession)
- [Async/Await](https://developer.apple.com/videos/play/wwdc2021/10132/)
- [Swift Codable](https://developer.apple.com/documentation/foundation/codable)

---

## ❓ Preguntas Frecuentes

**P: ¿Cómo cambio la URL base?**
A: Pasala al constructor de Network:
```swift
let network = Network(baseURL: URL(string: "https://nueva.api.com")!)
```

**P: ¿Cómo agrego headers globales?**
A: Modifica en `buildRequest`:
```swift
request.setValue("es-ES", forHTTPHeaderField: "Accept-Language")
```

**P: ¿Cómo manejo timeout personalizado?**
A: Modifica en `buildRequest`:
```swift
request.timeoutInterval = 60 // segundos
```

**P: ¿Puedo usar variables de entorno?**
A: Sí, en EndpointConfiguration:
```swift
let baseURL = URL(string: APIConfig.baseURL)!
```

**P: ¿Cómo testeo sin internet?**
A: Usa MockNetwork en tests:
```swift
datasource = UserRemoteDataSource(network: MockNetwork())
```

¡Eso es todo! La capa de Network está lista para usar. 🚀
