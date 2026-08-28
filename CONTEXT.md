# CONTEXT.md

Documento de retorno rápido al proyecto. Destila el estado real del repositorio
a fecha 2026-08-28. No sustituye al README, lo resume para retomar trabajo.

## 1. Qué es

Proyecto de análisis de similitud acústica entre archivos de audio WAV (efectos
de sonido 8-bit de videojuego) mediante reducción de dimensionalidad. Extrae
parámetros acústicos y coeficientes MFCC de cada muestra, calcula distancias
entre pares y las proyecta en 2D con Multidimensional Scaling (MDS) para
visualizar qué sonidos se parecen y detectar redundancias en una colección
grande. Origen: Trabajo Fin de Máster (IEBS, Business Intelligence & Data
Science, octubre 2020) de Alberto Jiménez Rodríguez, reescrito y modernizado.

## 2. Stack

- **Lenguaje:** R 4.0+ (proyecto RStudio, `Clasificacion Frecuencial MDS.Rproj`).
- **Paquetes:** `tuneR`, `seewave` (lectura WAV y análisis espectral);
  `warbleR`, `NatureSounds` (extracción de parámetros acústicos y
  cross-correlation MFCC); `igraph` (grafo de similitud y layout);
  `cluster` (matriz de distancias); `ggplot2`, `ggfortify` (boxplots y scatter).
- **Sin gestor de dependencias declarado** (no hay `DESCRIPTION`, `renv.lock`
  ni `requirements`). Instalación manual vía `install.packages()` según README.
- **Despliegue:** no aplica. Es un script de análisis que se ejecuta localmente
  en R/RStudio (`source("Frecuencial_classification.R")`). No hay CI, servidor
  ni empaquetado.

## 3. Arquitectura

Un único script secuencial en la raíz, `Frecuencial_classification.R`, con
7 secciones numeradas que forman un pipeline lineal:

1. **Carga** — `selection_table(whole.recs = TRUE)` lee todos los WAV de
   `TFM_iebs/Data/8bits/` (ruta relativa vía `file.path(getwd(), ...)`).
2. **Parámetros acústicos** — `spectro_analysis()` produce frecuencia media,
   sd, asimetría, curtosis, entropía espectral, rango de frecuencia dominante,
   etc. La categoría se deriva por regex del nombre de archivo
   (`"Gunner (3).wav"` -> `"Gunner"`).
3. **Boxplots por categoría** — 6 paneles `boxplot(param ~ category)` mostrando
   la distribución de cada parámetro por tipo de sonido.
4. **Cross-correlation MFCC** — `cross_correlation(type = "mfcc", parallel = 4)`
   genera la matriz de correlación entre pares de muestras.
5. **Distancias + MDS** — `dist(method = "euclidean")` sobre la matriz y
   `cmdscale(eig = TRUE)` para la solución 2D.
6. **Grafo de similitud** — se normaliza la distancia, se convierte en
   similitud `1 - d`, se aplica umbral > 0.75, y se construye un grafo no
   dirigido con `graph_from_adjacency_matrix()`; layout por `layout.mds()`.
7. **Scatter MDS** — `autoplot()` de ggfortify sobre la solución de `cmdscale`.

**Salidas** (PNG versionados en la raíz): `category_Boxplots.png`,
`similitud_muestras.png`, `Scatter MDS.png`. Documento original de la tesis:
`Clasificación_frecuencial.pdf`.

**`TFM_iebs/`** contiene el proyecto original de 2020 (scripts `.R` y `.Rmd`,
HTML/TeX generados, diagramas, `resultado.RData`) y los datos en
`TFM_iebs/Data/8bits/` + `8bits.zip`. Es material histórico/de referencia; el
punto de entrada actual es el script de la raíz.

## 4. Decisiones clave

- **MDS + MFCC como método** — reducción de dimensionalidad y correlación
  cepstral son agnósticas al dominio; se aplican a audio pero el README
  argumenta explícitamente que sirven igual para datos de negocio (ejemplo:
  clustering de posts de redes sociales por rendimiento). Se eligió el dominio
  de diseño de sonido por experiencia previa del autor, no el de negocio del
  máster.
- **Actualización de API de `warbleR`** — el paquete renombró funciones entre
  2020 y la versión actual: `specan()` -> `spectro_analysis()`,
  `xcorr()` -> `cross_correlation()`, `read_wave()` -> `read_sound_file()`.
- **Boxplots por categoría en vez de scatter por índice** — el script original
  graficaba parámetros contra el índice de fila (posición arbitraria en la
  tabla), sin valor informativo. Descartado a favor de boxplots agrupados.
- **Grafo con conexiones reales en vez de `graph.tree()`** — el original usaba
  un árbol arbitrario cuyas aristas no representaban relación real. Ahora las
  aristas son correlación MFCC > 0.75 (similitud acústica efectiva).
- **Portabilidad y limpieza** — se eliminaron rutas hardcodeadas (ahora
  `file.path(getwd(), ...)`), llamadas a `install.packages()` dentro del
  script, librerías sin uso (`imager`, `knitr`), y código duplicado/comentado.
  Se añadió `parallel = 4` en la cross-correlation.
- **WAV fuera del repositorio** — `.gitignore` excluye `*.wav` y `*.zip` por
  tamaño; aun así `TFM_iebs/Data/8bits/*.wav` y `8bits.zip` aparecen en el
  árbol de trabajo (PENDIENTE DE CONFIRMAR si están realmente trackeados o solo
  presentes localmente).

## 5. Estado actual

- **Funciona:** el pipeline completo del script de la raíz produce las 3
  visualizaciones, ya versionadas como PNG. README en inglés, con badges,
  diagrama Mermaid del pipeline, tabla de stack y sección de cambios respecto
  al original.
- **Rama:** `main`, actualizada con `origin/main`. No hay ramas activas
  adicionales conocidas.
- **Cambios sin commitear:** solo `Clasificacion Frecuencial MDS.Rproj`
  (modificado): `RnwWeave: Sweave` -> `RnwWeave: knitr`. Cambio trivial de
  config de RStudio; decidir si se commitea o se descarta.
- **Historial reciente (`git log --oneline -15`, 8 commits en total):**
  - `1743b2b` Sustituye pipeline ASCII por diagrama Mermaid
  - `9647421` Add repository link to README author section
  - `94206b2` Improve README with badges, context descriptions and tech stack table
  - `8eb9eab` Add Applications Beyond Audio section to Project Description
  - `68b36b3` Translate README to English, move background section to top
  - `9f33901` Add academic context and master's thesis background to README
  - `b5bb09d` Add result images and explanations to README
  - `e7b57c6` Initial commit: frequency classification of audio samples via MDS
  - El trabajo reciente ha sido **exclusivamente de documentación (README)**;
    el script no se ha tocado desde el commit inicial.
- **Falta / sin verificar:**
  - No hay `DECISIONS.md`, `TODO.md`, ni carpeta `JOURNAL/`. Este CONTEXT.md
    es la primera documentación de estado.
  - README menciona "55 WAV files" pero también "Dataset: 55"; el recuento real
    de `TFM_iebs/Data/8bits/` es PENDIENTE DE CONFIRMAR (el listado parcial
    incluye categorías no citadas en el README como `Game_over`,
    `Ship_inspecting`, `Single gunner`).
  - No hay tests ni validación automatizada.
  - `.RData` (9.5 MB) y `.Rhistory` presentes en el directorio de trabajo pero
    ignorados por git.

## 6. Próximos pasos

Priorizados (no hay backlog formal; derivados del estado del repo):

1. **Resolver el cambio pendiente del `.Rproj`** — commitear el cambio a
   `knitr` o revertirlo para dejar el árbol limpio.
2. **Confirmar el dataset** — verificar número real de WAV y lista de
   categorías, y alinear el README (55 vs. recuento real; categorías
   `Game_over`, `Ship_inspecting`, `Single gunner`).
3. **Reproducibilidad de dependencias** — añadir `renv` o al menos un bloque
   de versiones de paquetes, dado que `warbleR` ya rompió la API una vez.
4. **Verificar ejecución end-to-end** con la versión actual de `warbleR` y R,
   y regenerar los PNG si cambian.
5. **Traducir/actualizar** el material de `TFM_iebs/Script/` o decidir
   archivarlo formalmente (marcar como legacy en el README).
6. **Parametrizar el script** — umbral de similitud (0.75), `parallel`, y ruta
   de datos como variables al inicio o argumentos, para reutilizarlo con otras
   colecciones.
