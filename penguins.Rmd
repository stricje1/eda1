---
title: "Simpson's Paradox"
author: "Jeffrey Strickland"
date: "2/22/2022"
output: word_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, message=FALSE, warning=FALSE, fig.width=5, fig.height=4, scipen = 1000000)
```
## Example
Our goal here is to look at a sitation where we can misinterpret data if our EDA is not thorough. We'll see a phenomenon called Yule-Simpson effect or Simpson's Paradox.

Definition. Simpson's Paradox is a phenomenon in probability and statistics, in which a trend appears in several different groups of data but disappears or reverses when these groups are combined.

In other words, the same data set can appear to show opposite trends depending on how it’s grouped.The reason there are different interpretations of the same data, and what is evading our eye is something called the Lurking variable — a conditional variable that can affect our conclusions about the relationship between two variables.

To examine this phenomenon, we'll use a drop-in replacement for the famous iris dataset. The dataset consists of details about three species of penguins, including their culmen length and depth, their flipper length, body mass, and sex. The culmen is essentially the upper ridge of a penguin’s beak, while their wings are called flippers. We'll look at `culmen_length_mm` versus `culmen_depth_mm`.

## MICE Package

There are few missing values in the dataset. Let’s get rid of those. MICE (Multivariate Imputation via Chained Equations) is one of the commonly used package by R users. Creating multiple imputations as compared to a single imputation (such as mean) takes care of uncertainty in missing values.

MICE assumes that the missing data are Missing at Random (MAR), which means that the probability that a value is missing depends only on observed value and can be predicted using them. It imputes data on a variable by variable basis by specifying an imputation model per variable.

### Installe and Load Libraries
```{r}
library(mice)
library(missForest)
library(VIM)
library(ggplot2)
library(readr)
```

### Set working directory is needed and map the path

```{r}
path = getwd()
cat("The working directory is ", path)
```

### Get zip Data from GitHub 
There are two .csv files in penguin.zip
* penguin-size.csv
* penguin_lter.csv

```{r}
filename = "penguins_size.csv"
if (!file.exists(filename)) {
  urlzip <- "https://github.com/stricje1/eda1/raw/main/penguins.zip"
  download.file(urlzip, destfile = "./penguins.zip", method = "curl", extra = "-L")
  unzip ("./penguins.zip", exdir = path )
}
```

### Create dataframe from penguin-size data

```{r}
df1 <- read.csv("penguins_size.csv")
head(df1, 11)
```

### Check for Missing Values

```{r}
head(is.na(df1[,1:5]),8)
```

We already knw there are missing values in the dataset, so let's look at a visual for insight.

### Plot missig data patterns

```{r}
md.pattern(df1, plot = TRUE, rotate.names = TRUE)
mice_plot <- aggr(df1, col=c('navyblue','yellow'),
                  numbers=TRUE, sortVars=TRUE,
                  labels=names(df1), cex.axis=.7,
                  gap=3, ylab=c("Missing data","Pattern"))
```

### Impute missing values
We now use the `mice` package to input missing values. The `mice()` function can impute mixes of continuous, binary, unordered categorical and ordered categorical data. In addition, `mice` can impute continuous two-level data, and maintain consistency between imputations by means of passive imputation. Among the parameters are the `data`, `df1` in this case, `m` or the number of multiple imputations, with the defualt being 5. `maxit` is a scalar giving the number of iterations, with the default being 5. method can be either a single string, or a vector of strings with length `ncol`(data), specifying the univariate imputation method to be used for each column in data. we'll use  `pmm`, predictive mean matching (numeric data). Finally, we'll set the random number `seed` to 500.

```{r}
imputed_Data <- mice(df1, m=5, maxit = 50, method = 'pmm', seed = 500)
summary(imputed_Data)
```

### Check Imputed Dataset
Now that we have imputed missing values, we want to verify that we were successful. The next code chunk shows us the values that replaced the missing rows (4 and 430) for each of the 5 imputations.

```{r}
imputed_Data$imp$culmen_length_mm
```

From the output, we'll select the third imputation values to replace the missing values.

### Get complete data (3rd out of 7)
The `complete()` function takes an object of class `mids`, fills in the missing data, and returns the completed data in a specified format. To repeat, we'll fill in the third imputation (recall that we did `m = 5` imputations.

```{r}
completeData <- complete(imputed_Data,3)
```

### Recheck for missing values
Now we'll reinspect the data for missing values. The output shows there are none.

```{r results='hide'}
is.na(completeData)==0
```

### Create dataframe
Now, we'll create a datframe from the complteData imputed data.

```{r}
df2 <- data.frame(completeData)
```

### Define x and y variables
Here, we'll define the varoables x and y as `culmen_length_mm` and `culmen_depth_mm`, respectively.

```{r}
x <- df2[,3]
y <- df2[,4]
```

### Create scatterplot
Now, we'll generate a scatterplot of the x and y variables, with a line fitted for the data. This plot will show a trend, indicated by the fitted line, of the two plotted variables. It shows that there is a slightly downward trend (negative slope) in the data when considering `culmen_length_mm` versus `culmen_depth_mm` only. This demonstrates Simpson's Paradox.

```{r}
plot(x,y, lwd = 2)
abline(lm(y ~ x, data = df2), col = "red", lwd = 2)
```

### Create Coplot by Species
If we stopped now, we might not understand what the data is trying to tell us as we interrogate it. Plotting `culmen_length_mm` versus `culmen_depth_mm` by the three penguin `species` yields a different insight. Here we can see that the actual trends are slightly positive.

```{r}
require(graphics)
coplot(y~x | as.factor(species), data = df2,
       panel = panel.smooth, rows = 3, lwd = 2)
```
### Conclusion


