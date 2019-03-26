# read export quality file and diversification index file and then merge
expquality <- read.csv("C:/Users/HZhang2/Desktop/APD/Export_Diversification/ExportQuality.csv", check.names = FALSE)
exp_q<- melt(expquality,id=c("cty","ID")) #from the reshape package
colnames(exp_q)[3] <- "year"
exp_q1<- reshape(exp_q,idvar=c("cty","year"), timevar= "ID", direction = "wide")
diversification_index <- read.csv("C:/Users/HZhang2/Desktop/APD/Export_Diversification/DiversificationIndex.csv")
m1 <- merge(exp_q1,diversification_index, by = c("cty","year"), all = TRUE)

#read GDP diversification file
diversification<-read.csv("C:/Users/HZhang2/Desktop/APD/R-programing/diversification3.csv")
m2 <- merge(m1, diversification, by = c("cty","year"), all = TRUE)
head(m2)

#read ND database
ND <- read.csv("//DATA2/APD/Data/PIU/Natural_Disaster_Database/Irene_results/Codes/ND_database.csv")
master <- merge(ND, m2, by = c("cty","year"), all = TRUE)
master2<-master[!(is.na(master$year)),]
write.csv(master2, file = "masterfileV1.csv")