# Comments on Conceptualizing and Measuring the Exchange of Beauty and Status

This repository contains the code used in my comment (forthcoming) on the [2014 article](http://asr.sagepub.com/content/79/4/575) by Elizabeth McClintock in the *American Sociological Review* entitled "Beauty and Status: The Illusion of Exchange in Partner Selection?" The comment is scheduled to appear in the August 2017 edition of the *ASR*. You can get a pre-print [here](https://osf.io/preprints/socarxiv/5ydxd).

The original data for this analysis are from the [National Longitudinal Study of Adolescent to Adult Health](http://www.cpc.unc.edu/projects/addhealth) (AddHealth). These AddHealth data (specifically the Romantic Pairs subdata) are not available without IRB approval and a contract so I cannot distribute them here, nor can I publish the tables used in the log-linear models because of table cell size restrictions. However, the code in `organizedata.do` will produce the data used for the analysis for individuals with access to both the main AddHealth data and the Romantic Pairs data.

Here is a brief description of each code script:

- `organizedata.do`: This stata script will read in the raw AddHealth data and format it and re-code it for analysis. This script will also run some summary statistics to compare the results to McClintock's original study.
- `runregmodels.do`: This stata script will run the conventional and difference regression models used in the paper.
- `loglinmodels.R`: This R script will run the log-linear (technically, negative binomial) models used in the paper.

In addition, there is a `logs` folder which contains the most recent output from these three scripts.
