# Installations
## apt-get install libssl-dev
## install.packages('httr')
## install.packages('acs')

# load httr namespace

library(httr)

# define the api host, path and query

host <- 'https://api.census.gov'
path <- '/data/2015/acs5'
query <- list('get' = 'NAME,AIANHH',
              'for' = 'county',
              'in' = 'state:24')
response <- GET(url = host, path = path, query = query)

# get a household income variable for tracts in MD
## http://api.census.gov/data/2015/acs5/variables/B19001_001E.json

query <- list('get' = 'NAME,B19001_001E',
              'for' = 'tract:*',
              'in' = 'state:24')
response <- GET(url = host, path = path, query = query)

# check the status

http_status(response)

# wrestle response into a data frame

parsed <- content(response, 'parsed')
content <- matrix(unlist(parsed), ncol = 5, byrow = TRUE)
df <- data.frame(content[-1,], stringsAsFactors=FALSE)
names(df) <- content[1,]
df$B19001_001E <- as.numeric(df$B19001_001E)

# the "acs" package for R

library(acs)
api.key.install(key='0b884613943d0a01a21d1d55d2e1e9011bb8c1a7')

geo <- geo.make(state='MD', county = '*', tract = '*')
result <- acs.fetch(endyear = 2015, geo = geo, table.number = "B19001")

# wrestle response into a data frame

df_geo <- data.frame(result@geography)
df_est <- data.frame(result@estimate)
df <- cbind(df_geo, df_est)

# visualize data
library(ggplot2)

ggplot(df, aes(x = factor(county), y = B19001_001)) +
  geom_boxplot()
