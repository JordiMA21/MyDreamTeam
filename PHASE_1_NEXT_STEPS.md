# Phase 1: Próximos Pasos INMEDIATOS

## 🎯 Lo que acabamos de completar

✅ Creados todos los 7 archivos de Fase 1:
1. AuthenticatedUser.swift
2. FirebaseAuthDataSource.swift
3. AuthenticationDTO.swift
4. AuthenticationRepositoryProtocol.swift
5. AuthenticationRepository.swift
6. AuthenticationUseCase.swift
7. AuthenticationContainer.swift

---

## ⚡ Pasos para Completar Fase 1 (Ahora mismo)

### Paso 1: Descargar GoogleService-Info.plist

1. Ve a https://console.firebase.google.com
2. Selecciona tu proyecto `MyDreamTeam`
3. Click en **Configuración del proyecto** (⚙️)
4. Descarga `GoogleService-Info.plist`

### Paso 2: Agregar archivo a Xcode

1. Abre Xcode el proyecto `MyDreamTeam.xcodeproj`
2. Arrastra `GoogleService-Info.plist` a la carpeta `MyDreamTeam` en Xcode
3. Asegúrate de seleccionar:
   - ✅ "Copy items if needed"
   - ✅ Target: `MyDreamTeam`

### Paso 3: Instalar Firebase SDK

```bash
cd /Users/jordimiguelaguado/Desktop/Jordi/MyDreamTeam

# Ver contenido actual del Podfile
cat Podfile
```

**Ejemplo de Podfile actualizado:**

```ruby
platform :ios, '16.0'

target 'MyDreamTeam' do
  use_frameworks!

  # Firebase
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Functions'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'

  # Tus pods existentes aquí...

end
```

**Instalar:**
```bash
pod install
```

### Paso 4: Configurar AppDelegate

**Archivo:** `MyDreamTeam/MyDreamTeamApp.swift`

Debe verse así:

```swift
import SwiftUI
import Firebase

@main
struct MyDreamTeamApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
```

### Paso 5: Compilar y Verificar

```bash
# Cerrar Xcode
# Abrir workspace (NO proyecto):
open MyDreamTeam.xcworkspace

# Limpiar y compilar
xcodebuild clean
xcodebuild build -workspace MyDreamTeam.xcworkspace -scheme MyDreamTeam -configuration Debug
```

**O en Xcode:**
- Product → Clean Build Folder (⇧⌘K)
- Product → Build (⌘B)

---

## 🔍 Verificar que todo compila

Si ves errores:

1. **"Cannot find 'Firebase' in scope"**
   - Asegúrate de agregar `import Firebase` en `MyDreamTeamApp.swift`

2. **"Module 'Firebase' not found"**
   - Ejecuta `pod install` nuevamente
   - Asegúrate de abrir `.xcworkspace` (no `.xcodeproj`)

3. **"FirebaseAuthDataSourceProtocol not found"**
   - Verifica que los archivos estén en el target `MyDreamTeam`

---

## 📱 Crear una View de Prueba (Opcional)

Para verificar que todo funciona, crea `AuthTestView.swift`:

```swift
import SwiftUI

struct AuthTestView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""

    private let authUseCase = AuthenticationContainer.shared.makeUseCase()

    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            HStack(spacing: 10) {
                Button("Sign Up") {
                    signUp()
                }
                .buttonStyle(.borderedProminent)

                Button("Sign In") {
                    signIn()
                }
                .buttonStyle(.bordered)
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            if let user = authUseCase.getCurrentUser() {
                Text("✅ Logged in as: \(user.email)")
                    .foregroundColor(.green)
            }
        }
        .padding()
    }

    private func signUp() {
        isLoading = true
        Task {
            do {
                let user = try await authUseCase.signUp(email: email, password: password)
                print("✅ Signed up: \(user.email)")
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func signIn() {
        isLoading = true
        Task {
            do {
                let user = try await authUseCase.signIn(email: email, password: password)
                print("✅ Signed in: \(user.email)")
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
```

---

## 🧪 Test con Firebase Emulator (Recomendado)

Para testing local sin necesidad de Firebase real:

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Inicializar emuladores
firebase init emulators
# Selecciona: Firestore, Authentication

# Iniciar emuladores
firebase emulators:start
```

Luego en tu código:

```swift
#if DEBUG
// Conectar a emulator cuando está en desarrollo
Auth.auth().useEmulator(withHost: "localhost", port: 9099)
#endif
```

---

## ✅ Checklist Final

- [ ] `GoogleService-Info.plist` descargado y agregado a Xcode
- [ ] Podfile actualizado con pods de Firebase
- [ ] `pod install` ejecutado
- [ ] `MyDreamTeamApp.swift` configurado con `FirebaseApp.configure()`
- [ ] Proyecto compilado sin errores (⌘B)
- [ ] (Opcional) AuthTestView.swift creado y funciona
- [ ] (Opcional) Firebase Emulator iniciado

---

## 📊 Progreso Actual

```
Phase 1: Authentication
├── ✅ Domain Layer (3 archivos)
├── ✅ Data Layer (3 archivos)
├── ✅ DI (1 archivo)
├── ⏳ Firebase Setup (pendiente - AHORA)
├── ⏳ Compilación (pendiente - AHORA)
└── ⏳ Testing (opcional)

Progreso: 7/7 archivos + Setup
```

---

## 🚀 Una vez que Phase 1 compile...

Pasaremos a **Phase 2: Users Collection** que requiere:
- Crear colección `users` en Firestore
- 7 archivos similares a Phase 1
- Implementación de crear usuario, leer perfil, actualizar perfil

---

## 📞 Preguntas Frecuentes

**P: ¿Dónde descargo GoogleService-Info.plist?**
R: Firebase Console → Configuración del Proyecto → Descargar archivo

**P: ¿Qué pasa si tengo errores de compilación?**
R: Casi siempre es porque:
1. No ejecutaste `pod install`
2. Abriste `.xcodeproj` en lugar de `.xcworkspace`
3. Falta `import Firebase` en `MyDreamTeamApp.swift`

**P: ¿Necesito el emulator?**
R: No es obligatorio, pero es muy útil para testing local sin usar cuota de Firebase.

**P: ¿Cuándo puedo empezar Phase 2?**
R: Inmediatamente después de que Phase 1 compile exitosamente.

---

## 🎯 Tiempo Estimado

- Descarga de plist: 2 min
- Instalación de pods: 5 min
- Configuración AppDelegate: 2 min
- Compilación: 3-5 min
- Testing (opcional): 10 min

**Total: 15-25 minutos**

---

**¿Listo para empezar? ¡Vamos!**
