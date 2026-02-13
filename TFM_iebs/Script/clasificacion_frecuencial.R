library(imager)
library(knitr)
library(NatureSounds)
library(seewave)
library(warbleR)
library(tuneR)
library(igraph)

warbleR_options(wav.path = "~/Documentos/.../tu_carpeta_wav/") # ajusta path


todas_las_muestras <- selection_table(whole.recs = TRUE, extended = TRUE)

sample_acoust_param <- na.omit(specan(todas_las_muestras, wl = 512, fsmooth = 0.1,
                                      threshold = 10, wn = "hanning",
                                      flim = c(0, 22), bp = c(0,20),
                                      fast.spec = FALSE, ovlp = 50,
                                      pal = reverse.gray.colors.2,
                                      widths = c(2, 1), main = NULL,
                                      plot = TRUE, all.detec = FALSE))


xcor <- xcorr(todas_las_muestras, bp = c(0, 20), wl = 512, ovlp = 99, path = NULL,
              type = "mfcc", method= 1, na.rm = TRUE)

distancia <- dist(xcor, method = "euclidean")

valores <- cmdscale(distancia, eig = T)

old.par <- par(mfrow=c(1, 2))
#plot(modelo, type = "p", xlab = "Coord 1", ylab = "Coord 2")
plot(xcor, type = "p", xlab = "Coord 1", ylab = "Coord 2")
text(xcor[,1],xcor[,2], labels = rownames(xcor), pos = 2, cex = 0.8 )
matplot(xcor, lty = 1)
par(old.par)

plot(sample_acoust_param$dfrange)
title(main = "frecuencia dominante", cex = 1.5,col = "red", font = 3)
old.par <- par(mfrow=c(2, 3))

old.par <- par(mfrow=c(2, 3))
plot(sample_acoust_param$meanfreq)
title(main = "Frecuencia media", cex = 1.5,col = "red", font = 3)
plot(sample_acoust_param$sd)
title(main = "desviación estandar", cex = 1.5,col = "red", font = 3)
plot(sample_acoust_param$skew)
title(main = "asimetria", cex = 1.5,col = "red", font = 3)
plot(sample_acoust_param$kurt)
title(main = "Pico del espectro", cex = 1.5,col = "red", font = 3)
plot(sample_acoust_param$sp.ent)
title(main = "entropía espectral", cex = 1.5,col = "red", font = 3)
plot(sample_acoust_param$dfrange)
title(main = "frecuencia dominante", cex = 1.5,col = "red", font = 3)
par(old.par)

graf <- graph.tree(ncol(xcor),mode = c("in"))
V(graf)$label <- colnames(xcor)
layout <- layout.mds(graf, dist = as.matrix(distancia))
plot(graf, vertex.size = .1)

library(ggplot2)
library(ggfortify)
alles_dir <- "/media/ion/WD-500/back-up/05_Vídeos/Vídeos/04_Portfolio/01_Gameprefabs/8 bit construction kit/FX/alles"
wav_names <- list.files(alles_dir, pattern = "\\.wav$")
sound_design <- selection_table(whole.recs = TRUE, path = alles_dir, extended = TRUE)

xcor <- xcorr(sound_design, bp = c(0, 20), wl = 512, ovlp = 99, path = alles_dir,
              type = "mfcc", method= 1, na.rm = TRUE,
              parallel = 4)

distancia <- dist(xcor, method = "euclidean")
valores <- cmdscale(distancia, eig = T)
autoplot(cmdscale(distancia, eig = T), label = TRUE, label.size = 3, frame = TRUE)

