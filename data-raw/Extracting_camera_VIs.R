###################################################
#Aim:Extracting the VIs from the Camera
#processed the PhenoCam data that Lorenze sent me (data range from Mar,2021-Oct,2022)
###################################################
Sys.setenv(tz="UTC")
library(phenopix)
library(zoo)
library(lubridate)
library(tidyverse)
#create the strucuture folder:
folder.path<-"./data-raw/"
# structureFolder(folder.path)  ##create the folders for analysis

years<-c(2021,2022)

#done for this step(extraction VIs)!
# for (i in 1:length(years)) {
#
#   #-----set the path----
#   ## set path of the reference image where to draw ROIs. Only one jpeg image is allowed in this folder.
#   path.image.ref <- paste(folder.path,'REF/',sep='')  #here is the path for reference image
#   ## set path where to store the ROI coordinates
#   path.roi <- paste(folder.path,'ROI/',sep='')
#   ## define path with all images to be processed
#   img.path <- paste0("D:/data/WSL_PhenoCam/Lorenz_Walthert/images_2021_2022/",years[i],"/") #change the path
#   ## define in which folder VI data will be stored
#   vi.path <- paste0(folder.path,'VI/',years[i],"/")
#
#   #months:
#   months<-list.files(img.path)
#   #---------------------
#   #(1)select the tree ROI:Tree1,Tree2-->this has done!
#   #---------------------
#
#   roi.names <- c('tree1', 'tree2')
#   nroi=length(roi.names)
#   # drawROI<-FALSE
#   #
#   # if (drawROI == TRUE){
#   #
#   #   DrawMULTIROI(path.image.ref, path.roi, nroi=nroi,roi.names,file.type = ".JPG")
#   #
#   # }
#
#   #---------------------
#   #(2)vegetation indices(VIs) extraction
#   #---------------------
#   for (j in 5:length(months)) {
#
#   extractVIs(img.path = paste0(img.path,months[j],"/"),roi.path = path.roi,
#                vi.path = vi.path,roi.name = roi.names,
#                #set the begin date to save the data with different names
#                begin = paste0(years[i],"-",months[j],"-","01"),
#                plot=TRUE,
#                date.code="yyyymmddHHMMSS",ncores = "all",
#                file.type = ".JPG")
#   #
#     print(j)
#   }
#
# }

#---------------------------------
#(3)filter the data and the needed data
#---------------------------------
#load the extracted VIs
VI.data.merge<-c()
for (i in 1:length(years)) {
  vi.path <- paste0(folder.path,'VI/',years[i],"/")
  file.names<-list.files(vi.path)
  #
  for (j in 1:length(file.names)) {
    vi.path.proc<-paste0(vi.path,file.names[j])
    load(vi.path.proc)
    if(i==1&j==1){
      VI.data.merge<-list(VI.data[[1]],VI.data[[2]])
    }
    if(j>1){
      VI.data.merge[[1]]<-rbind(VI.data.merge[[1]],VI.data[[1]])
      VI.data.merge[[2]]<-rbind(VI.data.merge[[2]],VI.data[[2]])
    }
    rm(VI.data)
  }
}
#
names(VI.data.merge)<-c('tree1', 'tree2')

##filtered the data:
filtered.VI_tree1<-autoFilter(VI.data.merge$tree1,dn=c("r.av","g.av","b.av"),raw.dn = TRUE,filter = "max",plot = T)
filtered.VI_tree2<-autoFilter(VI.data.merge$tree2,dn=c("r.av","g.av","b.av"),raw.dn = TRUE,filter = "max",plot = T)
#
filtered.VI_tree1<-convert(filtered.VI_tree1) #convert zoo to data.frame
filtered.VI_tree2<-convert(filtered.VI_tree2)
filtered.VI_tree1<-filtered.VI_tree1 %>%
  mutate(date=doy,doy=NULL)
filtered.VI_tree2<-filtered.VI_tree2 %>%
  mutate(date=doy,doy=NULL)
#---------------------------------
#saving the data
#---------------------------------
# save.path<-"./data/processed_VIs/"
# #original data:
# write.csv(VI.data.merge$tree1,file = paste0(save.path,"ori_tree1_GCC.csv"))
# write.csv(VI.data.merge$tree2,file = paste0(save.path,"ori_tree2_GCC.csv"))
# #filtered data:
# write.csv(filtered.VI_tree1,file = paste0(save.path,"filtered_tree1_GCC.csv"))
# write.csv(filtered.VI_tree2,file = paste0(save.path,"filtered_tree2_GCC.csv"))
#---------------------------------
#(4)plotting
#---------------------------------
save.path<-"./manuscript/figures/"
#
png(file=paste0(save.path,"trees_greenness.png"),width=600,height = 480)
par(fig=c(0,1,0.4,1))
#tree1
plot(VI.data.merge$tree1$date,VI.data.merge$tree1$gi.av,xlab="",
     ylab="GCC",pch=16,col="gray",xaxt="n")
points(filtered.VI_tree1$date,filtered.VI_tree1$max.filtered,
       col="forestgreen",pch=16)
legend("topleft",pch = 16,bty="n",col = c("gray","forestgreen"),
       legend=c("each photo","daily greenness"),y.intersp = 0.8)
text(x=as.POSIXct("2022-08-31"),y=0.32,labels = "tree1")

par(fig=c(0,1,0,0.6),new=T)
#tree2
# png(file=paste0(save.path,"tree2 greenness.png"))
plot(VI.data.merge$tree2$date,VI.data.merge$tree2$gi.av,
     xlab="",ylab="GCC",pch=16,col="gray",xaxt="n")
labels.x=as.POSIXct(c("2021-06-01","2021-09-01","2021-12-01",
                    "2022-06-01","2022-09-01"),tz="UTC")
pos.x<-match(as.Date(labels.x),as.Date(VI.data.merge$tree1$date))
axis(1,at=VI.data.merge$tree1$date[pos.x],
     labels=as.character(labels.x), cex.axis = 1.1,)
points(filtered.VI_tree2$date,filtered.VI_tree2$max.filtered,
       col="forestgreen",pch=16)
legend("topleft",pch = 16,bty="n",col = c("gray","forestgreen"),
       legend=c("each photo","daily greenness"),y.intersp = 0.8)
text(x=as.POSIXct("2022-08-31"),y=0.32,labels = "tree2")
dev.off()


