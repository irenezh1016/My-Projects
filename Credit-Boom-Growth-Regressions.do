clear
cd "C:\Users\HZhang2\Desktop\APD\creditBoom"

import excel "C:\Users\HZhang2\Desktop\APD\creditBoom\wb_data3.xlsx", sheet("wb_data3") firstrow
destring gov_csmp FDI edu trd_gdp RGDPPC_PPP, replace force
kountry CountryCode, from(iso3c) to(imfn)

rename CountryCode code_wb
rename _IMFN_ CountryCode
rename year Year
drop code_wb
drop if missing(CountryCode)
save "C:\Users\HZhang2\Desktop\APD\creditBoom\wbdata.dta",replace


///////////////
//Financial development regression dummy


clear
use C:\Users\HZhang2\Desktop\APD\creditBoom\datastata.dta
//use C:\Users\HZhang2\Desktop\APD\creditBoom\cred-data-2019.dta

merge 1:1 Year CountryCode using C:\Users\HZhang2\Desktop\APD\creditBoom\wbdata.dta
drop _merge
drop if missing(Country)
rename Unique unique
save "C:\Users\HZhang2\Desktop\APD\creditBoom\merge1.dta",replace

use C:\Users\HZhang2\Desktop\APD\creditBoom\crisis.dta
merge 1:1 unique using C:\Users\HZhang2\Desktop\APD\creditBoom\merge1.dta
drop year _merge
drop if missing(CountryCode) &  missing(Year)
save "C:\Users\HZhang2\Desktop\APD\creditBoom\merge2.dta",replace

clear
import excel "\\DATA2\APD\Data\PIU\Export_Diversification\datacleaning\FDI_stata.xlsx", sheet("Panel") firstrow
rename code_id CountryCode
rename year Year
merge 1:1 CountryCode Year using C:\Users\HZhang2\Desktop\APD\creditBoom\merge2.dta
drop _merge

//NGDP is in billion national currency, population is in units
sort Country Year
gen GDPPC = NGDP*1000000000/Pop //in national currency, unit
gen GDPPC_growth = 100*((GDPPC[_n]/GDPPC[_n-1])-1)

gen RGDPPC = RGDPPC_PPP/1000 //in thousands
gen RGDPPC1 = RGDP*1000000000/Pop //non-PPP RGDPPC
gen RGDPPC_growth = 100*((RGDPPC1[_n]/RGDPPC1[_n-1])-1)
gen RGDPG = 100*((RGDP[_n]/RGDP[_n-1])-1)
encode Region, gen(region)
encode Income_IMF, gen(income)

//clean up years
drop if Year < 1992
drop if Year ==2017
drop if missing(Year)

//drop if Country == "Zimbabwe" | Country == "Belarus" | Country == "Venezuela, Republica Bolivariana de" | Country == "Zambia"


//clean up outliners
quietly sum RGDPPC_growth, d
gen RGDPPC_g_trim = RGDPPC_growth
replace RGDPPC_g_trim = . if RGDPPC_g_trim <= r(p1)|RGDPPC_g_trim>= r(p99)
replace RGDPPC_growth = RGDPPC_g_trim
drop RGDPPC_g_trim

replace cred2gdp = . if cred2gdp > 180 | cred2gdp < 5
replace credgrowth = . if credgrowth > 90 | credgrowth < -40
gen APD = 0
replace APD = 1 if Region == "APD"

br Country CountryCode Year credgrowth Crisis if credgrowth > 20 & !missing(credgrowth) | Crisis == 1

// Afghanistan, Islamic Republic of Congo, Democratic Republic of Country	Year Eritrea	1996 Kosovo, Republic of Kyrgyz Republic 1997 08 Sudan
//Tajikistan

foreach num of numlist 612 512 636 732 967 614	912	419	218	516	628	634	248	642	646	429	433	916	443	672	694	449	453	922	456	733	537	369	925	466	299	474 {
drop if CountryCode == `num'
}

br Country Year FD credgrowth RGDPG if Country == "Spain" | Country == "Greece" |Country == "United Kingdom" |Country == "Korea, Republic of" |Country == "Nepal"| Country == "Myanmar"| Country == "Bangladesh" | Country == "Lao People's Democratic Republic" | Country == "Cambodia"
//generate five-year average

sort CountryCode Year
xtile quant6 = Year, nq(5)
collapse (mean) RGDPPC_growth credgrowth cred2gdp gov_csmp Crisis edu trd_gdp FDI inflation FD (first) Income_IMF Country Region RGDPPC APD , by(CountryCode quant6)


//generate interation terms and controls
replace RGDPPC_growth = RGDPPC_growth/100
replace cred2gdp = cred2gdp/100
gen credgrowth2 = credgrowth^2
gen cred2gdp2 = cred2gdp^2

gen interaction = credgrowth * cred2gdp
gen interaction2 = interaction^2
gen control = RGDPPC * credgrowth
gen control2 = control^2

tabulate quant6, generate(t_)
replace Crisis = 1 if Crisis !=. & Crisis !=0

foreach var of varlist FDI edu gov_csmp trd_gdp RGDPPC {
	gen l`var' = log(`var')
}



foreach var of varlist FDI edu gov_csmp trd_gdp  {
	gen n`var' = `var'/100
	replace `var' = n`var'
	drop n`var'
}

gen FD_AD = 0
replace FD_AD = 1 if FD > .7224529  & !missing(FD)
gen FD_control = FD_AD * credgrowth
gen FD_control2 = FD_control ^2

gen FD_LD = 0
replace FD_LD = 1 if FD <  .15   & !missing(FD)
gen LD_control = FD_LD * credgrowth
gen LD_control2 = LD_control ^2

gen FD_MD = 0
replace FD_MD = 1 if FD >  .15   & FD < .7224529 & !missing(FD)
gen MD_control = FD_MD * credgrowth
gen MD_control2 = MD_control ^2

gen LIDC = 0
replace LIDC = 1 if Income_IMF == "LIDC"
gen LIDC_control = LIDC * credgrowth

gen EM = 0
replace EM = 1 if Income_IMF == "EMDE" 
gen EM_control = EM * credgrowth

gen AE = 0
replace AE = 1 if Income_IMF == "AE" 
gen AE_control = AE * credgrowth

gen FI_control = FD * credgrowth
gen FI_control2 = FI_control ^ 2

br Country code Year FD credgrowth FD_LD FD_AD if FD_LD == 1 | FD_AD == 1


//replace RGDPPC = log(RGDPPC)
********************************************************************************************************
//xtset CountryCode Year

//reg RGDPPC_growth credgrowth
//reg RGDPPC_growth l.credgrowth
//reg RGDPPC_growth cred2gdp cred2gdp2
//reg RGDPPC_growth l.cred2gdp
//reg RGDPPC_growth credgrowth credgrowth2
//reg RGDPPC_growth credgrowth cred2gdp
//reg RGDPPC_growth credgrowth cred2gdp credgrowth2
//reg RGDPPC_growth credgrowth cred2gdp interaction
//reg RGDPPC_growth credgrowth credgrowth2 cred2gdp interaction

//reg RGDPPC_growth  credgrowth credgrowth2 lFDI ledu Crisis lgov_csmp ltrd_gdp lRGDPPC

//reg RGDPPC_growth cred2gdp cred2gdp2 lFDI ledu Crisis lgov_csmp ltrd_gdp lRGDPPC
//outreg2 using 2-21-2019-FINAL1.xls

//reg RGDPPC_growth cred2gdp cred2gdp2 FDI edu Crisis gov_csmp trd_gdp lRGDPPC
//outreg2 using 2-21-2019-FINAL1.xls

//xtreg RGDPPC_growth RGDPPC credgrowth credgrowth2 FDI edu Crisis gov_csmp trd_gdp i.Year if Income_IMF == "EMDE", fe vce(robust)
//xtreg RGDPPC_growth RGDPPC credgrowth credgrowth2 FDI edu Crisis gov_csmp trd_gdp i.Year if Income_IMF == "LIDC", fe vce(robust)

********************************************************************************************************
********************************************************************************************************
br Country quant6 FD credgrowth if Country == "Spain" | Country == "Nepal"| Country == "Myanmar"| Country == "Bangladesh" | Country == "Lao People's Democratic Republic" | Country == "Cambodia"
//6-6-2018 9 sets of regressionsq
**** lag limit, iv(eq(diff) or eq(level)) 

***************************************
//Crisis = 0 if Year > 2012
***************************************
xtset CountryCode quant6


*******BASELINE CREDIT TO GDP*************

****************************
****************************
local controls FDI Crisis edu gov_csmp trd_gdp  
local cred credgrowth credgrowth2 LD_control2
xtabond2 RGDPPC_growth lRGDPPC `cred' `controls' t_*, gmm(lRGDPPC `controls', lag(1 3) ) gmm(`cred', lag(1 2) collapse) iv(t_*) two robust
outreg2 using 3-4-2019-FINAL1.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)
****************************
local controls FDI Crisis edu gov_csmp trd_gdp  
local cred credgrowth credgrowth2 LD_control LD_control2
xtabond2 RGDPPC_growth lRGDPPC `cred' `controls' t_*, gmm(lRGDPPC `controls', lag(1 3) ) gmm(`cred', lag(1 2) collapse) iv(t_*) two robust
outreg2 using 3-4-2019-FINAL1.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)
****************************
local controls FDI Crisis edu gov_csmp trd_gdp
local cred credgrowth credgrowth2 FD_control2
xtabond2 RGDPPC_growth lRGDPPC `cred' `controls' t_*, gmm(lRGDPPC `controls', lag(1 3) ) gmm(`cred', lag(1 2) collapse) iv(t_*) two robust
outreg2 using 3-4-2019-FINAL1.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)
****************************
local controls FDI Crisis edu gov_csmp trd_gdp
local cred credgrowth credgrowth2 FD_control FD_control2
xtabond2 RGDPPC_growth lRGDPPC `cred' `controls' t_*, gmm(lRGDPPC `controls', lag(1 3) ) gmm(`cred', lag(1 2) collapse) iv(t_*) two robust
outreg2 using 3-4-2019-FINAL1.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

****************************

local controls FDI Crisis edu gov_csmp trd_gdp
local cred credgrowth credgrowth2 MD_control MD_control2
xtabond2 RGDPPC_growth lRGDPPC `cred' `controls' t_*, gmm(lRGDPPC `controls', lag(1 3) ) gmm(`cred', lag(1 2) collapse) iv(t_*) two robust
outreg2 using 3-4-2019-FINAL1.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

****************************
local controls FDI Crisis edu gov_csmp trd_gdp
local cred credgrowth credgrowth2 MD_control2
xtabond2 RGDPPC_growth lRGDPPC `cred' `controls' t_*, gmm(lRGDPPC `controls', lag(1 3) ) gmm(`cred', lag(1 2) collapse) iv(t_*) two robust
outreg2 using 3-4-2019-FINAL1.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)

****************************

local cred credgrowth credgrowth2 LD_control LD_control2
xtabond2 RGDPPC_growth lRGDPPC `cred' `controls' t_*, gmm(lRGDPPC `controls', lag(1 3) ) gmm(`cred', lag(1 2) collapse) iv(t_*) two robust
outreg2 using 3-4-2019-FINAL1.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)
****************************
local cred credgrowth credgrowth2 FD_control FD_control2
xtabond2 RGDPPC_growth lRGDPPC `cred' `controls' t_*, gmm(lRGDPPC `controls', lag(1 3) ) gmm(`cred', lag(1 2) collapse) iv(t_*) two robust
outreg2 using 3-4-2019-FINAL1.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)
****************************
local controls FDI  
local cred credgrowth credgrowth2 LD_control LD_control2
xtabond2 RGDPPC_growth lRGDPPC `cred' `controls' t_*, gmm(lRGDPPC `controls', lag(1 3) ) gmm(`cred', lag(1 2) collapse) iv(t_*) two robust
outreg2 using 3-4-2019-FINAL1.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)
****************************
local controls FDI 
local cred credgrowth credgrowth2 FD_control FD_control2
xtabond2 RGDPPC_growth lRGDPPC `cred' `controls' t_*, gmm(lRGDPPC `controls', lag(1 3) ) gmm(`cred', lag(1 2) collapse) iv(t_*) two robust
outreg2 using 3-4-2019-FINAL1.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)
****************************
local controls FDI Crisis   
local cred credgrowth credgrowth2 LD_control LD_control2
xtabond2 RGDPPC_growth lRGDPPC `cred' `controls' t_*, gmm(lRGDPPC `controls', lag(1 3) ) gmm(`cred', lag(1 2) collapse) iv(t_*) two robust
outreg2 using 3-4-2019-FINAL1.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)
****************************
local controls FDI Crisis 
local cred credgrowth credgrowth2 FD_control FD_control2
xtabond2 RGDPPC_growth lRGDPPC `cred' `controls' t_*, gmm(lRGDPPC `controls', lag(1 3) ) gmm(`cred', lag(1 2) collapse) iv(t_*) two robust
outreg2 using 3-4-2019-FINAL1.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)
****************************
local controls FDI Crisis edu 
local cred credgrowth credgrowth2 LD_control LD_control2
xtabond2 RGDPPC_growth lRGDPPC `cred' `controls' t_*, gmm(lRGDPPC `controls', lag(1 3) ) gmm(`cred', lag(1 2) collapse) iv(t_*) two robust
outreg2 using 3-4-2019-FINAL1.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)
****************************
local controls FDI Crisis edu 
local cred credgrowth credgrowth2 FD_control FD_control2
xtabond2 RGDPPC_growth lRGDPPC `cred' `controls' t_*, gmm(lRGDPPC `controls', lag(1 3) ) gmm(`cred', lag(1 2) collapse) iv(t_*) two robust
outreg2 using 3-4-2019-FINAL1.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)
****************************
local controls FDI Crisis edu gov_csmp 
local cred credgrowth credgrowth2 LD_control LD_control2
xtabond2 RGDPPC_growth lRGDPPC `cred' `controls' t_*, gmm(lRGDPPC `controls', lag(1 3) ) gmm(`cred', lag(1 2) collapse) iv(t_*) two robust
outreg2 using 3-4-2019-FINAL1.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)
****************************
local controls FDI Crisis edu gov_csmp 
local cred credgrowth credgrowth2 FD_control FD_control2
xtabond2 RGDPPC_growth lRGDPPC `cred' `controls' t_*, gmm(lRGDPPC `controls', lag(1 3) ) gmm(`cred', lag(1 2) collapse) iv(t_*) two robust
outreg2 using 3-4-2019-FINAL1.xls, append ctitle(regression 0) label tstat coefastr addstat(AR2 ,e(ar2p),Hansen,e(hansenp),Instruments,e(j)) tdec(3) drop(t_*)
****************************
