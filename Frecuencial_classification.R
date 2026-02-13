# =============================================================================
# Clasificación frecuencial de muestras de audio mediante MDS
# =============================================================================
#
# Analiza la similitud acústica entre archivos WAV usando:
#   1. Extracción de parámetros acústicos (spectro_analysis)
#   2. Cross-correlation MFCC entre pares de muestras
#   3. Distancia euclidiana + Multidimensional Scaling (MDS)
#   4. Visualización: boxplots por categoría, grafo de similitud y scatter MDS
#
# Requisitos:
#   install.packages(c("tuneR", "seewave", "warbleR", "NatureSounds",
#                       "igraph", "cluster", "ggplot2", "ggfortify"))
# =============================================================================

library(tuneR)
library(seewave)
library(warbleR)
library(NatureSounds)
library(igraph)
library(cluster)
library(ggplot2)
library(ggfortify)

# -- Configuración -------------------------------------------------------------
wav_path <- file.path(getwd(), "TFM_iebs", "Data", "8bits")
warbleR_options(wav.path = wav_path)

# -- 1. Cargar muestras --------------------------------------------------------
todas_las_muestras <- selection_table(whole.recs = TRUE)

# -- 2. Parámetros acústicos ---------------------------------------------------
sample_acoust_param <- na.omit(spectro_analysis(
  todas_las_muestras,
  wl = 512, fsmooth = 0.1, threshold = 10, wn = "hanning",
  flim = c(0, 22), bp = c(0, 20),
  fast.spec = FALSE, ovlp = 50,
  pal = reverse.gray.colors.2,
  widths = c(2, 1), main = NULL,
  plot = TRUE, all.detec = FALSE
))

# Extraer categoría del nombre del archivo (ej: "Gunner (3).wav" -> "Gunner")
sample_acoust_param$category <- gsub("\\s*\\(.*", "",
                                     gsub("\\.wav$", "", sample_acoust_param$sound.files))

# -- 3. Boxplots por categoría -------------------------------------------------
old.par <- par(mfrow = c(2, 3), mar = c(8, 4, 2, 1))
boxplot(meanfreq ~ category, data = sample_acoust_param, las = 2,
        main = "Frecuencia media", cex.axis = 0.7)
boxplot(sd ~ category, data = sample_acoust_param, las = 2,
        main = "Desviación estándar", cex.axis = 0.7)
boxplot(skew ~ category, data = sample_acoust_param, las = 2,
        main = "Asimetría", cex.axis = 0.7)
boxplot(kurt ~ category, data = sample_acoust_param, las = 2,
        main = "Pico del espectro", cex.axis = 0.7)
boxplot(sp.ent ~ category, data = sample_acoust_param, las = 2,
        main = "Entropía espectral", cex.axis = 0.7)
boxplot(dfrange ~ category, data = sample_acoust_param, las = 2,
        main = "Frecuencia dominante", cex.axis = 0.7)
par(old.par)

# -- 4. Cross-correlation MFCC ------------------------------------------------
xcor <- cross_correlation(
  todas_las_muestras,
  bp = c(0, 20), wl = 512, ovlp = 99,
  type = "mfcc", method = 1, na.rm = TRUE,
  parallel = 4
)

# -- 5. Distancias y MDS ------------------------------------------------------
dist_matrix <- as.matrix(dist(xcor, method = "euclidean"))
distancia <- as.dist(dist_matrix)
valores <- cmdscale(distancia, eig = TRUE)

# -- 6. Grafo de similitud (umbral correlación > 0.75) -------------------------
dist_norm <- dist_matrix / max(dist_matrix)
sim_matrix <- 1 - dist_norm
diag(sim_matrix) <- 0
sim_matrix[sim_matrix < 0.75] <- 0

graf <- graph_from_adjacency_matrix(sim_matrix, mode = "undirected", weighted = TRUE)

labels_clean <- gsub("\\.wav.*", "", V(graf)$name)
categories <- gsub("\\s*\\(.*", "", labels_clean)
cat_colors <- as.numeric(as.factor(categories))
palette <- rainbow(length(unique(categories)))
layout_mds <- layout.mds(graf, dist = dist_matrix)

graphics.off()
par(mar = c(1, 1, 2, 8), xpd = TRUE)
plot(graf,
     layout = layout_mds,
     vertex.size = 6,
     vertex.color = palette[cat_colors],
     vertex.frame.color = "gray30",
     vertex.label = labels_clean,
     vertex.label.cex = 0.5,
     vertex.label.dist = 1.5,
     vertex.label.color = "gray20",
     edge.width = E(graf)$weight * 1.5,
     edge.color = rgb(0.5, 0.5, 0.5, 0.3),
     edge.curved = 0.2,
     main = "Similitud acústica entre muestras (MFCC)")

legend("right", inset = c(-0.15, 0),
       legend = sort(unique(categories)),
       col = palette[as.numeric(as.factor(sort(unique(categories))))],
       pch = 19, cex = 0.6, pt.cex = 1.2, bty = "n", title = "Categoría")

# -- 7. Scatter MDS (ggplot) ---------------------------------------------------
autoplot(valores, label = TRUE, label.size = 3, frame = TRUE) +
  ggtitle("MDS - Clasificación frecuencial de muestras")

