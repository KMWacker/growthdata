*The below STATA code produces the dominance statistics underpinning subsection 5.2 of our WBPRWP ("goodness to explain variation in income")
*Note that the following two packages need to be installed first:
ssc install moremata
ssc install domin

*The following commands can then be run on our growthdata_public.dta data (after running 1_WBPRWP_analysis.do),
*noting that those are quite time intensive (expect up to a day for estimation):

*ANOVA that is the basis for the horizontal axis in Figure 1
domin $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop lcredit lFDIstock_ipol actotal, reg(xtreg, fe) sets((i.period) (lEDI_ipol lEDI_ipol_sq))

*ANOVA that is the basis for the horizontal axis in Online Appendix Figure A.1:
domin $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop lcredit lFDIstock_ipol actotal lhc dgini, reg(xtreg, fe) sets((i.period) (lEDI_ipol lEDI_ipol_sq))

*After having estimated those dominance statistics, we put them into the .csv/.xlsx files "3a_WBPRWP_relevance" and run the codes contained in "3_Figure1"
