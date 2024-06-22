#-----   IMPORT DATA

if(!file.exists("D:/EPConsumption")){dir.create("D:/EPConsumption")}

fileUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
download.file(fileUrl,destfile = "D:/Education/R/Data/EPConsumption/zipped.zip", method = "curl")

# Let's see how many files are in the folder
unzip("D:/EPConsumption/zipped.zip", list=TRUE)

# Set the time we imported the data
dateDownloaded <- date()

# Unzip folder into a new folder "unzipped"
unzip("D:/EPConsumption/zipped.zip",exdir = "D:/EPConsumption/unzipped")

#---------   LOAD DATA

#Filter then extract header first, then extract data
con <- file("D:/EPConsumption/unzipped/household_power_consumption.txt")
open(con)
header <- read.table(con, nrow=1, sep = ";")
datain <- read.table(con, skip = 65000, nrow=50000, sep = ";")
datain3 <- read.table(con, skip = 65000, nrow=50000, sep = ";", na.strings="?")
close(con)


# ------ CLEAN DATA

# Load dplyr before using mutate and lubridate before converting dates/time
library(dplyr)
library(lubridate)

# Name all columns with the header 
colnames(datain) <- header

# Convert date column from char to date and Time column to HMS and the rest to numeric
datain1 <- datain |> mutate(Date =dmy(Date))
datain1 <- datain1 |> mutate(Time = hms(Time))
datain1 <- datain1 |> mutate(across(Global_active_power:Sub_metering_2, as.numeric))

#  -------  EXTRACT FEBRUARY 2007  (month ==2)
feb_data <- subset(datain1, month(datain1$Date) == 02)


#  -------  EXTRACT 2 DAY PERIOD THURSDAY & FRIDAY
# Extract day of the week into column "DayofWeek" and convert to factor in the event we need to use it
# Extract the day from Date in the month, it'll be an integer

feb_data <- feb_data |> 
        mutate(DayofWeek = as.factor(weekdays(Date)), Day = day(Date))


# Extract data for a two day period as requested in the Case study. Since the first day in 
# February and dataset is Thursday, we will choose the Thursday and Friday the first 2 days

thu_sat <- subset(feb_data, Day <3) 




#-------------PLOT 2  SAVE TO PNG
png(filename = "/plot2.png", width = 480, height = 480, units = "px")
plot(thu_sat$Global_active_power,
     type = "l",
     ylab ="Global Active Power (kilowatts)",
     xlab = "",
     xaxt="n")
axis(1, at=seq(1,4320, by =4320/3), labels=c("Thu","Fri","Sat"))
#4320 is how many minutes are till end of Saturday. In order to place the last tick on the first minute of Sat
#I used the total number of rows for all 3 days 4320 and divided by 3 tick labels
dev.off()