# read energy use data

library(raster)
library(rgeos)
library(rgdal)

main <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/"
datapath <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/"
newproj <- "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"
gem_he <- readOGR(paste0(datapath, "Gemeinden_Hessen.shp"))


############### ENERGY USE SEPARATE FROM ABOVE ###########################
# read energy production
gem_he <- readOGR(paste0(datapath, "GemMiHe_EEnergieproduktion.shp"))
eec <- read.csv(paste0(main, "energiedaten/Stromverbrauch_2016.csv"), sep=";", stringsAsFactors = F,
                dec=",")

# NAMEN GEM_HE UND ENERGIEPRODUKTION BEREINIGEN
eec$Gemeinde.Stadt <- as.character(eec$Gemeinde..Stadt)
eec$Gemeinde.Stadt[eec$Gemeinde.Stadt=="Allendorf"] <- "Allendorf (Lumda)"
eec$Gemeinde.Stadt[eec$Gemeinde.Stadt=="Lauterbach"] <- "Lauterbach (HE)"
eec$Gemeinde.Stadt[eec$Gemeinde.Stadt=="Mue］chhausen"] <- "Muenchhausen"
eec$Gemeinde.Stadt[eec$Gemeinde.Stadt=="Gemue］den"] <- "Gemuenden"
eec$Gemeinde.Stadt[eec$Gemeinde.Stadt=="Mue…ke"] <- "Muecke"
eec$Gemeinde.Stadt[eec$Gemeinde.Stadt=="Biedenkopf "] <- "Biedenkopf"
eec$Gemeinde.Stadt[eec$Gemeinde.Stadt=="Weilmue］ster"] <- "Weilmuenster"
eec$Gemeinde.Stadt[eec$Gemeinde.Stadt=="H「ettenberg"] <- "Huettenberg"
eec$Gemeinde.Stadt[eec$Gemeinde.Stadt=="Haiger "] <- "Haiger"

#gem_he$GEN_G[gem_he$AGS_G=="06534015"] <- "Muenchhausen"


# make sums from double occurring names in eeg
doubles <- table(eec$Gemeinde.Stadt)>1
dub <- doubles[doubles==TRUE]
names(dub)

for(i in seq(dub)){
  x <- eec[eec$Gemeinde.Stadt==names(dub[i]),]
  y <- x[,4:8]
  z <- colSums(y, na.rm=TRUE)
  target <- x[1,]
  target[,4:8] <- z
  eec <- eec[!eec$Gemeinde.Stadt==names(dub[i]),] # all rows except doubles
  eec[nrow(eec)+1,] <- target
  print(i)
}
eec$gem <- eec$Gemeinde.Stadt # dupliziere Gemeindename, damit er nicht beim mergen verloren geht

# subselect Mittelhessen from gem_he to check if all Mittelhessen Gemeinden are matched
kreise <- c("Marburg-Biedenkopf", "Giessen", "Vogelsbergkreis", "Lahn-Dill-Kreis",
            "Limburg-Weilburg", "Wetteraukreis")

mittelhessendat <- lapply(seq(kreise), function(i){
  gem_he@data[gem_he$GEN_K == kreise[i],]
})

mh <- rbind(mittelhessendat[[1]], mittelhessendat[[2]], mittelhessendat[[3]],
            mittelhessendat[[4]], mittelhessendat[[5]], mittelhessendat[[6]])

# welche Namen sind noch nicht gematcht?
nonamemh <- which(is.na(match(mh$GEN_G, eec$Gemeinde.Stadt)))
nonameeec <- which(is.na(match(eec$Gemeinde.Stadt, mh$GEN_G)))

mh$GEN_G[nonamemh]
eec$Gemeinde.Stadt[nonameeec]

# merge when all names are cleared
meec <- merge(gem_he@data, eec, by.x="GEN_G", by.y="Gemeinde.Stadt", all.x=T)
meecord <- meec[order(meec$AGS_G),] # bring into correct order for shapefiles
sum(!is.na(match(gem_he$AGS_G, meecord$AGS_G))) # works!!
gem_he@data <- meecord

writeOGR(gem_he, dsn=paste0(datapath, "GemMiHe_EEnergie_prod_cons.shp"), driver="ESRI Shapefile",
         layer="GemMiHe_EEnergie_prod_cons", overwrite=T, layer_options = "RESIZE=YES")



View(gem_he@data)
