# Maika y la Biblia Fragmentada

Un juego RPG desarrollado en Flutter donde Maika, la protagonista, debe buscar y recolectar los libros perdidos de la Biblia distribuidos por todo el mundo del juego.

## 🎮 Descripción del Juego

**Maika y la Biblia Fragmentada** es un juego educativo que combina la aventura RPG con el aprendizaje bíblico.

### Historia
El mundo ha sido fragmentado y los libros de la Biblia están dispersos por todo el mapa. Maika, la protagonista, tiene la misión de encontrar estos libros perdidos para reconstruir la Biblia completa.

### Mecánica de Juego
- **Exploración**: Maika explora un mundo abierto buscando libros bíblicos perdidos
- **Recolección**: Cada libro encontrado se añade a la colección del jugador
- **Aprendizaje**: Por cada libro encontrado, Maika revela un versículo bíblico, permitiendo al usuario aprender y jugar al mismo tiempo
- **Progreso**: A medida que se encuentran más libros, se va reconstruyendo la Biblia completa

### Estado del Proyecto
Este es un **prototipo** desarrollado en Flutter. El objetivo es eventualmente integrar este juego en otra aplicación más grande.

## ⚙️ Detalles Técnicos

### Motor y Tecnologías
- **Motor de Juegos**: Flame Game Engine (Flame - Flutter Game Engine)
- **Framework**: Flutter
- **Lenguaje**: Dart
- **Arquitectura de Estado**: BLoC Pattern (flutter_bloc)
- **Gestión de Estados**: Cubit/Bloc para gestión del estado del juego

### Librerías y Dependencias
- `flame` - Motor de juegos 2D para Flutter
- `flutter_bloc` - Gestión de estado reactiva
- `equatable` - Comparación de objetos en Dart

### Plataformas Soportadas
- Android (API 21+)
- iOS
- macOS
- Linux
- Windows
- Web (HTML5)

## 🏗️ Arquitectura del Proyecto

```
lib/
├── main.dart                      # Punto de entrada de la aplicación
└── presentation/
    └── games/
        └── rpg/
            ├── bloc/              # Lógica de estado del juego (BLoC)
            │   ├── rpg_game_bloc.dart    # Gestor principal del estado
            │   ├── rpg_game_event.dart   # Eventos del juego
            │   └── rpg_game_state.dart   # Estados del juego
            ├── data/              # Repositorio de datos bíblicos
            │   └── bible_repository.dart # Acceso a datos de versículos
            ├── models/            # Modelos de datos
            │   ├── game_item.dart        # Modelo de items/libros
            │   └── verse_fragment.dart   # Modelo de fragmentos de versículos
            ├── pages/             # Páginas/Pantallas del juego
            │   └── rpg_game_page.dart    # Pantalla principal del juego
            └── world/             # Componentes del mundo del juego
                ├── item_component.dart   # Componente de items
                ├── player_component.dart # Componente del jugador (Maika)
                └── rpg_game_world.dart    # Mundo/Map del juego
```

## 🎯 Características Técnicas Implementadas

- **Sistema de Personajes**: Componente de jugador con movimientos y acciones
- **Sistema de Items**: Recolección de objetos (libros bíblicos)
- **Sistema de Mapas**: Mapas tileados (Tiled TMX)
- **Sistema de Sprites**: Gráficos 2D para personajes y entorno
- **Motor de Audio**: Soporte para música de fondo (OGG)
- **Estado del Juego**: Persistencia de progreso del jugador

## 📂 Assets del Proyecto

```
assets/
├── images/                # Imágenes del juego
│   ├── character.png    # Sprites del personaje
│   ├── tiles.png        # Tiles del mundo
│   ├── libros.png       # Iconos de libros
│   ├── Overworld.png   # Sprites del mundo exterior
│   ├── cave.png         # Sprites de cuevas
│   ├── Inner.png        # Sprites de interiores
│   ├── objects.png      # Objetos del juego
│   ├── font.png         # Fuente del juego
│   └── NPC_test.png     # Sprites de NPC
└── tiles/
    └── world_map.tmx    # Mapa del mundo (formato Tiled)
```

## 🚀 Cómo Ejecutar

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en modo desarrollo
flutter run

# Construir para Android
flutter build apk

# Construir para iOS
flutter build ios

# Construir para Web
flutter build web

# Construir para Linux
flutter build linux
```

## 📋 Requisitos

- **Flutter SDK**: 3.x o superior
- **Dart SDK**: 3.x o superior
- **Versión mínima de Android**: API 21 (Android 5.0)

## 🎨 Estilo de Código

El proyecto sigue las mejores prácticas de Flutter:
- Clean Architecture
- Patrón BLoC para gestión de estado
- Separación de responsabilidades (UI / Lógica / Datos)
- Código limpio y documentado

## 👤 Autores

Desarrollado por joshuaMBux

## 📄 Licencia

Este proyecto es un prototipo para futura integración en otra aplicación.
