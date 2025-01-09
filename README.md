# Proyecto Visual-PDE

Este proyecto consta de dos partes principales: el **front-end** y el **back-end**.

---

## Front-end

La carpeta `visual-pde-main` hace referencia al front-end del proyecto. Para levantar el front-end, sigue estos pasos:

---

**1. Compila el contenedor de Docker:**
```bash
docker-compose build
```

---

**2. Levanta el contenedor:**
```bash
docker-compose up
```

---

**Si ocurre algún error, asegúrate de hacer un pull de la imagen correcta de Ruby:**
```bash
docker pull ruby:3.1
```
Esto se debe a que la versión 3.1 de Ruby es necesaria para las librerías utilizadas.

---

## Back-end

La carpeta `funcional` hace referencia al back-end del proyecto. Esta parte no tiene una estructura de aplicación completa, sino que está diseñada como una **API**, y será levantada con un intérprete de Python en lugar de opciones como Flask.

---

### Instalación de Librerías

**Para levantar el back-end, necesitamos instalar las siguientes librerías:**

- `pyproj`
- `requests`
- `flask`
- `flask_cors`
- `shapely`

---

### Uso de Docker

**En esta parte del proyecto, utilizamos Docker para:**

1. Procesar imágenes con Acolite.  
2. Procesar el área de referencia de las imágenes con Matlab.  
3. Separar el contorno que necesitamos.  

---

## Funcionamiento de Cada Parte

### Front-end

**En el front-end, se ha modificado el layout de la página principal (`home`) para ocultar el resto de las ventanas al usuario.** Sin embargo, se mantienen todos los archivos originales del proyecto Visual-PDE.

---

### Back-end

**1. Modelo Informaciones:**  
Controla el número de descargas de una imagen y gestiona la lista de imágenes seleccionadas por el usuario.  

---

**2. Clase `ImagenesSentinel`:**  
Se encarga de buscar y descargar imágenes satelitales.  

- Respecto a una fecha dada, busca imágenes de manera descendente.  
- La primera imagen seleccionada se utilizará junto con el tiempo de simulación.  
- **(FALTA)** Seleccionar la imagen `c1` para calcular el coeficiente de difusión.  
- **(FALTA)** Cambios simples en desarrollo para descargar las imágenes satelitales `c1` y `c0`.

---

**3. Procesamiento con Acolite:**  
Aplicamos el algoritmo de Mishra para estimar la materia orgánica en el agua.  

---

**4. Clase `Simulacion` (nombre tentativo):**  
Organiza las imágenes en carpetas y por fechas.  

---

**5. Procesamiento con Matlab:**  
Utilizando un paquete para analizar imágenes, desplegamos un Docker con scripts que:  
- Separan la isobara de la imagen satelital.  
- Separan el fondo del área con agua.  
- Calculan el coeficiente de difusión usando `c0` y `c1`.  

---

**6. Integración (en desarrollo):**  
- **(FALTA)** Conectar la respuesta del back-end con el front-end tras estas iteraciones.  
- Establecer el modelo en Visual-PDE para trasladar el área y los valores de cada píxel.  

---

## Repositorio Original

**El front-end mantiene todos los archivos originarios del proyecto Visual-PDE.**
