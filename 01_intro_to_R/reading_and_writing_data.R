# These are the packages used but also will spell them out in the functions
library(data.table)
library(readxl)
library(writexl)

## First, to ensure everybody can follow along, read in some data available with base R
# See available datasets
data()

# Read in data set on orange tree growth
orange_data <- Orange

#### Write data locally -----------

## As a csv file
data.table::fwrite(orange_data, "1_intro_to_r_rstudio/orange_data.csv")

## As an excel file
writexl::write_xlsx(orange_data, "1_intro_to_r_rstudio/orange_data.xlsx")

#### Read data locally -----------

# From a csv file
data.table::fread("1_intro_to_r_rstudio/orange_data.csv")
orange_data_csv <- data.table::fread("1_intro_to_r_rstudio/orange_data.csv")

# From an excel file
orange_data_excel <- readxl::read_excel("1_intro_to_r_rstudio/orange_data.xlsx")

#### Only using base packages ----------
# This is a slower, particularly with large data
# But can be useful if you want to avoid loading additional packages

write.csv(orange_data, "1_intro_to_r_rstudio/orange_data_base.csv", row.names = FALSE)
read.csv("1_intro_to_r_rstudio/orange_data_base.csv")


