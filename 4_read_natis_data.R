
library(raster)
library(rgeos)
library(rgdal)

main <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/"
datapath <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/"
newproj <- "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"

gem_he <- readOGR(paste0(datapath, "GemMiHe_EEnergieproduktion.shp"))

# read NATIS animal dataset
natisffh <- read.csv(paste0(main, "DATA_FFHandNATIS_animals.csv"), 
                     sep=";", stringsAsFactors = F)
# replace , with . in order to convert to numeric
natisffh$X <- as.numeric(gsub(",", ".", natisffh$X))
natisffh$Y <- as.numeric(gsub(",", ".", natisffh$Y)) 

gausskr <- "+proj=tmerc +lat_0=0 +lon_0=9 +k=1 +x_0=3500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs "
natisffhsh <- SpatialPointsDataFrame(natisffh[,17:18],
                               natisffh,    #the R object to convert
                               proj4string = crs(gausskr))   # assign a CRS 
mapview::mapview(natisffhsh)
natisffhshutm <- spTransform(natisffhsh, crs(newproj))
writeOGR(natisffhshutm, paste0(datapath, "natisffh_animals.shp"), driver="ESRI Shapefile", 
         layer="animals")



# read NATIS plant fish mollusca dataset
natispfm <- read.csv(paste0(main, "DATA_FFH_plantfishmollusca.csv"), 
                     sep=";", stringsAsFactors = F)
# replace , with . in order to convert to numeric
natispfm$X <- as.numeric(gsub(",", ".", natispfm$X))
natispfm$Y <- as.numeric(gsub(",", ".", natispfm$Y)) 

gausskr <- "+proj=tmerc +lat_0=0 +lon_0=9 +k=1 +x_0=3500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs "
natispfmsh <- SpatialPointsDataFrame(natispfm[,4:5],
                                     natispfm,    #the R object to convert
                                     proj4string = crs(gausskr))   # assign a CRS 
mapview::mapview(natispfmsh)
natispfmshutm <- spTransform(natispfmsh, crs(newproj))
writeOGR(natispfmshutm, paste0(datapath, "natis_plantfishmolusca.shp"), driver="ESRI Shapefile", 
         layer="plantfishmolusca")
plot(natispfmshutm, add=T)
