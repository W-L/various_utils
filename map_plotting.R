library(rgdal)
library(ggplot2)

# ----------- minimal example ------------
# this folder includes a shapefile (.shp) and some other files which are associated metadata
# It is from https://www.naturalearthdata.com
# load the shapefile: path and filename (without extension) as arguments
shapefile <- readOGR("./raw_shapefile", "ne_10m_admin_0_countries")

# transform from class SpatialPolygonsDataFrame to a normal dataframe for plotting
shapefile_df <- fortify(shapefile)

# then plot the outlines as geom_path in ggplot
# geom_polygon can also be used if you want to assign fill
# but causes problems with clipping when countries extend outside of the plot
map <- ggplot() +
  geom_path(data = shapefile_df, aes(x = long, y = lat, group = group), color = 'darkgray', size = .2) +
print(map) 


# ----------- europe example ------------
# to display only a certain region you can set axis limits or you can also subset the original shapefile
shapefile_europe_et_al <- subset(shapefile, CONTINENT == "Europe")
shapefile_europe_df <- fortify(shapefile_europe_et_al)

map <- ggplot() +
  geom_path(data = shapefile_europe_df, aes(x = long, y = lat, group = group), color = 'darkgray', size = .2) +
  coord_map() + # coord_map() makes the aspect ratio nicer
  ylim(c(33, 64)) + # set latitude range to plot
  xlim(c(-11, 42)) + # longitude range
  ylab('Latitude') +
  xlab('Longitude') +
  theme_minimal()
print(map) 


# ----------- mystery example ------------
mystery_shapefile <- subset(shapefile, NAME %in% c("Austria", "Germany", "India", "Mongolia", "Greece"))
mystery_shapefile_df <- fortify(mystery_shapefile)

loc <- data.frame(lat=c(47.52, 37.9439, 52.628637, 48.281702, 28.481413),
                  long=c(106.54, 23.7921, 13.664087, 16.268822, 77.212073))

map <- ggplot() +
  geom_path(data = mystery_shapefile_df, aes(x = long, y = lat, group = group), color = 'darkgray', size = .2) +
  geom_curve(mapping = aes(x=long, y=lat, xend=16.26, yend=48.28), data=loc, arrow=arrow(type="closed", length = unit(0.2, "cm")),
             curvature=0.2, ncp=20) +
  theme(axis.line=element_blank(),axis.text.x=element_blank(),axis.text.y=element_blank(),axis.ticks=element_blank(),
        axis.title.x=element_blank(), axis.title.y=element_blank(), panel.background=element_blank(),
        panel.border=element_blank(),panel.grid.major=element_blank(), panel.grid.minor=element_blank(),
        plot.background=element_blank())
print(map) 
