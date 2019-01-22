# read rest of Hess. Gemeindestatistik
library(raster)
library(rgeos)
library(rgdal)

main <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/"
datapath <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/"
newproj <- "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"


# LANDWIRTSCHAFTLICH GENUTZTE FLÄCHE
gem_he <- readOGR(paste0(datapath, "Gemeinden_Hessen_clean.shp"))
lws <- read.csv(list.files(paste0(main, "HessischeGemeindestatistik/"), pattern="LWS.csv", full.names = T),
                sep=";", stringsAsFactors = F)
names(lws)[1] <- "AGS"
lws$AGS <- as.factor(paste0("06",lws$AGS)) # add 06 for Hessen to code
# which position do codes have in two datasets?
match(gem_he$AGS_G, lws$AGS) # works!!
matched <- merge(gem_he@data, lws, by.x="AGS_G", by.y="AGS")
gem_he@data <- matched
writeOGR(gem_he, dsn=paste0(datapath, "GemHe_LWS.shp"), driver="ESRI Shapefile",
         layer="GemHe_LWS", overwrite=T)

# FLÄCHENNUTZUNG
gem_he <- readOGR(paste0(datapath, "Gemeinden_Hessen_clean.shp"))
fln <- read.csv(list.files(paste0(main, "HessischeGemeindestatistik/"), pattern="HG_17_Flaechennutzung.csv", full.names = T),
                sep=";", stringsAsFactors = F)
fln$AGS <- as.factor(paste0("06",fln$AGS)) # add 06 for Hessen to code
# which position do codes have in two datasets?
match(gem_he$AGS_G, fln$AGS) # works!!
matched <- merge(gem_he@data, fln, by.x="AGS_G", by.y="AGS")
gem_he@data <- matched
writeOGR(gem_he, dsn=paste0(datapath, "GemHe_Flaechennutzung.shp"), driver="ESRI Shapefile",
         layer="GemHe_Flaechennutzung", overwrite=T)

# TOURISMUS
gem_he <- readOGR(paste0(datapath, "Gemeinden_Hessen_clean.shp"))
trm <- read.csv(list.files(paste0(main, "HessischeGemeindestatistik/"), pattern="HG_17_Tourismus.csv", full.names = T),
                sep=";", stringsAsFactors = F)
trm$AGS <- as.factor(paste0("06",trm$AGS)) # add 06 for Hessen to code
# which position do codes have in two datasets?
match(gem_he$AGS_G, trm$AGS) # works!!
matched <- merge(gem_he@data, trm, by.x="AGS_G", by.y="AGS")
gem_he@data <- matched
writeOGR(gem_he, dsn=paste0(datapath, "GemHe_Tourismus.shp"), driver="ESRI Shapefile",
         layer="GemHe_Tourismus", overwrite=T)


# visualize with mapview
mapview(gem_he, zcol="mean_betten_angebot", burst=F, label=ee$GEN_G, na.color="#e5e4e2",
               legend=T, layer.name="Bettenangebot")
gem_he$GEN_K
