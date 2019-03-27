#=============================================================================================
#> required packages to run the codes
install.packages("reshape")
install.packages("tidyverse")
install.packages("ggpubr")
install.packages("randomcoloR")
library(randomcoloR)
library(tidyverse)
library(reshape)
library(dplyr)
library(ggpubr)
library(RColorBrewer)

#> Read data from excel (exported from stata_diversification) and reshape data
diversification<-read.csv("Q:/Data/PIU/Export_Diversification/data_files/diversification3.csv")

div <-diversification[-c(1:2)]
rep_div <- melt(div,id=c("cty","year")) #from the reshape package
# pic<-c("FJI","SLB","TLS","MHL","PLW","TUV","VUT","PNG","TON","KIR","WSM","FSM")

#> sort data by value (biggest first)
rep_div_a <- arrange(rep_div,cty,year,desc(value)) #from tidyverse


#> write a function to apply on split.data

top3<- function(x) {
  t3<- x %>% head(3) #from dplyr
}

#> try to look at the big picture
# ggplot(data=FJI) +
#   geom_col(mapping = aes(x=year,y=value,fill=variable), position="stack")

# Plot every PIC
#split country data based on cty
cty.split <- split(rep_div_a,rep_div_a$cty,drop = FALSE)
#cty.split

#Split country data based on both cty and year
cty.yr.split <- split(rep_div_a,list(rep_div_a$year,rep_div_a$cty),drop=FALSE)
#cty.yr.split

#Apply the top3 function to the splited results
cty.yr.split.results <- lapply(cty.yr.split,top3)
#cty.yr.split.results

# putting the splited results back together for plotting
cty1 <- do.call("rbind",cty.yr.split.results)
cty.plot <- subset(cty1,value!="NA" & value >0 ,select = c(cty,variable,year,value))
#cty.plot

#==================================Plot all PICs=============================================

# Assign a color to each variable

cols = rainbow(21, s = 1, v=1)
names(cols)<-levels(cty.plot$variable)


dis<-distinctColorPalette(k = 21)
names(dis)<-levels(cty.plot$variable)

rancol <- randomColor(count = 21, luminosity = c("bright"))
names(rancol)<-levels(cty.plot$variable)

#Print each chart out
# for(var in unique(cty.plot$cty)) {
#   dev.new()
#   print(ggplot(data=cty.plot[cty.plot$cty == var,]) +
#           geom_col(mapping = aes(x=year,y=value, fill=variable ,colour = "black"), position="stack") +
#           ggtitle(var)+
#           scale_fill_manual(values = cols)+
#           theme_bw())
# }

for(var in unique(cty.plot$cty)) {
  dev.new()
  print(ggplot(data=cty.plot[cty.plot$cty == var,],aes(x=year,y=value, fill=variable)) +
          geom_bar(stat = "identity",colour = "gray", size = 0.01, position="stack") +
          ggtitle(var)+
          scale_fill_manual(values = cols)+
          labs(x = "Year", y="In percent of GDP")+
          theme_bw())
}


#Store each chart in a list
plot_list = list()
for(var in unique(cty.plot$cty)) {
  dev.new()
  p = ggplot(data=cty.plot[cty.plot$cty == var,],aes(x=year,y=value, fill=variable)) +
          geom_bar(stat = "identity",colour = "gray", position="stack") +
          ggtitle(var)+
          scale_fill_manual(values = cols)+
          labs(x = "Year", y="In percent of GDP")+
          theme_bw()
  plot_list[[var]] = p
}

#Save each chart in tiff
for (var in unique(cty.plot$cty)) {
  file_name = paste("pic_plot", var, ".tiff", sep="")
  tiff(file_name,width = 600, height = 480)
  print(plot_list[[var]])
  dev.off()
}

# Save each chart in jpeg
# for (var in unique(cty.plot$cty)) {
#   file_name = paste("pic_plot", var, ".jpeg", sep="")
#   jpeg(file_name,width = 600, height = 480)
#   print(plot_list[[var]])
#   dev.off()
# }
# plot_list

# Arrange charts 4 for a panel
pic1<-ggarrange(plot_list$FJI,plot_list$WSM,plot_list$VUT,plot_list$PLW, ncol=2,nrow = 2)
pic2<-ggarrange(plot_list$MHL,plot_list$TUV,plot_list$FSM,plot_list$KIR, ncol=2,nrow = 2)
pic3<-ggarrange(plot_list$SLB,plot_list$TON,plot_list$TLS,plot_list$PNG, ncol=2,nrow = 2)

# Save each panel as pdf format
pdf("pic_1.pdf",paper='A4r', width = 14, height = 8)
print(pic1)
dev.off()
pdf("pic_2.pdf",paper='A4r', width = 14, height = 8)
print(pic2)
dev.off()
pdf("pic_3.pdf",paper='A4r', width = 14, height = 8)
print(pic3)
dev.off()
