library(raster)
library(rgdal)
library(stringr)
library(mapview)

main <- "C:/Users/mleza/Documents/Jobs/BioMan/Variablen/mein_GIS/final_GIS_2/"
shapepath <- "C:/Users/mleza/Documents/Jobs/BioMan/BioMan_final_product/shapefiles/"
allvars <- readOGR(paste0(shapepath, "allvars.shp"))
htmlmappath <- "C:/Users/mleza/Documents/Jobs/BioMan/BioMan_final_product/html_maps/"

# display function
# needs shapefile as object name, variable and variable names as character, 
# htmlmappath shall be adjusted to the desired folder
# The label shown on the map is shape$GG per default, can be changed to shape$xx as needed
dispfunc <- function(shape, variable, variable_name, lab=shape$GG){ 
  map <- mapview::mapview(shape, zcol=variable, burst=F, label=lab, na.color="#e5e4e2",
                          legend=T, layer.name=variable_name)
  ## create standalone .html
  setwd(htmlmappath)
  mapshot(map, url = paste0(getwd(), paste0("/",str_replace_all(variable_name, pattern=" ", repl=""), ".html")))
}



################### PRESSURES: ##################################################
# landuse
landuse <- readOGR(paste0(shapepath, "landuse.shp"))
dispfunc(landuse, "c_LU_25", "Anteil Mischwald laut Corine")

# Gesamtstromverbrauch
dispfunc(allvars, "verbrG", "Gesamtstromverbrauch")


############## STATE: ############################################################

# Ökosystemfunktionen
dispfunc(allvars, "WldVG_P", "Ökosystemfunktionen")

# Tiervorkommen (besser in QGIS wenn geringer Arbeitsspeicher)
# plfm <- readOGR(paste0(shapepath, "shapefiles/natis_plantfishmolusca_mh.shp"))
# an <- readOGR(paste0(shapepath, "natisffh_animals_mh.shp"))
# 
# dispfunc(an, "FAMILY", "Tierarten", lab=shape$ARTNAME)
# dispfunc(plfm, "FAMILY", "Tierarten", lab=shape$ARTNAME)

# Beschäftigte
dispfunc(allvars, "besW", "Beschaeftigte am Wohnort")
dispfunc(allvars, "besA", "Beschaeftigte am Arbeitsort")
dispfunc(allvars, "pndl", "Pendlersaldo")

# Bevölkerung
dispfunc(allvars, "EWkm2", "Einwohner pro Quadratmeter")
dispfunc(allvars, "bevG", "Gesamtbevoelkerung")


######### RESPONSES ########################################################
# Produktion erneuerbarer Energien
allvars$renew <- rowSums(allvars@data[,41:46], na.rm=T)
dispfunc(allvars, "renew", "kWh erneuerbare Quellen")

# ökol. Landbau ha
dispfunc(allvars, "oek_H", "oekologischer Landbau in ha")

