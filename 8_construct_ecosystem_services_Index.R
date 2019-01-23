### construct ecosystem services Index


main <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/final_GIS_2/"
cpath <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/corine/"
newproj <- "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"

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


