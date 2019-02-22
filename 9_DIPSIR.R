library(raster)
library(rgdal)

main <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/final_GIS_2/"
esip <- paste0(main, "ecosystem_services_index/")
ess <- readOGR(paste0(esip, "allvars.shp"))



#PRESSURES: 
# landuse

landuse <- ess
landuse <- landuse[1:2]

corine <- raster(paste0(main, "corine.tif"))
corineproj <- projectRaster(corine, crs=CRS("+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"),
                            method = "ngb")

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
landusecorine <- extrcorine(raster=corineproj, shape=landuse, topic= "LU")

writeOGR(landusecorine, dsn=paste0(esip, "landuse.shp"), driver="ESRI Shapefile",
         layer="landuse", overwrite=T)

#STATE:
# Tiervorkommen
# Ökosystemfunktionen

# make Index based on Früh-Müller
# provisioning: 
Gewässer_ha <- ess$gewH # freshwater supply
Wald_Veg_ha <- ess$Wald_ha + ess$Veget_h # biomass supply
agr_prod <- ag <- ess$Vieh_G +  ess$Gtr_G # agricultural production: Getreide gesamt, Vieh_gs
stromG <- el <- ess$stromG # Gesamtstromproduktion

# REGULATION: NOT AVAILABLE carbon storage and erosion control: invekos???

# CULTURAL:
Afth_Trtn <- ess$aufthd # mittlere Aufenthaltsdauer Touristen
WaldVegGewssr_P <- rec_nat <- (ess$Wald_p + ess$Veget_p + ess$gewP)/3 # Anteil Wald, Vegetation und Gewässer

# einfache Gewichtung: beide Teile normalisieren und addieren
esfdf <- data.frame(Gewässer_ha, Wald_Veg_ha, agr_prod, stromG, Afth_Trtn, WaldVegGewssr_P)

# normalize each variable
nrm <- function(x){
  (x-min(x, na.rm=T))/(max(x, na.rm=T)-min(x, na.rm=T))
} 

esfdfnorm <- esfdf

for(i in seq(ncol(esfdfnorm))){
  esfdfnorm[,i] <- nrm(esfdfnorm[,i])
}

# make rowSums excluding NA
esfdfnorm$esf <- rowSums(esfdfnorm)
esfdfnorm$esf_narm <- rowSums(esfdfnorm, na.rm=T)

#normalize those
esfdfnorm$esfnr <- nrm(esfdfnorm$esf)
esfdfnorm$esfnanr <- nrm(esfdfnorm$esf_narm)

#put back into shapefile
y <- (length(names(ess))+1)
ess@data[,(y):(y+ncol(esfdfnorm)-1)] <- esfdfnorm

mapview::mapview(ess, zcol="WaldVegGewssr_P", burst=F, label=flaech$GEN_G, na.color="#e5e4e2",
                 legend=T, layer.name="esf normalized")


# write csv
write.csv(esfdfnorm, paste0(esip, "ecosystem_functions.csv"))
# write shapefile
writeOGR(ess, dsn=paste0(esip, "allvars.shp"), driver="ESRI Shapefile",
         layer="allvars", overwrite=T)

# Beschäftigte
# Bevölkerung


# RESPONSES
# Gesamtstromverbrauch
ess$oek_H # ökol. Landbau ha
# Gesamtproduktion erneuerbare Energien in kwh
ess$rnw_kWh <- rowSums(ess@data[,42:47], na.rm=T)


mapview::mapview(ess, zcol="rnw_kWh", burst=F, label=flaech$GEN_G, na.color="#e5e4e2",
                 legend=T, layer.name="renewable_energ_sum")
