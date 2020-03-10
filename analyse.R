library(ggplot2)
library(reshape2)

filename <- "covid-2020-03-10.csv"

title = "Corona, accumulated cases in different countries"
title = "Corona in the Netherlands"
caption = "(based on data from https://www.ecdc.europa.eu, see https://bit.ly/2TB0UpM)"
xlab = "date"
ylab = "total number of verified infections"

# Countries to select from table
select_countries <- c('NL')

plot_log = 0

data <- data.frame(read.csv(filename, header = TRUE))

data$date <- as.Date(data$DateRep)

# This dataset starts at the last day of 2019
#start_date <- "2019/12/31" 
# Starting Feb. 15th
start_date <- "2020/02/15"
dates <- data.frame(seq(as.Date(start_date), Sys.Date(), "days"));
colnames(dates)[1] <- "date"

country_table <- unique(data[,c("GeoId", "CountryExp")])

country_table$index <- seq.int(nrow(country_table))

#print("Possible country abbreviations")
#print(country_table)

select_countries_indices <- subset(country_table, country_table$GeoId %in% select_countries)$index

selected_countries <- country_table[select_countries_indices,]

print("Selected countries")
print(selected_countries)

geoIds <- array(selected_countries$GeoId)
geoNames <- array(selected_countries$CountryExp)

k <- length(geoIds)

res <- dates

for (i in 1:k) {

	geoId <- geoIds[i]
	geoName <- geoNames[i]

	country_data <- subset(data, data$GeoId==geoId)

	country_data_select <- subset(country_data, select=c("date", "NewConfCases"))

	res <- merge(res, country_data_select, by="date")

	res$temp <-cumsum(res$NewConfCases)

	names(res)[names(res) == "temp"] <- geoName

	res$NewConfCases <- NULL
}

m <- melt(res, id.vars='date', variable.name='country', value.name='cases')

p <- ggplot(m, aes(x = date, y = cases, color = country)) + geom_point(size = 3)

if (plot_log) {
	p <- p + scale_y_continuous(trans='log10')
}

p <- p + labs(title=title, caption=caption, x=xlab, y=ylab)

p <- p + theme(
			   plot.title = element_text(color="black", size=14, face="bold.italic"),
			   axis.title.x = element_text(color="black", size=12, face="bold"),
			   axis.title.y = element_text(color="black", size=12, face="bold"),
			   legend.title = element_text(color="black", size=12, face="bold"),
			   legend.text = element_text(color="black", size=10),
			   legend.position = c(0.1, 0.8),
			   )

plot(p)

ggsave("covid-19.png")
