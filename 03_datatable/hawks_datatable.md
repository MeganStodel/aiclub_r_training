Working with data and data.table
================
Megan Stodel
27 May 2020

Let’s look at the hawks data base we used for the `ggplot2` workshop.
With the `data.table` library, we can use `fread()` to read in the csv,
which will be quick and give us a data.table object.

``` r
library(data.table)

hawks <- fread('https://vincentarelbundock.github.io/Rdatasets/csv/Stat2Data/Hawks.csv', 
               select = c('Species', 'Age', 'Sex', 'Wing', 'Weight', 'Tail', 'KeelFat', 'Tarsus', 'Year'))


# View the first five rows
hawks[1:5]
```

    ##    Species Age Sex Wing Weight Tail KeelFat Tarsus Year
    ## 1:      RT   I      385    920  219      NA     NA 1992
    ## 2:      RT   I      376    930  221      NA     NA 1992
    ## 3:      RT   I      381    990  235      NA     NA 1992
    ## 4:      CH   I   F  265    470  220      NA     NA 1992
    ## 5:      SS   I   F  205    170  157      NA     NA 1992

### Missing data

There are a few ways to look for missing data. We can use the `is.na()`
function when filtering by rows, like this:

``` r
hawks[is.na(Weight)]
```

    ##     Species Age Sex Wing Weight Tail KeelFat Tarsus Year
    ##  1:      RT   A      393     NA  238      NA     NA 1992
    ##  2:      RT   I      326     NA  215      NA     NA 1993
    ##  3:      SS   A   F  194     NA  154      NA     NA 1993
    ##  4:      SS   I   F  202     NA  164      NA     NA 1995
    ##  5:      SS   I   M  162     NA  130       1     NA 1997
    ##  6:      RT   I      361     NA  214      NA     NA 1998
    ##  7:      RT   I      271     NA  235       2     NA 1999
    ##  8:      SS   I   F  205     NA  161      NA     NA 1999
    ##  9:      SS   I   F  190     NA  153       2     NA 2000
    ## 10:      RT   A      406     NA  222       2     NA 2000

This shows us rows where Weight has an NA value. You can do this across
all columns with `complete.cases()`, which is from the base stats
package, negating it with a `!` to find incomplete cases:

``` r
hawks[!complete.cases(hawks)]
```

    ##      Species Age Sex Wing Weight Tail KeelFat Tarsus Year
    ##   1:      RT   I      385    920  219      NA     NA 1992
    ##   2:      RT   I      376    930  221      NA     NA 1992
    ##   3:      RT   I      381    990  235      NA     NA 1992
    ##   4:      CH   I   F  265    470  220      NA     NA 1992
    ##   5:      SS   I   F  205    170  157      NA     NA 1992
    ##  ---                                                     
    ## 830:      RT   I      380   1525  224       3     NA 2003
    ## 831:      SS   I   F  190    175  150       4     NA 2003
    ## 832:      RT   I      360    790  211       2     NA 2003
    ## 833:      RT   I      369    860  207       2     NA 2003
    ## 834:      RT   A      199   1290  222       1     NA 2003

OK, there are a LOT of incomplete cases. Looking at the data it seems
likely that KeelFat and Tarsus are full of missing data.

``` r
hawks[is.na(KeelFat), .N]
```

    ## [1] 341

``` r
hawks[is.na(Tarsus), .N]
```

    ## [1] 833

We might decide for our analysis we don’t want to include those
variables if they are that incomplete. There are a couple of ways to get
rid of multiple columns. You can either select a list of the columns you
do want:

``` r
# To save this you would need to assign it to an object
hawks[, .(Species, Age, Sex, Wing, Weight, Tail, Year)]
```

    ##      Species Age Sex Wing Weight Tail Year
    ##   1:      RT   I      385    920  219 1992
    ##   2:      RT   I      376    930  221 1992
    ##   3:      RT   I      381    990  235 1992
    ##   4:      CH   I   F  265    470  220 1992
    ##   5:      SS   I   F  205    170  157 1992
    ##  ---                                      
    ## 904:      RT   I      380   1525  224 2003
    ## 905:      SS   I   F  190    175  150 2003
    ## 906:      RT   I      360    790  211 2003
    ## 907:      RT   I      369    860  207 2003
    ## 908:      RT   A      199   1290  222 2003

Or instead set the columns you want to get rid of to `NULL`::

``` r
hawks[, c("KeelFat", "Tarsus") := NULL]

# No need to reassign
hawks[1:5]
```

    ##    Species Age Sex Wing Weight Tail Year
    ## 1:      RT   I      385    920  219 1992
    ## 2:      RT   I      376    930  221 1992
    ## 3:      RT   I      381    990  235 1992
    ## 4:      CH   I   F  265    470  220 1992
    ## 5:      SS   I   F  205    170  157 1992

Let’s review the incomplete cases again.

``` r
hawks[!complete.cases(hawks)]
```

    ##     Species Age Sex Wing Weight Tail Year
    ##  1:      RT   A      393     NA  238 1992
    ##  2:      RT   I      326     NA  215 1993
    ##  3:      SS   A   F  194     NA  154 1993
    ##  4:      SS   I   F  202     NA  164 1995
    ##  5:      CH   A       NA    480  198 1995
    ##  6:      SS   I   M  162     NA  130 1997
    ##  7:      RT   I      361     NA  214 1998
    ##  8:      RT   I      271     NA  235 1999
    ##  9:      SS   I   F  205     NA  161 1999
    ## 10:      SS   I   F  190     NA  153 2000
    ## 11:      RT   A      406     NA  222 2000

We could probably get rid of those; there are now only 11 out of 908
observations.

``` r
hawks <- hawks[complete.cases(hawks)]
hawks[is.na(Weight)]
```

    ## Empty data.table (0 rows and 7 cols): Species,Age,Sex,Wing,Weight,Tail...

But the very observant will have noticed that there is also missing data
in some of the columns that doesn’t seem to be registering. For example,
the first row of the dataset isn’t in this summary of incomplete cases,
even though it’s missing information on sex.

``` r
hawks[1]
```

    ##    Species Age Sex Wing Weight Tail Year
    ## 1:      RT   I      385    920  219 1992

That’s because the Sex variable isn’t an NA value; it appears to just be
an empty string. Let’s check that by looking at the unique values for
Sex.

``` r
hawks[, unique(Sex)]
```

    ## [1] ""  "F" "M"

As suspected, it’s an empty string rather than an NA value. But how many
are there?

``` r
hawks[, .N, by = Sex]
```

    ##    Sex   N
    ## 1:     570
    ## 2:   F 170
    ## 3:   M 157

Oh dear - hawks with unknown sex make up most of the dataset, so we
can’t really just remove them. For now, we’ll make it a bit more
explicit the data is unknown. Note that we are using `:=` so we don’t
have to reassign the data.table object.

``` r
hawks[Sex == "", Sex := "Unknown"]
hawks[1:5]
```

    ##    Species Age     Sex Wing Weight Tail Year
    ## 1:      RT   I Unknown  385    920  219 1992
    ## 2:      RT   I Unknown  376    930  221 1992
    ## 3:      RT   I Unknown  381    990  235 1992
    ## 4:      CH   I       F  265    470  220 1992
    ## 5:      SS   I       F  205    170  157 1992

We should check the other character columns.

``` r
hawks[, .N, by = Species]
```

    ##    Species   N
    ## 1:      RT 572
    ## 2:      CH  69
    ## 3:      SS 256

``` r
hawks[, .N, by = Age]
```

    ##    Age   N
    ## 1:   I 677
    ## 2:   A 220

Great, both Species and Age are complete columns.

### Changing category values

We saw above how we could change a value by filtering it first. Let’s do
that for the other sex values.

``` r
hawks[Sex == "F", Sex := "Female"]
hawks[Sex == "M", Sex := "Male"]
```

We can then change this to a factor variable, to ensure only these
values can be used.

``` r
hawks[, Sex := factor(Sex, levels = c("Female", "Male", "Unknown"))]
levels(hawks[, Sex])
```

    ## [1] "Female"  "Male"    "Unknown"

And the same for Species, but this time redefining the values after
they’ve become factors so you see both ways.

``` r
hawks[, Species := factor(Species, levels = c("CH", "RT", "SS"))]
levels(hawks$Species) <- c("Cooper's", "Ring-tailed", "Sharp-shinned")

levels(hawks[, Species])
```

    ## [1] "Cooper's"      "Ring-tailed"   "Sharp-shinned"

### Exploring the data

So far we’ve been looking at the data for issues that we want to clean
up, but you can use `data.table` to answer questions you have about the
data too. Here’s an example to find out which species had the most
adults recorded in the year 2000.

``` r
# Filter by year, then count cases while grouping by species and age
age_species_2000 <- hawks[Year == 2000, .(Count = .N), by = .(Species, Age)]
age_species_2000
```

    ##          Species Age Count
    ## 1: Sharp-shinned   I    12
    ## 2:   Ring-tailed   I    62
    ## 3:   Ring-tailed   A    17
    ## 4:      Cooper's   A     4
    ## 5: Sharp-shinned   A    16
    ## 6:      Cooper's   I     4

``` r
# Filter to adults
adult_species_2000 <- age_species_2000[Age == "A"]
adult_species_2000
```

    ##          Species Age Count
    ## 1:   Ring-tailed   A    17
    ## 2:      Cooper's   A     4
    ## 3: Sharp-shinned   A    16

``` r
# Order by count
ordered <- adult_species_2000[order(-Count)]
ordered
```

    ##          Species Age Count
    ## 1:   Ring-tailed   A    17
    ## 2: Sharp-shinned   A    16
    ## 3:      Cooper's   A     4

``` r
# Select the value for the species in the first row
most_adults <- ordered[1, Species]
most_adults
```

    ## [1] Ring-tailed
    ## Levels: Cooper's Ring-tailed Sharp-shinned

See how you can pipe this all together if you
want:

``` r
hawks[Year == 2000, .(Count = .N), by = .(Species, Age)][Age == "A"][order(-Count)][1, Species]
```

    ## [1] Ring-tailed
    ## Levels: Cooper's Ring-tailed Sharp-shinned

### Excercises

1.  Change the Age variable so it is a factor with the levels Immature
    and Adult.
2.  Make a new boolean column that indicates if wing length is more than
    400.
3.  Rename ‘Tail’ to ‘TailLength’.
4.  Which year had the highest mean weight of hawk? (use the `mean()`
    function)
5.  Make every column a character class.
