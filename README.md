
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mapstatHelpers

<!-- badges: start -->

<!-- badges: end -->

The *mapstatHelpers* package provides a few functions that will help you
import sequencing results obtained with the new workflow at CGE, which
involves file formats such as `.mapstat` and `.refdata`.

## Installation

You need to install the package directly from GitHub using the
`install_github()` function from the `devtools` package. Of course this
means that you might need to install `devtools` first:

``` r
install.packages("devtools")
devtools::install_github("roeder/mapstatHelpers")
```

## Mapstat metadata

Every `.mapstat` file starts with six lines containing information on
the mapping that was performed in order to obtain the results within
that file.

Here is an example header:

    ## method   KMA
    ## version  1.2.8
    ## database ResFinder_20190213
    ## fragmentCount    32955753
    ## date 2019-07-23
    ## command  /home/projects/cge/apps/kma/1.2.8/kma/kma -ipe "/home/projects/cge/analysis/EFFORT/trim/pig/1001-17-001_R1_001.trim.fq.gz" "/home/projects/cge/analysis/EFFORT/trim/pig/1001-17-001_R2_001.trim.fq.gz" -o "/home/projects/cge/analysis/EFFORT/kma_resfinder/2019-07-23_all_EFFORT_with_replicates_merged/ResFinder_20190213/ResFinder_20190213__1001-17-001_R1_001" -t_db /home/databases/metagenomics/kma_db/ResFinder/ResFinder_20190213 -mem_mode -ef -1t1 -cge -shm 1 -t 1 

The package offers functions for importing the mapping metadata of many
`.mapstat` files at once. Use `get_multiple_metadata()` to load the
metadata of all `.mapstat` files in a directory. The function returns a
data frame and prints a summary of the metadata across all samples:

``` r
library(mapstatHelpers)
nice_example_dir <- "~/projects/nice_mapping/mapstat/"
```

``` r
nice_metadata <- get_multiple_metadata(nice_example_dir)
# --------- Mapstat metadata summary ---------
# No. of mapstat files: 548
# Date of mapping:  2019-07-23
# Mapping method(s):    KMA
# Method version(s):    1.2.8
# Database version(s):  ResFinder_20190213
```

You can inspect the data frame containing the imported metadata. Note
that the name of each file is added in the column `sample_id`:

``` r
head(nice_metadata)
# # A tibble: 6 x 7
#   sample_id method method_version db_version total_fragments date      
#   <chr>     <chr>  <chr>          <chr>                <int> <date>    
# 1 ResFinde… KMA    1.2.8          ResFinder…        32955753 2019-07-23
# 2 ResFinde… KMA    1.2.8          ResFinder…        27920183 2019-07-23
# 3 ResFinde… KMA    1.2.8          ResFinder…        32457805 2019-07-23
# 4 ResFinde… KMA    1.2.8          ResFinder…        63412648 2019-07-23
# 5 ResFinde… KMA    1.2.8          ResFinder…        38228707 2019-07-23
# 6 ResFinde… KMA    1.2.8          ResFinder…        60464980 2019-07-23
# # … with 1 more variable: command <chr>
```

An additional warning message is printed if multiple mapping methods,
method versions or database versions are detected:

``` r
problem_example_dir <- "~/projects/problematic_mapping/mapstat/"
```

``` r
problem_metadata <- get_multiple_metadata(problem_example_dir)
# --------- Mapstat metadata summary ---------
# No. of mapstat files: 540
# Date of mapping:  2019-07-24 to 2019-08-30
# Mapping method(s):    KMA
# Method version(s):    1.2.8, 1.2.10b
# Database version(s):  genomic_20190404
# 
# Careful! The following fields have more than one entry:
# method_version
# 
# Consider remapping so that all samples are mapped in the same manner.
```

After importing the metadata table, you can always print the summary
again by using `check_metadata()`:

``` r
check_metadata(problem_metadata)
# --------- Mapstat metadata summary ---------
# No. of mapstat files: 540
# Date of mapping:  2019-07-24 to 2019-08-30
# Mapping method(s):    KMA
# Method version(s):    1.2.8, 1.2.10b
# Database version(s):  genomic_20190404
# 
# Careful! The following fields have more than one entry:
# method_version
# 
# Consider remapping so that all samples are mapped in the same manner.
```

## Importing mapstat files

Once you are happy with the metadata corresponding to all your
`.mapstat` files, you can go ahead and import the actual content,
i.e. the mapping results, using `read_multiple_mapstats()`:

``` r
nice_mapstat_results <- read_multiple_mapstats(nice_example_dir)
head(nice_mapstat_results)
#                                sample_id                       refSequence
# 1 ResFinder_20190213__1001-17-001_R1_001     sul1_15_EF667294 sulphonamide
# 2 ResFinder_20190213__1001-17-001_R1_001 blaOXA-193_1_CP013032 beta-lactam
# 3 ResFinder_20190213__1001-17-001_R1_001  blaIMP-63_1_KX821663 beta-lactam
# 4 ResFinder_20190213__1001-17-001_R1_001   VanG2XY_1_FJ872410 glycopeptide
# 5 ResFinder_20190213__1001-17-001_R1_001      tet(Q)_1_L33696 tetracycline
# 6 ResFinder_20190213__1001-17-001_R1_001    cfr(C)_2_CANB01000378 phenicol
#   readCount fragmentCount mapScoreSum refCoveredPositions refConsensusSum
# 1         9             6         682                 538             538
# 2        41            41         101                 101             101
# 3        28            28          40                  24              23
# 4        56            43        2972                1402            1385
# 5     13500          8164     1243470                1926            1924
# 6        54            48         908                 524             524
#   bpTotal depthVariance nucHighDepthVariance depthMax snpSum insertSum
# 1     682      0.495573                    0        2      0         0
# 2     101      0.113463                    0        1      0         0
# 3      46      0.117604                   22        2      0         1
# 4    3104      2.049606                    0        5     33         0
# 5 1273609  32258.009855                    0     1016   7612        19
# 6     916      1.690881                   35        8      2         0
#   deletionSum
# 1           0
# 2           0
# 3           0
# 4           0
# 5          30
# 6           0
```

## Importing refdata files

Last (and kind of least), the package also allows the import of
`.refdata` files. We use such files for the taxonomic annotation
corresponding to our large genome databases. Import them with
`read_refdata()`:

``` r
genomic_refdata <- read_refdata("~/projects/nice_mapping/genomic_20190404.refdata")
```
