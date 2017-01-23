library(rgdal)
library(sp)
library(rgeos)
library(plyr)
library(dplyr)
library(magrittr)
library(datacheckr)

setwd("~/Google_Drive/Data")

### load fetch data
hgfetch=read.csv('wave_exposure/Vector_fetch/txt_files/fetch_calcs/haida.gwaii.fetch.5.csv')
### load wind data
hgwind=read.csv('wave_exposure/wind/windhg.1216.csv')
### load sample site data
shzn.sites=read.csv('wave_exposure/Vector_fetch/txt_files/sample_sites/SHZN_grndstn.csv')
### more manageable datasets for testing functions
fetred <- hgfetch[sample(nrow(hgfetch),50000),]
winred <- hgwind[sample(nrow(hgwind),50000),]

### 5 functions comprising R package "..."
# ConvertProj - takes any data with coordinates and converts to SpatialPointsDataFrame Class Object (sp) of user-defined projection.
              # default converts lon/lat (WGS84) to BC Albers
              # option to keep original lat/lon columns, option to not convert to SpatialPointsDataFrame
# NearestPt   - Find nearest point and distance to that point from any two sets of point data (must be SpatialPointsDataFrame and identical projection)
# SumFetch    - Takes site data and fetch data (downloaded Haida Gwaii data, or any data with columns providing values of fetch distance at each line)
              # finds nearest fetch data point and calculates summed fetch from all sites
              # user sets any maximum distance
              # note that NearestPt does not need to be run first
# WindWeights - takes wind data (downloaded Haida Gwaii 2012-2016, or any wind data in same format) - calculates proportion of time that inwd blows in each direction
              # user may define which years, which months and which stations to calculate weights matrix
# WindFetch   - Takes site data and fetch data (downloaded Haida Gwaii data, or any data with columns providing values of fetch distance at each line)
              # weights fetch lines according to weights from nearest wind.station and calculates summed fetch
              # user sets any maximum distance,
              # if user wants to limit weighting to one or several but not all wind stations, this may be defined in the WindWeights function

### ConvertProj
ConvertProj=function(data, data.x="lon", data.y="lat", data.CRS="+init=epsg:4326", new.CRS="+init=epsg:3005", keep=FALSE, SpatialPointsDataFrame=TRUE) {
  if(class(data)=="SpatialPointsDataFrame")
    warning('Data is already a SpatialPointsDataFrame. Check that the coordinates were not already converted to a different CRS.')
  data=as.data.frame(data)
  if(keep==FALSE) {
    coordinates(data) <- c(data.x, data.y)
    proj4string(data) <- CRS(data.CRS)
    results <- spTransform(data, new.CRS)
  }
  if(keep==TRUE) {
    sp.data <- data
    coordinates(sp.data) <- c(data.x, data.y)
    proj4string(sp.data) <- CRS(data.CRS)
    sp.results <- spTransform(sp.data, new.CRS)
    results <- merge(sp.results,data)
  }
  if(SpatialPointsDataFrame==FALSE) {
    results <- data.frame(results)
  }
  return(results)
}

# example
sp.shzn=ConvertProj(shzn.sites,data.x="LON",data.y="LAT")
sp.wind=ConvertProj(hgwind)
sp.fetch=ConvertProj(hgfetch, data.CRS="+init=epsg:3005", new.CRS="+init=epsg:3005")

### NearestPt
NearestPt=function(site.data, point.data, pointID="pointID") {
  if(class(site.data)!="SpatialPointsDataFrame"|class(point.data)!="SpatialPointsDataFrame")
    stop('data sets must be SpatialPointsDataFrame! Use convert function first.')
  if(identical(site.data@proj4string,point.data@proj4string)==FALSE)
    stop('data sets must have same projection! Use convert function first.')
  # extract only points with unique coordinates
  point.unique <- remove.duplicates(point.data)
  # find nearest point, distance to point and add to site.data
  site.data$nearest <- point.unique[apply(gDistance(point.unique,site.data,byid=TRUE),1,which.min),pointID]@data
  site.data$distance.to.nearest <- round(apply(gDistance(point.unique,site.data,byid=TRUE),1,min),1)
  return(site.data)
}

# example
ptm <- proc.time()
nearest.wind=NearestPt(sp.shzn,sp.wind, pointID="wind.station")
proc.time() - ptm
View(nearest.wind)
nearest.fetch=NearestPt(nearest.wind, sp.fetch)
View(nearest.fetch)


### SumFetch
SumFetch=function(site.data, fetch.data, fetch.cols=3:74, max.distance=650000, SpatialPointsDataFrame=TRUE) {
  if (class(site.data)!="SpatialPointsDataFrame"|class(fetch.data)!="SpatialPointsDataFrame")
    stop('data sets must be SpatialPointsDataFrame! Use convert function first.')
  if (identical(site.data@proj4string,fetch.data@proj4string)==FALSE)
    stop('data sets must have same projection! Use convert function first.')
  if (SpatialPointsDataFrame==TRUE) {
    # set max fetch distance
    fetch.data@data[,fetch.cols][fetch.data@data[,fetch.cols]=="Inf"|fetch.data@data[,fetch.cols]>max.distance]=max.distance
    # find nearest point, add fetchlines, find sum
    site.data$sumfetch <- rowSums(fetch.data[apply(gDistance(fetch.data,site.data,byid=TRUE),1,which.min),fetch.cols]@data)
    return(site.data)
  }
  if (SpatialPointsDataFrame==FALSE) {
    site.data <- as.data.frame(site.data)
    return(site.data)
  }
}

# example
ptm <- proc.time()
fetch.sites <- SumFetch(sp.shzn, sp.fetch, 650000)
proc.time() - ptm


### WindWeights
Windweights <- function(site.data, wind.data, years=2012:2016, months=1:12, station="all") {
  if (class(site.data)!="SpatialPointsDataFrame"|class(wind.data)!="SpatialPointsDataFrame")
    stop('data sets must be SpatialPointsDataFrame! Use convert function first.')
  if (identical(site.data@proj4string,wind.data@proj4string)==FALSE)
    stop('data sets must have same CRS! Use convert function first.')
  # remove rows with missing values
  na.index <- unique(as.data.frame(which(is.na(wind.data@data),arr.ind=TRUE)))[1]
  wind.narm <- wind.data[-na.index[,1],]
  # calculate wind weighting
  # subset years
  wind.ly <- list()
  for (i in years)
  {
    wind.ly[[i]] <- subset(wind.narm, year==i)
    wind.y <- ldply(wind.ly, as.data.frame)
  }
  # subset months
  wind.lm <- list()
  for (i in months)
  {
    wind.lm[[i]] <- subset(wind.y, month==i)
    wind.ym <- ldply(wind.lm, as.data.frame)
  }
  wind.ym$dum <- 1
  # calculate weights
  wind.weight <- list()
  wind.total <- list()
  wind.t <- list()
  for (i in sort(unique(wind.ym$wind.station)))
  {
    wind.weight[[i]] <- subset(wind.ym, wind.station==i)
    wind.total[[i]] <- nrow(wind.weight[[i]])
    wind.weight[[i]] <- ddply(wind.weight[[i]], .(windir), summarize, total=sum(dum))
    wind.weight[[i]]$prop <- wind.weight[[i]]$total/wind.total[[i]]
    wind.t[[i]] <- transform(t(wind.weight[[i]]))[3,]
  }
  df.wt <- ldply(wind.t, data.frame)
  # add coordinates
  df.wt$lon[df.wt[,1]=="Langara"]=-133.06
  df.wt$lat[df.wt[,1]=="Langara"]=54.26
  df.wt$lon[df.wt[,1]=="Rose Point"]=-131.66
  df.wt$lat[df.wt[,1]=="Rose Point"]=54.16
  df.wt$lon[df.wt[,1]=="Cumshewa"]=-131.6
  df.wt$lat[df.wt[,1]=="Cumshewa"]=53.03
  df.wt$lon[df.wt[,1]=="Kindakun Rocks"]=-132.77
  df.wt$lat[df.wt[,1]=="Kindakun Rocks"]=53.32
  df.wt$lon[df.wt[,1]=="Sandspit"]=-131.81
  df.wt$lat[df.wt[,1]=="Sandspit"]=53.25
  df.wt$lon[df.wt[,1]=="Masset"]=-132.13
  df.wt$lat[df.wt[,1]=="Masset"]=54.03
  df.wt$lon[df.wt[,1]=="Cape St James"]=-131.02
  df.wt$lat[df.wt[,1]=="Cape St James"]=51.94
  colnames(df.wt) <- c("wind.station", colnames(df.wt[2:39]))
  coordinates(df.wt) <- c("lon","lat")
  proj4string(df.wt) <- CRS("+init=epsg:4326")
  df.wt.trans <- spTransform(df.wt, site.data@proj4string)
  if (station[1]=="all") {
    return(df.wt.trans)
  }
  if (station[1]!="all") {
    return(subset(df.wt.trans, (wind.station %in% station)))
  }
}

# example
wind.weights <- Windweights(sp.shzn, sp.wind)
wind2 <- Windweights(sp.shzn, sp.wind, station=c("Cumshewa","Langara"))
wind3 <- Windweights(sp.shzn, sp.wind, years=2014:2016, months=9:12, station=c("Cumshewa","Langara"))

### WindFetch
WindFetch=function(site.data, fetch.data, wind.weights, fetch.cols=3:74,  max.distance=650000) {
  if (class(site.data)!="SpatialPointsDataFrame"|class(fetch.data)!="SpatialPointsDataFrame"|class(wind.weights)!="SpatialPointsDataFrame")
    stop('data sets must be SpatialPointsDataFrame! Use convert function first.')
  if (identical(site.data@proj4string,fetch.data@proj4string)==FALSE|identical(fetch.data@proj4string,wind.weights@proj4string)==FALSE)
    stop('data sets must have same CRS! Use convert function first.')
  # create fetch props for fetch lines in-between wind measurements (probably a more efficient way to do this?)
  wind.weights@data$X1.5 <- (wind.weights@data[,2]+wind.weights@data[,3])/2
  wind.weights@data$X2.5 <- (wind.weights@data[,3]+wind.weights@data[,4])/2
  wind.weights@data$X3.5 <- (wind.weights@data[,4]+wind.weights@data[,5])/2
  wind.weights@data$X4.5 <- (wind.weights@data[,5]+wind.weights@data[,6])/2
  wind.weights@data$X5.5 <- (wind.weights@data[,6]+wind.weights@data[,7])/2
  wind.weights@data$X6.5 <- (wind.weights@data[,7]+wind.weights@data[,8])/2
  wind.weights@data$X7.5 <- (wind.weights@data[,8]+wind.weights@data[,9])/2
  wind.weights@data$X8.5 <- (wind.weights@data[,9]+wind.weights@data[,10])/2
  wind.weights@data$X9.5 <- (wind.weights@data[,10]+wind.weights@data[,11])/2
  wind.weights@data$X10.5 <- (wind.weights@data[,11]+wind.weights@data[,12])/2
  wind.weights@data$X11.5 <- (wind.weights@data[,12]+wind.weights@data[,13])/2
  wind.weights@data$X12.5 <- (wind.weights@data[,13]+wind.weights@data[,14])/2
  wind.weights@data$X13.5 <- (wind.weights@data[,14]+wind.weights@data[,15])/2
  wind.weights@data$X14.5 <- (wind.weights@data[,15]+wind.weights@data[,16])/2
  wind.weights@data$X15.5 <- (wind.weights@data[,16]+wind.weights@data[,17])/2
  wind.weights@data$X16.5 <- (wind.weights@data[,17]+wind.weights@data[,18])/2
  wind.weights@data$X17.5 <- (wind.weights@data[,18]+wind.weights@data[,19])/2
  wind.weights@data$X18.5 <- (wind.weights@data[,19]+wind.weights@data[,20])/2
  wind.weights@data$X19.5 <- (wind.weights@data[,20]+wind.weights@data[,21])/2
  wind.weights@data$X20.5 <- (wind.weights@data[,21]+wind.weights@data[,22])/2
  wind.weights@data$X21.5 <- (wind.weights@data[,22]+wind.weights@data[,23])/2
  wind.weights@data$X22.5 <- (wind.weights@data[,23]+wind.weights@data[,24])/2
  wind.weights@data$X23.5 <- (wind.weights@data[,24]+wind.weights@data[,25])/2
  wind.weights@data$X24.5 <- (wind.weights@data[,25]+wind.weights@data[,26])/2
  wind.weights@data$X25.5 <- (wind.weights@data[,26]+wind.weights@data[,27])/2
  wind.weights@data$X26.5 <- (wind.weights@data[,27]+wind.weights@data[,28])/2
  wind.weights@data$X27.5 <- (wind.weights@data[,28]+wind.weights@data[,29])/2
  wind.weights@data$X28.5 <- (wind.weights@data[,29]+wind.weights@data[,30])/2
  wind.weights@data$X29.5 <- (wind.weights@data[,30]+wind.weights@data[,31])/2
  wind.weights@data$X30.5 <- (wind.weights@data[,31]+wind.weights@data[,32])/2
  wind.weights@data$X31.5 <- (wind.weights@data[,32]+wind.weights@data[,33])/2
  wind.weights@data$X32.5 <- (wind.weights@data[,33]+wind.weights@data[,34])/2
  wind.weights@data$X33.5 <- (wind.weights@data[,34]+wind.weights@data[,35])/2
  wind.weights@data$X34.5 <- (wind.weights@data[,35]+wind.weights@data[,36])/2
  wind.weights@data$X35.5 <- (wind.weights@data[,36]+wind.weights@data[,37])/2
  wind.weights@data$X36.5 <- (wind.weights@data[,37]+wind.weights@data[,2])/2
  wind.weights <- wind.weights[,c(1,2,38,3,39,4,40,5,41,6,42,7,43,8,44,
                                  9,45,10,46,11,47,12,48,13,49,14,50,15,
                                  51,16,52,17,53,18,54,19,55,20,56,21,57,
                                  22,58,23,59,24,60,25,61,26,62,27,63,28,
                                  64,29,65,30,66,31,67,32,68,33,69,34,70,
                                  35,71,36,72,37,73)]
  # find nearest wind station and fetch point
  nearest.station <- wind.weights[(apply(gDistance(wind.weights,sp.shzn, byid = TRUE), 1, which.min)),]
  # find nearest fetch points and add fetch lines
  # set max fetch distance
  fetch.data@data[,fetch.cols][fetch.data@data[,fetch.cols]=="Inf"|fetch.data@data[,fetch.cols]>max.distance]=max.distance
  nearest=fetch.data[(apply(gDistance(fetch.data,site.data, byid = TRUE), 1, which.min)),]
  # calcualte windfetch
  site.data$wind.fetch <- rowSums(nearest[,fetch.cols]@data*nearest.station[,2:73]@data)
  return(site.data)
}

# example
windfetch <- Windfetch(sp.shzn, sp.fetch, wind.weights)


# cehck fetch estimates from function against fetch estimates from original site locations
setwd("~/Google_Drive/Masters/Thesis_Data_Analysis/Fetch_Programs/Fetch_Accuracy (updated)/")
itsite <- read.table('fetch_it_05_01.txt', sep=';', header=TRUE)
itsitexy <- read.table('ITsite_1mrin_xyalbers.txt', sep=';')
itfetch <- merge(itsite, itsitexy, by.x="X", by.y="V1")
coordinates(itfetch)=c("V2", "V3")
proj4string(itfetch)=CRS("+init=epsg:3005")
itfetch@data[,2:73][itfetch@data[,2:73]=="Inf"|itfetch@data[,2:73]>650000]=650000
itfetch$sumfetch=rowSums(itfetch@data[,2:73])

itfetch2 <- SumFetch(itfetch, sp.fetch, 650000)
compare <- as.data.frame(cbind(itfetch2$sumfetch,round(itfetch$sumfetch, 0)))
compare$diff <- compare[,1]-compare[,2]
plot(compare[,1],compare[,2])

