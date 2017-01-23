hgfetch <- read.csv('~/Google_drive/Data/wave_exposure/Vector_fetch/txt_files/fetch_calcs/haidagwaii-fetch-5.csv')
hg.fetch <- subset(hgfetch, PointID < 200)
sp.fetch=convert_proj(hgfetch, data.x="Long", data.y = "Lat", data.CRS="+init=epsg:3005", new.CRS="+init=epsg:3005")
weights <- wind_weights(cumshewa_wind)
sp.shzn=convert_proj(shzn.sites,data.x="LON",data.y="LAT")

colnames(sp.fetch@data)[colnames(sp.fetch@data) == "Distance"] <- 'd'

sp.fetch@data[,'d'][sp.fetch@data[,'d']>300000] = 300000

fetch <- as.data.frame(sp.fetch)

fetch %<>% ddply('PointID', summarize, sumfetch = sum(d), long = min(colnames(sp.fetch@coords[,1])), lat = min(colnames(sp.fetch@coords[,2])))

coordinates(fetch) <- colnames(sp.fetch@coords)
proj4string(fetch) <- sp.fetch@proj4string

tree <- createTree(coordinates(fetch))

index <- knnLookup(tree, newdat=coordinates(site.data), k=1)

site.data@data %<>% mutate(sumfetch = fetch@data[index[,1], 'sumfetch'])

sp.fetch@data %<>% ddply('PointID', summarize, sumfetch = sum(d))

tree <- createTree(coordinates(sp.fetch))

index <- knnLookup(tree, newdat=coordinates(sp.shzn), k=1)

sp.shzn@data %<>% mutate(sumfetch = sp.fetch@data[index[,1], 'sumfetch'])
