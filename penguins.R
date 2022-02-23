library(ggplot)
library(readr)
path = getwd() 
filename = "penguins.zip"
if (!file.exists(filename)) {
  urlzip <- "https://github.com/stricje1/eda1/penguins.zip"
  download.file(urlzip, destfile = "./penguins.zip" )
  unzip ("./penguins.zip", exdir = path )
}
cat("The working directory is ", path)
