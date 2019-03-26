clear
capture log close
clear *
set more off

cd "Q:\Data\PIU\InfrastructureGovernance\Event_analysis\DataFiles"
local outfile "`dir'\Method1-non-dasia-2019-3-6.xlsx"
local reglist "igov_r gdp pd fb"

use coredata.dta
tsset ifscode year, yearly

replace dasia = dasia[_n-1] if missing(dasia)

drop if year > 2015 

//drop PICs
//foreach num of numlist 819	826	537	867	868	565	853	862	813	866	869	846	836 {
	//drop if ifscode == `num'
//}

gen lngdp_r = ln(NGDP_R)
replace lngdp_r = ln(NGDP_R) if missing(lngdp_r)


tsset ifscode year

gen f0gdp = d.lngdp_r
forvalues y = 1/10 {
	gen f`y'gdp = (f`y'.lngdp_r - l.lngdp_r)
	}	

gen f0pd =(pubdebt-l.pubdebt)
forvalues y = 1/10 {
	gen f`y'pd = (f`y'.pubdebt - l.pubdebt)
	}
	
gen f0igov_r = (igov_r-l.igov_r)
forvalues y = 1/10 {
	gen f`y'igov_r = (f`y'.igov_r - l.igov_r)
	}

gen f0fb = (fb_gdp-l.fb_gdp)
forvalues y = 1/10 {
	gen f`y'fb = (f`y'.fb_gdp - l.fb_gdp)
}

			
gen boom_begin  = 0
tsset ifscode year

///// Make new investment booms/////

***generate moving average - 3 years
egen igov_r_mvb3 = filter(igov_r),coef(1 1 1) lags(1/3) normalise
egen igov_r_mvf3 = filter(igov_r),coef(1 1 1) lags(-2/0) normalise

gen mv_diff = igov_r_mvf3 - igov_r_mvb3
egen mv_diff_p75 = pctile(mv_diff), by(ifscode) p(75)

gen nboom_begin = 0
replace nboom_begin = 1 if mv_diff > mv_diff_p75 & !missing(mv_diff)

gen nboom = 0
gen boom_c = nboom_begin[_n] + nboom_begin[_n+1] + nboom_begin[_n+2] 
replace nboom = 1 if boom_c == 3
replace nboom = 1 if mv_diff >2 & !missing(mv_diff)

gen n_boom_begin = nboom
replace n_boom_begin = 0 if l.nboom ==1 

save "Q:\Data\PIU\InfrastructureGovernance\Event_analysis\CountryCharts\boom_charts.dta", replace

//// Run only on EMDE ASIAN countries//////
drop if dasia == 0
//drop if year > 1990

*=======================================================================
* Basic specification with no lags of the dependent variable
*=======================================================================

foreach X of local reglist  {	 
	gen b_`X'=.
	gen se_`X'=.
		
	forvalues y = 0/10 {
	areg f`y'`X' n_boom_begin i.year, absorb(ifscode) cluster(ifscode)
	replace b_`X' = _b[n_boom_begin] if _n==`y'+1
	replace se_`X' = _se[n_boom_begin] if _n==`y'+1
	}
}

keep b_* se_* 
drop if _n>20
//export excel "`outfile'", sheet("Stata_IRFL0") firstrow(variables) sheetreplace
