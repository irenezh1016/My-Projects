********************************************************************************
********************************************************************************

***************************************
***************************************
***************************************
***************************************
********STYLIZED FACTS*****************
***************************************
***************************************
***************************************
***************************************
***************************************

clear
set mat 11000
set more off

cd  "Q:\Data\PIU\Export_Diversification\datacleaning"
import excel "Q:\Data\PIU\Export_Diversification\datacleaning\expdivdb_final2.xlsx", sheet("expdivdb_final") firstrow

destring g_food-RGDPPC_growth, force replace
xtset country_code Year
save expdiv_gmm.dta, replace

clear
import excel "\\DATA2\APD\Data\PIU\Export_Diversification\datacleaning\FDI_stata.xlsx", sheet("Panel") firstrow
rename code_id country_code
rename year Year

merge 1:1 Year country_code using expdiv_gmm.dta
destring, replace
drop _merge

gen ss = 0 
replace ss = 1 if country_code == 624|country_code == 632|country_code ==	684|country_code ==	716|country_code ==	718|country_code ==	734|country_code ==	514|country_code ==	819|country_code ==	826	|country_code ==556	|country_code ==867	|country_code ==868	|country_code ==565 |country_code ==862	|country_code ==813	|country_code ==537	|country_code ==866	|country_code ==869	|country_code ==846	|country_code ==943	|country_code ==611	|country_code ==311	|country_code ==313	|country_code ==316	|country_code ==339	|country_code ==321 |country_code ==328	|country_code ==336	|country_code ==361	|country_code ==362	|country_code ==364	|country_code ==366	|country_code ==369

keep if ss == 1| country_group == "LIDC"

sort country_code Year
gen RGDPG = (RGDP[_n]/RGDP[_n-1]-1)*100
gen POPG = (pop[_n]/pop[_n-1]-1)*100

drop if Year < 2001
drop if Year > 2015
//drop if country == "PLW"| country== "MNE"|country== "TUV"

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

gen lpop = log(POP)

/////VOL calculations
//drop if Year > 2010
//drop if Year < 2011
egen vol = sd(RGDPPC_growth), by(country)
collapse (mean)  divindexall divindex3 divindex5 idx_g idx_s RGDPG (first) vol country_group ss (lastnm) POP, by(country)


//gen quant5 = 0
//replace quant5 = 1 if Year >2000 & Year <2004
//replace quant5 = 2 if Year >2003 & Year <2007
//replace quant5 = 3 if Year >2006 & Year <2010
//replace quant5 = 4 if Year >2009 & Year <2013
//replace quant5 = 5 if Year >2012 & Year <2016


twoway scatter divindexall vol  || lfit divindexall vol , ytitle("Diversification Index") xtitle("Real GDP Volatility") title("Diversification and Volatility in LIDC and SS")
twoway scatter divindexall RGDPG || lfit divindexall RGDPG, ytitle("Diversification Index") xtitle("Real GDP Growth") title("Diversification and Growth in LIDC and SS")

twoway scatter idx_g vol  || lfit idx_g vol , ytitle("Diversification Index (goods sector)") xtitle("Real GDP Volatility") title("Diversification and Volatility in LIDC and SS")
twoway scatter idx_g RGDPG || lfit idx_g RGDPG, ytitle("Diversification Index (goods sector)") xtitle("Real GDP Growth") title("Diversification and Growth in LIDC and SS")


twoway scatter idx_s vol  || lfit idx_s vol , ytitle("Diversification Index (service sector)") xtitle("Real GDP Volatility") title("Diversification and Volatility in LIDC and SS")
twoway scatter idx_s RGDPG || lfit idx_s RGDPG, ytitle("Diversification Index (service sector)") xtitle("Real GDP Growth") title("Diversification and Growth in LIDC and SS")



twoway scatter divindexall vol if  ss == 1 || lfit divindexall vol if  ss == 1 , ytitle("Diversification Index") xtitle("Real GDP Volatility") title("Diversification and Volatility in SS")
twoway scatter divindexall RGDPG if  ss == 1 || lfit divindexall RGDPG if  ss == 1, ytitle("Diversification Index") xtitle("Real GDP growth") title("Diversification and Growth in SS")

twoway scatter divindex3 vol if  ss == 1 || lfit divindex3 vol if  ss == 1 , ytitle("Diversification Index (top 3 sectors)") xtitle("Real GDP Volatility") title("Diversification and Volatility in SS")
twoway scatter divindex3 RGDPG if  ss == 1 || lfit divindex3 RGDPG if  ss == 1, ytitle("Diversification Index (top 3 sectors)") xtitle("Real GDP growth") title("Diversification and Growth in SS")

twoway scatter divindex5 vol if  ss == 1 || lfit divindex5 vol if  ss == 1 , ytitle("Diversification Index (top 3 sectors)") xtitle("Real GDP Volatility") title("Diversification and Volatility in SS")
twoway scatter divindex5 RGDPG if  ss == 1 || lfit divindex5 RGDPG if  ss == 1, ytitle("Diversification Index (top 3 sectors)") xtitle("Real GDP growth") title("Diversification and Growth in SS")

//non-overlapping every 3 year
xtile quant5 = Year, nq(5)
collapse (mean) gs_ratio s_ratio tourism cmmdty RGDPG RGDPPC_growth credgrowth cred2gdp gov_csmp trd_gdp pop FDI divindexall inflation idx_g idx_s divindexall5 divindexall4 divindexall3 divindexall2 divindex3 divindex5 POPG (first) ss FD FI FM  RGDP RGDPPC_PPP (last) FDIVOL gov_csmpvol trd_gdpvol inflvol credg_vol cred2gdp_vol RGDPVOL, by(country_code quant5)

//LIDC and SS
twoway scatter divindexall RGDPG  || lfit divindexall RGDPG, ytitle("Diversification Index") xtitle("Real GDP Growth") title("Diversification and Real GDP growth in LIDC and SS")
twoway scatter divindexall RGDPVOL  || lfit divindexall RGDPVOL, ytitle("Diversification Index") xtitle("Real GDP Volatility") title("Diversification and Volatility in LIDC and SS")


//SS
twoway scatter divindexall RGDPG if  ss == 1  || lfit divindexall RGDPG if  ss == 1 , ytitle("Diversification Index") xtitle("Real GDP Growth") title("Diversification and Real GDP growth in SS")
twoway scatter divindexall RGDPVOL if  ss == 1 || lfit divindexall RGDPVOL if  ss== 1 , ytitle("Diversification Index") xtitle("Real GDP Volatility") title("Diversification and Volatility in SS")

twoway scatter divindex3 RGDPG if ss == 1|| lfit divindex3 RGDPG if ss == 1 , ytitle("Diversification Index (Top 3 sectors)") xtitle("Real GDP Growth") title("Diversification and Real GDP growth in SS")
twoway scatter divindex3 RGDPVOL if  ss == 1 || lfit divindex3 RGDPVOL if  ss== 1 , ytitle("Diversification Index (Top 3 sectors)") xtitle("Real GDP Volatility") title("Diversification and Volatility in SS")

//population
twoway scatter divindexall lpop if Year == 2015  || lfit divindexall lpop if Year == 2015, ylabel(0(0.2)1) ytitle("Diversification Index") xtitle("Log Population") title("Diversification and Population")
twoway scatter divindex3 lpop if Year == 2015 || lfit divindexall lpop if Year == 2015 , ylabel(0(0.2)1) ytitle("Diversification Index (top 3 sectors)") xtitle("Log Population") title("Diversification and Population")

twoway scatter divindexall lpop || lfit divindexall lpop, ytitle("Diversification Index") xtitle("Log Population") title("Diversification and Population")
twoway scatter divindex3 lpop || lfit divindexall lpop, ytitle("Diversification Index (top 3 sectors)") xtitle("Log Population") title("Diversification and Population")


twoway scatter divindexall RGDPPC_PPP || lfit divindexall RGDPPC_PPP , ytitle("Diversification Index") xtitle("Real GDP percapita PPP")

twoway scatter divindexall RGDPVOL if ss==1 & Year > 2012 || lfit divindexall RGDPVOL if ss==1 & Year > 2012, ytitle("Diversification Index") xtitle("Real GDP Volatility")
drop if RGDPVOL > 15
twoway scatter divindexall RGDPVOL if Year > 2012 || lfit divindexall RGDPVOL if Year > 2012, ytitle("Diversification Index") xtitle("Real GDP Volatility")

drop if RGDPG < 0 |RGDPG > 10
twoway scatter divindexall RGDPG if Year > 2012 || lfit divindexall RGDPG if Year > 2012, ytitle("Diversification Index") xtitle("Real GDP Growth")

twoway scatter divindexall RGDPG if ss==1 & Year > 2012 || lfit divindexall RGDPG if ss==1 & Year > 2012, ytitle("Diversification Index") xtitle("Real GDP Growth")
twoway scatter divindexall RGDPG if ss==1 & Year < 2012 || lfit divindexall RGDPG if ss==1 & Year < 2012, ytitle("Diversification Index") xtitle("Real GDP Growth")
twoway scatter divindexall RGDPG if ss==0 & country_group == "LIDC" || lfit divindexall RGDPG if ss==0 & country_group == "LIDC", ytitle("Diversification Index") xtitle("Real GDP Growth")
twoway scatter divindexall RGDPG if ss==0 & country_group == "LIDC" & Year > 2012|| lfit divindexall RGDPG if ss==0 & country_group == "LIDC" & Year > 2012, ytitle("Diversification Index") xtitle("Real GDP Growth")

twoway scatter divindexall RGDPG if ss==1 & country_group == "LIDC" || lfit divindexall RGDPG if ss==0 & country_group == "LIDC", ytitle("Diversification Index") xtitle("Real GDP Growth")
twoway scatter divindexall RGDPG if ss==1  || lfit divindexall RGDPG if ss==1 , ytitle("Diversification Index") xtitle("Real GDP Growth")
twoway scatter divindexall RGDPG if ss==1 & Year > 2012 || lfit divindexall RGDPG if ss==1 & Year > 2012, ytitle("Diversification Index") xtitle("Real GDP Growth")

twoway scatter idx_g RGDPG if Year > 2012|| lfit idx_g RGDPG if Year > 2012
twoway scatter idx_s RGDPG if Year > 2012|| lfit idx_s RGDPG if Year > 2012

xtile quant5 = Year, nq(5)
collapse (mean) RGDPG RGDPPC_growth credgrowth cred2gdp gov_csmp trd_gdp pop FDI divindexall inflation idx_g idx_s divindexall5 divindexall4 divindexall3 divindexall2 FDIVOL RGDPVOL gov_csmpvol trd_gdpvol inflvol credg_vol cred2gdp_vol  (first) ss FD FI FM  RGDP RGDPPC_PPP , by(country_code quant5)

twoway scatter idx_g RGDPG || lfit idx_g RGDPG 
twoway scatter idx_s RGDPG || lfit idx_s RGDPG 

twoway scatter idx_g RGDPG if quant5 == 5 || lfit idx_g RGDPG if quant5 == 5
twoway scatter idx_s RGDPG if quant5 == 5|| lfit idx_s RGDPG if quant5 == 5

twoway scatter idx_g RGDPPC_PPP if country_code==819 || lfit idx_g RGDPPC_PPP if country_code==819
twoway scatter idx_g RGDPPC_PPP if country_code==826 || lfit idx_g RGDPPC_PPP if country_code==826

twoway scatter idx_g RGDPPC_PPP if country_code==688 || lfit idx_g RGDPPC_PPP if country_code==688
twoway scatter idx_g RGDPPC_PPP if country_code==513 || lfit idx_g RGDPPC_PPP if country_code==513
twoway scatter idx_g RGDPPC_PPP if country_code==537 || lfit idx_g RGDPPC_PPP if country_code==537
twoway scatter idx_g RGDPPC_PPP if country_code==313 || lfit idx_g RGDPPC_PPP if country_code==313
twoway scatter idx_g RGDPPC_PPP if country_code==514 || lfit idx_g RGDPPC_PPP if country_code==514
twoway scatter idx_g RGDPPC_PPP if country_code==556 || lfit idx_g RGDPPC_PPP if country_code==556
