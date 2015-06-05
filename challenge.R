library(ggplot2)
library(sqldf)

# NOTE: excel truncates profile_id values. we need to load data in directly from raw files!
dfListens <- read.table("C:/Users/rcoleman/Documents/GitHub/iHeartRadio-Challenge/iHeartRadio datasets/listens.tsv",sep="",header=TRUE)

dfArtists <- read.delim("C:/Users/rcoleman/Documents/GitHub/iHeartRadio-Challenge/iHeartRadio datasets/artists.tsv")

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

########################################Question 3#############################################

colnames(dfListens)[3] <-  "artist_id"

dfTemp <- merge(dfArtists,dfListens,by="artist_id")

dfFinal <- merge(dfTemp,dfUsers,by="profile_id")

top10Both <- sqldf("
select genre 
  ,sum(tracks_listened_to) as total_listens 
from dfFinal 
where genre is not null
group by 1 
order by 2 desc limit 10")

top10Female <- sqldf("
select genre 
  ,sum(tracks_listened_to) as total_listens 
from dfFinal 
where genre is not null and gender='FEMALE'
group by 1 
order by 2 desc limit 10")

top10Male <- sqldf("
select genre 
  ,sum(tracks_listened_to) as total_listens 
from dfFinal 
where genre is not null and gender='MALE'
group by 1 
order by 2 desc limit 10")

dfFinalTop10Both <- merge(dfFinal,top10Both,by="genre")

dfFinalTop10Female <- merge(dfFinal,top10Female,by="genre")
dfFinalTop10Male <- merge(dfFinal,top10Male,by="genre")

genreByGenderBoth <- sqldf("
SELECT genre
	,gender
	,avg(age) AS avg_age
	,sum(tracks_listened_to) AS total_listens
FROM dfFinalTop10Both
GROUP BY 1
	,2
ORDER BY 4 DESC
")

genreByGenderFemale <- sqldf("
SELECT genre
	,avg(age) AS avg_age
	,sum(tracks_listened_to) AS total_listens
FROM dfFinalTop10Female
where gender='FEMALE'
GROUP BY 1
ORDER BY 3 DESC
")

genreByGenderMale <- sqldf("
SELECT genre
	,avg(age) AS avg_age
	,sum(tracks_listened_to) AS total_listens
FROM dfFinalTop10Male
where gender='MALE'
GROUP BY 1
ORDER BY 3 DESC
")

#both gender
ggplot(data=genreByGender,aes(x=genre)) +
  geom_bar(data=subset(genreByGender,gender=="FEMALE"),aes(y=avg_age,fill='FEMALE'),alpha=.5,stat="identity") +
  geom_bar(data=subset(genreByGender,gender=="MALE"),aes(y=avg_age,fill='MALE'),alpha=.5,stat="identity") +
  labs(title="Average Age by Genre (Top 10 Genres Overall)",y="Average Age",x="Top 10 Genres",fill='Gender')

#female
ggplot(data=genreByGenderFemale,aes(x=genre,y=avg_age)) +
  geom_bar(fill="pink",stat="identity") +
  labs(title="Average Age by Genre (Top 10 Genres for Females)",y="Average Age",x="Top 10 Genres")

#male
ggplot(data=genreByGenderMale,aes(x=genre,y=avg_age)) +
  geom_bar(fill="blue",stat="identity") +
  labs(title="Average Age by Genre for Males (Top 10 Genres for Males)",y="Average Age",x="Top 10 Genres")