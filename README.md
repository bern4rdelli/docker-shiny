# docker-shiny

Base image for the R shiny server to host the R data apps. Actual dependencies:

```R
install.packages(c('R.cache','ggplot2','plotly','scales','RPostgreSQL', 'R6'), repos='http://cran.us.r-project.org')
```
