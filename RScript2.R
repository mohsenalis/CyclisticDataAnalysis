### Cyclistic_Full_Year_Analysis ###

# # # # # # # # # # # # # # # # # # # # # # # 
# Install required packages
# tidyverse for data import and wrangling
# lubridate for date functions
# ggplot for visualization
# # # # # # # # # # # # # # # # # # # # # # #  
install.packages("plyr")                           # Install plyr package
library("plyr")   
install.packages("dplyr")                          # Install dplyr package
library("dplyr")                                   # Load dplyr


library(tidyverse)  #helps wrangle data
library(lubridate)  #helps wrangle date attributes
library(ggplot2)  #helps visualize data
getwd() #displays your working directory
setwd("C:/Case Study/Data")

#=====================
# STEP 1: COLLECT DATA
#=====================
# Upload datasets (csv files) here
q2_2021 <- read_csv("q2_2021.csv")
q3_2021 <- read_csv("q3_2021.csv")
q4_2021 <- read_csv("q4_2021.csv")
q1_2021 <- read_csv("q1_2021.csv")

#====================================================
# STEP 2: WRANGLE DATA AND COMBINE INTO A SINGLE FILE
#====================================================
# Compare column names each of the files
colnames(q3_2021)
colnames(q4_2021)
colnames(q2_2021)
colnames(q1_2021)


# Inspect the dataframes and look for incongruencies
str(q1_2021)
str(q4_2021)
str(q3_2021)
str(q2_2021)


q4_2021$date <- as.Date(q4_2021$started_at)
q3_2021$date <- as.Date(q3_2021$started_at)

q2_2021$date <- as.Date(q2_2021$started_at,format = "%m/%d/%Y")
q1_2021$date <- as.Date(q1_2021$started_at,format = "%m/%d/%Y")


#calculate time difference early



# Add a "ride_length" calculation to all_trips (in seconds)

# There is a problem we will need to fix:
# (1) In the started_at and ended_at column, there are two formats for date fro q1,q2 and q3,q4 respectively. 

q1_2021$ride_length <- difftime((strptime(q1_2021$ended_at, format = "%m/%d/%Y %H:%M")),strptime(q1_2021$started_at, format = "%m/%d/%Y %H:%M"))
q2_2021$ride_length <- difftime((strptime(q2_2021$ended_at, format = "%m/%d/%Y %H:%M")),strptime(q2_2021$started_at, format = "%m/%d/%Y %H:%M"))
q3_2021$ride_length <- difftime((strptime(q3_2021$ended_at, format = "%Y-%m-%d %H:%M:%S")),strptime(q3_2021$started_at, format = "%Y-%m-%d %H:%M:%S"))
q4_2021$ride_length <- difftime((strptime(q4_2021$ended_at, format = "%Y-%m-%d %H:%M:%S")),strptime(q4_2021$started_at, format = "%Y-%m-%d %H:%M:%S"))




# Stack individual quarter's data frames into one big data frame

library(dplyr)
all_trips <- rbind(q1_2021, q2_2021, q3_2021, q4_2021)


# Remove lat, long, birthyear, and gender fields as this data was dropped beginning in 2020
all_trips <- all_trips %>%  
  select(-c(start_lat, start_lng, end_lat, end_lng, start_station_id   ,end_station_name,   end_station_id))

#======================================================
# STEP 3: CLEAN UP AND ADD DATA TO PREPARE FOR ANALYSIS
#======================================================
# Inspect the new table that has been created
colnames(all_trips)  #List of column names
nrow(all_trips)  #How many rows are in data frame?
dim(all_trips)  #Dimensions of the data frame?
head(all_trips)  #See the first 6 rows of data frame.  Also tail(all_trips)
str(all_trips)  #See list of columns and data types (numeric, character, etc)
summary(all_trips)  #Statistical summary of data. Mainly for numerics


 
# Add columns that list the date, month, day, and year of each ride
# This will allow us to aggregate ride data for each month, day, or year ... before completing these operations we could only aggregate at the ride level

all_trips$month <- format(as.Date(all_trips$date), "%m")
all_trips$day <- format(as.Date(all_trips$date), "%d")
all_trips$year <- format(as.Date(all_trips$date), "%Y")
all_trips$day_of_week <- format(as.Date(all_trips$date), "%A")



# Inspect the structure of the columns
str(all_trips)

# Convert "ride_length" from Factor to numeric so we can run calculations on the data
is.factor(all_trips$ride_length)
all_trips$ride_length <- as.numeric(as.character(all_trips$ride_length))
is.numeric(all_trips$ride_length)


# (2) There are some rides where trip duration shows up as negative, including several hundred rides where Divvy took bikes out of circulation for Quality Control reasons. We will want to delete these rides.

all_trips_v1.5 <- all_trips[!(all_trips$start_station_name == "HQ QR" | all_trips$ride_length<0),]





# Remove "bad" data
# The dataframe includes a row which does not contain the date value
# We will create a new version of the dataframe (v2) since data is being removed

all_trips_v2 = na.omit(all_trips_v1.5)

#=====================================
# STEP 4: CONDUCT DESCRIPTIVE ANALYSIS
#=====================================
# Descriptive analysis on ride_length (all figures in seconds)
mean(all_trips_v2$ride_length) #straight average (total ride length / rides)
median(all_trips_v2$ride_length) #midpoint number in the ascending array of ride lengths
max(all_trips_v2$ride_length) #longest ride
min(all_trips_v2$ride_length) #shortest ride

# You can condense the four lines above to one line using summary() on the specific attribute
summary(all_trips_v2$ride_length)

# Compare members and casual users
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = mean)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = median)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = max)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = min)

# See the average ride time by each day for members vs casual users
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)

# Notice that the days of the week are out of order. Let's fix that.
all_trips_v2$day_of_week <- ordered(all_trips_v2$day_of_week, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

# Now, let's run the average ride time by each day for members vs casual users
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)

# analyze ridership data by type and weekday
all_trips_v2 %>% 
  mutate(weekday = day_of_week) %>%  #creates weekday field using wday()
  group_by(member_casual, weekday) %>%  #groups by usertype and weekday
  summarise(number_of_rides = n()							#calculates the number of rides and average duration 
            ,average_duration = mean(ride_length)) %>% 		# calculates the average duration
  arrange(member_casual, weekday)								# sorts

# Let's visualize the number of rides by rider type
all_trips_v2 %>% 
  mutate(weekday = day_of_week) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>% 
  

  ggplot(aes(x = weekday, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") +ggtitle("Number of Rides by Rider Type") + labs(y = "Number of Rides"
      , x = "Day of Week", fill = "Member Type") 
      




# Let's create a visualization for average duration
all_trips_v2 %>% 
  mutate(weekday = day_of_week) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge") +ggtitle("Average Duration of Ride by Rider Type") + labs(y = "Average Duration of Ride (s)"
                                                                                , x = "Day of Week", fill = "Member Type") 

#=================================================
# STEP 5: EXPORT SUMMARY FILE FOR FURTHER ANALYSIS
#=================================================
# Create a csv file that we will visualize in Excel, Tableau, or my presentation software
# N.B.: This file location is for a Mac. If you are working on a PC, change the file location accordingly (most likely "C:\Users\YOUR_USERNAME\Desktop\...") to export the data. You can read more here: https://datatofish.com/export-dataframe-to-csv-in-r/
counts <- aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)
write.csv(counts, file = 'C:///AvgRideTimeforEachDay.csv')

counts <- aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)




