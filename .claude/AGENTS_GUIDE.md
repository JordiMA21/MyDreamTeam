# Guía de Agentes para MyDreamTeam

Aquí hay 5 agentes especializados creados para acelerar el desarrollo de tu app iOS. Cada uno tiene un propósito específico.

## 🚀 Cómo Usar los Agentes

### Opción 1: Desde Claude Code
```bash
/agents
```
Selecciona el agente que necesites de la lista.

### Opción 2: Invocación Directa
Cuando interactúes conmigo, puedo invocar un agente específico basándome en tu solicitud.

---

## 📋 Los 6 Agentes

### 0. **Project Manager** ⭐ NUEVO
**Para**: Planificar, organizar y coordinar el desarrollo del proyecto

**Úsalo cuando**:
- Necesites crear un plan de actuación detallado
- Quieras dividir features en tareas manejables
- Necesites generar tarjetas de Trello
- Quieras seguimiento de progreso
- Necesites reportes de estado
- Identifiques dependencias entre tareas

**Ejemplo de uso**:
```
"Project Manager, crea un plan detallado para implementar autenticación"
"Necesito desglosar la feature de Fantasy Squad en tareas"
"Genera tarjetas de Trello para la Fase 1"
"Identifica riesgos y bloqueos para este proyecto"
```

**Genera**:
✅ Plan de proyecto estructurado con fases
✅ Desglose arquitectónico de tareas
✅ Tarjetas de Trello organizadas
✅ Matriz de dependencias
✅ Reportes de estado y progreso
✅ Documentación de decisiones
✅ Evaluación de riesgos

---

### 1. **SwiftUI Architecture Reviewer**
**Para**: Revisar código y validar que sigue tus patrones arquitectónicos

**Úsalo cuando**:
- Necesites validar que tu código sigue Clean Architecture + MVVM
- Quieras verificar que el Router está en ViewModel (no en View)
- Necesites revisar separación de capas
- Quieras asegurar que los DTOs se mapean solo en Repository

**Ejemplo de uso**:
```
"Revisor, ¿está este código siguiendo los patrones de MyDreamTeam?"
"Necesito validar que la arquitectura es correcta en ProductViewModel.swift"
```

**Valida**:
✅ Router en ViewModel, NO en View
✅ Separación de capas (Presentation, Domain, Data)
✅ Diseño basado en protocolos
✅ Mapeo de DTOs solo en Repository
✅ Manejo de errores (TripleA → AppError)
✅ Navegación con custom Navigator

---

### 2. **iOS Test Generator**
**Para**: Generar tests unitarios para ViewModels, UseCases, Repositories

**Úsalo cuando**:
- Necesites tests para un ViewModel
- Quieras generar tests para tu UseCase o Repository
- Necesites mocks para tus dependencias
- Quieras ejemplos de testing patterns

**Ejemplo de uso**:
```
"Generador, crea tests para ProductViewModel"
"Necesito tests para ProductRepository con mocks"
```

**Genera**:
✅ ViewModel tests (con mocks de Router y UseCase)
✅ UseCase tests (validando lógica de negocio)
✅ Repository tests (mapeo de DTOs y transformación de errores)
✅ DataSource tests (llamadas API)
✅ Mocks reutilizables

---

### 3. **SwiftUI Component Builder**
**Para**: Crear nuevas features/pantallas completas siguiendo toda la arquitectura

**Úsalo cuando**:
- Necesites crear una nueva pantalla o feature
- Quieras generar todo: View, ViewModel, Router, UseCase, Repository, DTO
- Quieras estructura lista para copiar y pegar

**Ejemplo de uso**:
```
"Constructor, crea una nueva feature de Perfil de Usuario"
"Necesito una pantalla de búsqueda con Vista, ViewModel, Router, UseCase y Repository"
```

**Genera**:
✅ View (solo UI, state-driven)
✅ ViewModel (@Published properties, business logic)
✅ Router (extensión de Router, métodos de navegación)
✅ UseCase + Protocol
✅ Repository + Protocol + DTO + Mapper
✅ DataSource
✅ DI Container
✅ Builder (factory pattern)

---

### 4. **Firebase Integration Specialist**
**Para**: Integrar Firebase (Auth, Firestore, Cloud Functions, Analytics) manteniendo la arquitectura

**Úsalo cuando**:
- Necesites autenticación con Firebase
- Quieras integrar Firestore para datos en tiempo real
- Necesites Cloud Functions
- Quieras analytics o crash reporting

**Ejemplo de uso**:
```
"Especialista, integra autenticación Firebase con email/contraseña"
"Necesito observar cambios en Firestore de órdenes en tiempo real"
```

**Implementa**:
✅ Firebase Auth (sign up, sign in, Apple Sign-In)
✅ Firestore (lectura/escritura, observación de cambios)
✅ Cloud Functions (procesar pagos, generar reportes)
✅ Analytics (eventos personalizados)
✅ Crashlytics (reporte de errores)

---

### 5. **PR Review and Code Correction**
**Para**: Revisar Pull Requests y sugerir correcciones

**Úsalo cuando**:
- Necesites revisar un PR
- Quieras validación arquitectónica antes de mergear
- Necesites sugerencias de mejora específicas
- Quieras asegurar que no hay problemas de seguridad

**Ejemplo de uso**:
```
"Revisor, analiza este PR para ver si está listo para mergear"
"Necesito una revisión completa del código en ProductViewController.swift"
```

**Revisa**:
✅ Cumplimiento arquitectónico
✅ Calidad de código (naming, memoria, performance)
✅ Manejo de errores
✅ Seguridad (hardcoded secrets, validación, etc.)
✅ Calidad de commits y PR
✅ Proporciona correcciones específicas con código

---

## 🎯 Flujos de Trabajo Comunes

### Workflow: Planificar un Proyecto Completo (NUEVO)
```
1. "Project Manager, crea un plan detallado para MyDreamTeam"
2. Recibe plan estructurado con fases y dependencias
3. "Project Manager, genera tarjetas de Trello para la Fase 1"
4. Importa tarjetas a tu tablero Trello
5. "Project Manager, identifica riesgos y dependencias críticas"
6. Comienza a ejecutar fases con seguimiento continuo
```

### Workflow: Crear nueva feature
```
1. "Project Manager, desglose la feature de Carrito en tareas"
2. Recibe tareas organizadas por capa arquitectónica
3. "Constructor, crea una feature de Carrito de Compras con..."
4. Copia el código generado
5. "Revisor, valida que esto sigue la arquitectura"
6. Realiza ajustes sugeridos
7. "Generador, crea tests para CartViewModel"
```

### Workflow: Revisar PR
```
1. "Revisor, analiza este PR de la feature X"
2. Recibe feedback detallado con issues y correcciones
3. "Generador, crea tests para los componentes nuevos"
4. Sube cambios y solicita re-review
5. "Revisor, ¿está listo para mergear ahora?"
```

### Workflow: Integrar Firebase con Plan Completo
```
1. "Project Manager, crea plan para integración Firebase"
2. Recibe fases: Database → API Docs → Domain → Data → Presentation → UI
3. "Firebase Specialist, diseña esquema de Firestore"
4. "Project Manager, genera tarjetas de Trello para la Fase de Data"
5. "Firebase Specialist, integra autenticación Firebase"
6. "Constructor, crea UI para login con ese UseCase"
7. "Revisor, valida que la integración es segura"
```

### Workflow: Entender un patrón
```
1. "Constructor, muéstrame un ejemplo completo de una feature con ServiceType awareness"
2. Aprende del código generado
3. "Revisor, ¿esto que escribí sigue ese patrón?"
```

---

## 💡 Tips para Usar los Agentes Eficientemente

1. **Sé específico**: "Crea tests para ProductViewModel" es mejor que "Crea tests"

2. **Proporciona contexto**: Si das el código o el archivo, el agente hace mejor trabajo

3. **Encadena agentes**: Primero Constructor crea el código, luego Revisor lo valida, luego Generador crea tests

4. **Reutiliza el trabajo**: Los ejemplos generados sirven como plantillas para otros features

5. **Pregunta sobre patrones**: "¿Por qué está el Router en ViewModel y no en View?" - El Revisor lo explica

6. **Valida antes de mergear**: Siempre usa Revisor antes de mergear PRs a main

7. **Aprende de las correcciones**: Los agentes no solo arreglan código, también enseñan

---

## 📁 Ubicación de los Agentes

Todos los agentes están en:
```
.claude/agents/
├── project-manager.md                       ⭐ NUEVO
├── swift-architecture-reviewer.md
├── ios-test-generator.md
├── swiftui-component-builder.md
├── firebase-integration-specialist.md
└── pr-review-and-code-correction.md
```

Están versionados en git, así que tu equipo puede usarlos también.

---

## 🔧 Personalización

Puedes editar los archivos `.md` en `.claude/agents/` para:
- Ajustar instrucciones según evoluciona tu proyecto
- Agregar nuevos patrones que descubras
- Refinar ejemplos de código
- Agregar nuevas restricciones o reglas

Después de cambios, los agentes automáticamente usarán la versión actualizada.

---

## ⚡ Accesos Rápidos

**Para planificar un proyecto:**
```
/agents → Select "Project Manager"
```

**Para crear una pantalla completa:**
```
/agents → Select "SwiftUI Component Builder"
```

**Para revisar código:**
```
/agents → Select "PR Review and Code Correction"
```

**Para validar arquitectura:**
```
/agents → Select "SwiftUI Architecture Reviewer"
```

**Para generar tests:**
```
/agents → Select "iOS Test Generator"
```

**Para integrar Firebase:**
```
/agents → Select "Firebase Integration Specialist"
```

---

## 🎓 Documentación Relacionada

- **Arquitectura**: Ver `CLAUDE.md` para patrones y guías
- **Patrones de Testing**: Ver agente "iOS Test Generator"
- **Integración Firebase**: Ver agente "Firebase Integration Specialist"
- **Reviisión de PR**: Ver agente "PR Review and Code Correction"

¡Ahora tienes un equipo de agentes especializados listos para ayudarte! 🚀
