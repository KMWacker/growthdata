# growthdata
Panel dataset on correlates of economic growth: 1970-2019 (version 1.0)

This branch of the "growthdata" repository contains the STATA codes and data necessary to reproduce our WBPRWP.

1_WBPRWP_analysis.do explains what data to load and contains all relevant commands.

Since the "dominance" analysis (for economic relevance) takes several hours (possibly > 1 day) to compile, we have separated those commands in the file 2_WBPRWP_dominance.do

Files with the prefix 3 contain all information for the analysis in section 5.2: The file 3b_WBPRWP_relevance.csv contains the dominance statistics estimated in 2_WBPRWP_dominance.do and the standardized beta coefficients (which are calculated in the Excel file 3a_WBPRWP_relevance.xlsx). Also see the code file "3_Figure1" in this repository.

To see which raw data have been used and how they have been transformed, please see: 0_WBPRWP_datacr.do (which is for documentation only and not necessary for the analysis, which can straight use growthdata_public.dta from this repository).
