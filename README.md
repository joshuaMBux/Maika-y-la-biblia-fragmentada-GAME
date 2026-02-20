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

## 🛠️ Tecnologías

- **Framework**: Flutter
- **Arquitectura**: BLoC Pattern
- **Plataformas soportadas**: Android, iOS, macOS, Linux, Windows, Web

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                      # Punto de entrada de la aplicación
└── presentation/
    └── games/
        └── rpg/
            ├── bloc/              # Lógica de estado del juego
            ├── data/              # Repositorio de datos bíblicos
            ├── models/            # Modelos de datos (items, versículos)
            ├── pages/             # Páginas del juego
            └── world/             # Componentes del mundo RPG
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
```

## 📋 Requisitos

- Flutter SDK 3.x o superior
- Dart SDK 3.x o superior

## 👤 Autores

Desarrollado por joshuaMBux

## 📄 Licencia

Este proyecto es un prototipo para futura integración en otra aplicación.
