###################################################
#Aim:Extracting the VIs from the Camera
#test code that used to extract the PhenoCam VIs
###################################################
Sys.setenv(tz="UTC")
library(phenopix)
library(zoo)
library(lubridate)
library(tidyverse)
#create the strucuture folder:
folder.path<-"./data-raw/"
# structureFolder(folder.path)  ##create the folders for analysis

#-----set the path----
## set path of the reference image where to draw ROIs. Only one jpeg image is allowed in this folder.
path.image.ref <- paste(folder.path,'REF/',sep='')  #here is the path for reference image
## set path where to store the ROI coordinates
path.roi <- paste(folder.path,'ROI/',sep='')
## define path with all images to be processed
# img.path <- paste(folder.path,'IMG/',sep='')
img.path <- "D:/data/Test_data/PhenoCam_GCC/Lorenz_Walthert/Test_greenness/change_name/" #change the path
## define in which folder VI data will be stored
vi.path <- paste(folder.path,'VI/test/',sep='')


#---------------------
#(1)select the tree ROI:Tree1,Tree2
#---------------------

roi.names <- c('tree1', 'tree2')
nroi=length(roi.names)
drawROI<-FALSE

if (drawROI == TRUE){

  DrawMULTIROI(path.image.ref, path.roi, nroi=nroi,roi.names,file.type = ".JPG")

}

#---------------------
#(2)vegetation indices(VIs) extraction
#---------------------

extractVIs(img.path = img.path,roi.path = path.roi,
                    vi.path = vi.path,roi.name = roi.names,
                    plot=TRUE,
                    date.code="yyyy-mm-dd-HHMM",ncores = 16,
                    file.type = ".JPG")

## notes: the object VI.site is actually a list of length == nrois. Each object of the list is names with
## roi.names. Vi.data is saved as RData in vi.path, the name of the dataframe is VI.data
load(paste(vi.path,'VI.data.Rdata',sep=''))

#---------------------------------
#(3)filter the data and the needed data
#---------------------------------
filtered.VI_tree1<-autoFilter(VI.data$tree1,dn=c("r.av","g.av","b.av"),raw.dn = TRUE,filter = "max",plot = T)
filtered.VI_tree2<-autoFilter(VI.data$tree2,dn=c("r.av","g.av","b.av"),raw.dn = TRUE,filter = "max",plot = T)

filtered.VI_tree1<-convert(filtered.VI_tree1) #convert zoo to data.frame
filtered.VI_tree2<-convert(filtered.VI_tree2)
filtered.VI_tree1<-filtered.VI_tree1 %>%
  mutate(date=doy,doy=NULL)
filtered.VI_tree2<-filtered.VI_tree2 %>%
  mutate(date=doy,doy=NULL)

#---------------------------------
#(4)plotting
#---------------------------------
save.path<-"./test/figures/"
#
png(file=paste0(save.path,"tree1 greenness.png"))
#tree1
plot(VI.data$tree1$date,VI.data$tree1$gi.av,xlab="",ylab="GCC",pch=16,col="gray")
points(filtered.VI_tree1$date,filtered.VI_tree1$max.filtered,
       col="forestgreen",pch=16)
legend("topleft",pch = 16,bty="n",col = c("gray","forestgreen"),
       legend=c("each photo","daily greenness"))
dev.off()

#tree2
png(file=paste0(save.path,"tree2 greenness.png"))
plot(VI.data$tree2$date,VI.data$tree2$gi.av,xlab="",ylab="GCC",pch=16,col="gray")
points(filtered.VI_tree2$date,filtered.VI_tree2$max.filtered,
       col="forestgreen",pch=16)
legend("topleft",pch = 16,bty="n",col = c("gray","forestgreen"),
       legend=c("each photo","daily greenness"))
dev.off()
