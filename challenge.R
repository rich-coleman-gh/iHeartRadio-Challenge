library(ggplot2)
library(sqldf)

# NOTE: excel truncates profile_id values. we need to load data in directly from raw files!
dfListens <- read.table("C:/Users/rcoleman/Documents/GitHub/iHeartRadio-Challenge/iHeartRadio datasets/listens.tsv",sep="",header=TRUE)

dfArtists <- read.csv("C:/Users/rcoleman/Documents/GitHub/iHeartRadio-Challenge/iHeartRadio datasets/artist.csv")

dfUsers <- read.table("C:/Users/rcoleman/Documents/GitHub/iHeartRadio-Challenge/iHeartRadio datasets/users.tsv",sep="",header=TRUE)

#####################################Question 1#######################################
totalListeners <- sqldf("select count(distinct profile_id) as total_listeners from dfUsers")

activeListeners <- sqldf("select count(distinct profile_id) as total_listeners from dfListens")

######################################Question 2#######################################

dfActiveListeners <- merge(dfListens,dfUsers,by="profile_id")

activeListenerAge <- sqldf("select avg(age) as avg_age from dfActiveListeners where age != 'NA'")

# left join all users with active users
dfInactiveListenersTemp <- merge(dfUsers,dfListens,by="profile_id",all.x = TRUE)

# filter out active users leaving us with only inactive users
dfInactiveListeners <- sqldf("select * from dfInactiveListenersTemp where listen_date is null")

# verify no duplicate users
sqldf("select count(*), count(distinct profile_id) from dfInactiveListeners")

inactiveListenerAge <- sqldf("select avg(age) as avg_age from dfInactiveListeners where age != 'NA'")

# statistical differences among populations
# NOTE: what level of detail do we want to show the differences between these two populations? perhaps distribution?
summary(dfActiveListeners$age)
sqldf("select count(*) from dfActiveListeners")

summary(dfInactiveListeners$age)
sqldf("select count(*) from dfInactiveListeners")
