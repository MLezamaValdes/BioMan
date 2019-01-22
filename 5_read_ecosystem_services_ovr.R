# read ecosystem services .ovr


library(raster)
main <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/ÖSL/ÖSL_Hessen/ÖSL_Hessen/"
gausskr <- "+proj=tmerc +lat_0=0 +lon_0=9 +k=1 +x_0=3500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs "
newproj <- "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"
ovrproj <- "+proj=tmerc +lat_0=0 +lon_0=6 +k=1 +x_0=2500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs"

r1 <- raster(paste0(main, "agrifertil_g.ovr"))

crs(r1) <- ovrproj
mapview::mapview(r1)
