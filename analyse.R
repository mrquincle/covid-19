library(ggplot2)
library(reshape2)

filename <- "dataset/covid-2020-03-10.csv"

# Countries to select from table
select_countries <- c('DE','NL','BE','CH','IT','CN','KR')
#select_countries <- c('CN')

plot_log = 1
plot_line = 1
plot_since_zero = 1

since_zero_threshold = 10

title = "Corona, accumulated cases in different countries"
caption = "(based on data from https://www.ecdc.europa.eu, see https://bit.ly/2TB0UpM)"
xlab = "date"
ylab = "total number of verified infections"

# Adjust titles when plotting other things
if ((length(select_countries) == 1) && (select_countries[1] == 'NL')) {
	title = "Corona in the Netherlands"
}
if (plot_since_zero) {
	title = paste("Corona development after day \"zero\" (the first day with more than", since_zero_threshold, "cases)")
	xlab = paste("days after first number of cases exceeding", since_zero_threshold)
}

data <- data.frame(read.csv(filename, header = TRUE))

data$date <- as.Date(data$DateRep)

# This dataset starts at the last day of 2019
first_start_date <- as.Date("2019/12/31")
# Starting Feb. 15th
start_date <- as.Date("2020/02/15")
end_date <- Sys.Date()
dates <- data.frame(seq(start_date, end_date, "days"));
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

days <- as.double(end_date - first_start_date)
since_zero <- data.frame(seq(1, days))
names(since_zero)[1] = "index"

for (i in 1:k) {

	geoId <- geoIds[i]
	geoName <- geoNames[i]

	# Create data for plot with dates
	country_data <- subset(data, data$GeoId==geoId)
	country_data_select <- subset(country_data, select=c("date", "NewConfCases"))
	res <- merge(res, country_data_select, by="date")
	res$temp <-cumsum(res$NewConfCases)
	names(res)[names(res) == "temp"] <- geoName
	res$NewConfCases <- NULL

	# Create data for plot that starts with day zero
	country_data_select <- country_data_select[order(country_data_select$date),]
	country_data_select$temp <-cumsum(country_data_select$NewConfCases)
	country_data_select$NewConfCases <- NULL
	thr <- subset(country_data_select, country_data_select$temp > since_zero_threshold)
	thr$date <- NULL
	thr$index <- seq.int(nrow(thr))
	since_zero <- merge(since_zero, thr, by="index",incomparables=0,all.x=TRUE)
	names(since_zero)[names(since_zero) == "temp"] <- geoName
}

# Only keep rows where we do not have only NA values
since_zero <- since_zero[rowSums(is.na(since_zero))<k,]

if (plot_since_zero) {
	m <- melt(since_zero, id.vars='index', variable.name='country', value.name='cases')
	p <- ggplot(m, aes(x = index, y = cases, color = country)) 
} else {
	m <- melt(res, id.vars='date', variable.name='country', value.name='cases')
	p <- ggplot(m, aes(x = date, y = cases, color = country))
}

if (plot_line) {
	p <- p + geom_line(size = 2)
} else {
	p <- p + geom_point(size = 3)
}

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
