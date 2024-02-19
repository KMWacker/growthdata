/* Do file that performs the analysis presented in the WBPRWP */

use growthdata_public.dta    /* can be found at: https://github.com/KMWacker/growthdata/blob/main/growthdata_public.dta */

/*************************/
/* Create income dummies */
/*************************/

gen dum_inc_low = 0
gen dum_inc_mid = 0
gen dum_inc_high =0
foreach year of numlist 1/10 {
_pctile rgdpe_pc if period==`year', p(33.333, 66.667)
replace dum_inc_low = 1 if rgdpe_pc <= r(r1) & period==`year'
replace dum_inc_mid = 1 if rgdpe_pc > r(r1) & rgdpe_pc <= r(r2) & period==`year'
replace dum_inc_high = 1 if rgdpe_pc > r(r2) & rgdpe_pc!=. & period==`year'
}
replace dum_inc_low = . if rgdpe_pc==.
replace dum_inc_mid = . if rgdpe_pc==.
replace dum_inc_high =. if rgdpe_pc==.
gen group_income = .
replace group_income = 1 if dum_inc_low == 1
replace group_income = 2 if dum_inc_mid == 1
replace group_income = 3 if dum_inc_high == 1

/***************************/
/* Create regional dummies */
/***************************/

drop NAMES_STD
kountry country, from(other) geo(un)
rename GEO region_un

generate dum_region_africa = 0
generate dum_region_americas = 0
generate dum_region_asia = 0
generate dum_region_europe = 0
replace dum_region_africa = 1 if region_un=="Africa"
replace dum_region_americas = 1 if region_un=="Americas"
replace dum_region_asia = 1 if region_un=="Asia" | region_un=="Oceania"
replace dum_region_europe = 1 if region_un=="Europe"
gen group_region = .
replace group_region = 1 if dum_region_africa == 1
replace group_region = 2 if dum_region_americas == 1
replace group_region = 3 if dum_region_asia == 1
replace group_region = 4 if dum_region_europe == 1

keep if period >= 0 & period <11

/*********************/
/* VARIABLE SETTINGS */
/*********************/

gen lEDI_ipol_sq = lEDI_ipol*lEDI_ipol
gen dltot = d.ltot
gen durbanpop = d.urbanpop
rename infrastructure_index infra_index
gen dgini = d.gini_mkt

global depvar lrgdpna_pc
global explvars lkg lrer ltraderesid lcredit linflation infra_index dltot lEDI_ipol lEDI_ipol_sq lFDIstock_ip actotal dum_finc /*lkg sd_temp*/
*other candidates: emp lphone
global demography lhc /*emp durbanpop*/ dgini
gen lagdependent = L.$depvar

/****************************************************/
/* RUN MIMIMUM MODEL AND PROVIDE SUMMARY STATISTICS */
/****************************************************/

xtreg $depvar lagdependent i.period, fe robust
gen smpl_full = 1 if e(sample) 

sum  lrgdp* lhc lkg lrer ltraderesid lcredit linflation_na infra_index dltot lEDI_ipol lEDI_ipol_sq lFDIstock_ipol actotal dum_fincrisis sd_temperature sd_growth durbanpop remittances dgini agri_valad if smpl_full==1

/*****************************/
/* DIFFERENT POSSIBLE MODELS */
/*****************************/

*small model, almost all observations 1,507
xtreg $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop i.period, fe robust

*medium model 
xtreg $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop lcredit lFDIstock_ipol lEDI_ipol lEDI_ipol_sq actotal i.period, fe robust
gen smpl_med = 1 if e(sample)

*large model 
xtreg $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop lcredit lFDIstock_ipol lEDI_ipol lEDI_ipol_sq actotal lhc dgini i.period, fe robust
gen smpl_large = 1 if e(sample)

*extended model 
xtreg $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop lcredit lFDIstock_ipol lEDI_ipol lEDI_ipol_sq actotal lhc dgini emprate agri_valadded remittances i.period, fe robust
gen smpl_extended = 1 if e(sample) 

/***********************/
/* Group heterogeneity */
/***********************/

*by income group
xtreg $depvar c.(lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop)##i.group_income i.period, fe robust
xtreg $depvar linflation_na infra_index dum_fincrisis sd_temperature durbanpop c.(lagdependent lrer ltraderesid dltot lkg sd_growth)##i.group_income i.period, fe robust
xtreg $depvar c.(lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop lcredit lFDIstock_ipol lEDI_ipol lEDI_ipol_sq actotal lhc dgini)##i.group_income i.period, fe robust

***plots
xtreg $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop i.period if group_income==1, fe robust
estimates store est_lowinc
xtreg $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop i.period if group_income==2, fe robust
estimates store est_midinc
xtreg $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop i.period if group_income==3, fe robust
estimates store est_highinc

coefplot (est_lowinc, label(low income)) (est_midinc, label(middle income)) (est_highinc, label(high income)), keep(lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop) xline(0) graphregion(color(white)) rename(dum_fincrisis=fincrisis infra_index="infra index" sd_growth=sdgrowth sd_temperature="sd(temp)")

*by region
xtreg $depvar c.(lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop)##i.group_region i.period, fe robust
xtreg $depvar lagdependent lrer sd_temperature sd_growth c.(linflation_na ltraderesid infra_index dum_fincrisis dltot lkg durbanpop)##i.group_region i.period, fe robust
xtreg $depvar c.(lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop lcredit lFDIstock_ipol lEDI_ipol lEDI_ipol_sq actotal lhc dgini)##i.group_region i.period, fe robust

***plots
xtreg $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop i.period if group_region==1, fe robust
estimates store est_africa
xtreg $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop i.period if group_region==2, fe robust
estimates store est_america
xtreg $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop i.period if group_region==3, fe robust
estimates store est_asia
xtreg $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop i.period if group_region==4, fe robust
estimates store est_europe

coefplot (est_africa, label(Africa)) (est_america, label(Americas)) (est_asia, label(Asia)) (est_europe, label(Europe)), keep(lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop) xline(0) graphregion(color(white)) rename(dum_fincrisis=fincrisis infra_index="infra index" sd_growth=sdgrowth sd_temperature="sd(temp)")

/************************/
/* Residual diagnostics */
/************************/

*small model
qui regress $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop i.period i.geo
lvr2plot, mlab(geo) graphregion(color(white))
xtreg $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop i.period if iso3!= "AZE" & iso3!= "BIH" & iso3!= "GNQ" & iso3!= "LBR" & iso3!= "TJK" & iso3!= "YEM", fe robust

*large model
qui regress $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop lcredit lFDIstock_ipol lEDI_ipol lEDI_ipol_sq actotal lhc dgini i.period i.geo
lvr2plot, mlab(geo) graphregion(color(white))
xtreg $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop lcredit lFDIstock_ipol lEDI_ipol lEDI_ipol_sq actotal lhc dgini i.period if iso3!="ZWE", fe robust

/************************/
/* Results over periods */
/************************/

xtreg $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop i.period if period != 1 & period !=2, fe robust
xtreg $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop i.period if period != 9 & period !=10, fe robust

xtreg $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop lcredit lFDIstock_ipol lEDI_ipol lEDI_ipol_sq actotal lhc dgini i.period if period != 1 & period !=2, fe robust
xtreg $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop lcredit lFDIstock_ipol lEDI_ipol lEDI_ipol_sq actotal lhc dgini i.period if period != 9 & period !=10, fe robust

/* plot period dummies */
coefplot (est_small, label(small model)) (est_large, label(large model) mcolor(gray) ciopts(color(gray))), keep(*.period) graphregion(color(white))

/******************/
/* GMM estimation */
/******************/

gen period2 = period+2
xtabond2 $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop i.period2, robust arlevel gmm(lagdependent, collapse lag(1 2) eq(level)) gmm(lrer ltraderesid infra_index sd_temperature, collapse lag(1 3) eq(both)) gmm(linflation dum_fincrisis dltot lkg sd_growth durbanpop, lag(1 3) eq(level)) iv(i.period2, eq(level)) twostep
xtabond2 $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop lcredit lFDIstock_ipol lEDI_ipol lEDI_ipol_sq actotal i.period2, robust arlevel gmm(lagdependent, collapse lag(1 2) eq(level)) gmm(lrer ltraderesid infra_index sd_temperature lcredit lFDIstock_ipol lEDI_ipol lEDI_ipol_sq, collapse lag(1 8) eq(both)) gmm(linflation dum_fincrisis dltot lkg sd_growth durbanpop actotal, collapse lag(1 8) eq(level)) iv(i.period2, eq(level))  twostep
xtabond2 $depvar lagdependent linflation_na lrer ltraderesid infra_index dum_fincrisis sd_temperature dltot lkg sd_growth durbanpop lcredit lFDIstock_ipol lEDI_ipol lEDI_ipol_sq actotal lhc dgini i.period2, robust arlevel gmm(lagdependent, collapse lag(1 2) eq(level)) gmm(lrer ltraderesid infra_index sd_temperature lcredit lFDIstock_ipol lEDI_ipol lEDI_ipol_sq lhc, collapse lag(1 6) eq(both)) gmm(linflation dum_fincrisis dltot lkg sd_growth durbanpop actotal dgini, collapse lag(1 6) eq(level)) iv(i.period2, eq(level)) twostep
  
