# 🌱 Seed Data - Instrucciones

## ¿Qué es Seed Data?

Son datos de ejemplo (equipos y jugadores) que se cargan en Firestore para que puedas ver la app funcionando sin tener que crear datos manualmente.

---

## 📁 Archivos Creados

```
MyDreamTeam/Shared/SeedData/
└── SeedDataManager.swift          ✅ Manager que carga datos en Firestore

MyDreamTeam/Presentation/Screens/Debug/
└── DebugView.swift                ✅ Interfaz para ejecutar el seed data
```

---

## 🚀 Cómo Usar

### Opción 1: Desde la App (Recomendado)

1. **Abre la app en Xcode**
2. **Accede al menú Debug**
   - Agrega un botón en HomeView o crea un menú de settings
   - O navega directamente a `DebugView()`

3. **Toca el botón "Seed Firestore Data"**
   - Espera a que se complete
   - Verás confirmación cuando termina

4. **Listo!** Los datos ahora están en Firestore

### Opción 2: Desde Swift Playground (Alternativo)

```swift
import Combine

Task {
    try await SeedDataManager.shared.seedAllData()
    print("✅ Seed completado")
}
```

---

## 📊 Datos que se Cargan

### ⚽ Equipos (6 total)

#### La Liga (España)
- **Real Madrid** (1902)
  - Coach: Carlo Ancelotti
  - Stadium: Santiago Bernabéu
  - Record: 14W-4D-2L (46 pts, Posición 1)

- **FC Barcelona** (1899)
  - Coach: Xavi Hernández
  - Stadium: Camp Nou
  - Record: 13W-3D-4L (42 pts, Posición 2)

- **Atlético Madrid** (1903)
  - Coach: Diego Simeone
  - Stadium: Civitas Metropolitano
  - Record: 12W-5D-3L (41 pts, Posición 3)

#### Premier League (Inglaterra)
- **Manchester City** (1880)
  - Coach: Pep Guardiola
  - Stadium: Etihad Stadium
  - Record: 15W-4D-1L (49 pts, Posición 1)

- **Liverpool FC** (1892)
  - Coach: Arne Slot
  - Stadium: Anfield
  - Record: 14W-3D-3L (45 pts, Posición 2)

- **Arsenal FC** (1886)
  - Coach: Mikel Arteta
  - Stadium: Emirates Stadium
  - Record: 13W-4D-3L (43 pts, Posición 3)

---

### 👥 Jugadores (8 total)

#### Real Madrid
| Nombre | Posición | Número | Goles | Asist | Rating | Valor |
|--------|----------|--------|-------|-------|--------|-------|
| Vinicius Junior | FWD | 7 | 12 | 5 | 8.4 | €85M |
| Karim Benzema | FWD | 9 | 10 | 3 | 8.2 | €35M |
| Luka Modrić | MID | 10 | 3 | 6 | 8.1 | €28M |

#### Barcelona
| Nombre | Posición | Número | Goles | Asist | Rating | Valor |
|--------|----------|--------|-------|-------|--------|-------|
| Robert Lewandowski | FWD | 9 | 14 | 4 | 8.3 | €50M |
| Pablo Gavi | MID | 6 | 2 | 5 | 7.8 | €60M |

#### Manchester City
| Nombre | Posición | Número | Goles | Asist | Rating | Valor |
|--------|----------|--------|-------|-------|--------|-------|
| Erling Haaland | FWD | 9 | 18 | 3 | 8.9 | €180M |
| Kevin De Bruyne | MID | 17 | 5 | 8 | 8.6 | €75M |

#### Liverpool
| Nombre | Posición | Número | Goles | Asist | Rating | Valor |
|--------|----------|--------|-------|-------|--------|-------|
| Mohamed Salah | FWD | 11 | 13 | 6 | 8.5 | €70M |

#### Arsenal
| Nombre | Posición | Número | Goles | Asist | Rating | Valor |
|--------|----------|--------|-------|-------|--------|-------|
| Bukayo Saka | FWD | 7 | 8 | 7 | 8.0 | €55M |

---

## ✅ Qué Puedes Hacer Después

### 1. **Buscar Jugadores**
- Abre PlayerSelection
- Busca "Haaland", "Salah", "Lewandowski", etc.
- Verás los jugadores con sus estadísticas

### 2. **Filtrar por Posición**
- FWD: 8 delanteros disponibles
- MID: 4 centrocampistas
- DEF: Sin defensas (puedes agregar más en SeedDataManager)
- GK: Sin porteros (puedes agregar más)

### 3. **Ver Estadísticas**
- Rating, Goles, Asistencias
- Valor de mercado
- Equipo actual

### 4. **Crear Equipo Fantasy**
- Presupuesto: 100€
- Selecciona jugadores
- Ve cómo cambia el presupuesto

### 5. **Comparar Jugadores**
- Selecciona un jugador
- Toca "Comparar" con otro
- Ve el análisis comparativo

---

## 🔄 Actualizar Datos

Si quieres modificar los datos (agregar más jugadores, cambiar estadísticas, etc.):

### Opción 1: Editar SeedDataManager.swift

```swift
// Agrega más equipos
let newTeam = createTeamDTO(
    id: "team_juventus",
    name: "Juventus",
    country: "Italy",
    city: "Turin",
    // ... resto de parámetros
)

// Agrega al array de teams
var teams = [team1, team2, newTeam] // Nueva línea
```

### Opción 2: Agregar a través de Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Abre tu proyecto MyDreamTeam
3. Ve a Firestore Database
4. Agrega manualmente documentos en `/players` o `/teams`

---

## 🗑️ Limpiar Datos

Si quieres empezar de cero:

### Opción 1: Firebase Console
1. Ve a Firestore Database
2. Selecciona colección `/players`
3. Selecciona todos los documentos
4. Delete
5. Repite para `/teams`

### Opción 2: Script (Opcional)
```swift
// En SeedDataManager.swift, agrega:
func deleteAllData() async throws {
    let playersSnapshot = try await db.collection("players").getDocuments()
    for doc in playersSnapshot.documents {
        try await db.collection("players").document(doc.documentID).delete()
    }

    let teamsSnapshot = try await db.collection("teams").getDocuments()
    for doc in teamsSnapshot.documents {
        try await db.collection("teams").document(doc.documentID).delete()
    }
}
```

---

## 📍 Estructura Firestore Creada

```
Firestore Database
│
├── players/
│   ├── player_vinicius
│   │   ├── id: "player_vinicius"
│   │   ├── firstName: "Vinicius"
│   │   ├── lastName: "Junior"
│   │   ├── position: "FWD"
│   │   ├── marketValue: 85.0
│   │   ├── stats: { played, goals, assists, ... }
│   │   └── ... otros campos
│   │
│   ├── player_haaland
│   │   ├── firstName: "Erling"
│   │   ├── position: "FWD"
│   │   ├── marketValue: 180.0
│   │   └── ...
│   │
│   └── ... (6 jugadores más)
│
└── teams/
    ├── team_real_madrid
    │   ├── id: "team_real_madrid"
    │   ├── name: "Real Madrid"
    │   ├── league: "La Liga"
    │   ├── stats: { played, won, drawn, lost, points, position, ... }
    │   └── ...
    │
    ├── team_manchester_city
    │   ├── name: "Manchester City"
    │   ├── league: "Premier League"
    │   └── ...
    │
    └── ... (4 equipos más)
```

---

## 🔐 Security Rules

Los datos seed usan las mismas security rules que el resto de la app:

```javascript
match /players/{playerId} {
  allow read: if true;      // Lectura pública
  allow write: if false;    // Escritura solo backend
}

match /teams/{teamId} {
  allow read: if true;      // Lectura pública
  allow write: if false;    // Escritura solo backend
}
```

---

## 🧪 Testing

### Ver datos en Firebase Console

1. Abre [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto
3. Ve a Firestore Database
4. Verás las colecciones `players` y `teams` pobladas

### Ver en la App

1. Abre PlayerSelectionView
2. Carga los jugadores
3. Busca "Haaland"
4. Debería aparecer con rating 8.9 y €180M

---

## 📝 Notas Importantes

- Los datos son de **ejemplo/ficción** (mezcla de ligas)
- **Están los mismos jugadores en múltiples equipos** (solo para demo)
- **No hay estadísticas reales** (son inventadas)
- **Para producción** necesitarías datos reales de una API

---

## 🚀 Próximos Pasos

1. **Agregar más defensas y porteros**
   - Actualmente solo FWD y MID
   - Necesitas GK y DEF para formar equipos válidos

2. **Importar datos reales**
   - API de Transfermarkt
   - API de ESPN
   - Datos oficiales de ligas

3. **Actualizar estadísticas automáticamente**
   - Después de cada jornada
   - Basado en resultados reales

4. **Crear dashboard de administración**
   - Para agregar/editar datos sin código

---

## ❓ FAQ

**P: ¿Dónde ejecuto el seed data?**
R: En DebugView, que puedes navegar desde cualquier pantalla o agregar un botón en Settings.

**P: ¿Puedo ejecutarlo múltiples veces?**
R: Sí, sobrescribirá los datos existentes sin problemas.

**P: ¿Los datos persisten?**
R: Sí, se guardan en Firestore. Permanecerán hasta que los borres manualmente.

**P: ¿Necesito usuario autenticado?**
R: No, el seed data se carga directamente a Firestore sin autenticación (porque write: false).

**P: ¿Puedo editar los datos del seed?**
R: Sí, modifica `SeedDataManager.swift` y ejecuta de nuevo.

---

**¡Listo! 🎉 Ahora tienes datos para testear toda la funcionalidad de Teams y Players.**

