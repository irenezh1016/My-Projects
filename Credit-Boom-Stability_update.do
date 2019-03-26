clear
cd "C:\Users\HZhang2\Desktop\APD\creditBoom"

import excel "C:\Users\HZhang2\Desktop\APD\creditBoom\wb_data4.xlsx", sheet("wb_data4") firstrow
destring gov_csmp FDI edu trd_gdp RGDPPC_PPP CAB rev_imp, replace force
kountry CountryCode, from(iso3c) to(imfn)
rename CountryCode code_wb
rename _IMFN_ CountryCode
rename year Year
drop code_wb
drop if missing(CountryCode)
save "C:\Users\HZhang2\Desktop\APD\creditBoom\wbdata.dta",replace

clear
use C:\Users\HZhang2\Desktop\APD\creditBoom\datastata.dta
merge 1:1 Year CountryCode using C:\Users\HZhang2\Desktop\APD\creditBoom\wbdata.dta
drop _merge
drop if missing(Country)
rename Unique unique
save "C:\Users\HZhang2\Desktop\APD\creditBoom\merge1.dta",replace

use C:\Users\HZhang2\Desktop\APD\creditBoom\crisis.dta
merge 1:1 unique using C:\Users\HZhang2\Desktop\APD\creditBoom\merge1.dta
drop year _merge

drop if missing(CountryCode) | missing(Year)
save "C:\Users\HZhang2\Desktop\APD\creditBoom\merge2.dta",replace

clear
import excel "C:\Users\HZhang2\Desktop\APD\creditBoom\reergap.xlsx", sheet("Sheet1") firstrow
save "C:\Users\HZhang2\Desktop\APD\creditBoom\REERGAP.dta",replace

use C:\Users\HZhang2\Desktop\APD\creditBoom\merge2.dta
merge 1:1 CountryCode Year using C:\Users\HZhang2\Desktop\APD\creditBoom\REERGAP.dta
drop _merge 
drop if Year < 1990
drop if missing(unique)

//NGDP is in billion national currency, population is in units
sort Country Year
gen GDPPC = NGDP*1000000000/Pop //in national currency, unit
gen GDPPC_growth = 100*((GDPPC[_n]/GDPPC[_n-1])-1)
gen NFA = NRLiab/NGDP*100

gen RGDPPC = RGDPPC_PPP/1000 //in thousands
gen RGDPPC1 = RGDP*1000000000/Pop //non-PPP RGDPPC
gen RGDPPC_growth = 100*((RGDPPC1[_n]/RGDPPC1[_n-1])-1)
encode Region, gen(region)
encode Income_IMF, gen(income)

//clean up years
//drop if Year < 1992
drop if Year ==2017
drop if missing(Year)

//drop small states and HK Macao
//drop if CountryCode == 624|CountryCode ==	632|CountryCode ==	684|CountryCode ==	716|CountryCode ==	718|CountryCode ==	734|CountryCode ==	514|CountryCode ==	819|CountryCode ==	826	|CountryCode ==556	|CountryCode ==867	|CountryCode ==868	|CountryCode ==565 |CountryCode ==862	|CountryCode ==813	|CountryCode ==537	|CountryCode ==866	|CountryCode ==869	|CountryCode ==846	|CountryCode ==943	|CountryCode ==611	|CountryCode ==311	|CountryCode ==313	|CountryCode ==316	|CountryCode ==339	|CountryCode ==321 |CountryCode ==328	|CountryCode ==336	|CountryCode ==361	|CountryCode ==362	|CountryCode ==364	|CountryCode ==366	|CountryCode ==369 |CountryCode == 532 |CountryCode ==546
//drop if Income_IMF == "AE"
//clean up outliners
quietly sum RGDPPC_growth, d
gen RGDPPC_g_trim = RGDPPC_growth
replace RGDPPC_g_trim = . if RGDPPC_g_trim <= r(p1)|RGDPPC_g_trim>= r(p99)
replace RGDPPC_growth = RGDPPC_g_trim
drop RGDPPC_g_trim

replace cred2gdp = . if cred2gdp > 180 | cred2gdp < 5
replace credgrowth = . if credgrowth > 300 | credgrowth < -50
gen APD = 0
replace APD = 1 if Region == "APD"

//generate five-year average
sort CountryCode Year
//xtile quant6 = Year, nq(5)
//collapse (mean) RGDPPC_growth credgrowth cred2gdp gov_csmp Crisis edu trd_gdp FDI (first) RGDPPC APD, by(CountryCode quant6)

// generate interation terms and controls
//gen credgrowth2 = credgrowth^2
gen interaction = (credgrowth/100) * cred2gdp
gen CAD = -CAB
//gen interaction2 = interaction^2
//gen control = RGDPPC * credgrowth

//tabulate quant6, generate(t_)
//replace Crisis = 1 if Crisis !=. & Crisis !=0



xtset CountryCode Year
***************************************
xtlogit Crisis CAB rev_imp inflation cred2gdp RGDPgrowth, fe nolog // not significant
outreg2 using 8-16.xls, append
xtprobit Crisis CAB rev_imp inflation cred2gdp RGDPgrowth, vce(robust) nolog // significant 
outreg2 using 8-16.xls, append

xtlogit Crisis CAB rev_imp inflation credgrowth RGDPgrowth, fe nolog // not significant
outreg2 using 8-16.xls, append
xtprobit Crisis CAB rev_imp inflation credgrowth RGDPgrowth, vce(robust) nolog // significant 
outreg2 using 8-16.xls, append

xtlogit Crisis CAB rev_imp inflation interaction RGDPgrowth, fe nolog // not significant
outreg2 using 8-16.xls, append
xtprobit Crisis CAB rev_imp inflation interaction RGDPgrowth, vce(robust) nolog // significant 
outreg2 using 8-16.xls, append

xtlogit Crisis CAB rev_imp inflation interaction credgrowth RGDPgrowth, fe nolog // not significant
outreg2 using 8-16.xls, append
xtprobit Crisis CAB rev_imp inflation interaction credgrowth RGDPgrowth, vce(robust) nolog // significant 
outreg2 using 8-16.xls, append

****************************************** Contemporary
xtlogit Crisis CAD rev_imp inflation cred2gdp RGDPgrowth, fe nolog // not significant
outreg2 using 8-16.xls, append
xtprobit Crisis CAD rev_imp inflation cred2gdp RGDPgrowth, vce(robust) nolog // significant 
outreg2 using 8-16.xls, append

xtlogit Crisis CAD rev_imp inflation credgrowth RGDPgrowth, fe nolog // not significant
outreg2 using 8-16.xls, append
xtprobit Crisis CAD rev_imp inflation credgrowth RGDPgrowth, vce(robust) nolog // significant 
outreg2 using 8-16.xls, append
margins, at(credgrowth = (0(10)100)) atmeans
marginsplot, ylabel(0(0.05)0.15)


xtlogit Crisis CAD rev_imp inflation interaction RGDPgrowth, fe nolog // not significant
outreg2 using 8-16.xls, append
xtprobit Crisis CAD rev_imp inflation interaction RGDPgrowth, vce(robust) nolog // significant 
outreg2 using 8-16.xls, append

xtlogit Crisis CAD rev_imp inflation interaction credgrowth RGDPgrowth, fe nolog // not significant
margins, at(interaction = (0(10)100)) atmeans
marginsplot, ylabel(0(0.5)1.5) xtitle("Credit growth x Credit-to-GDP")
outreg2 using 8-16.xls, append
xtprobit Crisis CAD rev_imp inflation interaction credgrowth RGDPgrowth, vce(robust) nolog // significant 
outreg2 using 8-16.xls, append

xtlogit Crisis CAD rev_imp inflation interaction cred2gdp credgrowth RGDPgrowth, fe nolog // not significant

xtprobit Crisis CAD rev_imp inflation interaction cred2gdp credgrowth RGDPgrowth, vce(robust) nolog // significant 

****************************************** Lag
xtlogit Crisis L.CAD L.rev_imp inflation L.cred2gdp RGDPgrowth, fe nolog // not significant
//predict pcrisis if e(sample), xb
//roctab Crisis pcrisis
//outreg2 using test.xls
outreg2 using 8-16.xls, append
xtprobit Crisis L.CAD L.rev_imp inflation L.cred2gdp RGDPgrowth, vce(robust) nolog // significant 
outreg2 using 8-16.xls, append

xtlogit Crisis L.CAD L.rev_imp inflation L.credgrowth RGDPgrowth, fe nolog // not significant
outreg2 using 8-16.xls, append
xtprobit Crisis L.CAD L.rev_imp inflation L.credgrowth, vce(robust) nolog // significant 
outreg2 using 8-16.xls, append

xtlogit Crisis L.CAD L.rev_imp inflation L.interaction RGDPgrowth, fe nolog // not significant
outreg2 using 8-16.xls, append
xtprobit Crisis L.CAD L.rev_imp inflation L.interaction RGDPgrowth, vce(robust) nolog // significant 
outreg2 using 8-16.xls, append

xtlogit Crisis L.CAD L.rev_imp inflation L.interaction L.credgrowth RGDPgrowth, fe nolog // not significant
outreg2 using 8-16.xls, append
xtprobit Crisis L.CAD L.rev_imp inflation L.interaction L.credgrowth RGDPgrowth, vce(robust) nolog // significant 
outreg2 using 8-16.xls, append

xtprobit Crisis L.CAD L.rev_imp inflation L.cred2gdp L.credgrowth RGDPgrowth, vce(robust) nolog // significant 
xtlogit Crisis L.CAD L.rev_imp inflation L.cred2gdp L.credgrowth RGDPgrowth, fe nolog // significant 

xtlogit Crisis L.CAD L.rev_imp inflation L.cred2gdp*L.credgrowth RGDPgrowth, fe nolog // significant 

xtlogit Crisis L.CAD L.rev_imp inflation L.interaction  RGDPgrowth, fe nolog // not significant



****************************************************************************
rename CountryCode country_code
rename Year year
drop unique
merge 1:m country_code year using "C:\Users\HZhang2\Desktop\APD\creditBoom\Final_results_all.dta"
drop _merge


foreach var of varlist credgrowth RGDPgrowth cred2gdp inflation CAB Crisis {
	twoway (line `var' year if country_code == 522 & year > 2004 & year < 2012, lcolor(lavender)), name(`var',replace) ytitle(`var') 
}
graph combine credgrowth RGDPgrowth cred2gdp inflation CAB Crisis, title("Cambodia, credit boom 2008")
graph export Cambodia.emf, replace

foreach var of varlist credgrowth RGDPgrowth cred2gdp inflation CAB Crisis {
	twoway (line `var' year if country_code == 514 & year > 2005 & year < 2013, lcolor(lavender)), name(`var',replace) ytitle(`var') 
}
graph combine credgrowth RGDPgrowth cred2gdp inflation CAB Crisis, title("Buthan, credit boom 2009")
graph export Buthan.emf, replace

foreach var of varlist credgrowth RGDPgrowth cred2gdp inflation CAB Crisis {
	twoway (line `var' year if country_code == 524 & year > 2007 & year < 2014, lcolor(lavender)), name(`var',replace) ytitle(`var') 
}
graph combine credgrowth RGDPgrowth cred2gdp inflation CAB Crisis, title("Sri Lanka, credit boom 2010")
graph export SriLanka.emf, replace

foreach var of varlist credgrowth RGDPgrowth cred2gdp inflation CAB Crisis {
	twoway (line `var' year if country_code == 544 & year > 2005 & year < 2013, lcolor(lavender)), name(`var',replace) ytitle(`var') 
}
graph combine credgrowth RGDPgrowth cred2gdp inflation CAB Crisis, title("Lao, credit boom 2009")
graph export Lao.emf, replace

foreach var of varlist credgrowth RGDPgrowth cred2gdp inflation CAB Crisis {
	twoway (line `var' year if country_code == 582 & year > 2003 & year < 2011, lcolor(lavender)), name(`var',replace) ytitle(`var') 
}
graph combine credgrowth RGDPgrowth cred2gdp inflation CAB Crisis, title("Vietnam, credit boom 2007")
graph export Viet.emf, replace

foreach var of varlist credgrowth RGDPgrowth cred2gdp inflation CAB Crisis {
	twoway (line `var' year if country_code == 948 & year > 2007 & year < 2015, lcolor(lavender)), name(`var',replace) ytitle(`var') 
}
graph combine credgrowth RGDPgrowth cred2gdp inflation CAB Crisis, title("Mongolia, credit boom 2011")
graph export MNG.emf, replace


