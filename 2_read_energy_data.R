# read energy data

library(raster)
library(rgeos)
library(rgdal)

main <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/"
datapath <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/"
newproj <- "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"
gem_he <- readOGR(paste0(datapath, "Gemeinden_Hessen.shp"))


########### ENERGIEPRODUKTION ###################################################

eep <- read.csv(paste0(main, "energiedaten/EE_2016.csv"), sep=";", stringsAsFactors = F,
                dec=",")

# NAMEN GEM_HE UND ENERGIEPRODUKTION BEREINIGEN
eep$Gemeinde.Stadt <- as.character(eep$Gemeinde.Stadt)
gem_he$GEN_G <- as.character(gem_he$GEN_G)

# change names in EE data
eep$Gemeinde.Stadt[eep$Gemeinde.Stadt=="Allendorf"] <- "Allendorf (Lumda)"
gem_he$GEN_G[gem_he$AGS_G=="06534001"] <- "Amoeneburg"
gem_he$GEN_G[gem_he$AGS_G=="06531005"] <- "Giessen"
gem_he$GEN_G[gem_he$AGS_G=="06531006"] <- "Gruenberg"
gem_he$GEN_G[gem_he$AGS_G=="06531009"] <- "Langgoens"
gem_he$GEN_G[gem_he$AGS_G=="06532001"] <- "Asslar"
gem_he$GEN_G[gem_he$AGS_G=="06532005"] <- "Dietzhoelztal"
gem_he$GEN_G[gem_he$AGS_G=="06532014"] <- "Huettenberg"
gem_he$GEN_G[gem_he$AGS_G=="06532018"] <- "Schoeffengrund"
gem_he$GEN_G[gem_he$AGS_G=="06533008"] <- "Huenfelden"
gem_he$GEN_G[gem_he$AGS_G=="06533010"] <- "Loehnberg"
gem_he$GEN_G[gem_he$AGS_G=="06533018"] <- "Weilmuenster"
gem_he$GEN_G[gem_he$AGS_G=="06534001"] <- "Amoeneburg"
gem_he$GEN_G[gem_he$AGS_G=="06534006"] <- "Coelbe"
gem_he$GEN_G[gem_he$AGS_G=="06534006"] <- "Coelbe"
gem_he$GEN_G[gem_he$AGS_G=="06534015"] <- "Muenchhausen"
gem_he$GEN_G[gem_he$AGS_G=="06534020"] <- "Weimar"
gem_he$GEN_G[gem_he$AGS_G=="06535005"] <- "Gemuenden"
gem_he$GEN_G[gem_he$AGS_G=="06535013"] <- "Muecke"
gem_he$GEN_G[gem_he$AGS_G=="06535013"] <- "Muecke"
gem_he$GEN_G[gem_he$AGS_G=="06533009"] <- "Limburg"
gem_he$GEN_G[gem_he$AGS_G=="06533016"] <- "Waldbrunn"
gem_he$GEN_G[gem_he$AGS_G=="06534016"] <- "Neustadt"
gem_he$GEN_G[gem_he$AGS_G=="06534021"] <- "Wetter"
gem_he$GEN_G[gem_he$AGS_G=="06535009"] <- "Homberg"
gem_he$GEN_G[gem_he$AGS_G=="06535011"] <- "Lauterbach (HE)"
eep$Gemeinde.Stadt[eep$Gemeinde.Stadt=="Lauterbach"] <- "Lauterbach (HE)"
gem_he$GEN_G[gem_he$AGS_G=="06535012"] <- "Lautertal"
gem_he$GEN_K <- as.character(gem_he$GEN_K)
gem_he$GEN_K[gem_he$RS_K=="06531"] <- "Giessen"


writeOGR(gem_he, dsn=paste0(datapath, "Gemeinden_Hessen_clean.shp"), driver="ESRI Shapefile",
         layer="Gemeinden_Hessen_clean", overwrite=T)

# make sums from double occurring names in eeg
doubles <- table(eep$Gemeinde.Stadt)>1
dub <- doubles[doubles==TRUE]
names(dub)

for(i in seq(dub)){
  x <- eep[eep$Gemeinde.Stadt==names(dub[i]),]
  y <- x[,4:(ncol(x))]
  z <- colSums(y, na.rm=TRUE)
  target <- x[1,]
  target[,4:ncol(target)] <- z
  eep <- eep[!eep$Gemeinde.Stadt==names(dub[i]),] # all rows except doubles
  eep[nrow(eep)+1,] <- target
  print(i)
}
eep$gem <- eep$Gemeinde.Stadt # dupliziere Gemeindename, damit er nicht beim mergen verloren geht


# subselect Mittelhessen from gem_he to check if all Mittelhessen Gemeinden are matched
kreise <- c("Marburg-Biedenkopf", "Giessen", "Vogelsbergkreis", "Lahn-Dill-Kreis",
  "Limburg-Weilburg", "Wetteraukreis")

mittelhessendat <- lapply(seq(kreise), function(i){
  gem_he@data[gem_he$GEN_K == kreise[i],]
})
mittelhessendat[[5]]$GEN_K

mh <- rbind(mittelhessendat[[1]], mittelhessendat[[2]], mittelhessendat[[3]],
      mittelhessendat[[4]], mittelhessendat[[5]], mittelhessendat[[6]])

# welche Namen sind noch nicht gematcht?
nonamemh <- which(is.na(match(mh$GEN_G, eep$Gemeinde.Stadt)))
nonameeep <- which(is.na(match(eep$Gemeinde.Stadt, mh$GEN_G)))

mh$GEN_G[nonamemh]
eep$Gemeinde.Stadt[nonameeep]



# merge when all names are cleared
meep <- merge(gem_he@data, eep, by.x="GEN_G", by.y="Gemeinde.Stadt", all.x=T)
meepord <- meep[order(meep$AGS_G),] # bring into correct order for shapefiles
sum(!is.na(match(gem_he$AGS_G, meepord$AGS_G))) # works!!
gem_he@data <- meepord

writeOGR(gem_he, dsn=paste0(datapath, "GemMiHe_EEnergieproduktion.shp"), driver="ESRI Shapefile",
         layer="GemMiHe_EEnergieproduktion", overwrite=T, layer_options = "RESIZE=YES")

# DISPLAY 
library(sf)
library(tmap)
library(viridis)
library(ggplot2)
library(broom)



# input energy 
ee <- st_read(paste0(datapath, "GemMiHe_EEnergieproduktion.shp"))

# with mapview
library(mapview)
eekwh <- as.data.frame(ee[,c(33, 36, 39, 42, 45, 48)])
eekwh$geometry <- NULL
rseekwh <- rowSums(eekwh, na.rm = T)
ee$eeind <- rseekwh

ee$eeind[ee$eeind==0] <- NA
emapind <-mapview(ee, zcol="eeind", burst=F, label=ee$GEN_G, na.color="#e5e4e2",
                  legend=T, layer.name="Ern. E Summe kWh")

## create standalone .html
mapshot(emapind, url = paste0(datapath, "/renew_energy_generation_sum.html"))

