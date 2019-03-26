
*********************************************************************************************
**GMM panel estimation on Export diversification's impact on GDP growth
*********************************************************************************************

*********************************************************************************************
**Import data and merge with other datasets
*********************************************************************************************

clear
set mat 11000
set more off

cd  "Q:\Data\PIU\Export_Diversification\Results"
import excel "Q:\Data\PIU\Export_Diversification\datacleaning\expdivdb_final.xlsx", sheet("expdivdb_final") firstrow

destring country_code g_food-crisis, force replace
xtset country_code Year
save expdiv_gmm1.dta, replace

clear
import excel "\\DATA2\APD\Data\PIU\Export_Diversification\datacleaning\FDI_stata.xlsx", sheet("Panel") firstrow
rename code_id country_code
rename year Year

merge 1:1 Year country_code using expdiv_gmm1.dta
destring, replace
drop _merge
save expdiv_gmm1.dta, replace


***********************************************************************************************************************************


************************************************************************************
** GMM Estimation
************************************************************************************

clear
set mat 11000
set more off

cd  "Q:\Data\PIU\Export_Diversification\Results"
use expdiv_gmm1.dta

*********************************************************************************************
**Generate Small States dummy 
**and clean up countries that are not desired
*********************************************************************************************

gen ss = 0 
replace ss = 1 if country_code == 624|country_code == 632|country_code ==	684|country_code ==	716|country_code ==	718|country_code ==	734|country_code ==	514|country_code ==	819|country_code ==	826	|country_code ==556	|country_code ==867	|country_code ==868	|country_code ==565 |country_code ==862	|country_code ==813	|country_code ==537	|country_code ==866	|country_code ==869	|country_code ==846	|country_code ==943	|country_code ==611	|country_code ==311	|country_code ==313	|country_code ==316	|country_code ==339	|country_code ==321 |country_code ==328	|country_code ==336	|country_code ==361	|country_code ==362	|country_code ==364	|country_code ==366	|country_code ==369
keep if ss == 1| country_group == "LIDC"

gen LIC=0
replace LIC=1 if country_group == "LIDC"

****data not available
drop if country_code==611|country_code==628|country_code==734

//***data not available
//drop if country_code==611|country_code==628|country_code==678|country_code==733/*
//*/|country_code==813|country_code==479|country_code==927|country_code==734


*********************************************************************************************
**Generate variables for GMM regression
*********************************************************************************************

sort country_code Year

//generate population growth and real GDP growth
gen RGDPG = (RGDP[_n]/RGDP[_n-1]-1)*100
gen POPG = (pop[_n]/pop[_n-1]-1)*100
gen lnRGDPPC_PPP=ln(RGDPPC_PPP)

gen RGDP_usd=RGDPPC_PPP*pop

** generate population/GDPPC dummy
tabstat(pop RGDP_usd RGDPPC_PPP) if Year==2015, statistics(mean median min max)
centile(pop RGDP_usd RGDPPC_PPP) if Year==2015, centile (20 25 30 40 60 70 75 80)


gen POP_med = 0 
replace POP_med = 1 if pop > 5476274 & Year==2015
egen POP_lg = max(POP_med), by(country_code)

gen POP_p20 = 0 
replace POP_p20 = 1 if pop > 284217  & Year==2015
egen POP_lg20 = max(POP_p20), by(country_code)

gen POP_p25 = 0 
replace POP_p25 = 1 if pop > 504285.5 & Year==2015
egen POP_lg25 = max(POP_p25), by(country_code)

gen POP_p30 = 0 
replace POP_p30 = 1 if pop > 695336.5 & Year==2015
egen POP_lg30 = max(POP_p30), by(country_code)

gen POP_p40 = 0 
replace POP_p40 = 1 if pop > 1977590 & Year==2015
egen POP_lg40 = max(POP_p40), by(country_code)

gen POP_p60 = 0 
replace POP_p60 = 1 if pop > 8960829 & Year==2015
egen POP_lg60 = max(POP_p60), by(country_code)

gen POP_p70 = 0 
replace POP_p70 = 1 if pop > 1.52e+07 & Year==2015
egen POP_lg70 = max(POP_p70), by(country_code)

gen POP_p75 = 0 
replace POP_p75 = 1 if pop > 1.86e+07 & Year==2015
egen POP_lg75 = max(POP_p75), by(country_code)

gen POP_p80 = 0 
replace POP_p80 = 1 if pop > 2.42e+07 & Year==2015
egen POP_lg80 = max(POP_p80), by(country_code)



gen RGDPPC_med = 0 
replace RGDPPC_med = 1 if RGDPPC_PPP > 3627.202 & Year==2015
egen RGDPPC_hg = max(RGDPPC_med), by(country_code)

gen RGDPPC_p20 = 0 
replace RGDPPC_p20 = 1 if RGDPPC_PPP > 1629.271 & Year==2015
egen RGDPPC_hg20 = max(RGDPPC_p20), by(country_code)

gen RGDPPC_p25 = 0 
replace RGDPPC_p25 = 1 if RGDPPC_PPP > 1753.063 & Year==2015
egen RGDPPC_hg25 = max(RGDPPC_p25), by(country_code)

gen RGDPPC_p30 = 0 
replace RGDPPC_p30 = 1 if RGDPPC_PPP > 2149.605 & Year==2015
egen RGDPPC_hg30 = max(RGDPPC_p30), by(country_code)

gen RGDPPC_p40 = 0 
replace RGDPPC_p40 = 1 if RGDPPC_PPP > 2857.874 & Year==2015
egen RGDPPC_hg40 = max(RGDPPC_p40), by(country_code)

gen RGDPPC_p60 = 0 
replace RGDPPC_p60 = 1 if RGDPPC_PPP > 5037.67 & Year==2015
egen RGDPPC_hg60 = max(RGDPPC_p60), by(country_code)

gen RGDPPC_p70 = 0 
replace RGDPPC_p70 = 1 if RGDPPC_PPP > 5853.177 & Year==2015
egen RGDPPC_hg70 = max(RGDPPC_p70), by(country_code)

gen RGDPPC_p75 = 0 
replace RGDPPC_p75 = 1 if RGDPPC_PPP > 7743.338 & Year==2015
egen RGDPPC_hg75 = max(RGDPPC_p75), by(country_code)

gen RGDPPC_p80 = 0 
replace RGDPPC_p80 = 1 if RGDPPC_PPP > 10144.15 & Year==2015
egen RGDPPC_hg80 = max(RGDPPC_p80), by(country_code)



//generate FDI govrnment consumption growth, in national currency.
gen gov_csmp1 = gov_csmp * NGDP/100
gen FDI1 = FDI * NGDP/100
gen govcs_g = (gov_csmp1[_n]/gov_csmp1[_n-1]-1)*100
gen FDI_g = (FDI1[_n]/FDI1[_n-1]-1)*100

//generate FDI govrnment consumption growth, in percent of gdp.
gen govcs_gdp_g = gov_csmp[_n]-gov_csmp[_n-1]
gen FDI_gdp_g = FDI[_n]-FDI[_n-1]
gen cred2gdp_g=cred2gdp[_n]-cred2gdp[_n-1]

//generate natural disaster dummies
replace totaldamage = 0 if missing(totaldamage)
replace Totaldeaths = 0 if missing(Totaldeaths)
replace Totalaffected = 0 if missing(Totalaffected)

gen totalaffected = 100*(Totaldeaths + Totalaffected)/pop if !missing(pop)
replace totalaffected = 0 if missing(totalaffected)

gen nd1 = 0
replace nd1 = 1 if totaldamage*1000*100/gdp_usd >1
replace nd1 = 0 if missing(totaldamage)

gen nd2 = 0
replace nd2 = 1 if totaldamage*1000*100/gdp_usd >1 | totalaffected > 3

gen exp = export/1000000
gen gs = g_total + s_total
gen GS = gs
replace GS = exp if missing(gs)| gs<exp
gen gs_ratio = 100*g_total/GS
gen s_ratio = 100*s_total/GS
replace gs_ratio = 100-s_ratio if missing(gs_ratio)

gen tourism = 100*travl/s_total
gen cmmdty = 100*(g_min + g_crd)/g_total

sort country_code Year

gen idx_g3 = (max_g1^2+max_g2^2+max_g3^2)/(max_g1 + max_g2 + max_g3)^2
gen idx_s3 = (max_s1^2+max_s2^2+max_s3^2)/(max_s1 + max_s2 + max_s3)^2

//Set sample period
drop if Year < 2001
drop if Year > 2015

xtile quant5 = Year, nq(5)

/*
gen quant5 = 0
replace quant5 = 1 if Year >2000 & Year <2004
replace quant5 = 2 if Year >2003 & Year <2007
replace quant5 = 3 if Year >2006 & Year <2010
replace quant5 = 4 if Year >2009 & Year <2013
replace quant5 = 5 if Year >2012 & Year <2016
*/

collapse (mean) crisis nd1 nd2 service_va mnfc_va cred2gdp_g FDI_g govcs_g FDI_gdp_g govcs_gdp_g POPG gs_ratio s_ratio tourism cmmdty RGDPG RGDPPC_growth credgrowth cred2gdp gov_csmp trd_gdp pop FDI divindexall inflation idx_g idx_s idx_g3 idx_s3 divindexall5 divindexall4 divindexall3 divindexall2 divindex3 divindex5 FDIVOL gov_csmpvol trd_gdpvol inflvol credg_vol cred2gdp_vol RGDPVOL (first) country_group ss FD FI FM  RGDP RGDPPC_PPP lnRGDPPC_PPP, by(country_code quant5  POP_lg POP_lg20 POP_lg25 POP_lg30 POP_lg40 POP_lg60 POP_lg70 POP_lg75 POP_lg80 RGDPPC_hg RGDPPC_hg20 RGDPPC_hg25 RGDPPC_hg30 RGDPPC_hg40 RGDPPC_hg60 RGDPPC_hg70 RGDPPC_hg75 RGDPPC_hg80 LIC)


/*
//clean up crisis/nd dummies
foreach var of varlist nd1 nd2 crisis {
	replace `var' = 1 if `var' >0
}
*/

tabulate quant5, generate(t_)

foreach var of varlist FDI gov_csmp trd_gdp RGDP pop {
	gen l`var' = log(`var')
	replace `var' = l`var'
	drop l`var'
}


gen SSD = ss*divindexall
gen SSD3 = ss*divindex3
gen SSD5 = ss*divindex5

gen SSDg = ss*idx_g
gen SSDs = ss*idx_s
gen div2 = divindexall^2

gen gintr = gs_ratio * divindexall
gen sintr = s_ratio * divindexall

gen cintr = cmmdty * divindexall
gen tintr = tourism * divindexall

gen ggintr = gs_ratio * idx_g
gen ssintr = s_ratio * idx_s

gen trintr = tourism * idx_s
gen cmintr = cmmdty * idx_g

//generate dummies for tourism and commodity
gen tourcty = 0
replace tourcty = 1 if tourism > 50
gen tourcty_div = tourcty * divindexall 
gen tourcty_div3 = tourcty * divindex3 
gen tourcty_div5 = tourcty * divindex5 

//disaster/crisis*5 : number of disaster/crisis
gen ND2=nd2*3
gen ND1=nd1*3
gen Crisis=crisis*3


gen div_manr=divindexall*mnfc_va
gen div5_manr=divindex5*mnfc_va
gen div3_manr=divindex3*mnfc_va
gen div_serr=divindexall*service_va
gen div5_serr=divindex5*service_va
gen div3_serr=divindex3*service_va
gen div_indr=divindexall*(mnfc_va+service_va)
gen div5_indr=divindex5*(mnfc_va+service_va)
gen div3_indr=divindex3*(mnfc_va+service_va)

gen idxg_r=idx_g*mnfc_va
gen idxg3_r=idx_g3*mnfc_va
gen idxs_r=idx_s*service_va
gen idxs3_r=idx_s3*service_va

ren mnfc_va manr
ren service_va serr

*********************************************
//SYSTEM GMM two step system with divindexall 
*********************************************

//All sectors

xtset country_code quant5

//All vs. non-SS LICs
cd "Q:\Data\PIU\Export_Diversification\Results\WithCred_results"

**All
local controls divindexall lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth `controls' ND2 t_*, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth.xls, replace ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth `controls' ND2 t_*, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth `controls' ND2 t_*, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)


**LICs
local controls divindexall lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth `controls' ND2 t_* if LIC==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
gen byte used=e(sample)

outreg2 using growth.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth `controls' ND2 t_* if LIC==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth  `controls' ND2 t_* if LIC==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

**non-SS LICs
local controls divindexall lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth `controls' ND2 t_* if ss==0&LIC==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth `controls' ND2 t_* if ss==0&LIC==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth  `controls' ND2 t_* if ss==0&LIC==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)



//By Country-size

**POP_lower 75 percentile
local controls divindexall lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg75==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop.xls, replace ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg75==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth  `controls' ND2 t_* if POP_lg75==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

**POP_upper 75 percentile
local controls divindexall lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg25==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg25==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg25==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)


//By GDPPC

**GDPPC_lower 75 percentile
local controls divindexall lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg75==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC.xls, replace ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg75==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth  `controls' ND2 t_* if RGDPPC_hg75==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

**GDPPC_upper 75 percentile
local controls divindexall lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg25==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg25==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation credgrowth
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg25==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)





********************************************************************************
************************ p70 *************************************************** 
********************************************************************************

//By Country-size

**POP_lower 70 percentile
local controls divindexall lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg70==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop70.xls, replace ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg70==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop70.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth  `controls' ND2 t_* if POP_lg70==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop70.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

**POP_upper 70 percentile
local controls divindexall lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg30==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop70.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg30==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop70.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg30==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop70.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)


//By GDPPC

**GDPPC_lower 70 percentile
local controls divindexall lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg70==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC70.xls, replace ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg70==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC70.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth  `controls' ND2 t_* if RGDPPC_hg70==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC70.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

**GDPPC_upper 70 percentile
local controls divindexall lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg30==1, gmm(`controls', lag(1 4) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC70.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg30==1, gmm(`controls', lag(1 4) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC70.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg30==1, gmm(`controls', lag(1 4) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC70.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)




********************************************************************************
************************ p80 *************************************************** 
********************************************************************************

//By Country-size

**POP_lower 80 percentile
local controls divindexall lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg80==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop80.xls, replace ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg80==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop80.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth  `controls' ND2 t_* if POP_lg80==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop80.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

**POP_upper 80 percentile
local controls divindexall lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg20==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop80.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg20==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop80.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg20==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop80.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)



//By GDPPC

**GDPPC_lower 80 percentile
local controls divindexall lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg80==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC80.xls, replace ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg80==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC80.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth  `controls' ND2 t_* if RGDPPC_hg80==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC80.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

**GDPPC_upper 80 percentile
local controls divindexall lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg20==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC80.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg20==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC80.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg20==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC80.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)



********************************************************************************
************************ p60 *************************************************** 
********************************************************************************

//By Country-size

**POP_lower 60 percentile
local controls divindexall lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg60==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop60.xls, replace ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg60==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop60.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth  `controls' ND2 t_* if POP_lg60==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop60.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

**POP_upper 60 percentile
local controls divindexall lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg40==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop60.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg40==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop60.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if POP_lg40==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_pop60.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)



//By GDPPC

**GDPPC_lower 60 percentile
local controls divindexall lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg60==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC60.xls, replace ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg60==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC60.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth  `controls' ND2 t_* if RGDPPC_hg60==0, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC60.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

**GDPPC_upper 60 percentile
local controls divindexall lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg40==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC60.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg40==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC60.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 lnRGDPPC_PPP POPG trd_gdp govcs_g FDI_g inflation
xtabond2 RGDPPC_growth `controls' ND2 t_* if RGDPPC_hg40==1, gmm(`controls', lag(1 2) collapse) iv(ND2 t_*) two robust
outreg2 using growth_GDPPC60.xls, append ctitle(regression 0) label coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)
































******************not used: insignificant*************************************************************

//All sectors: man+ser sector ratio

local controls divindexall div_indr t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_ind.xls, replace ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls trd_gdp cred2gdp FDI_g govcs_g inflation ND2 Crisis divindexall div_indr t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_ind.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 div5_indr t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_ind.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls trd_gdp cred2gdp FDI_g govcs_g inflation ND2 Crisis divindex5 div5_indr t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_ind.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 div3_indr t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_ind.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls trd_gdp cred2gdp FDI_g govcs_g inflation ND2 Crisis divindex3 div3_indr t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_ind.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)


//All sectors: ser sector ratio

local controls divindexall div_serr t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_ser.xls, replace ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls trd_gdp cred2gdp FDI_g govcs_g inflation ND2 Crisis divindexall div_serr t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_ser.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex5 div5_serr t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_ser.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls trd_gdp cred2gdp FDI_g govcs_g inflation ND2 Crisis divindex5 div5_serr t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_ser.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls divindex3 div3_serr t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_ser.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls trd_gdp cred2gdp FDI_g govcs_g inflation ND2 Crisis divindex3 div3_serr t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_ser.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)




////////idx_s vs idx_g

local controls idx_g t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_sector.xls, replace ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls trd_gdp cred2gdp FDI_g govcs_g inflation ND2 Crisis idx_g t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_sector.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls idx_g3 t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_sector.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls trd_gdp cred2gdp FDI_g govcs_g inflation ND2 Crisis idx_g3 t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_sector.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)


local controls idx_s t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_sector.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls trd_gdp cred2gdp FDI_g govcs_g inflation ND2 Crisis idx_s t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_sector.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls idx_s3 t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_sector.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls trd_gdp cred2gdp FDI_g govcs_g inflation ND2 Crisis idx_s3 t_*
xtabond2 RGDPPC_growth lnRGDPPC_PPP  `controls', gmm(lnRGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using growth_sector.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)










***************************************
//GMM with interactions (infrastructure/financial)-->Focused on growth dside
***************************************

gen fdintr = FD *100 * divindexall
gen fiintr = FI *100 * divindexall
gen intr = cred2gdp * credgrowth
gen intr2 = cred2gdp * divindexall
gen intr3 = credgrowth * divindexall

//gen divindexall2 = divindexall^2

***************************************
//SYSTEM GMM two step system with divindexall + Intr3
***************************************
xtset country_code quant5
local controls FDI inflation cred2gdp gov_csmp divindexall intr3 
xtabond2 RGDPPC_growth RGDPPC_PPP  `controls' t_*, gmm(RGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using divGMM1.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

***************************************
//SYSTEM GMM two step system with divindexall + Intr2
***************************************
xtset country_code quant5
local controls FDI inflation cred2gdp gov_csmp divindexall intr2 
xtabond2 RGDPPC_growth RGDPPC_PPP  `controls' t_*, gmm(RGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using divGMM1.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

***************************************
//SYSTEM GMM two step system with divindexall + Intr2 + Intr3 
***************************************
xtset country_code quant5
local controls FDI inflation cred2gdp gov_csmp divindexall intr2 intr3
xtabond2 RGDPPC_growth RGDPPC_PPP  `controls' t_*, gmm(RGDPPC_PPP `controls', lag(1 2) collapse) iv(t_*) two robust
outreg2 using divGMM1.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)


***************************************
//SYSTEM GMM two step system with divindexall + SSD
***************************************


//time fixed effects
xtset country_code quant5
local controls FDI trd_gdp credgrowth inflation gov_csmp divindexall SSD t_*
xtabond2 RGDPPC_growth RGDPPC_PPP  `controls' t_*, gmm(RGDPPC_PPP `controls', lag(1 3) collapse) iv(t_*) two robust
outreg2 using pregrowthSSD.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls FDI trd_gdp credgrowth inflation gov_csmp divindex3 SSD3 t_*
xtabond2 RGDPPC_growth RGDPPC_PPP  `controls' t_*, gmm(RGDPPC_PPP `controls', lag(1 3) collapse) iv(t_*) two robust
outreg2 using pregrowthSSD.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls FDI trd_gdp credgrowth inflation gov_csmp divindex5 SSD5 t_*
xtabond2 RGDPPC_growth RGDPPC_PPP  `controls' t_*, gmm(RGDPPC_PPP `controls', lag(1 3) collapse) iv(t_*) two robust
outreg2 using pregrowthSSD.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

// no time fixed effects

local controls FDI trd_gdp credgrowth inflation gov_csmp divindexall SSD
xtabond2 RGDPPC_growth RGDPPC_PPP  `controls', gmm(RGDPPC_PPP `controls', lag(1 3) collapse) two robust
outreg2 using pregrowthSSD.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls FDI trd_gdp credgrowth inflation gov_csmp divindex3 SSD3
xtabond2 RGDPPC_growth RGDPPC_PPP  `controls', gmm(RGDPPC_PPP `controls', lag(1 3) collapse) two robust
outreg2 using pregrowthSSD.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

local controls FDI trd_gdp credgrowth inflation gov_csmp divindex5 SSD5
xtabond2 RGDPPC_growth RGDPPC_PPP  `controls', gmm(RGDPPC_PPP `controls', lag(1 3) collapse) two robust
outreg2 using pregrowthSSD.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)
