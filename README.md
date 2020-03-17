# Covid-19

People regretfully do not understand exponential curves so well.

See e.g. [this animation](https://www.youtube.com/watch?v=Kas0tIxDvrg]) by 3blue1brown.

In general:

* it exhibits an exponential curve in any country before taking counter measures;
* propagation can be slowed down considerably by taking counter measures (see China, Singapore).

# Script

Run the R script in R itself

```
source('analyse.R')
```

It will plot a graph and also write it to `covid-19.png`. Adjust e.g. the countries in the variable `select_countries`.

![Covid 19 in the Netherlands](https://github.com/mrquincle/covid-19/raw/master/image/covid-19-nl-2020-03-10.png)

# Data source

https://www.ecdc.europa.eu/en/publications-data/download-todays-data-geographic-distribution-covid-19-cases-worldwide

Transform to `.csv` file with something like:

```
ssconvert COVID-19-geographic-disbtribution-worldwide-2020-03-10.xls covid-2020-03-10.csv
```

There is only relevant data on the first sheet, you can ignore the warning.
