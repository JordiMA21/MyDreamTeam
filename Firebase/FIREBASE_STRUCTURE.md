# Firebase Database Structure - MyDreamTeam

## 📊 Overview

La estructura de Firebase se divide en dos bases de datos:
- **Firestore**: Datos estructurados (usuarios, equipos, jugadores, ligas, etc.)
- **Realtime Database**: Eventos deportivos en tiempo real

---

## 🔥 FIRESTORE DATABASE STRUCTURE

### Convenciones
- **Colecciones**: camelCase singular (`user`, `team`, `player`, `league`)
- **Documentos**: UUID o nombre significativo
- **Campos**: camelCase
- **Timestamps**: ISO 8601 o Firestore timestamp

---

## 📋 COLECCIONES PRINCIPALES

### 1. `users` - Perfiles de Usuarios

```
/users/{userId}
├── uid: String (Firebase Auth UID)
├── email: String
├── displayName: String
├── profileImage: String (URL)
├── bio: String
├── createdAt: Timestamp
├── updatedAt: Timestamp
├── preferences: {
│   ├── favoriteTeam: String (teamId)
│   ├── favoriteLeagues: [String] (leagueIds)
│   ├── notifications: Boolean
│   └── language: String
├── stats: {
│   ├── leaguesCreated: Int
│   ├── leaguesJoined: Int
│   ├── totalPoints: Int
│   └── rank: Int
└── status: String (active, inactive, suspended)
```

**Índices necesarios**:
- `createdAt`
- `status`

---

### 2. `leagues` - Ligas Fantasy

```
/leagues/{leagueId}
├── name: String
├── description: String
├── createdBy: String (userId)
├── createdAt: Timestamp
├── season: Int (2024, 2025, etc.)
├── status: String (active, ended, draft)
├── maxPlayers: Int
├── scoringFormat: String (ppr, standard, custom)
├── scoringRules: {
│   ├── goalScore: Int
│   ├── assistScore: Int
│   ├── cleanSheetScore: Int
│   ├── yellowCardScore: Int (negativo)
│   └── redCardScore: Int (negativo)
├── settings: {
│   ├── startDate: Timestamp
│   ├── endDate: Timestamp
│   ├── isPublic: Boolean
│   ├── allowTransfers: Boolean
│   └── transferDeadline: Timestamp
├── totalPlayers: Int
├── image: String (URL)
└── rules: String (descripción de reglas)
```

**Índices necesarios**:
- `createdBy`
- `season`
- `status`
- `createdAt`

---

### 3. `leagueMembers` - Miembros de Ligas

```
/leagues/{leagueId}/members/{userId}
├── userId: String
├── leagueId: String
├── joinedAt: Timestamp
├── teamName: String (nombre del equipo fantasy)
├── totalPoints: Int
├── rank: Int
├── wins: Int
├── draws: Int
├── losses: Int
├── matchesPlayed: Int
├── transfersRemaining: Int
├── status: String (active, inactive, removed)
└── squad: [String] (playerIds en el equipo)
```

**Índices necesarios**:
- `leagueId`
- `totalPoints` (descending)
- `rank`

---

### 4. `teams` - Equipos Reales (Base de Datos)

```
/teams/{teamId}
├── teamId: String (identificador único)
├── name: String
├── country: String
├── city: String
├── founded: Int (año)
├── league: String
├── coach: String
├── stadium: String
├── logo: String (URL)
├── colors: {
│   ├── primary: String (hex)
│   └── secondary: String (hex)
├── season: Int (2024, 2025)
├── stats: {
│   ├── played: Int
│   ├── won: Int
│   ├── drawn: Int
│   ├── lost: Int
│   ├── goalsFor: Int
│   ├── goalsAgainst: Int
│   ├── points: Int
│   └── position: Int
└── history: Boolean (marca si hay datos históricos)
```

**Índices necesarios**:
- `season`
- `league`
- `country`

---

### 5. `players` - Jugadores Reales (Base de Datos)

```
/players/{playerId}
├── playerId: String
├── firstName: String
├── lastName: String
├── nationality: String
├── dateOfBirth: Timestamp
├── position: String (GK, DEF, MID, FWD)
├── number: Int
├── height: Double
├── weight: Double
├── foot: String (left, right, both)
├── currentTeamId: String
├── status: String (active, injured, suspended, loaned)
├── season: Int (2024, 2025)
├── stats: {
│   ├── played: Int
│   ├── goals: Int
│   ├── assists: Int
│   ├── yellowCards: Int
│   ├── redCards: Int
│   ├── cleanSheets: Int
│   ├── minutes: Int
│   └── averageRating: Double
├── photo: String (URL)
├── marketValue: {
│   ├── amount: Double
│   ├── currency: String (EUR, USD)
│   └── lastUpdated: Timestamp
└── history: Boolean (marca si hay datos históricos)
```

**Índices necesarios**:
- `currentTeamId`
- `position`
- `season`
- `status`

---

### 6. `matches` - Resultados de Partidos

```
/matches/{matchId}
├── matchId: String
├── homeTeamId: String
├── awayTeamId: String
├── homeTeamName: String
├── awayTeamName: String
├── date: Timestamp
├── status: String (scheduled, ongoing, finished, postponed)
├── season: Int
├── round: Int (jornada)
├── league: String
├── homeScore: Int
├── awayScore: Int
├── venue: String
├── referee: String
├── attendance: Int
├── events: [{
│   ├── minute: Int
│   ├── player: String (playerName)
│   ├── playerId: String
│   ├── type: String (goal, assist, yellow, red, substitution)
│   └── team: String (home, away)
}]
└── createdAt: Timestamp
```

**Índices necesarios**:
- `date`
- `status`
- `season`
- `homeTeamId`
- `awayTeamId`

---

### 7. `transfers` - Mercado de Fichajes

```
/transfers/{transferId}
├── transferId: String
├── playerId: String
├── playerName: String
├── fromTeamId: String
├── toTeamId: String
├── transferFee: {
│   ├── amount: Double
│   ├── currency: String
│   └── type: String (free, loan, permanent)
├── date: Timestamp
├── season: Int
├── status: String (completed, pending, cancelled)
├── loanDetails: {
│   ├── duration: Int (en meses)
│   ├── obligatoryBuy: Boolean
│   └── buyoutClause: Double
}
└── createdAt: Timestamp
```

**Índices necesarios**:
- `date` (descending)
- `season`
- `playerId`
- `status`

---

### 8. `leagueMatchups` - Enfrentamientos en Liga Fantasy

```
/leagues/{leagueId}/matchups/{matchupId}
├── matchupId: String
├── leagueId: String
├── week: Int (jornada de la liga fantasy)
├── team1UserId: String
├── team1Name: String
├── team1Score: Int
├── team2UserId: String
├── team2Name: String
├── team2Score: Int
├── status: String (scheduled, ongoing, finished)
├── startDate: Timestamp
├── endDate: Timestamp
├── winner: String (team1, team2, draw)
└── matchDetails: [{
    ├── playerId: String
    ├── points: Int
    ├── gamesPlayed: Int
    └── stats: { goals, assists, cleanSheets, etc. }
}]
```

**Índices necesarios**:
- `leagueId`
- `week`
- `status`

---

### 9. `leagueFeed` - Tablón Público de Liga

```
/leagues/{leagueId}/feed/{postId}
├── postId: String (UUID)
├── leagueId: String
├── authorId: String
├── authorName: String
├── authorImage: String (URL)
├── type: String (trade_proposal, injury_alert, milestone, comment, result_reaction)
├── title: String
├── content: String (descripción del evento)
├── relatedMatch: String (matchId, si aplica)
├── relatedPlayer: String (playerId, si aplica)
├── createdAt: Timestamp
├── updatedAt: Timestamp
├── likes: Int
├── likedBy: [String] (userIds)
├── comments: [{
│   ├── commentId: String
│   ├── authorId: String
│   ├── authorName: String
│   ├── content: String
│   ├── createdAt: Timestamp
│   ├── likes: Int
│   └── likedBy: [String]
}]
└── visibility: String (public, league-only)
```

**Índices necesarios**:
- `leagueId`
- `createdAt` (descending)
- `type`

---

### 10. `seasonHistory` - Histórico de Temporadas

```
/seasonHistory/{historyId}
├── season: Int
├── teamId: String (o playerId para historial de jugador)
├── type: String (team, player)
├── data: {
│   // Copia de stats de esa temporada
│   ├── name: String
│   ├── stats: { ... }
│   └── matches: [matchIds]
}
└── createdAt: Timestamp
```

---

### 11. `userFantasySquads` - Equipos Fantasy de Usuarios

```
/users/{userId}/fantasySquads/{squadId}
├── squadId: String
├── leagueId: String
├── leagueName: String
├── teamName: String
├── createdAt: Timestamp
├── players: [{
│   ├── playerId: String
│   ├── playerName: String
│   ├── position: String
│   ├── currentTeam: String
│   ├── weekPoints: Int
│   ├── totalPoints: Int
│   └── marketValue: Double
}]
├── formation: String (4-3-3, 3-5-2, etc.)
├── budget: {
│   ├── total: Double
│   ├── spent: Double
│   ├── remaining: Double
│   └── currency: String
}
├── bench: [{
│   // Mismo formato que players
}]
└── substitutions: [{
    ├── playerOut: String
    ├── playerIn: String
    ├── date: Timestamp
    └── points: Int
}]
```

---

## ⚡ REALTIME DATABASE STRUCTURE

Para eventos deportivos en tiempo real (actualizaciones de partidos en vivo):

```
/liveMatches/{matchId}
├── status: String (ongoing, finished)
├── homeScore: Int
├── awayScore: Int
├── lastUpdate: Timestamp
├── events: {
│   ├── {timestamp}: {
│   │   ├── type: String (goal, assist, yellow, red, substitution, start, end)
│   │   ├── playerId: String
│   │   ├── team: String (home, away)
│   │   ├── minute: Int
│   │   └── details: String (descripción del evento)
│   └── ...
├── possession: {
│   ├── home: Int (porcentaje)
│   └── away: Int (porcentaje)
├── shots: {
│   ├── home: Int
│   └── away: Int
}
└── corners: {
    ├── home: Int
    └── away: Int
}
```

**Listeners en tiempo real**:
- Usuarios observan partidos en vivo
- Se actualizan automáticamente con cada evento
- Ideal para notificaciones push

---

## 🔗 RELACIONES ENTRE COLECCIONES

```
Users
├── → Leagues (createdBy)
├── → LeagueMembers (userId)
├── → FantasySquads (userId)
└── → LeagueFeed (authorId)

Leagues
├── → LeagueMembers (leagueId)
├── → LeagueMatchups (leagueId)
├── → LeagueFeed (leagueId)
└── → Matches (season, league)

Players
├── → CurrentTeam (currentTeamId → Teams)
├── → Matches (playerStats)
├── → Transfers (playerId)
└── → UserFantasySquads (players array)

Teams
├── → Players (currentTeamId)
├── → Matches (homeTeamId, awayTeamId)
└── → Transfers (fromTeamId, toTeamId)

Matches
├── → Teams (homeTeamId, awayTeamId)
├── → Players (en events)
├── → LiveMatches (en Realtime DB)
└── → LeagueFeed (relatedMatch)

Transfers
├── → Players (playerId)
├── → Teams (fromTeamId, toTeamId)
└── → LeagueFeed (si es relevante)
```

---

## 🔐 FIRESTORE SECURITY RULES

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Public read, authenticated write
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
      allow read: if request.auth != null && {
        match /fantasySquads/{squad} {
          allow read, write: if request.auth.uid == userId;
        }
      }
    }

    // Public read for data
    match /teams/{teamId} {
      allow read: if true;
      allow write: if false; // Admin only
    }

    match /players/{playerId} {
      allow read: if true;
      allow write: if false; // Admin only
    }

    match /matches/{matchId} {
      allow read: if true;
      allow write: if false; // Admin only
    }

    // Leagues - members only
    match /leagues/{leagueId} {
      allow read: if true;
      allow write: if resource.data.createdBy == request.auth.uid;

      match /members/{userId} {
        allow read: if true;
        allow write: if request.auth.uid == userId ||
                       get(/databases/$(database)/documents/leagues/$(leagueId)).data.createdBy == request.auth.uid;
      }

      match /feed/{postId} {
        allow read: if true;
        allow write: if request.auth.uid == request.resource.data.authorId;
        allow delete: if request.auth.uid == resource.data.authorId;
      }
    }

    match /transfers/{transferId} {
      allow read: if true;
      allow write: if false; // Admin only
    }
  }
}
```

---

## 📊 Índices Compuestos Necesarios

Firestore pedirá crear estos automáticamente, pero documentados aquí:

| Colección | Campos | Dirección |
|-----------|--------|-----------|
| `users` | `createdAt` | Desc |
| `leagues` | `createdBy, createdAt` | Asc, Desc |
| `leagues` | `season, status` | Asc, Asc |
| `leagueMembers` | `leagueId, totalPoints` | Asc, Desc |
| `matches` | `date, status` | Desc, Asc |
| `matches` | `season, homeTeamId` | Asc, Asc |
| `leagueFeed` | `leagueId, createdAt` | Asc, Desc |
| `transfers` | `date, season` | Desc, Asc |

---

## 📝 Convenciones de Datos

### Timestamps
```swift
// Firestore Timestamp
createdAt: Timestamp.now()

// En las queries
.whereField("createdAt", isGreaterThan: startDate)
```

### Arrays
```javascript
// Nunca guarden arrays muy grandes (max 1000)
// Para más de 100 items, usar sub-colecciones

// Correcto
players: ["player1", "player2", "player3"]

// Incorrecto para muchos
comments: [{ todas los comentarios }] // Si hay miles
// Usar sub-colección en su lugar
```

### Subcollections vs Fields
```
// Usar sub-colecciones si:
// - Más de 100 documentos
// - Datos que cambian frecuentemente
// - Necesitas queries independientes

// Usar arrays si:
// - Menos de 100 items
// - Datos relativamente estáticos
// - Necesitas acceso juntos siempre
```

---

## 🚀 Pasos para Configurar

1. **Firestore**: Ir a Firebase Console → Crear Firestore Database
2. **Realtime Database**: Ir a Firebase Console → Crear Realtime Database
3. **Reglas de Seguridad**: Copiar reglas anteriores a cada BD
4. **Índices**: Crear índices compuestos como se lista arriba
5. **Datos Iniciales**: Poblar base de datos de equipos/jugadores (vía API o manual)

---

## 📚 Próximos Pasos

1. Crear DataSources para interactuar con Firestore
2. Crear Repositories implementando protocolos
3. Crear UseCases para lógica de negocio
4. Crear ViewModels para UI
5. Generar código para Realtime Database con listeners

