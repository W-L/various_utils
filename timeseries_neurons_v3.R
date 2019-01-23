#timeseries v3

library("rhdf5")
library("viridis")
library("ggplot2")
library("nat")
library("grid")
library("TTR")



#frames in seconds

setwd("/home/lukas")
input <- "output_H13_M57_S27_frames_laud.mat" 
timeseries <- h5read(file = input, name = "/timeseries")
timeseries_ <- h5read(file = input, name = "/timeseries_")
bg_spatial<- h5read(file = input, name = "/bg_spatial")
std_image <- h5read(file = input, name = "/std_image")
centers <- h5read(file = input, name = "/centers")
h5ls(input)

frames <- 1000
neurons <- 74
sparfactor <- 0
pdftext <- "fig_neurons_M57_2"
pdftext2 <- "heatmap_neurons_M57_2"
kp <- c(4:64)
kpl <- length(kp)  
curr_v <- timeseries_
fourier_min <- 90
fourier_max <- 910

H5close()


#create vectors with neuron numbers and timepoints

neuron_num <- NULL
k <- 1

for (x in seq(1,kpl,by=1)) {
  for (x in seq(1,frames,by=1)) {
    neuron_num <- c(neuron_num,k)
  }
  k <- k+1
}

time_points <- NULL
l <- 1

for (x in seq(1,kpl,by=1)) {
  for (x in seq(1,frames,by=1)) {
    time_points <- c(time_points,l)
    l <- l+1
  }
  l <- 1
}

single_times <- seq(1,frames,by=1)

#scaling

trans_timeseries_ <- as.data.frame(t(curr_v))
trans_timeseries_ <- trans_timeseries_[1:frames,]

scaled_times_tmp <- NULL
master_frame <- as.data.frame(matrix(NA, nrow=frames,ncol=1))

for (x in seq(1,neurons,by=1)) {
  scaled_times_tmp<- scale(trans_timeseries_[[x]], center = TRUE, scale = TRUE)
  sst_plot <- data.frame(y=scaled_times_tmp, x=single_times)
  master_frame <- data.frame(master_frame,y=sst_plot$y)
}

master_frame <- master_frame[,2:74]
master_frame <- master_frame[,kp]

#detrend
curr_neur<-NULL
lmfit<-NULL
master_frame_2<- as.data.frame(matrix(NA, nrow=frames,ncol=1))

for (x in seq(1,kpl,by=1)) {
  curr_neur <- master_frame[[x]]
  lmfit <- lm(curr_neur ~ single_times)
  master_frame_2<- data.frame(master_frame_2,y=lmfit$resid)
}

master_frame_2 <- master_frame_2[,2:(kpl+1)]


#fourier transform filter

four <- NULL
master_frame_3<- as.data.frame(matrix(NA, nrow=frames,ncol=1))

for (x in seq(1,kpl,by=1)) {
  four <- master_frame_2[[x]]
  four_fft <- fft(four)
  #four_fft_re <- Re(four_fft)
  four_fft[fourier_min:fourier_max] <- 0+0i
  four_ifft <- fft(four_fft, inverse=TRUE)/length(four_fft)
  four_num <- as.numeric(four_ifft)
  master_frame_3<- data.frame(master_frame_3,y=four_num)
}

master_frame_3 <- master_frame_3[,2:(kpl+1)]

#convert to long format
all_n <- NULL
for (x in seq(1,kpl,by=1)) {
  v_tmp<- master_frame_3[[x]]
  all_n <- c(all_n,v_tmp)
}

#master_frame in long format
ts_master <- data.frame(neuron_num,all_n,time_points)

#plot all neurons 
neuron_tmp <- NULL
m <- 1
pdf(paste("/home/lukas/Schreibtisch/neurons_",pdftext,".pdf",sep=""), width=35/2.54, height=5/2.54)

for (x in seq(1,kpl,by=1)) {
  neuron_tmp <- subset(ts_master,neuron_num == m)
  print(ggplot(neuron_tmp,aes(x=time_points,y=all_n)) + 
          geom_line(colour="#004953") + 
          theme_bw(base_size=5, base_family = "Times") +
          xlab("frames"))
  m <- m+1
}

dev.off()




#heatmap
pdf(paste("/home/lukas/Schreibtisch/neurons_",pdftext2,".pdf",sep=""),width=15,height=10)
ggplot(ts_master,aes(x=time_points,y=neuron_num,fill=all_n)) +
  geom_raster() +
  scale_fill_viridis(option="viridis", name="") +
  scale_x_continuous(breaks=c(0, 250, 500, 750, 1000), labels=c("0","15","30","45","60")) +
  xlab("Time (s)")+
  ylab("Neuron")+
  theme_bw(base_size=28, base_family = "Times")+
  theme(legend.position="bottom")
dev.off()


#plot ind neur

ns <- c(9,10,13,27,36,52)
neuron_fig1 <- ts_master[8001:9000,]
neuron_fig2 <- ts_master[9001:10000,]
neuron_fig3 <- ts_master[12001:13000,]
neuron_fig4 <- ts_master[26001:27000,]
neuron_fig5 <- ts_master[35001:36000,]
neuron_fig6 <- ts_master[51001:52000,]

neurons_fig <- rbind(neuron_fig1,neuron_fig2,neuron_fig3,neuron_fig4,neuron_fig5,neuron_fig6)

pdf("/home/lukas/Schreibtisch/neuron_traces.pdf", width=15, height=7)
print(ggplot(neurons_fig,aes(x=time_points,y=all_n,colour=factor(neuron_num))) + 
  facet_grid(neuron_num ~ . , scales="free") +
  geom_line() + 
  theme_nothing(base_size=5, base_family = "Times") +
  xlab("frames")) +
  theme(panel.margin = unit(2, "lines"))
dev.off()



#neuron centers


cn <- centers[4:64,]
cn <- as.data.frame(cn)
cn_only_sel<- cn[c(9,10,13,27,36,52),]
Name <- c(1:61)

pdf("/home/lukas/Schreibtisch/neuron_centers_only.pdf", width=15, height=15)
print(ggplot(cn,aes(x=V2,y=V1)) + 
        geom_point(shape=1,size=5) + 
        scale_y_reverse()+
        #scale_x_reverse()+
        geom_text(aes(label=Name), size=4,hjust=3)+
        theme_nothing(base_size=5, base_family = "Times")) 
dev.off()




new_palette<-c("#004953","#800020","#ffc40c","#621","#E69F00","#0072B2")

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



1 #F8766D 1 1     1     1
# 2 #B79F00 2 2     1     2
# 3 #00BA38 3 3     1     3
# 4 #00BFC4 4 4     1     4
# 5 #619CFF 5 5     1     5
# 6 #F564E3 6 6     1     6
