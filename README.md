# growthdata
Panel dataset on correlates of economic growth: 1970-2019

This branch of the "growthdata" package contains the STATA codes and data necessary to reproduce our WBPRWP.

WBPRWP_analysis.do explains what data to load and contains all relevant commands.

Since the "dominance" analysis (for economic relevance) takes several hours (possibly > 1 day) to compile, we have separated those commands in the file WBPRWP_dominance.do

The WBPRWP_relevance files contain key variables/parameters from the dominance analysis and calculated 'standardized beta coefficients', as well as the STATA code lines (in the .xlsx file) to reproduce the scatter plots depicting economic relevance. Also see the code file "Figure1" in this repository for that purpose.
