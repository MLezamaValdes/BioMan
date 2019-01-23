
library(raster)
library(rgeos)
library(rgdal)

main <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/"
datapath <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/"
newproj <- "+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs"

#### read datasets BioMan project


# GEMEINDEN MIT AGS
# gem <- shapefile(paste0(datapath, "VZ250_GEM.shp"))
# kre <- shapefile(paste0(datapath, "Kreisgrenzen_HE.shp"))
# kre <- spTransform(kre, crs(gem))
# gem_he <- gem[gem$GEN_L=="Hessen",]
# gem_he$AGS_G <- as.numeric(gem_he$AGS_G)
# writeOGR(gem_he, dsn=paste0(datapath, "Gemeinden_Hessen.shp"), driver="ESRI Shapefile", 
#          layer="Gemeinden_Hessen", overwrite=T)


gem_he_path <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/old/Hessen_shapes/"
gem_he <- readOGR(paste0(gem_he_path, "Gemeinden_Hessen_clean.shp"))
gem_henam <- gem_he@data # to see gemeinde names

# CORINE HESSEN
corine <- raster(list.files(datapath, pattern="Corine_hessen.tif$", full.names = T))
corine_proj <- projectRaster(corine, crs=newproj)
writeRaster(corine_proj, paste0(datapath, "corine_hessen_proj.tif"), format="GTiff")

# HESSISCHE GEMEINDESTATISTIK
# Die 6-stelligen Gemeindeschlüssel setzen sich wie folgt zusammen: Landkreis 
# bzw. die kreisfreie Stadt (Stellen 1 bis 3), Gemeinde (Stellen 4 bis 6).


# BEVÖLKERUNG
path <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/HessischeGemeindestatistik/"
bev <- read.csv(list.files(path, pattern="_Bevoelkerung_2.csv", full.names = T),
                sep=";", stringsAsFactors = F)
# replace , with . and save as numeric
for(i in seq(17)){
  bev[,2+i] <- as.numeric(gsub(",", '.', bev[,2+i], fixed = T))
}
bev$AGS <- as.factor(paste0("06",bev$AGS)) # add 06 for Hessen to code
# which position do codes have in two datasets?
match(gem_he$AGS_G, bev$AGS) # works!!
gem_he@data <- merge(gem_he@data, bev, by.x="AGS_G", by.y="AGS")

#clip to mh
bevclip <- intersect(gem_he, kreise)
opp <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/final_GIS/"
writeOGR(bevclip, dsn=paste0(opp, "GemHe_Bevoelkerung_mh.shp"), driver="ESRI Shapefile",
         layer="GemHe_Bevoelkerung_mh", overwrite=T)
str(bevclip@data)
bev <- readOGR(paste0(datapath, "GemHe_Bevölkerung.shp"))

# BESCHÄFTIGTE
bes <- read.csv(list.files(datapath, pattern="Beschäftigte", full.names = T),
                sep=";", stringsAsFactors = F)
bes$AGS <- as.factor(paste0("06",bes$AGS)) # add 06 for Hessen to code
# which position do codes have in two datasets?
match(gem_he$AGS_G, bes$AGS) # works!!
matched <- merge(gem_he@data, bes, by.x="AGS_G", by.y="AGS")
gem_he@data <- matched
writeOGR(gem_he, dsn=paste0(datapath, "GemHe_Beschaeftigte.shp"), driver="ESRI Shapefile",
         layer="GemHe_Beschaeftigte", overwrite=T)

gem_he$WindkWh[gem_he$GEN_G=="Dillenburg"]

# DISPLAY 
      library(sf)
      library(tmap)
      library(viridis)
      library(ggplot2)
      library(broom)
      

      # beschäftigte
      besch <- st_read(paste0(datapath, "GemHe_Beschaeftigte.shp"))
      str(besch)
      besch$Bsch_Arbrt <- as.numeric(besch$Bsch_Arbrt)
      besch$BschWhnr_1 <- as.numeric(besch$BschWhnr_1)
      
      
      ggplot(besch)+ 
        geom_sf(aes(fill=Bsch_Arbrt))+
        scale_fill_gradient(low="#fff68f", high="#971849")
      
      ggplot(besch)+
        geom_sf(aes(fill=BschWhnr_1))+
        scale_fill_gradient(low="#fff68f", high="#971849")
      
      
      # with tmap
      tm_shape(besch)+
        tm_polygons("BschWhnr_1", id="Nam_x", palette="Greens")
      
      # make interactive view and save as html
      tmap_mode("view")
      tmap_last()
      beschmap <- tmap_last()
      tmap_save(beschmap, paste0(main, "Beschaeftigte_Hessen.html"))
      



