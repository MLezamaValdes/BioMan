### construct ecosystem services Index


main <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/final_GIS_2/"
cpath <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/corine/"
newproj <- "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"

# read required data
corine <- raster(list.files(cpath, pattern="tif", full.names = T))
corineproj <- projectRaster(corine, method="ngb", crs=newproj)
r2 <- crop(corine, extent(kreise))
corinem <- mask(r2, kreise)
writeRaster(corinem, paste0(opp, "corine.tif"), format="GTiff")

# PROVISIONING
# biomass
range(corine[], na.rm=T)
cv <- corine[]
plot(corine)

# REGULATING
# CULTURAL
