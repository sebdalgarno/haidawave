hgfetch <- read.csv('~/Google_drive/Data/wave_exposure/Vector_fetch/txt_files/fetch_calcs/haidagwaii-fetch-5.csv')
hg.fetch <- subset(hgfetch, PointID < 200)
sp.fetch=convert_proj(hgfetch, data.x="Long", data.y = "Lat", data.CRS="+init=epsg:3005", new.CRS="+init=epsg:3005")
weights <- wind_weights(cumshewa_wind)
sp.shzn=convert_proj(shzn.sites,data.x="LON",data.y="LAT")

colnames(sp.fetch@data)[colnames(sp.fetch@data) == fetch.distance] <- 'd'

sp.fetch@data[,'d'][sp.fetch@data[,'d']>max.distance]=max.distance

tree.wind <- createTree(coordinates(weights))

index.wind <- knnLookup(tree.wind, newdat=coordinates(sp.fetch), k=1)

fetch@data %<>% mutate(Station = weights@data[index.wind[,1], wind.station])

sp.fetch$id <- paste(sp.fetch[,'Station'], sp.fetch[,'Bearing'], sep=':')

weights %<>% mutate(Bearing = round(Bearing, -1))

weights$id <- paste(wind.weights.data[,'Station'], weights[,'Bearing'], sep=':')

m1 <-  match(sp.fetch$id, weights$id)

m2 <-  which(!is.na(m1))

sp.fetch$Weights[m2] <- weights$Weights[m1[!is.na(m1)]]

sp.fetch %<>% mutate(weight.dist = Distance*Weights)

colnames(sp.fetch@coords) <- c("Long", "Lat")

fetch <- as.data.frame(sp.fetch)

fetch %<>% ddply('PointID', summarize, windfetch = sum(d), Long = min(Long), Lat = min(Lat))

coordinates(fetch) <- c("Long", "Lat")
proj4string(fetch) <- sp.fetch@proj4string

tree <- createTree(coordinates(fetch))

index <- knnLookup(tree, newdat=coordinates(sp.shzn), k=1)

sp.shzn@data %<>% mutate(windfetch = fetch@data[index[,1], 'windfetch'])
