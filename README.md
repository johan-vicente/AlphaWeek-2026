# SirenaXperience — AlphaRamos 2026

Proyecto desarrollado por **ITLA (Instituto Tecnológico de las Américas)** para **AlphaWeek 2026**, el hackatón organizado por **Grupo Ramos**.

## 💡 Sobre el proyecto

SirenaMap es una extensión conceptual de la app de Sirena, enfocada en mejorar la experiencia de compra dentro de la tienda física. La idea nace del eje **"Experiencia de Usuario"**, buscando resolver un problema real: ayudar a los clientes a encontrar productos rápido, sin perder tiempo recorriendo pasillos a ciegas.

## 🧭 Funcionalidades del MVP

- **Navegación indoor en tienda** — el cliente marca su ubicación y destino tocando el mapa, y la app calcula la ruta óptima (algoritmo BFS) hasta el producto.
- **Escáner de código de barras** — cámara en vivo, entrada manual, y búsqueda por nombre para productos de peso variable.
- **Estado de cajas en tiempo real** — indica qué cajas están habilitadas en cada sucursal.
- **Ruta multi-destino** — si tienes varios productos en el carrito, la app calcula una ruta óptima que pase por todos.

## 🤖 Sira — Asistente de compras con IA

Un diferenciador adicional: **Sira**, un asistente conversacional integrado a la app, impulsado por la API de Claude (Anthropic).

- **Chat de texto, voz y foto** — el cliente puede escribir, dictar por voz, o tomarle foto a un producto físico para que Sira lo identifique.
- **Tool use real** — Sira nunca inventa productos: busca contra el catálogo real de Firebase antes de proponer cualquier cosa, verifica disponibilidad por sucursal, arma listas de compra aproximadas por presupuesto, y agrega directo al carrito con tu confirmación.
- **Modo oscuro** propio del chat, tarjetas de producto clickeables a su ficha, y botón directo a "Ver carrito".
- **Valoración del servicio** — al finalizar una conversación, el cliente puede calificarla (1-5 estrellas + comentario opcional), lo que le da a Grupo Ramos estadísticas reales de satisfacción sin depender de una consultora externa.
- **Seguridad por diseño** — Sira solo puede ejecutar un set cerrado de acciones predefinidas (nunca acceso libre al sistema), límite de mensajes por sesión, y control de gasto a nivel de proveedor.

## 🏬 Sucursales soportadas (demo)

- Sirena Villa Mella
- Sirena Las Américas
- Sirena Autopista San Isidro

## 🛠️ Stack técnico

- **Flutter / Dart** (Android nativo en Java)
- **Firebase Realtime Database** — backend de productos, grafo de navegación, estado de cajas y valoraciones del chat
- **Hive** — caché local para modo offline y contexto persistente de Sira
- **mobile_scanner** — escaneo de códigos de barra
- **Claude API (Anthropic)** — motor conversacional y tool use de Sira

## 👥 Equipo

Representando a ITLA en AlphaWeek 2026:

- **Johan Manuel Vicente Berroa** — Desarrollo (Flutter)
- **Merly** — Desarrollo (Flutter)
- Equipo de Multimedia — Diseño UI/UX y material de presentación

---

*Proyecto desarrollado como parte de la competencia AlphaRamos Week 2026 organizada por Grupo Ramos. Todo el contenido de marca (Sirena, SirenaMás) se usa con fines demostrativos y educativos dentro del contexto de la competencia.*
