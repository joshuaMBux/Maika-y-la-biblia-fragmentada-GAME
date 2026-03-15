# Maika y la Biblia Fragmentada

Un juego RPG educativo desarrollado en Flutter donde **Maika**, la protagonista, debe buscar y recolectar los libros perdidos de la Biblia distribuidos por todo el mundo del juego.

## Descripción del juego

En **Maika y la Biblia Fragmentada** el mundo ha sido fragmentado y los libros de la Biblia están dispersos por el mapa.  
La misión del jugador es ayudar a Maika a encontrar estos libros para reconstruir la Biblia completa mientras aprende versículos y contenido bíblico.

### Mecánicas principales

- **Exploración**: Maika recorre mapas 2D buscando libros bíblicos.
- **Recolección**: Cada libro encontrado se añade a la colección del jugador.
- **Aprendizaje**: Por cada libro se muestra contenido bíblico (versículos/fragmentos).
- **Progreso**: A medida que se encuentran más libros, se avanza en la reconstrucción de la Biblia.

### Estado del proyecto

Este proyecto se encuentra en fase de **prototipo avanzado** y se utiliza como base para integrarlo dentro de una aplicación más grande.

Ramas relevantes:

- `master`: rama principal del prototipo.
- `feature/integracion-juego-maika`: rama usada para probar la integración del juego con el proyecto **Maika_APP_estable**.

## Detalles técnicos

### Motor y tecnologías

- **Motor de juego**: Flame (Flutter Game Engine).
- **Framework**: Flutter.
- **Lenguaje**: Dart.
- **Gestión de estado**: BLoC / Cubit (`flutter_bloc`).
- **Plataformas objetivo**:
  - Android
  - iOS
  - Web
  - Windows
  - Linux
  - macOS

### Dependencias principales

- `flame` – motor de juegos 2D para Flutter.
- `flutter_bloc` – gestión de estado reactiva.
- `equatable` – comparación de objetos de forma sencilla.

## Arquitectura del proyecto

Estructura general del código fuente:

```text
lib/
  main.dart                          # Punto de entrada de la app
  presentation/
    games/
      rpg/
        bloc/                        # Lógica de estado del juego (BLoC)
          rpg_game_bloc.dart
          rpg_game_event.dart
          rpg_game_state.dart
        data/                        # Repositorios y datos bíblicos
          bible_repository.dart
        models/                      # Modelos de dominio
          game_item.dart
          verse_fragment.dart
        pages/                       # Pantallas del juego
          rpg_game_page.dart
        world/                       # Componentes del mundo del juego
          player_component.dart
          item_component.dart
          projectile_component.dart
          rpg_game_world.dart
          heart_hud_component.dart   # HUD de vidas/corazones
```

## Assets del proyecto

```text
assets/
  images/                      # Imágenes y sprites del juego
    maika.png                 # Sprite principal de Maika
    book.png                  # Icono de libro recolectable
    item_book_red.png         # Variantes de libros
    ball1.png                 # Proyectiles
    enemy.png                 # Sprites de enemigos
    shield_gold.png           # Icono de escudo
    tiles.png                 # Tiles del mundo
    libros.png                # Iconos de libros
    Overworld.png             # Sprites del mundo exterior
    cave.png                  # Sprites de cuevas
    Inner.png                 # Sprites de interiores
    objects.png               # Objetos del juego
    font.png                  # Fuente pixel-art del juego
    log.png                   # Elementos del escenario
    NPC_test.png              # Sprites de NPC
  tiles/
    world_map.tmx             # Mapa del mundo (formato Tiled)
  audio/
    DarkWinds.ogg             # Música de fondo principal
```

## Cómo ejecutar

Comandos básicos para desarrollo:

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en modo debug en un dispositivo/emulador
flutter run
```

Construcciones típicas:

```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web

# Linux
flutter build linux

# Windows
flutter build windows
```

## Requisitos

- **Flutter SDK**: 3.x o superior.
- **Dart SDK**: 3.x o superior.
- **Android**: API 21 o superior para builds móviles.

## Estilo de código

El proyecto sigue buenas prácticas de Flutter:

- Separación de responsabilidades entre UI, lógica y datos.
- Uso de BLoC/Cubit para el estado del juego.
- Código orientado a ser reutilizable y fácil de probar.

## Autor

Proyecto desarrollado por **joshuaMBux**.

## Notas

Este repositorio se utiliza como base para integrar el juego dentro de la aplicación principal de Maika.  
La rama `feature/integracion-juego-maika` puede incluir cambios experimentales pensados específicamente para esa integración.

