/* Baseline Models from Least Square Estimation (paper section 5.1) */

global depvar lrgdpna_pc
gen lagdependent = L.$depvar

/* small model (column (1) of table 2 */
xtreg $depvar lagdependent lkg lrer ltraderesid linflation_na dltot dum_fincrisis sd_growth durbanpop sd_temperature infra_index i.period, fe robust

/* medium model (column (2) of table 2 */
xtreg $depvar lagdependent lkg lrer ltraderesid lcredit linflation_na infra_index dltot lEDI_ipol lEDI_ipol_sq lFDIstock_ipol actotal dum_fincrisis i.period, fe robust

/* large model (column (3) of table 2 */
xtreg $depvar lagdependent lhc lkg lrer ltraderesid lcredit linflation_na infra_index dltot lEDI_ipol lEDI_ipol_sq lFDIstock_ipol actotal dum_fincrisis dgini i.period, fe robust
