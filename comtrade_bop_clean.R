## Read all csv files with a loop
library(tidyverse)
library(reshape)
setwd("Q:/Data/PIU/Export_Diversification/comtrade/bycountry")
temp = list.files(pattern = "*.csv")
for (i in 1:length(temp)) assign(temp[i],read.csv((temp[i])))

## merge goods and service data
#Goods
goodsdata<- rbind(`1.csv`, `2.csv`, `3.csv`, `4.csv`, `5.csv`, `6.csv`, `7.csv`)
goods<-goodsdata[c(2,10,11,22,32)]
colnames(goods)[4] <- "gcode"
colnames(goods)[5] <- "gvalue"

# BOP service data
bop<-read.csv("//DATA2/APD/Data/PIU/Export_Diversification/data_files/BOP6exp.csv",check.names = "false")
#reshape from short to long
boplong <- bop[-c(1)]%>% 
  melt(id = c("country_code","ISO","sector")) %>%
  reshape(idvar = c("country_code","ISO","variable"),timevar = "sector",direction = "wide")

colnames(boplong)[2:3]<-c("country","Year")

## Reshape goods data from short to long
colnames(goods)[3:5] <- c("country","code","value")
goods1 <-goods[-c(2)] %>%
  cast(Year+country~code, value = "value") %>% #From reshape package
  arrange(country,Year) 

## Merge goods and service data (in long format)
expdata1 <- merge(goods1, boplong, by = c("Year","country"), all = TRUE)
expdata1<- arrange(expdata1,country, Year)

write.csv(expdata1,file = "ssbopg.csv")