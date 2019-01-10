

# library(devtools)
# install_github('tylermorganwall/rayshader')


library(rayshader); library(raster); library(sp); library(rgdal); library(dplyr)


neighborhoodPoly <- readOGR('./', 'neighborhoodOutline') # Polygon outline of my neighborhood

lidar <- raster('./PhillyLiDAR_DEM.tif') # Digital elevation model of Philadelphia

buildings <- raster('./bldgFootprints.tif') # Rasterized building footprints, with building height as value.
# if building footprints are shapefile, can rasterize using raster::rasterize()


crs(lidar) <- proj4string(buildings)
buildings[is.na(buildings)] <- 0 # if there are NAs in raster, set to height=0

lidar2 <- crop(lidar, neighborhoodPoly) # only want elevation data for my neighborhood

lidar2 <- projectRaster(lidar2, buildings, method = 'ngb') # project elevation data so that it's in same projection as building height data

localLayers <- lidar2 + buildings # combine elevation data and building height data

localLayers[is.na(localLayers)] <- 0 # set any NAs in raster dataset to height=0

localLayers <- t(localLayers)

elev_matrix <- raster::as.matrix(localLayers) # convert raster to matrix

# use rayshader r package to visualize 3d model and save as .stl file for printing
elev_matrix %>%
  sphere_shade(texture = "desert") %>%
  plot_3d(elmat, soliddepth = -20)
save_3dprint("./bellaVista.stl", maxwidth = 120, unit = "mm")






