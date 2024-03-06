* IMPORTANT NOTES!!!!!!!!!
* 1. create a folder on your system where you want the code to run and the data to be compiled
* 2. enter this folder in line 16 of this code
* 3. in this folder, create a sub-directory: WBgrowthdataset
* 4. copy "0a_secondaryfiles.zip" into this `WBgrowthdataset' folder (no need to unzip them)
* 5. If EM-DAT data on natural disasters is desired, it has to be manually downloaded from https://public.emdat.be/ and added to the folder “WBgrowthdataset” (see lines 532 and 538 below). All exhibits can be reproduced without those files.
Delete this line or run code after this line once above notes have been implemented.

/**********************/
/* 1. GLOBAL SETTINGS */
/**********************/
clear
set more off
global path  C:\Users\KMWacker\ownCloud\Documents\Projects\WBgrowth\WBgrowthdataset\reproducibility_package\
cd "$path\WBgrowthdataset"
unzipfile 0a_secondaryfiles.zip

/**************************/
/* 1. INSHEET AND MERGING */
/**************************/
/*******************/
/* Insheet PWT10.0 */
/*******************/
use "https://www.rug.nl/ggdc/docs/pwt100.dta", replace
encode countrycode, gen(ccode)
xtset ccode year
/* HP filter for RER */
gen lxr = ln(xr)
gen rer = (pl_gdpo/xr)
gen lrer = ln(rer)
gen lyear = ln(year)
bys country: ipolate lrer lyear, gen(lrer_ip) epol
tsfilter hp lrer_deviation = lrer_ip, trend(hptrend_lrer)
label var lrer_deviation "Deviation of RER from HP trend"
tsfilter hp lxr_deviation = lxr, trend(hptrend_lxr)
label var lxr_deviation "Deviation of XR from HP trend"
drop if year<1965
drop ccode hptrend* lyear
save "$path\WBgrowthdataset\WBgrowthdata_holder.dta", replace
/****************************/
/* Merge NA module from PWT */
/****************************/
use "https://www.rug.nl/ggdc/docs/pwt100-na-data.dta", replace
gen na_pricelevel_c = v_c/q_c
gen na_govtcons = v_g / v_gdp
gen rer_na = ((v_gdp/q_gdp)/xr)			/* Uses GDP price index. Alternative index (e.g. exports) could be used */
gen traderatio_na = (v_x + v_m)/v_gdp
drop if year<1965
keep countrycode year na_pricelevel_c na_govtcons traderatio_na rer_na
merge 1:1 countrycode year using "$path\WBgrowthdataset\WBgrowthdata_holder.dta"
drop if _merge==1
drop _merge
label var country "Country name as in PWT"
save "$path\WBgrowthdataset\WBgrowthdata_holder.dta", replace
/******************/
/* Merge WDI data */
/******************/
import excel "$path\WBgrowthdataset\WDI_WBgro_May2021.xlsx", clear firstrow
drop TimeCode
drop if Time<1965
rename CountryCode countrycode
rename Time year
rename Foreigndirectinvestmentneti FDI_gdp
rename Droughtsfloodsextremetemper climateextrem
rename Domesticcredittoprivatesecto credit_gdp
rename Inflationconsumerpricesannu inflation
rename Urbanpopulationoftotalpop urbanpop
rename Netbartertermsoftradeindex TOT
rename Populationdensitypeoplepers popdens
rename Fixedtelephonesubscriptionsp infra_com_fixedline
rename Mobilecellularsubscriptionsp infra_com_mobile
rename Fixedbroadbandsubscriptionsp infra_com_broadband
rename SecureInternetserversper1m infra_com_secureinternet
rename Accesstoelectricityofpopu infra_electricaccess
rename IndividualsusingtheInternet infra_com_internet
rename Peopleusingatleastbasicsani infra_health_basicsani
rename Peopleusingsafelymanagedsani infra_health_safesani
rename Hospitalbedsper1000people infra_health_hospitalbeds
rename Physiciansper1000peopleS infra_health_physicians
rename Mediumandhightechexports techexports
rename Hightechnologyexportscurrent hightechexpvalue
rename Manufacturesexportsofmerch man_exportshare
merge 1:1 countrycode year using "$path\WBgrowthdataset\WBgrowthdata_holder.dta"
*from using PWT, only the follow ing countries don't have WDI data: Anguilla (AIA), Monserrat (MSR), Taiwan (TWN)
keep if _merge == 3
drop _merge
drop if country=="Bermuda" /*negative csh_g, pl_gdpo, pos csh_m in 1999-2003*/
save "$path\WBgrowthdataset\WBgrowthdata_holder.dta", replace
clear
/* Remittances (WDI) */
import excel "$path\WBgrowthdataset\WDI_WBgro_remit_agric_addons_June2021.xlsx", clear firstrow
drop TimeCode
drop if Time<1965 | Time==2020
rename CountryCode countrycode
rename Time year
rename Agricultureforestryandfishi agri_valadded
rename Employmentinagricultureof agri_empl
rename Personalremittancesreceived remittances
merge 1:1 countrycode year using "$path\WBgrowthdataset\WBgrowthdata_holder.dta"
tab country if _merge!=3 & year==2015
tab CountryName if country==""
drop if country==""			/* several "country" not included in PWT -- can hence be deleted (alternative: replace country = CountryName if country=="")  */
drop _merge
save "$path\WBgrowthdataset\WBgrowthdata_holder.dta", replace
clear
/* Govt consumption (WDI) */
import excel "$path\WBgrowthdataset\WDI_WBgro_govtcons_addon_Oct2021.xlsx", clear firstrow
drop TimeCode
drop if Time<1965 | Time==2020
rename CountryCode countrycode
rename Time year
rename Generalgovernmentfinalconsump govtcons_wdi
merge 1:1 countrycode year using "$path\WBgrowthdataset\WBgrowthdata_holder.dta"
tab country if _merge!=3 & year==2015
tab CountryName if country==""
drop if country==""			/* several "country" not included in PWT -- can hence be deleted (alternative: replace country = CountryName if country=="")  */
drop _merge
save "$path\WBgrowthdataset\WBgrowthdata_holder.dta", replace
/* Technology variables (WDI) */
import excel "$path\WBgrowthdataset\WDI_WBgro_technologyaddon_March2022.xlsx", clear firstrow
drop TimeCode
drop if Time<1965 | Time==2020
rename CountryCode countrycode
rename Time year
rename Patentapplicationsnonresident tech_patent_nonres
rename Patentapplicationsresidents tech_patent_resident
rename Mediumandhightechexports tech_medhighexp
rename Mediumandhightechmanufacturi tech_medhighexp_vash
rename ICTserviceexportsofservic tech_ictservexp
rename ICTgoodsexportsoftotalgo tech_ictgoodsexp
rename ICTgoodsimportstotalgoods tech_ictgoodsimp
merge 1:1 countrycode year using "$path\WBgrowthdataset\WBgrowthdata_holder.dta"
tab country if _merge!=3 & year==2015
tab CountryName if country==""
drop if country==""			/* several "country" not included in PWT -- can hence be deleted (alternative: replace country = CountryName if country=="")  */
drop _merge
save "$path\WBgrowthdataset\WBgrowthdata_holder.dta", replace
/******************/
/* Merge ECI data */
/******************/
insheet using "$path\WBgrowthdataset\eci_hs6_hs92_95-18.csv", names clear
reshape long yr, i(country) j(year)
rename yr eci
label var eci "Export Complexity Index (OEC)"
drop countryid
replace country = "Viet Nam" if country=="Vietnam"
replace country = "Venezuela (Bolivarian Republic of)" if country=="Venezuela"
replace country = "D.R. of the Congo" if country=="Democratic Republic of the Congo"
replace country = "Bolivia (Plurinational State of)" if country=="Bolivia"
replace country = "Côte d'Ivoire" if country=="Cote d'Ivoire"
replace country = "Congo" if country=="Republic of the Congo"
replace country = "Iran (Islamic Republic of)" if country=="Iran"
replace country = "Lao People's DR" if country=="Laos"
replace country = "Russian Federation" if country=="Russia"
replace country = "Czech Republic" if country=="Czechia"
replace country = "China, Hong Kong SAR" if country=="Hong Kong"
replace country = "Republic of Moldova" if country=="Moldova"
replace country = "Republic of Korea" if country=="South Korea"
replace country = "Syrian Arab Republic" if country=="Syria"
replace country = "U.R. of Tanzania: Mainland" if country=="Tanzania"
merge 1:1 country year using "$path\WBgrowthdataset\WBgrowthdata_holder.dta"
tab country if _merge!=3 & year==2015
drop _merge
save "$path\WBgrowthdataset\WBgrowthdata_holder.dta", replace
/******************/
/* Merge IMF Diversification data */
/******************/
import excel "$path\WBgrowthdataset\IMF_Export_Diversification.xlsx", clear firstrow
drop D F H
rename ExportDiversificationIndex ExpDivIndex
label var ExpDivIndex "IMF Export Diversification Index"
destring year, replace
replace ExpDivIndex = . if ExpDivIndex==0    
replace country = "Afghanistan" if country=="Afghanistan, Islamic Republic of"
replace country = "Armenia" if country=="Armenia, Republic of"
replace country = "Azerbaijan" if country=="Azerbaijan, Republic of"
replace country = "Bahamas" if country=="Bahamas, The"
replace country = "Bahrain" if country=="Bahrain, Kingdom of"
replace country = "Bolivia (Plurinational State of)" if country=="Bolivia"
replace country = "China" if country=="China, P.R.: Mainland"
replace country = "China, Hong Kong SAR" if country=="China, P.R.: Hong Kong" 
replace country = "China, Macao SAR" if country=="China, P.R.: Macao"
replace country = "D.R. of the Congo" if country=="Congo, Democratic Republic of"
replace country = "Congo" if country=="Congo, Republic of"
replace country = "Côte d'Ivoire" if country=="Cote d'Ivoire"
replace country = "Gambia" if country=="Gambia, The"
replace country = "Iran (Islamic Republic of)" if country=="Iran, Islamic Republic of"
replace country = "Republic of Korea" if country=="Korea, Republic of"
replace country = "Kyrgyzstan" if country=="Kyrgyz Republic"
replace country = "Lao People's DR" if country=="Lao People's Democratic Republic"
replace country = "North Korea" if country=="Korea, Democratic People's Rep. of"
replace country = "North Macedonia" if country=="North Macedonia, Republic of"
replace country = "Moldova" if country=="Republic of Moldova"
replace country = "Saint Kitts and Nevis" if country=="St. Kitts and Nevis"
replace country = "Saint Lucia" if country=="St. Lucia"
replace country = "Slovakia" if country=="Slovak Republic"
replace country = "Eswatini" if country=="Swaziland"
replace country = "U.R. of Tanzania: Mainland" if country=="Tanzania"
replace country = "Venezuela (Bolivarian Republic of)" if country=="Venezuela, Republica Bolivariana de"
replace country = "Viet Nam" if country=="Vietnam"
replace country = "Yemen" if country=="Yemen, Republic of"
merge 1:1 country year using "$path\WBgrowthdataset\WBgrowthdata_holder.dta"
drop _merge
save "$path\WBgrowthdataset\WBgrowthdata_holder.dta", replace
/*************************************/
/* Merge UNCTAD diversification data */
/*************************************/
import excel "$path\WBgrowthdataset\UNCTAD_concentdiversindices_81062638549722.xlsx", clear firstrow
destring year, replace
rename Absolutevalue ExpProdNo
label var ExpProdNo "Number of products exported at 3-digit SITC, Rev. 3 level (UNCTAD)"
rename ConcentrationIndex ExpHHI
label var ExpHHI "normalized Herfindahl-Hirschmann Product Index (UNCTAD)"
rename DiversificationIndex ExpDivers
label var ExpDivers "abs dev country's trade structure from world structure (UNCTAD)"
save "$path\WBgrowthdataset\UNCTADmodule.dta", replace
import excel "$path\WBgrowthdataset\UNCTAD_fdiflowsstock_81009535476315.xlsx", clear firstrow
destring yr*, force replace	/* (***) values indicate negative number...could be filled with ipolate as well */
reshape long yr, i(country) j(year)
rename yr FDIstock
label var FDIstock "inward FDI stock as % of GDP (UNCTAD)"
merge 1:1 country year using "$path\WBgrowthdataset\UNCTADmodule.dta"
/* inconsistencies, see: brow if country=="Germany,FederalRepublicof" | country=="Germany" | country=="Czechia" | country=="Czechoslovakia" | country=="Slovakia" */
drop _merge
save "$path\WBgrowthdataset\UNCTADmodule.dta", replace
import excel "$path\WBgrowthdataset\UNCTAD_fdiflowsstock_81009783013659.xlsx", clear firstrow
destring yr*, force replace	/* (***) values indicate negative number...could be filled with ipolate as well */
reshape long yr, i(country) j(year)
rename yr FDIflow_gfc
label var FDIflow_gfc "inward FDI flow as % of GFCF (UNCTAD)"
merge 1:1 country year using "$path\WBgrowthdataset\UNCTADmodule.dta"
drop _merge
replace country = "Bolivia (Plurinational State of)" if country=="Bolivia(PlurinationalStateof)"
replace country = "Bosnia and Herzegovina" if country=="BosniaandHerzegovina"
replace country = "British Virgin Islands" if country=="BritishVirginIslands"
replace country = "Brunei Darussalam" if country=="BruneiDarussalam"
replace country = "Burkina Faso" if country=="BurkinaFaso"
replace country = "Cabo Verde" if country=="CaboVerde"
replace country = "Cayman Islands" if country=="CaymanIslands"
replace country = "Central African Republic" if country=="CentralAfricanRepublic"
replace country = "China, Hong Kong SAR" if country=="China,HongKongSAR"
replace country = "China, Macao SAR" if country=="China,MacaoSAR"
replace country = "D.R. of the Congo" if country=="Congo,Dem.Rep.ofthe"
replace country = "Costa Rica" if country=="CostaRica"
replace country = "Czech Republic" if country=="Czechia"
replace country = "Côte d'Ivoire" if country=="Côted'Ivoire"
replace country = "Dominican Republic" if country=="DominicanRepublic"
replace country = "El Salvador" if country=="ElSalvador"
replace country = "Equatorial Guinea" if country=="EquatorialGuinea"
replace country = "North Korea" if country=="Korea,Dem.People'sRep.of"
replace country = "Iran (Islamic Republic of)" if country=="Iran(IslamicRepublicof)"
replace country = "Lao People's DR" if country=="LaoPeople'sDem.Rep."
replace country = "New Zealand" if country=="NewZealand"
replace country = "North Macedonia" if country=="NorthMacedonia"
replace country = "Republic of Moldova" if country=="Moldova,Republicof"
replace country = "Russian Federation" if country=="RussianFederation"
replace country = "Saint Kitts and Nevis" if country=="SaintKittsandNevis"
replace country = "Sao Tome and Principe" if country=="SaoTomeandPrincipe"
replace country = "Saudi Arabia" if country=="SaudiArabia"
replace country = "South Africa" if country=="SouthAfrica"
replace country = "Sri Lanka" if country=="SriLanka"
replace country = "St. Vincent and the Grenadines" if country=="SaintVincentandtheGrenadines"
replace country = "State of Palestine" if country=="StateofPalestine"
replace country = "Syrian Arab Republic" if country=="SyrianArabRepublic"
replace country = "U.R. of Tanzania: Mainland" if country=="Tanzania,UnitedRepublicof"
replace country = "Trinidad and Tobago" if country=="TrinidadandTobago"
replace country = "Turks and Caicos Islands" if country=="TurksandCaicosIslands"
replace country = "United Arab Emirates" if country=="UnitedArabEmirates"
replace country = "United Kingdom" if country=="UnitedKingdom"
replace country = "United States" if country=="UnitedStatesofAmerica"
replace country = "Venezuela (Bolivarian Republic of)" if country=="Venezuela(BolivarianRep.of)"
replace country = "Viet Nam" if country=="VietNam"
replace country = "Sint Maarten (Dutch part)" if country=="SintMaarten(Dutchpart)"
replace country = "Sierra Leone" if country=="SierraLeone"
replace country = "Saint Lucia" if country=="SaintLucia"
replace country = "Republic of Korea" if country=="Korea,Republicof"
replace country = "Antigua and Barbuda" if country=="AntiguaandBarbuda"
replace country = "South Sudan" if country=="SouthSudan"
replace country = "Papua New Guinea" if country=="PapuaNewGuinea"
save "$path\WBgrowthdataset\UNCTADmodule.dta", replace
merge 1:1 country year using "$path\WBgrowthdataset\WBgrowthdata_holder.dta"
/* fill Ethiopa */
foreach yr of numlist 1970/1991 {
sum FDIflow_gfc if country=="Ethiopia(...1991)" & year==`yr'
replace FDIflow_gfc = r(mean) if country=="Ethiopia" & year==`yr'
}
foreach yr of numlist 1980/1991 {
sum FDIstock if country=="Ethiopia(.1991)" & year==`yr'
replace FDIstock = r(mean) if country=="Ethiopia" & year==`yr'
}
drop if country=="Ethiopia(...1991)" | country=="Ethiopia(.1991)"
/* fill Indonesia */
foreach yr of numlist 1970/2002 {
sum FDIflow_gfc if country=="Indonesia(...2002)" & year==`yr'
replace FDIflow_gfc = r(mean) if country=="Indonesia" & year==`yr'
}
foreach yr of numlist 1980/2002 {
foreach var of varlist FDIstock ExpProdNo ExpHHI ExpDivers {
sum `var' if country=="Indonesia(.2002)" & year==`yr'
replace `var' = r(mean) if country=="Indonesia" & year==`yr'
}
}
drop if country=="Indonesia(...2002)" | country=="Indonesia(.2002)"
/* fill Sudan */
foreach yr of numlist 1970/2011 {
sum FDIflow_gfc if country=="Sudan(...2011)" & year==`yr'
replace FDIflow_gfc = r(mean) if country=="Sudan" & year==`yr'
}
foreach yr of numlist 1980/2011 {
foreach var of varlist FDIstock ExpProdNo ExpHHI ExpDivers {
sum `var' if country=="Sudan(.2011)" & year==`yr'
replace `var' = r(mean) if country=="Sudan" & year==`yr'
}
}
drop if country=="Sudan(...2011)" | country=="Sudan(.2011)"
tab country if _merge!=3 & year==2015
drop _merge
***RENAME for KOUNTRY command
replace country = "Bolivia" if country=="Bolivia (Plurinational State of)"
replace country = "Democratic Republic of Congo" if country=="D.R. of the Congo"
replace country = "Swaziland" if country=="Eswatini"
replace country = "Macedonia" if country=="North Macedonia"
replace country = "Hong Kong" if country=="China, Hong Kong SAR" 
replace country = "Macao" if country=="China, Macao SAR"
replace country = "Taiwan" if country=="China,TaiwanProvinceof"
replace country = "Venezuela" if country=="Venezuela (Bolivarian Republic of)"
replace country = "Cape Verde" if country=="Cabo Verde"
replace country = "French Polynesia" if country=="French Territories: French Polynesia"
replace country = "New Caledonia" if country=="French Territories: New Caledonia"
replace country = "Marshall Islands" if country=="Marshall Islands, Republic of"
replace country = "Tanzania" if country=="U.R. of Tanzania: Mainland"
replace country = "Laos" if country=="Lao People's DR"
replace country = "Micronesia" if country=="Micronesia(FederatedStatesof)"
replace country = "Netherlands Antilles" if country=="NetherlandsAntilles"
replace country = "Curacao" if country=="Curaçao"
replace country = "Cook Islands" if country=="CookIslands"
replace country = "Cote d'Ivoire" if country=="Côte d'Ivoire"
replace country = "American Samoa" if country=="AmericanSamoa"
replace country = "Faeroe Islands" if country=="FaroeIslands"
replace country = "Curacao" if country=="Curaçao"
replace country = "Cook Islands" if country=="CookIslands"
kountry country, from(other)
duplicates tag NAMES year, gen(duplex)	/* NOTE: tags number of duplicates, not if one obs is duplicate! */
tab NAMES if duplex>=1										
										
drop if duplex>=1
drop duplex
save "$path\WBgrowthdataset\WBgrowthdata_holder.dta", replace
/*************************/
/* Polity V Institutions */
/*************************/
import excel "$path\WBgrowthdataset\MEPVv2018.xls", clear firstrow
replace country="Central African Republic" if scode=="CEN"
drop if year < 1965
keep country year inttot civtot actotal
label var inttot "Total summed magnitudes of all interstate MEPV INTTOT = INTVIOL + INTWAR"
label var civtot "Total summed magnitudes of all societal MEPV CIVTOT = CIVVIOL + CIVWAR + ETHVIOL + ETHWAR"
label var actotal "Total summed magnitudes of all (societal and interstate) MEPV ACTOTAL = INTTOT + CIVTOT"
kountry country, from(other) 
replace country="Sudan" if country=="(North) Sudan"
replace NAME="Sudan" if NAME=="north sudan"
merge 1:1 NAME year using "$path\WBgrowthdataset\WBgrowthdata_holder.dta"
drop _merge
save "$path\WBgrowthdataset\WBgrowthdata_holder.dta", replace
/*************************/
/* Banking Crises */
/*************************/
import excel "$path\WBgrowthdataset\Bankingcrises.xlsx", clear firstrow
replace Country="Central African Republic" if Country=="Central African Rep."
replace Country="China" if Country=="China, P.R."
replace Country="Democratic Republic of Congo" if Country=="Congo, Dem. Rep. of"
replace Country="Cote d'Ivoire" if Country=="Côte d'Ivoire"
replace Country="Hong Kong" if Country=="China, P.R.: Hong Kong"
replace Country="Iran" if Country=="Iran, I.R. of"
replace Country="Laos" if Country=="Lao People's Dem. Rep."
replace Country="Sao Tome and Principe" if Country=="São Tomé and Principe"
replace Country="Yugoslavia" if Country=="Yugoslavia, SFR"
kountry Country, from(other) marker
drop if MARKER==0
drop MARKER
merge 1:m NAME using "$path\WBgrowthdataset\WBgrowthdata_holder.dta"
/* note that several countries are NOT part of Laeven and Valencia! */
drop _merge
gen bankingcr = 0
gen currencycr = 0
gen sovdebtcr = 0
gen sovdebtrestr = 0
replace bankingcr = 1 if year==Bankingcrisis1 | year==Bankingcrisis2 | year==Bankingcrisis3 | year==Bankingcrisis4 
replace currencycr = 1 if year==Currencycrisis1 | year==Currencycrisis2 | year==Currencycrisis3 | year==Currencycrisis4 | year==Currencycrisis5 | year==Currencycrisis6 | year==Currencycrisis7
replace sovdebtcr = 1 if year==Sovdebtcrisis1 | year==Sovdebtcrisis2 | year==Sovdebtcrisis3 | year==Sovdebtcrisis4 
replace sovdebtrestr = 1 if year==Sovdebtrestructur1 | year==Sovdebtrestructur2 | year==Sovdebtrestructur3
gen fincrisis = 0
replace fincrisis = 1 if bankingcr==1 | currencycr==1 | sovdebtcr==1
drop Bankingcrisis* Currencycrisis* Sovdebtcrisis* Sovdebtrestructur*
save "$path\WBgrowthdataset\WBgrowthdata_holder.dta", replace
/*************************/
/* SWIID Inequality data */
/*************************/
import delimited "$path\WBgrowthdataset\swiid9_1_summary.csv", clear
drop if year < 1965 | year==2020
replace country = "Congo Brazzaville" if country=="Congo-Brazzaville"
replace country = "Congo Kinshasa" if country=="Congo-Kinshasa"
replace country = "Ivory Coast" if country=="CÃ´te d'Ivoire"
replace country = "Korea South" if country=="Korea"
replace country = "Viet Nam" if country=="Vietnam"
replace country = "Saint Lucia" if country=="St. Lucia"
replace country = "St. Vincent and the Grenadines" if country=="St. Vincent and Grenadines"
replace country = "Sao Tome and Principe" if country=="SÃ£o TomÃ© and PrÃ­ncipe"
replace country = "Timor-Leste" if country=="Timor-Leste"
merge 1:1 country year using "$path\WBgrowthdataset\WBgrowthdata_holder.dta"
drop if _merge==1
drop _merge abs_red* gini_*_se
save "$path\WBgrowthdataset\WBgrowthdata_holder.dta", replace
/*************************/
/* CCKP temperature data */
/*************************/
insheet using "$path\WBgrowthdataset\CCKP_meantemp_month_tas_1901_2020.csv", names clear
drop statistics
drop if year < 1962
replace country = "Korea, Democratic People's Republic of" if iso3=="Democratic People's Republic of"
replace country = "Korea, Republic of" if iso3=="Republic of"
replace iso3 = "PRK" if iso3=="Democratic People's Republic of"
replace iso3 = "KOR" if iso3=="Republic of"
replace iso3 = "GMB" if country=="Gambia"
replace iso3 = "BHS" if country=="Bahamas"
replace iso3 = "TZA" if country=="Tanzania"
replace country = "Iran (Islamic Republic of)" if country=="Iran"
replace country = "Republic of Korea" if country=="Korea, Republic of"
replace country = "North Korea" if country=="Korea, Democratic People's Republic of"
kountry iso3, from(iso3c) 
collapse (mean) temperature, by(year iso3 country NAME)
merge 1:1 NAME year using "$path\WBgrowthdataset\WBgrowthdata_holder.dta"

/*********************/
/* Disaster Database */  /* needs to be downloaded separately, if desired, and below code in this section needs to be uncommented */
/*********************/
drop _merge
rename iso3 iso
replace iso="HKG" if NAME=="Hong Kong"
replace iso="MAC" if NAME=="Macao"
duplicates tag iso year, gen(isdupl)		
											/* NOTE: tags number of duplicates, not if one obs is duplicate! */
tab iso if isdupl>=1
drop if isdupl								/* drops obs w/o iso */
drop isdupl

/*
merge 1:1 iso year using "$path\WBgrowthdataset\disasterdb.dta"		/* Note: this file has to be separately downloaded from https://public.emdat.be/ due to copyright restrictions */
drop if _merge==2
drop _merge

save "$path\WBgrowthdataset\WBgrowthdata_holder.dta", replace

merge 1:1 iso year using "$path\WBgrowthdataset\total_affected_deaths.dta"	/* Note: this file has to be separately downloaded from https://public.emdat.be/ due to copyright restrictions */
drop if year < 1962

duplicates tag NAME year, gen(isdupl)	
										/* NOTE: tags number of duplicates, not if one obs is duplicate! */
drop if isdupl
drop isdupl
gen disaster_affected_pc = totalaffected/pop
gen disaster_death_pc = totaldeath/pop
label var disaster_aff "disaster affected per million of inhabitants"
label var disaster_death "disaster deaths per million of inhabitants"
*/

/***********************/
/* fill missing values */
/***********************/
bys country: ipolate ExpDivIndex ExpHHI, gen(ipol_ExpDivIndex) /* (corr 0.82) */
gen ExpDivIndex_ipol = ipol_ExpDivIndex
replace ExpDivIndex_ipol = ExpDivIndex if ExpDivIndex_ipol==.
drop ipol_ExpDivIndex
sort year, stable
bys country: ipolate FDIstock FDIflow_gfc, gen(ipol_FDIstock) /* (corr 0.95) */
gen FDIstock_ipol = ipol_FDIstock
replace FDIstock_ipol = FDIstock if FDIstock_ipol==.
drop ipol_FDIstock
sort year, stable

/*************************/
/* variable manipulation */
/*************************/
encode NAME, gen(geo)
xtset geo year
bys year: egen globaldemand = sum(rgdpe)
gen lglobaldemand = ln(globaldemand)
sort geo year, stable
gen rgdpe_pc = rgdpe/pop
gen rgdpo_pc = rgdpo/pop
gen rgdpna_pc = rgdpna/pop
gen tradesum = csh_x + (csh_m*(-1))
gen emprate = emp/pop
gen lpop = ln(pop)
gen lrgdpe = ln(rgdpe)
regress tradesum lpop lglobaldemand
predict trade_resid if e(sample), rstandard		/* note: resid = actual - predicted, so positive value = more trade than predicted */
regress traderatio_na lpop lglobaldemand
predict trade_resid_na if e(sample), rstandard		/* note: resid = actual - predicted, so positive value = more trade than predicted */
gen FDI_gfc = FDI_gdp/(csh_i*100)
gen TOT_pwt = pl_x/pl_m
gen inflation_na = ln(na_pricelevel_c) - ln(L.na_pricelevel_c)
gen lrgdpe_pc = ln(rgdpe_pc)
reg urbanpop lrgdpe_pc
predict urbanpop_resid if e(sample), rstandard		/* note: resid = actual - predicted, so positive value = more urbanpop than predicted */
*note: popdens has too immense outliers (Macao, Singapore)
/************************/
/* Infrastructure index */
/************************/
do "$path\WBgrowthdataset\WBgrowth_infraindex_Feb2022.do"
save "$path\WBgrowthdataset\WBgrowthdata_holder.dta", replace
/*******************/
/* make 5-year avg */
/*******************/
gen period = .
replace period = (floor((year-1970)/5))+1
snapshot erase _all
snapshot save, label("annual")
collapse (mean) rgdp*_pc hc csh_g pl_c na_govtcons rer* lrer_deviation lxr* emprate trade* FDI* credit_gdp inflation* infra_com_mobile infra_com_fixedline urbanpop* TOT* popdens csh_x csh_m eci Exp* *Margin man_exp techexports hightechexpvalue agri_valadded agri_empl remittances inttot civtot actot fincrisis bankingcr currencycr sovdebtcr temperature gini_* infrastructure_index infra_pca* govtcons_wdi, by(period country NAME)
/* create logs */
gen lrgdpe_pc = ln(rgdpe_pc)
gen lrgdpo_pc = ln(rgdpo_pc)
gen lrgdpna_pc = ln(rgdpna_pc)
gen lhc = ln(hc)
gen lkg = ln(csh_g)
gen lkg_wdi = ln(govtcons_wdi)
gen lkg_na = ln(na_govtcons)
gen lrer = ln(rer)
gen lcredit = ln(credit_gdp)
gen lmobile = ln(infra_com_mobile)
gen lphoneline = ln(infra_com_fixedline)
gen linflation_na = ln(inflation_na+1) 
gen ltot=ln(TOT_pwt)
gen lFDI=ln(FDI_gfc+100)
qui sum trade_resid
gen ltraderesid = ln(trade_resid-r(min)+0.01)
qui sum trade_resid_na
gen ltraderesid_na = ln(trade_resid_na - r(min)+0.01)
gen ltradesum = ln(tradesum)
qui sum urbanpop_resid
gen lurbanpopresid = ln(urbanpop_resid-r(min)+0.01)
gen lexpprodno = ln(ExpProdNo)
gen lexpHHI = ln(ExpHHI)
gen lexpdivers = ln(ExpDivers)
gen lFDIstock = ln(FDIstock)
gen lFDIstock_ipol = ln(FDIstock_ipol)
gen lEDI_ipol = ln(ExpDivIndex_ipol)
gen lremittances = ln(remittances)
gen lrer_na = ln(rer_na)
gen dum_mepv = .
gen dum_mepv_low = 0
gen dum_mepv_high = 0
replace dum_mepv = 0 if actotal == 0
replace dum_mepv = 1 if actotal > 0 & actotal!=.
replace dum_mepv_low = 1 if actotal > 0 & actotal <5 & actotal!=.
replace dum_mepv_high = 1 if actotal >=5 & actotal!=.
gen bankingcr_years = bankingcr*5
gen fincrisis_years = fincrisis*5
gen dum_bankingcr = 0
gen dum_fincrisis = 0
replace dum_bankingcr = 1 if bankingcr_years >= 1
replace dum_fincrisis = 1 if fincrisis_years >= 1
drop bankingcr fincrisis
label var bankingcr_years "no. of yrs w/ banking crisis during period"
label var fincrisis_years "no. of yrs w/ some financial crisis during period"
label var dum_bankingcr "dummy=1 if banking crisis has occured during period"
label var dum_fincr "dummy=1 if some financial crisis has occured during period"
save "$path\WBgrowthdataset\WBfiveyeardata_holder.dta", replace
/*********************/
/* SD of TEMPERATURE */
/*********************/
insheet using "$path\WBgrowthdataset\CCKP_meantemp_month_tas_1901_2020.csv", names clear
drop statistics
drop if year < 1962
gen period = .
replace period = (floor((year-1970)/5))+1
replace country = "Korea, Democratic People's Republic of" if iso3=="Democratic People's Republic of"
replace country = "Korea, Republic of" if iso3=="Republic of"
replace iso3 = "PRK" if iso3=="Democratic People's Republic of"
replace iso3 = "KOR" if iso3=="Republic of"
replace iso3 = "GMB" if country=="Gambia"
replace iso3 = "BHS" if country=="Bahamas"
replace iso3 = "TZA" if country=="Tanzania"
replace country = "Iran (Islamic Republic of)" if country=="Iran"
replace country = "Republic of Korea" if country=="Korea, Republic of"
replace country = "North Korea" if country=="Korea, Democratic People's Republic of"
kountry iso3, from(iso3c) 
collapse (sd) temperature, by(period iso3 country NAME)
rename temperature sd_temperature
merge 1:1 NAME period using "$path\WBgrowthdataset\WBfiveyeardata_holder.dta"
drop _merge
save "$path\WBgrowthdataset\WBfiveyeardata_holder.dta", replace

/*************/
/* SD of RER */
/*************/

use "https://www.rug.nl/ggdc/docs/pwt100.dta", clear

encode countrycode, gen(ccode)
xtset ccode year

* HP filter for RER
gen lxr = ln(xr)
gen rer = (pl_gdpo/xr)
gen lrer = ln(rer)
gen lyear = ln(year)
bys country: ipolate lrer lyear, gen(lrer_ip) epol


tsfilter hp lrer_deviation = lrer_ip, trend(hptrend_lrer)
label var lrer_deviation "Deviation of RER from HP trend"

tsfilter hp lxr_deviation = lxr, trend(hptrend_lxr)
label var lxr_deviation "Deviation of XR from HP trend"

drop if year<1965

gen period = .
replace period = (floor((year-1970)/5))+1

replace country = "Bolivia" if country=="Bolivia (Plurinational State of)"
replace country = "Democratic Republic of Congo" if country=="D.R. of the Congo"
replace country = "Swaziland" if country=="Eswatini"
replace country = "Macedonia" if country=="North Macedonia"
replace country = "Hong Kong" if country=="China, Hong Kong SAR" 
replace country = "Macao" if country=="China, Macao SAR"
replace country = "Venezuela" if country=="Venezuela (Bolivarian Republic of)"
replace country = "Cape Verde" if country=="Cabo Verde"
replace country = "Tanzania" if country=="U.R. of Tanzania: Mainland"
replace country = "Laos" if country=="Lao People's DR"
replace country = "Curacao" if country=="Curaçao"
replace country = "Cote d'Ivoire" if country=="Côte d'Ivoire"

kountry country, from(other)

replace lrer_deviation = abs(lrer_deviation)
collapse (sum) lrer_deviation, by(period country NAME)
rename lrer_deviation mad_lrer_deviation
merge 1:1 NAME period using "$path\WBgrowthdataset\WBfiveyeardata_holder.dta"
drop _merge

save "$path\WBgrowthdataset\WBfiveyeardata_holder.dta", replace

/****************/
/* SD of growth */
/****************/

use "https://www.rug.nl/ggdc/docs/pwt100.dta", replace

encode countrycode, gen(ccode)
xtset ccode year

gen lrgdpna_pc = ln(rgdpna/pop)
gen lagrealgrowth_pcpa = L2.lrgdpna_pc - L3.lrgdpna_pc

drop if year<1965

gen period = .
replace period = (floor((year-1970)/5))+1

replace country = "Bolivia" if country=="Bolivia (Plurinational State of)"
replace country = "Democratic Republic of Congo" if country=="D.R. of the Congo"
replace country = "Swaziland" if country=="Eswatini"
replace country = "Macedonia" if country=="North Macedonia"
replace country = "Hong Kong" if country=="China, Hong Kong SAR" 
replace country = "Macao" if country=="China, Macao SAR"
replace country = "Venezuela" if country=="Venezuela (Bolivarian Republic of)"
replace country = "Cape Verde" if country=="Cabo Verde"
replace country = "Tanzania" if country=="U.R. of Tanzania: Mainland"
replace country = "Laos" if country=="Lao People's DR"
replace country = "Curacao" if country=="Curaçao"
replace country = "Cote d'Ivoire" if country=="Côte d'Ivoire"

kountry country, from(other)

collapse (sd) lagrealgrowth_pcpa, by(period country NAME)
rename lagrealgrowth_pcpa sd_growth
merge 1:1 NAME period using "$path\WBgrowthdataset\WBfiveyeardata_holder.dta"
drop _merge

save "$path\WBgrowthdataset\growthdata_public.dta", replace

/**************************************/
/* GENERATE INCOME AND REGION DUMMIES */
/**************************************/

encode NAME, gen(geo)
xtset geo period

gen abovemedianinc = 0
label var abovemedianinc "dummy if country is (on avg over periods) above median (cross-country) pc income level"
bys geo: egen avgincome = mean(lrgdpe_pc)
sum avgincome, det
replace abovemedianinc = 1 if avgincome > r(p50)

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

compress
save "$path\WBgrowthdataset\growthdata_public.dta", replace
rm "$path\WBgrowthdataset\WBfiveyeardata_holder.dta"
rm "$path\WBgrowthdataset\WBgrowthdata_holder.dta"
