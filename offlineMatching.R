options(digits=8)

#usage: 
#input: test data, timestamp to start reading from
# ** I will consider the time frame ['start', 'start' + 10 minutes]
#output: I will output in a matrix 1 column all "free taxi drivers" and
	#in another column all "waiting customers" --> indicies of data
#Free taxi drivers: those who completed their trips before 'start'
	#there might be duplicate taxi drivers, I'll only accept the latest
	#completed taxi driver
#Waiting Customers: trips that have not started yet within the given time interval

predictOffline <- function(filename,start,interval=10) {
	data <- read.csv(filename, head=TRUE, sep=",") #reading the csv file
	polylines <- data$POLYLINE # this will grab all the polylines from the data
	polylines <- levels(polylines) #this will contain all the data w/o suffix summary
	coords <- list()
	#matrix(, nrow=length(polylines), ncol=4) #creating the matrix
	# to hold the x/y start/end coordinates
	for (i in 1:length(polylines))
	{
	  str <- strsplit(strsplit(polylines[i],"\\[\\[")[[1]][2],"\\]\\]")[[1]][1] #get rid of start and end brackets
	  arr <- strsplit(str, "\\],\\[")[[1]] #get all coords
	  trip <- list()
	  for (j in 1:length(arr))
	  {
	    x_y_tuple = as.numeric(strsplit(arr[j],",")[[1]])
	    trip <- append(trip,list(x_y_tuple))
	  }
	  coords[[i]] = trip
	}
	
	#sort entire datalist by timestamp
	data <- data[order(data$TIMESTAMP),]
	partition <- getPartitions(data,start,interval)
## for now, return partition. The next step is for each customer and driver, build sorted list of preferences, do bipartite matching
	
}
#Takes DATA in sorted format.
getPartitions <- function(data, start, interval) { #default searches for 10 MINUTE intervals
		
	drivers <- vector()
	customers <- vector()
	numdrivers <- 1
	numcust <- 1
	#GETTING INDICIES OF FREE DRIVERS
	for (i in 1:length(data$TIMESTAMP)) {
	                                      #I add seconds to it's start timestamp to see when it ends (every tick = 15 seconds)
	    if(data$TIMESTAMP[i] < start && (data$TIMESTAMP[i] + (length(coords[[i]])-1)*15) <= start) { #we have a free driver
	        drivers[numdrivers] = i #saving the data index
	        numdrivers <- numdrivers + 1
	    }
	    else if(data$TIMESTAMP[i] >= start && data$TIMESTAMP[i] < (start + interval*60)) #this is an available customer in this time frame
	    {
	        customers[numcust] = i
	        numcust <- numcust + 1
	    }
	}
	#now i have a list of drivers that are free WITH duplicates
	#I want to keep unique driver id's and getting rid of duplicates with earlier time stamps
	#I will remove all duplicate taxi IDs in the following way (as well as keeping the most recent duplicate trip)
	remove <- vector()
	remcnt <- 1
	uniqueid <- vector()
	uniqcnt <- 2
	uniqueid[1] = drivers[length(drivers)]
	#for(i in (length(drivers)-1):1) {#look at all drivers
	    #uni <- TRUE
	    #for(j in 1:length(uniqueid)) {#compare against unique list
	       # if(data$TAXI_ID[i] == data$TAXI_ID[uniqueid[j]]) {#duplicate
	       #     remove[remcnt] = i
	      #      remcnt <- remcnt + 1
	     #       uni <- FALSE
	    #    }
	    #}
	    #if(uni) {#if it was unique, append to uniques
	      #  uniqueid[uniqcnt] = i
	     #   uniqcnt <- uniqcnt + 1
	    #}
	#}
	#drivers <- uniqueid
	
	#i also have a list of all customers in this time period
	dim <- max(length(customers), length(drivers))
	partitions <- matrix(nrow=dim, ncol=2) #col 1 = taxi drivers, col2 = customers
	for(i in 1:dim) {
	    partitions[i,1] = drivers[i]
	    partitions[i,2]= customers[i]
	}
	return(partitions)
	#return all of these indicies, can use it to grab endpoints of all
	#free drivers and customers to create a bipartite matching problem
}

#distance function between two points
#returns the distance between the two points
distance <- function(p1, p2) { #i.e. pass in coords[[somedriver]][[length(coords[[somedriver]])]] for p1 point
                              #pass in coords[[somecustomer]][[1]] for p2 point
    xsq <- (p1[1] - p2[1])^2
    ysq <- (p1[2] - p2[2])^2
    return (sqrt(xsq + ysq))
}

#getMatching -- match waiting customers to free taxi drivers (closer = beter match)
#usage: will return the matching of customers to drivers with the least distance between all pairs
#input:
#coords passed in MUST be first sorted by TIMESTAMP then NORMALIZED (same way it was sorted when used to get drivers/customers)
#partitions is the list of all free drivers/waiting customers that was generated from the previous method
#output: pairs of indices that denote which driver gets paired with which customer
getMatching <- function(coords, partitions) {
  
}