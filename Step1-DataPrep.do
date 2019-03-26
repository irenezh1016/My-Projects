***************************************************************
* Program: Analyze macroeconomic performance surrounding booms
*
* Project: Infrastructure Governance
*
* Authors: hzhang2@imf.org
* Created: March 4th 2019
***************************************************************

**********************
*Preparing WEO dataset
**********************
clear
local dir "Q:\Data\PIU\InfrastructureGovernance\Event_analysis\DataFiles"

import excel "Q:\Data\PIU\InfrastructureGovernance\Event_analysis\DataFiles\weo_data-3-05.xlsx", sheet ("weo_data-3-05") firstrow
destring, force replace
rename GGXWDG_GDP ggxwdg //public debt
rename GGXCNL_GDP fb_gdp //fiscal balance

rename CountryCode ifscode
drop GGAAN_T

save "Q:\Data\PIU\InfrastructureGovernance\Event_analysis\DataFiles\WEO.dta", replace

***********************************************
*Preparing Public Investment dataset from FAD
***********************************************

clear
import excel "Q:\Data\PIU\InfrastructureGovernance\Event_analysis\DataFiles\igov-r.xlsx", sheet ("Sheet1") firstrow
save "Q:\Data\PIU\InfrastructureGovernance\Event_analysis\DataFiles\pubinv.dta", replace

*************************
*Merge with Coredatabase
*************************
clear

capture log close
clear *
set more off

cd "Q:\Data\PIU\InfrastructureGovernance\Event_analysis\DataFiles"
local dir "Q:\Data\PIU\InfrastructureGovernance\Event_analysis\DataFiles"
local coredataset  "`dir'\0_FinalAnnualDataset.dta"

use `coredataset', replace
tsset ifscode year, yearly

keep ifscode year country publicdebt igov_gdp igov_gdp_boomA_start igov_gdp_boomA igov_gdp_boomA_dur dasia ae 

merge 1:1 ifscode year using WEO.dta
sort ifscode year
drop _merge

merge 1:1 ifscode year using pubinv.dta
drop _merge
replace dasia = dasia[_n-1] if missing(dasia)

//generate new public debt series
gen pubdebt = publicdebt
replace pubdebt = ggxwdg if !missing(ggxwdg)

////Label variables
label variable igov_r "in billions of constant 2011 international dollars"
label variable pubdebt "public debt in % of GDP"
label variable fb "fiscal balance in % of GDP"
label variable NGDP_RPCH "real GDP growth (%)"

save "Q:\Data\PIU\InfrastructureGovernance\Event_analysis\DataFiles\coredata.dta", replace
