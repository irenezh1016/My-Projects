best<-function(state,outcome){
	
	data<-read.csv("outcome-of-care-measures.csv",colClasses="character")
	
	outcomes<-data[,c(2,7,11,17,23)]


	if(state %in% data$State) {
	} else { stop("invalid state")
	}


	column<- if(outcome %in% "heart attack"){ 3
	} else if(outcome %in% "heart failure"){ 4
	} else if(outcome %in% "pneumonia"){5
	} else { stop("invalid outcome")
	}

	
	##sort_by_column_NA

		outcomes[,column]<-suppressWarnings(as.numeric(outcomes[,column]))
		orderoutcomes<-outcomes[order(outcomes[,column]),]
		orderoutcomes<-orderoutcomes[complete.cases(orderoutcomes[,column]),]
	

	##sort_state

		stateoutcomes<-orderoutcomes[grep(state,orderoutcomes$State),]
		orderstateoutcomes<-stateoutcomes[order(stateoutcomes[,column]),]
		return(as.character(orderstateoutcomes[1,1]))
}
	
