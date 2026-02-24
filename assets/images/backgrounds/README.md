# Assets - Imágenes de Fondo

## 📁 Estructura

```
assets/
└── images/
    └── backgrounds/
        ├── home_background.jpg      - Imagen para pantalla de inicio
        ├── (futuro) login_background.jpg   - Imagen para login/registro
        └── (futuro) projects_background.jpg - Imagen para proyectos
```

## 🖼️ Cómo agregar la imagen de fondo para Home

### Opción 1: Copiar manualmente
1. Guarda tu imagen como `home_background.jpg`
2. Cópiala a: `assets/images/backgrounds/home_background.jpg`

### Opción 2: Usar PowerShell (Windows)
```powershell
# Desde la carpeta raíz del proyecto
Copy-Item "RUTA_A_TU_IMAGEN.jpg" -Destination "assets\images\backgrounds\home_background.jpg"
```

### Opción 3: Desde Downloads
```powershell
# Si la imagen está en tu carpeta de descargas
Copy-Item "~\Downloads\NOMBRE_DE_TU_IMAGEN.jpg" -Destination "assets\images\backgrounds\home_background.jpg"
```

## 📝 Especificaciones recomendadas

- **Formato**: JPG o PNG
- **Dimensiones**: Mínimo 1080x1920px (para pantallas verticales)
- **Peso**: Menor a 2MB para mejor rendimiento
- **Aspecto**: La imagen debe verse bien con un efecto de desvanecimiento (fade) en la parte inferior

## 🎨 Diseño

La imagen se mostrará con:
- Altura de 610px
- Efecto de desvanecimiento gradual hacia blanco en la parte inferior
- Centrada y cubriendo todo el ancho
- Fallback con gradiente verde claro si no se encuentra la imagen

## 🔄 Uso en otras pantallas

El widget `BackgroundImage` es reutilizable. Puedes usarlo en otras pantallas así:

```dart
BackgroundImage(
  imagePath: 'assets/images/backgrounds/TU_IMAGEN.jpg',
  height: 610, // opcional, por defecto 610
)
```

## ⚠️ Importante

- Asegúrate de que la imagen esté en formato JPG o PNG
- El nombre del archivo debe ser exactamente `home_background.jpg`
- Si cambias el nombre, actualiza la ruta en `pantalla_inicio.dart`
