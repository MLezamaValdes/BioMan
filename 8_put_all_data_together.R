### construct ecosystem services Index
library(raster)
library(rgdal)
datapath <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/"

main <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/final_GIS_2/"
cpath <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/corine/"
newproj <- "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"
esip <- paste0(main, "ecosystem_services_index/")
kreise <- readOGR(paste0("C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/final_GIS/",
                        "Kreise_comp.shp"))
bes <- readOGR(paste0(main, "GemHe_Beschaeftigte_mh.shp"))
bev <- readOGR(paste0(main, "GemHe_Bevoelkerung_mh.shp"))

# READ DATA
# corine <- raster(list.files(cpath, pattern="tif", full.names = T))
# kreise_corproj <- spTransform(kreise, crs(corine))
# r2 <- crop(corine, extent(kreise_corproj))
# corinem <- mask(r2, kreise_corproj)
# corineproj <- projectRaster(corinem, method="ngb", crs=newproj)
# writeRaster(corinem, paste0(main, "corine.tif"), format="GTiff", overwrite=T)

corine <- raster(paste0(main, "corine.tif"))
corineproj <- projectRaster(corine, crs=CRS("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"),
                            method="ngb")

flaech <- readOGR(paste0(main, "GemHe_Flaechennutzung_mh.shp"))
lws <- readOGR(paste0(main, "GemHe_LWS_mh.shp"))
ee <-readOGR(paste0(datapath, "GemMiHe_EEnergie_prod_cons.shp"))
tour <- readOGR(paste0(main, "GemHe_Tourismus.shp"))


# PROVISIONING
# biomass
biomass <- corineproj
biomass[biomass!=c(16, 18, 23:27, 29)] <- NA # siehe Legenden-xls grün

biomass2 <- flaech[,c(1,4,37,38,41,42)] # ha und % Vegetation und Wald

# freshwater
freshwater <- corineproj
freshwater[freshwater!=c(35,36,41)] <- NA # siehe Legenden-xls blau

freshwater2 <- flaech[,c(1,4,43,44)]

# agricultural production
lwsp <- lws[,c(1,4,38:41, 55, 57, 58, 60)]

# (renewable) energy production
eep <- ee[,c(1,4,33,36,39,42,45,48,56)]

# REGULATING
# erosion control due to vegetation: see biomass 
# carbon storage biomass & soil: invekos?

# CULTURAL
# recreation
rec <- corineproj
rec[rec!=c(10, 11, 23:27, 29, 35, 36, 41)] <- NA # siehe Legenden-xls orange
plot(rec)

rec2 <- tour[,c(1,4,32, 33)]
rec2


# energy consumption
eec <- ee[,c(1,4,60:length(names(ee)))]


# extract data from corine biomass, freshwater and rec
extrcorine <- function(raster, shape, topic){
  ex <- extract(raster, shape)
  vals <- unique(raster[], na.rm=T)[order(unique(raster[], na.rm=T))]
  vals <- vals[1:length(vals)-1]

  vec <- lapply(seq(ex),function(i){
    sapply(seq(vals), function(j){
      x <- (sum(ex[[i]]==vals[j], na.rm=T))/length(ex[[i]])
      names(x) <- as.character(vals[j])
      x
    })
  })

  mat <- matrix(unlist(vec), ncol=length(vals), byrow=T)
  df <- data.frame(mat) #sum of value (variables) per Gemeinde
  names(df) <- paste0("c_", topic, "_" ,vals)

  shape@data[,(ncol(shape)+1):(ncol(shape)+1+ncol(df))] <- df

  return(shape)
}

# percentage of occurrance in the respective Gemeinde
biomasscorine <- extrcorine(raster=biomass, shape=biomass2, topic= "BM")
freshwatercorine <- extrcorine(raster=freshwater, shape=freshwater2, topic= "FW")
reccorine <- extrcorine(raster=rec, shape=rec2, topic= "R")

# write all provisioning layers
writeOGR(biomasscorine, dsn=paste0(esip, "biomasscorine.shp"), driver="ESRI Shapefile",
         layer="biomasscorine", overwrite=T)
writeOGR(freshwatercorine, dsn=paste0(esip, "freshwatercorine.shp"), driver="ESRI Shapefile",
         layer="freshwatercorine", overwrite=T)
writeOGR(reccorine, dsn=paste0(esip, "reccorine.shp"), driver="ESRI Shapefile",
         layer="reccorine", overwrite=T)


biomasscorine <- readOGR(paste0(esip, "biomasscorine.shp"))
freshwatercorine <- readOGR(paste0(esip, "freshwatercorine.shp"))
reccorine <- readOGR(paste0(esip, "reccorine.shp"))

# view with mapview
mapview::mapview(biomasscorine, zcol="c_BM_18", burst=F, label=biomasscorine$GEN_G, na.color="#e5e4e2",
               legend=T, layer.name="corine Pasture percent")
mapview::mapview(biomasscorine, zcol="Veget_p", burst=F, label=biomasscorine$GEN_G, na.color="#e5e4e2",
                 legend=T, layer.name="vegetation_percent")

mapview::mapview(freshwatercorine, zcol="Gwssr_h", burst=F, label=freshwatercorine$GEN_G, na.color="#e5e4e2",
                 legend=T, layer.name="Gewässer Ha")


# make one shapefile for all relevant variables
ess <- biomasscorine
match(ess$AGS_G, lwsp$AGS_G) # works!!
matched <- merge(ess@data, freshwatercorine@data, by.x="AGS_G", by.y="AGS_G")
ess@data <- matched
matched2 <- merge(ess@data, reccorine@data, by.x="AGS_G", by.y="AGS_G")
ess@data <- matched2
lwdat <- lwsp@data
matched3 <- merge(ess@data, lwdat, by.x="AGS_G", by.y="AGS_G")
ess@data <- matched3
matched4 <- merge(ess@data, eep@data, by.x="AGS_G", by.y="AGS_G")
ess@data <- matched4

# Energiekonsum in kWh
ec <- data.frame(eec)
ec[is.na(ec)] <- 0
match(ess$AGS_G, ec$AGS_G) # works!!
matched <- merge(ess@data, ec, by.x="AGS_G", by.y="AGS_G")
ess@data <- matched



bes <- data.frame( bes@data[,c(1,30:35)])
matched5 <- merge(ess@data, bes, by.x="AGS_G", by.y="AGS_G")
ess@data <- matched5

bevdf <- data.frame(bev@data[,c(1,30:46)])
matched6 <- merge(ess@data, bevdf, by.x="AGS_G", by.y="AGS_G")
ess@data <- matched6
names(ess)

# # Gesamtproduktion erneuerbare Energien in kWh
# ee <- data.frame(eep)
# ee[is.na(ee)] <- 0
# match(ess$AGS_G, ee$AGS_G) # works!!
# 
# matched <- merge(ess@data, ee, by.x="AGS_G", by.y="AGS_G")
# names(matched)
# 
# ess@data <- matched
# matched <- merge(ess@data, lwsp@data, by.x="AGS_G", by.y="AGS_G")
# ess@data <- matched


namdf <- read.csv(paste0(datapath, "names_final_shape.csv"), sep=";", stringsAsFactors = F)

nam <- namdf$Variablenname

# clean up
essclean <- ess
#essclean <- ess[,which(!(vec %in% c(15, 23, 38, 47, 55:81, 86:113, 119:202)))]
names(essclean)
essclean$c_BM_16.1 <- NULL
essclean$c_FW_35.1 <- NULL
essclean$c_R_10.1 <- NULL
essclean$gem_y <- NULL
essclean$Gmnd__S <- NULL

# select all variables but pos
gen_gpos <- which(grepl("GEN_", names(essclean)))
pos <-gen_gpos[2:length(gen_gpos)]
essclean <- essclean[,-pos]

data.frame(nam, names(essclean))

names(essclean) <- nam

writeOGR(essclean, dsn=paste0(esip, "allvars.shp"), driver="ESRI Shapefile",
         layer="allvars", overwrite=T)

