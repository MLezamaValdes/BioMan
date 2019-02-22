# read ecosystem services .ovr


library(raster)
main <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/ÖSL/ÖSL_Hessen/ÖSL_Hessen/"
gausskr <- "+proj=tmerc +lat_0=0 +lon_0=9 +k=1 +x_0=3500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs "
newproj <- "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"
ovrproj <- "+proj=tmerc +lat_0=0 +lon_0=6 +k=1 +x_0=2500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs"

#EPSG codes: 31466, 31467, 31468, 31469 
nextproj <- "+proj=tmerc +lat_0=0 +lon_0=6 +k=1 +x_0=2500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs"
nextproj1 <- "+proj=tmerc +lat_0=0 +lon_0=9 +k=1 +x_0=3500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs "
nextproj2 <- "+proj=tmerc +lat_0=0 +lon_0=12 +k=1 +x_0=4500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs "
#nextproj3 <- "+proj=tmerc +lat_0=0 +lon_0=15 +k=1 +x_0=5500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs "

stefproj <- "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"

r1 <- raster(paste0(main, "agrifertil_g.ovr"))

crs(r1) <- nextproj3
mapview::mapview(r1)
