### construct ecosystem services Index


main <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/final_GIS_2/"
cpath <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/corine/"
newproj <- "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"
esip <- paste0(main, "ecosystem_services_index/")
kreise <- readOGR(paste0("C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/final_GIS/",
                        "Kreise_comp.shp"))
# READ DATA
# corine <- raster(list.files(cpath, pattern="tif", full.names = T))
# kreise_corproj <- spTransform(kreise, crs(corine))
# r2 <- crop(corine, extent(kreise_corproj))
# corinem <- mask(r2, kreise_corproj)
# corineproj <- projectRaster(corinem, method="ngb", crs=newproj)
# writeRaster(corinem, paste0(main, "corine.tif"), format="GTiff", overwrite=T)

corine <- raster(paste0(main, "corine.tif"))
flaech <- readOGR(paste0(main, "GemHe_Flaechennutzung_mh.shp"))
lws <- readOGR(paste0(main, "GemHe_LWS_mh.shp"))
ee <- readOGR(paste0(main, "GemMiHe_EEnergieproduktion_mh.shp"))
tour <- readOGR(paste0(main, "GemHe_Tourismus.shp"))


# PROVISIONING
# biomass
biomass <- corine
biomass[biomass!=c(16, 18, 23:27, 29)] <- NA # siehe Legenden-xls grün

biomass2 <- flaech[,c(1,4,37,38,41,42)] # ha und % Vegetation und Wald

# freshwater
freshwater <- corine
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
rec <- corine
rec[rec!=c(10, 11, 23:27, 29, 35, 36, 41)] <- NA # siehe Legenden-xls orange
plot(rec)

rec2 <- tour[,c(1,4,32, 33)]
rec2

# save 
indpath <- paste0(main, "ecosystem_services_index/")

# make data table
# extract data from corine biomass, freshwater and rec

extrcorine <- function(raster, shape, topic){
  ex <- extract(raster, shape)
  vals <- unique(raster[], na.rm=T)[order(unique(raster[], na.rm=T))]
  vals <- vals[1:length(vals)-1]
  
  vec <- lapply(seq(ex),function(i){
    sapply(seq(vals), function(j){
      x <- sum(ex[[i]]==vals[j], na.rm=T)
      names(x) <- as.character(vals[j])
      x
    })
  })
  
  mat <- matrix(unlist(vec), ncol=length(vals), byrow=T)
  df <- data.frame(mat)
  names(df) <- paste0("c_", topic, "_" ,vals)
  
  shape@data[,(ncol(shape)+1):(ncol(shape)+1+ncol(df))] <- df

  return(shape)
}

biomasscorine <- extrcorine(raster=biomass, shape=biomass2, topic= "biom")
freshwatercorine <- extrcorine(raster=freshwater, shape=freshwater2, topic= "frshw")
reccorine <- extrcorine(raster=rec, shape=rec2, topic= "rec")

# write all provisioning layers
writeOGR(biomasscorine, dsn=paste0(esip, "biomasscorine.shp"), driver="ESRI Shapefile",
         layer="biomasscorine", overwrite=T)
writeOGR(freshwatercorine, dsn=paste0(esip, "freshwatercorine.shp"), driver="ESRI Shapefile",
         layer="freshwatercorine", overwrite=T)
writeOGR(reccorine, dsn=paste0(esip, "reccorine.shp"), driver="ESRI Shapefile",
         layer="reccorine", overwrite=T)

# view with mapview
map <- mapview::mapview(flaech, zcol="Veget_p", burst=F, label=flaech$GEN_G, na.color="#e5e4e2",
               legend=T, layer.name="vegetation_percent")
mapview::mapview(biomasscorine, zcol="c_biom_16", burst=F, label=flaech$GEN_G, na.color="#e5e4e2",
                 legend=T, layer.name="vegetation_percent")

provisioning <- biomasscorine
match(biomasscorine$AGS_G, reccorine$AGS_G) # works!!
matched <- merge(biomasscorine@data, freshwatercorine@data, by.x="AGS_G", by.y="AGS_G")
provisioning@data <- matched
matched2 <- merge(provisioning@data, reccorine@data, by.x="AGS_G", by.y="AGS_G")
provisioning@data <- matched2
writeOGR(provisioning, dsn=paste0(esip, "provisioning.shp"), driver="ESRI Shapefile",
         layer="provisioning", overwrite=T)


