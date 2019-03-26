* Merge Macro with EMDAT ===========================================================================================================================================================
* Every macro variables are in billions, population is in million, GDPPC is in USD unit

clear 
set more off
use Q:\Data\PIU\Natural_Disaster_Database\Irene_results\Codes\fiscal\Macro.dta
merge 1:1 Year Country using Q:\Data\PIU\Natural_Disaster_Database\Irene_results\Codes\EMDAT.dta
destring, replace
drop _merge
save "Q:\Data\PIU\Fiscal Buffer\Irene\merge1.dta",replace

cd "Q:\Data\PIU\Fiscal Buffer\Irene"

*Reshape additional US AUS data
clear
import excel "Q:\Data\PIU\Fiscal Buffer\Irene\additionaldata.xlsx", sheet("Sheet2") firstrow

reshape long Year, i(A) j(year)

encode A, gen (var)
drop A

reshape wide Year, i(year) j(var)

//rename all the vars 

rename Year1 AUS_NGDPPC
rename Year2 AUS_RGDP
rename Year3 AUS_RGDPPC
rename Year4 AUS_TT
rename Year5 US_NGDPPC
rename Year6 US_RGDP
rename Year7 US_RGDPPC
rename Year8 US_TT
rename year Year

save "addtional.dta",replace

*Merge additional AUS US data with EMDAT data
clear
use "addtional.dta"
merge 1:m Year using "Q:\Data\PIU\Fiscal Buffer\Irene\merge1.dta"

drop _merge
save "fiscalcost.dta",replace

clear
use "REER.dta"
rename year Year
merge 1:1 Country Year using "Q:\Data\PIU\Fiscal Buffer\Irene\fiscalcost.dta"
drop _merge
save "fiscalcost.dta",replace


use "wbdata_pop.dta"
merge 1:1 Country Year using "Q:\Data\PIU\Fiscal Buffer\Irene\fiscalcost.dta"
drop _merge
save "fiscalcost.dta",replace

keep if Country == "FJI"|Country == "TUV"|Country == "TLS"|Country == "MHL"|Country == "FSM"|Country == "PNG"|Country == "TON"|Country == "WSM"|Country == "KIR"|Country == "PLW"|Country == "VUT"|Country == "SLB"
*========================================================================================================*

* Clean up false zeros from the merge
set more off
foreach x of varlist totaldamage TotalAffected totalaffected affected homeless injured totaldeaths Storm_damage Storm_affpop Flood_damage Flood_affpop Drought_damage Drought_affpop Earthquake_damage Earthquake_affpop Others_damage Others_affpop {
replace `x'= . if `x' == 0
}

* Generate variables for regression

replace NGDPD = GDP/1000000000 if missing(NGDPD)
replace Population = pop/1000000 if missing(Population)

rename TotalAffected Total_affpop
rename totaldamage Total_damage
*generate NGDPPC = NGDPD*1000/Population //in USD unit
generate NGDPPC = (NGDPD*1000/Population)/1000000000 //in billion
generate GDPPC = (RGDP*1000/Population)/1000000000 //in billion
generate GDPPC_growth = (GDPPC[_n]/GDPPC[_n-1]-1)*100 //in percent



foreach x of varlist *_affpop {
gen `x'_p = `x'/(Population*1000000)
}
foreach x of varlist *_damage {
gen `x'_p = `x'/(NGDPD*1000000)
}
foreach x of varlist Storm Flood Drought Earthquake Others {
replace `x' = 0 if missing(`x')
}
foreach x of varlist Gov_exp Gov_rev IMP EXP Gov_d Gov_gnt External_d Gov_extd {
gen `x'_p = (`x' / NGDPD)*100
}
gen Total = Storm + Flood + Earthquake +Drought + Others
replace Total = 1 if Total > 1


* Create Natural Disaster Dummy 50 and 75 percentile  

foreach x of varlist *_damage_p {
	foreach z of numlist 1.7 {
			gen `x'D50p=0
			replace `x'D50p= 1 if `x'*100 > `z' 
			replace `x'D50p= 0 if missing(`x') 
		}
}
foreach x of varlist *_affpop_p {
	foreach z of numlist 1.3 {
			gen `x'D50p=0
			replace `x'D50p= 1 if `x'*100 > `z' 
			replace `x'D50p= 0 if missing(`x') 
		}
}
foreach x of varlist *_damage_p {
	foreach z of numlist 10 {
			gen `x'D75p=0
			replace `x'D75p= 1 if `x'*100 > `z' 
			replace `x'D75p= 0 if missing(`x') 
		}
}

foreach x of varlist *_affpop_p {
	foreach z of numlist 7.5 {
			gen `x'D75p=0
			replace `x'D75p= 1 if `x'*100 > `z' 
			replace `x'D75p= 0 if missing(`x') 
		}
}


** Fixed effectes regression setup

encode Country, gen(Country_code)
xtset Country_code Year


foreach x of varlist Gov_exp Gov_rev IMP EXP Gov_d Gov_gnt GDPPC{
	gen log`x' = log(`x')
}

foreach x of varlist Gov_exp Gov_rev IMP EXP Gov_d Gov_gnt External_d Gov_extd{
	gen `x'_gr = D.`x'/L.`x'
}

foreach x of varlist IMP_p EXP_p {
	gen `x'_d = D.`x'
}

//******************************************//

//Generate nd_pc by using both Damage/GDP and Pop affected

egen dmgrank = rank(Total_damage_p)

egen poprank = rank(Total_affpop_p)

egen maxdmg = max(dmgrank)
gen dmg_pc = dmgrank/maxdmg

egen maxpop = max(poprank)
gen pop_pc = poprank/maxpop


gen nd_pc = dmg_pc
//replace nd_pc = pop_pc if pop_pc > dmg_pc 
replace nd_pc = pop_pc if nd_pc >=.


xtile quart20 = nd_pc , nq(20)
replace quart20=0 if quart20>=.

// Generate new 70 percentile dummy using (i) Damage/GDP and (ii) Population affected 

gen DP65 = 0 // 60 percentile dummy, Not significant 
replace DP65 = 1 if quart20 > 13

gen DP70 = 0 //70 percentile dummy
replace DP70 = 1 if quart20 > 14

gen DP75 = 0 //75 percentile dummy
replace DP75 = 1 if quart20 > 15

gen DP80 = 0 //80 percentile dummy
replace DP80 = 1 if quart20 >16

gen DP50 = 0 // 60 percentile dummy, Not significant 
replace DP50 = 1 if quart20 > 10


gen DP60 = 0 // 60 percentile dummy, Not significant 
replace DP60 = 1 if quart20 > 12


// Generate 75 percentile dummies based on disaster types using(i) Damage/GDP and (ii) Population affected 

local nd Storm Flood Drought Earthquake Others
 
foreach x of local nd {
	gen `x'_D75 = 0 
	replace `x'_D75 = 1 if DP75==1 & `x' == 1
}

local nd Storm Flood Drought Earthquake Others
 
foreach x of local nd {
	gen `x'_D70 = 0 
	replace `x'_D70 = 1 if DP70==1 & `x' == 1
}
local nd Storm Flood Drought Earthquake Others
 
foreach x of local nd {
	gen `x'_D80 = 0 
	replace `x'_D80 = 1 if DP80==1 & `x' == 1
}
** Based on 75 percentile, get the impact of higher percentile by using i.quart

gen quart60 = quart20
replace quart60 = 1 if quart60 <13

gen quart75 = quart20
replace quart75 = 1 if quart75 <16

gen quart70 = quart20
replace quart70 = 1 if quart70 <15

gen quart80 = quart20
replace quart80 = 1 if quart80 <17

gen quart65 = quart20
replace quart65 = 1 if quart65 < 14

//generate overall balance
gen fb_gdp = 100*((Gov_rev - Gov_exp)/NGDP)
gen rev_gdp = 100* Gov_rev/NGDP
gen exp_gdp = 100* Gov_exp/NGDP
gen dbt_gdp = 100*(Gov_d[_n]-Gov_d[_n-1])/NGDP[_n] // NC
gen gnt_gdp = 100* Gov_gnt/NGDP //NC
gen exd_gdp = 100 * (External_d[_n] - External_d[_n-1])/NGDPD[_n]
gen govexd_gdp = 100 * Gov_extd/NGDPD
gen rev_excl_gnt_gdp = rev_gdp - gnt_gdp //government revenue without grants
replace govexd_gdp = 100 * Gov_extd/NGDP if Country == "WSM" | Country == "Ton" |Country == "VUT" | Country == "MHL"

//Generate control variables
gen lreer = log(REER)
gen open=((IMP+EXP)/NGDPD)*100
gen US_RGDPG = 100*(US_RGDP[_n]/US_RGDP[_n-1]-1)
gen AUS_RGDPG = 100*(AUS_RGDP[_n]/AUS_RGDP[_n-1]-1)

// After disaster Fiscal indicator change
gen fb_gdp_change = fb_gdp[_n] - fb_gdp[_n-1]
gen RGDPG_change = RGDPG[_n] - RGDPG[_n-1]
gen gnt_gdp_change = gnt_gdp[_n] - gnt_gdp[_n-1]
gen rev_gdp_change = rev_gdp[_n] - rev_gdp[_n-1]
gen rev_excl_gnt_gdp_change = rev_excl_gnt_gdp[_n] - rev_excl_gnt_gdp[_n-1]
gen exp_gdp_change = exp_gdp[_n] - exp_gdp[_n-1]

//br DP75 Country Year fb_gdp_change RGDPG_change rev_gdp_change rev_excl_gnt_gdp_change exp_gdp_change gnt_gdp_change if DP75 == 1

//outliner cleanup

//replace DP75 = 0 if Country == "TUV" & Year ==2015
//drop if Country == "TUV"| Country == "TLS" | Country == "KIR"
//gen PNA = 0
//replace PNA = 1 if Year > 2011 & Country == "TUV" |Country == "MHL" |Country == "KIR" |Country == "FSM" 
//gen PNAi = PNA * rev_excl_gnt_gdp

//replace exp_gdp = . if Year == 2015 & Country == "TUV"
//replace rev_excl_gnt_gdp = . if Year == 2015 & Country == "TUV"

//replace exp_gdp = . if Year == 2016 & Country == "TLS"
//replace rev_excl_gnt_gdp = . if Year == 2016 & Country == "TLS"

//replace exp_gdp = . if Year == 2016 & Country == "MHL"
//replace rev_excl_gnt_gdp = . if Year == 2016 & Country == "MHL"


//replace exp_gdp = . if Year == 2013 & Country == "MHL"
//replace rev_excl_gnt_gdp = . if Year == 2013 & Country == "MHL"



//replace exp_gdp = . if Year == 1999 & Country == "KIR"
//replace rev_excl_gnt_gdp = . if Year == 1999 & Country == "KIR"

//*******************************************************//
//GMM 

//Panel VAR (GMM)//
tabulate Year, generate(t_)

xtset Country_code Year

drop if Year < 1990 | Year >2016
br Country_code Year exp_gdp rev_excl_gnt_gdp DP75 gnt_gdp
//********************************************************//
xtreg exp_gdp rev_excl_gnt_gdp DP75 L.DP75 L2.DP75 gnt_gdp, fe 
xtreg exp_gdp rev_excl_gnt_gdp DP75 L.DP75 L2.DP75 gnt_gdp, fe vce(robust)
xtreg rev_excl_gnt_gdp exp_gdp DP75 L.DP75 L2.DP75 gnt_gdp, fe
xtreg rev_excl_gnt_gdp exp_gdp DP75 L.DP75 L2.DP75 gnt_gdp, fe vce(robust)
xtreg rev_excl_gnt_gdp exp_gdp DP75 L.DP75 L2.DP75 gnt_gdp, be

xtreg exp_gdp rev_excl_gnt_gdp DP75 L.DP75 L2.DP75 gnt_gdp, fe 
xtreg exp_gdp rev_excl_gnt_gdp DP75 L.DP75 L2.DP75 gnt_gdp, fe vce(robust)
xtreg rev_excl_gnt_gdp exp_gdp DP75 L.DP75 L2.DP75 gnt_gdp, be


egen exp_m=mean(exp_gdp), by(Country)
egen rev_m=mean(rev_excl_gnt_gdp), by(Country)
egen gnt_m=mean(gnt_gdp), by(Country)

gen exp_r = exp_gdp-exp_m
gen rev_r = rev_excl_gnt_gdp - rev_m
gen gnt_r = gnt_gdp-gnt_m

//********************************************************//

xtreg exp_r rev_r gnt_r DP75 L.DP75 L2.DP75, fe vce(robust)
xtreg exp_gdp rev_excl_gnt_gdp DP75 L.DP75 L2.DP75 gnt_gdp i.Year, fe vce(robust)

//local exg PNA
//With US and AUS GDP growth control

pvar exp_r rev_r, exog(DP75 L.DP75 L2.DP75  gnt_r) lags(1) instlags(1/2) vce(robust) overid
outreg2 using fb_917.xls, append addstat(Hansen, e(J_pval))

pvar exp_r rev_r, exog(DP75 L.DP75 L2.DP75  gnt_r RGDPG) lags(1) instlags(1/2) vce(robust) overid
outreg2 using fb_917.xls, append addstat(Hansen, e(J_pval))

pvar exp_r rev_r, exog(DP75 L.DP75 L2.DP75  gnt_r L.RGDPG) lags(1) instlags(1/2) vce(robust) overid
outreg2 using fb_917.xls, append addstat(Hansen, e(J_pval))

pvar exp_r rev_r, exog(DP75 L.DP75 L2.DP75  gnt_r AUS_RGDPG US_RGDPG) lags(1) instlags(1/2) vce(robust) overid
outreg2 using fb_917.xls, append addstat(Hansen, e(J_pval))

pvar rev_r exp_r, exog(DP75 L.DP75 L2.DP75  gnt_r) lags(1) instlags(1/2) vce(robust) overid
pvarirf, impulse(exp_r) response( rev_r) level(95)
pvarirf, response(exp_r)oirf step(5) mc(200) level(95) cumulative

pvar exp_gdp rev_excl_gnt_gdp, exog(DP75 L.DP75 L2.DP75 gnt_gdp t_*) lags(1) instlags(1/2) gmmstyle vce(robust) overid
outreg2 using fiscal_7-18_v1.xls, append addstat(Hansen, e(J_pval))

pvar exp_gdp rev_excl_gnt_gdp , exog(DP75 L.DP75 L2.DP75 gnt_gdp RGDPG) instlags(1/2) gmmstyle vce(robust) overid
outreg2 using fiscal_7-18_v1.xls, append addstat(Hansen, e(J_pval))

pvar exp_gdp rev_excl_gnt_gdp, exog(DP75 L.DP75 L2.DP75 gnt_gdp L.RGDPG) instlags(1/2) gmmstyle vce(robust) overid
outreg2 using fiscal_7-18_v1.xls, append addstat(Hansen, e(J_pval))

pvar exp_gdp rev_excl_gnt_gdp, exog(DP75 L.DP75 L2.DP75 gnt_gdp AUS_RGDPG US_RGDPG) instlags(1/2) gmmstyle vce(robust) overid
outreg2 using fiscal_7-18_v1.xls, append addstat(Hansen, e(J_pval))

********************************************
//With US and AUS GDP growth control

pvar exp_gdp rev_excl_gnt_gdp, exog(DP75 L.DP75 L2.DP75 gnt_gdp L.AUS_RGDPG L.US_RGDPG )  instlags(1/2) gmmstyle vce(robust) overid
//eret list
outreg2 using fiscal_7-5-New.xls, append addstat(Hansen, e(J_pval))

pvar exp_gdp rev_excl_gnt_gdp, exog(DP75 L.DP75 L2.DP75 gnt_gdp L.US_RGDPG ) instlags(1/2) gmmstyle vce(robust) overid
outreg2 using fiscal_7-5-New.xls, append addstat(Hansen, e(J_pval))

pvar exp_gdp rev_excl_gnt_gdp, exog(DP75 L.DP75 L2.DP75 gnt_gdp L.AUS_RGDPG ) instlags(1/2) gmmstyle vce(robust) overid
outreg2 using fiscal_7-5-New.xls, append addstat(Hansen, e(J_pval))

pvar exp_gdp rev_excl_gnt_gdp, exog(DP75 L.DP75 L2.DP75 gnt_gdp L.AUS_RGDPG L.RGDPG) instlags(1/2) gmmstyle vce(robust) overid

pvar exp_gdp rev_excl_gnt_gdp, exog(DP75 L.DP75 L2.DP75 gnt_gdp L.AUS_RGDPG L.RGDPG) instlags(1/2) gmmstyle vce(robust) overid
