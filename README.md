# SirenaMap — AlphaRamos 2026

Proyecto desarrollado por **ITLA (Instituto Tecnológico de las Américas)** para **AlphaWeek 2026**, el hackatón organizado por **Grupo Ramos**.

## 💡 Sobre el proyecto

SirenaMap es una extensión conceptual de la app de Sirena, enfocada en mejorar la experiencia de compra dentro de la tienda física. La idea nace del eje **"Experiencia de Usuario"**, buscando resolver un problema real: ayudar a los clientes a encontrar productos rápido, sin perder tiempo recorriendo pasillos a ciegas.

## 🧭 Funcionalidades del MVP

- **Navegación indoor en tienda** — el cliente marca su ubicación y destino tocando el mapa, y la app calcula la ruta óptima (algoritmo BFS) hasta el producto.
- **Escáner de código de barras** — cámara en vivo, entrada manual, y búsqueda por nombre para productos de peso variable.
- **Estado de cajas en tiempo real** — indica qué cajas están habilitadas en cada sucursal.
- **Ruta multi-destino** — si tienes varios productos en el carrito, la app calcula una ruta óptima que pase por todos.

## 🏬 Sucursales soportadas (demo)

- Sirena Villa Mella
- Sirena Las Américas
- Sirena Autopista San Isidro

## 🛠️ Stack técnico

- **Flutter / Dart** (Android nativo en Java)
- **Firebase Realtime Database** — backend de productos, grafo de navegación y estado de cajas
- **Hive** — caché local para modo offline
- **mobile_scanner** — escaneo de códigos de barra

## 👥 Equipo

Representando a ITLA en AlphaWeek 2026:

- **Johan Manuel Vicente Berroa** — Desarrollo (Flutter)
- **Merly** — Desarrollo (Flutter)
- Equipo de Multimedia — Diseño UI/UX y material de presentación

## 📦 Cómo correrlo

1. Clona el repo
2. `flutter pub get`
3. Configura tu propio proyecto de Firebase (Realtime Database) y agrega tu `google-services.json` en `android/app/`
4. `flutter run`

---

*Proyecto desarrollado como parte de la competencia AlphaRamos Week 2026 organizada por Grupo Ramos. Todo el contenido de marca (Sirena, SirenaMás) se usa con fines demostrativos y educativos dentro del contexto de la competencia.*
