# ggplots2 summary 

library(ggplot2)
library(proto)
library(plyr)


# change levels of a categorical variable
dataframe1<-dataframe
dataframe1$variable <- factor(dataframe1$variable)
levels(dataframe1$variable)
dataframe1$variable<- revalue(dataframe1$variable,c("factor1"="a","factor2"="b","..."="..."))
levels(dataframe1$variable)

# use summarySE to get mean values and standard error, group variables and create errorbars
tmp<-summarySE(dataframe,measurevar="var1",groupvars=c("var2","var2"))

# transform columns, correct for a specific factor
dataframe_1<-dataframe
dataframe_1$variable[1:3]<-dataframe_1$variable[1:3]/factor1

#colour palettes
cb_palette<- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442","#0072B2", "#D55E00", "#CC79A7")
new_palette<-c("#004953","#004953","#800020","#800020","#ffc40c","#ffc40c","#621","#621")

#binsize for histogram
binsize<- diff(range(dataframe$variable))/15

# nothing theme for plots without much stuff
theme_nothing <- function(base_size = 12, base_family = "Helvetica")
{
  theme_bw(base_size = base_size, base_family = base_family) %+replace%
    theme(
      rect             = element_blank(),
      line             = element_blank(),
      text             = element_blank(),
      axis.ticks.margin = unit(0, "lines")
    )
}
# check that it is a complete theme
attr(theme_nothing(), "complete")


