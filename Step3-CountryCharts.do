clear
cd "Q:\Data\PIU\InfrastructureGovernance\Event_analysis\CountryCharts"
use boom_charts.dta

local print_control = "graph print"
*local print_control = ""

*==========================================================
* Charts on Booms
*==========================================================

replace country = "Sri_Lanka" if country == "Sri Lanka"
replace country = "Laos"      if country == "Lao P.D.R."

/*
	Bangladesh
	Bhutan
	Brunei Darussalam
	Myanmar
	Cambodia
	Sri Lanka
	India
	Indonesia
	Timor-Leste
	Lao P.D.R.
	Malaysia
	Maldives
	Nepal
	Philippines
	Thailand
	Vietnam
	Papua New Guinea
	China
	Mongolia
*/


twoway (scatteri 10 `=1977' 10 `=1978', bcolor(gs15) recast(area) ) ///
(scatteri 10 `=2005' 10 `=2007', bcolor(gs15) recast(area) ) ///
(line igov_r year if country == "Bangladesh", title("Bangladesh: Public Investment") leg(off) name(Bangladesh, replace))
graph export Bangladesh.png, replace
`print_control'

twoway (scatteri 25 `=1981' 25 `=1983', bcolor(gs15) recast(area) ) ///
(scatteri 25 `=1997' 25 `=1998', bcolor(gs15) recast(area) ) ///
(scatteri 25 `=2006' 25 `=2008', bcolor(gs15) recast(area) ) ///
(line igov_r year if country == "Bhutan", title("Bhutan: Public Investment") leg(off) name(Bhutan, replace))
graph export Bhutan.png, replace
`print_control'

twoway (scatteri 10 `=2002' 10 `=2010', bcolor(gs15) recast(area) ) ///
(line igov_r year if country == "Myanmar", title("Myanmar: Public Investment") leg(off) name(Myanmar, replace))
graph export Myanmar.png, replace
`print_control'

twoway (scatteri 10 `=1993' 10 `=1994', bcolor(gs15) recast(area) ) ///
(scatteri 10 `=2006' 10 `=2008', bcolor(gs15) recast(area) ) ///
(line igov_r year if country == "Cambodia", title("Cambodia: Public Investment") leg(off) name(Cambodia, replace))
graph export Cambodia.png, replace
`print_control'

twoway (scatteri 10 `=1975' 10 `=1976', bcolor(gs15) recast(area) ) ///
(scatteri 10 `=2004' 10 `=2007', bcolor(gs15) recast(area) ) ///
(line igov_r year if country == "Sri_Lanka", title("Sri_Lanka: Public Investment") leg(off) name(Sri_Lanka, replace))
graph export Sri_Lanka.png, replace
`print_control'

twoway (scatteri 10 `=1975' 10 `=1980', bcolor(gs15) recast(area) ) ///
(scatteri 10 `=2005' 10 `=2006', bcolor(gs15) recast(area) ) ///
(line igov_r year if country == "India", title("India: Public Investment") leg(off) name(India, replace))
graph export India.png, replace
`print_control'

twoway (scatteri 6 `=1973' 6 `=1974', bcolor(gs15) recast(area) ) ///
(scatteri 6 `=2001' 6 `=2002', bcolor(gs15) recast(area) ) ///
(line igov_r year if country == "Indonesia", title("Indonesia: Public Investment") leg(off) name(Indonesia, replace))
graph export Indonesia.png, replace
`print_control'

twoway (scatteri 10 `=1986' 10 `=1989', bcolor(gs15) recast(area) ) ///
(scatteri 10 `=2005' 10 `=2007', bcolor(gs15) recast(area) ) ///
(line igov_r year if country == "Laos", title("Laos: Public Investment") leg(off) name(Laos, replace))
graph export Laos.png, replace
`print_control'

twoway (scatteri 14 `=1978' 14 `=1982', bcolor(gs15) recast(area) ) ///
(scatteri 14 `=1990' 14 `=1992', bcolor(gs15) recast(area) ) ///
(scatteri 14 `=1999' 14 `=2001', bcolor(gs15) recast(area) ) ///
(line igov_r year if country == "Malaysia", title("Malaysia: Public Investment") leg(off) name(Malaysia, replace))
graph export Malaysia.png, replace
`print_control'

twoway (scatteri 20 `=1977' 20 `=1981', bcolor(gs15) recast(area) ) ///
(scatteri 20 `=2005' 20 `=2007', bcolor(gs15) recast(area) ) ///
(line igov_r year if country == "Maldives", title("Maldives: Public Investment") leg(off) name(Maldives, replace))
graph export Maldives.png, replace
`print_control'

twoway (scatteri 8 `=1973' 8 `=1975', bcolor(gs15) recast(area) ) ///
(scatteri 8 `=1981' 8 `=1982', bcolor(gs15) recast(area) ) ///
(line igov_r year if country == "Nepal", title("Nepal: Public Investment") leg(off) name(Nepal, replace))
graph export Nepal.png, replace
`print_control'

twoway (scatteri 10 `=1973' 10 `=1974', bcolor(gs15) recast(area) ) ///
(scatteri 10 `=1988' 10 `=1990', bcolor(gs15) recast(area) ) ///
(scatteri 10 `=2007' 10 `=2008', bcolor(gs15) recast(area) ) ///
(line igov_r year if country == "Philippines", title("Philippines: Public Investment") leg(off) name(Philippines, replace))
graph export Philippines.png, replace
`print_control'

twoway (scatteri 14 `=1975' 14 `=1978', bcolor(gs15) recast(area) ) ///
(scatteri 14 `=1990' 14 `=1996', bcolor(gs15) recast(area) ) ///
(line igov_r year if country == "Thailand", title("Thailand: Public Investment") leg(off) name(Thailand, replace))
graph export Thailand.png, replace
`print_control'

twoway (scatteri 10 `=1991' 10 `=1992', bcolor(gs15) recast(area) ) ///
(scatteri 10 `=1999' 10 `=2001', bcolor(gs15) recast(area) ) ///
(scatteri 10 `=2007' 10 `=2009', bcolor(gs15) recast(area) ) ///
(line igov_r year if country == "Vietnam", title("Vietnam: Public Investment") leg(off) name(Vietnam, replace))
graph export Vietnam.png, replace
`print_control'

twoway (scatteri 20 `=1975' 20 `=1980', bcolor(gs15) recast(area) ) ///
(scatteri 20 `=1989' 20 `=1991', bcolor(gs15) recast(area) ) ///
(line igov_r year if country == "Fiji", title("Fiji: Public Investment") leg(off) name(Fiji, replace))
graph export Fiji.png, replace
`print_control'

twoway (scatteri 20 `=1984' 20 `=1985', bcolor(gs15) recast(area) ) ///
(scatteri 20 `=1991' 20 `=1994', bcolor(gs15) recast(area) ) ///
(scatteri 20 `=1998' 20 `=1998', bcolor(gs15) recast(area) ) ///
(line igov_r year if country == "China", title("China: Public Investment") leg(off) name(China, replace))
graph export China.png, replace
`print_control'

twoway (scatteri 50 `=1993' 50 `=1994', bcolor(gs15) recast(area) ) ///
(scatteri 50 `=2006' 50 `=2007', bcolor(gs15) recast(area) ) ///
(scatteri 50 `=2010' 50 `=2012', bcolor(gs15) recast(area) ) ///
(line igov_r year if country == "Mongolia", title("Mongolia: Public Investment") leg(off) name(Mongolia, replace))
graph export Mongolia.png, replace
`print_control'

**========================================================================================
**with public debt
**========================================================================================

twoway (scatteri 60 `=1977' 60 `=1978', bcolor(gs15) recast(area) ) ///
(scatteri 60 `=2005' 60 `=2007', bcolor(gs15) recast(area)) ///
(line pubdebt year if country == "Bangladesh", yaxis(1)) ///
(line igov_gdp year if country == "Bangladesh", yaxis(2) ytitle("", axis(1)) ytitle("", axis(2)) title("Bangladesh: Public Investment") ///
legend(label (3 "Public Debt, RHS") label(4 "Public Investment, LHS") order (3 4) ) name(Bangladesh, replace))
graph export Bangladesh_pd.png, replace
`print_control'

twoway (scatteri 100 `=1981' 100 `=1983', bcolor(gs15) recast(area) ) ///
(scatteri 100 `=1997' 100 `=1998', bcolor(gs15) recast(area) ) ///
(scatteri 100 `=2006' 100 `=2008', bcolor(gs15) recast(area) ) ///
(line pubdebt year if country == "Bhutan", yaxis(1)) ///
(line igov_gdp year if country == "Bhutan", yaxis(2) ytitle("", axis(1)) ytitle("", axis(2)) title("Bhutan: Public Investment") ///
legend(label (4 "Public Debt, RHS") label(5 "Public Investment, LHS") order (4 5)) name(Bhutan, replace))
graph export Bhutan_pd.png, replace
`print_control'

//twoway (scatteri 250 `=2002' 250 `=2010', bcolor(gs15) recast(area) ) ///
//(line pubdebt year if country == "Myanmar", yaxis(1)) ///
//(line igov_gdp year if country == "Myanmar", yaxis(2) ytitle("", axis(1)) ytitle("", axis(2)) title("Myanmar: Public Investment") ///
//legend(label (4 "Public Debt, RHS") label(5 "Public Investment, LHS") order (4 5)) name(Myanmar, replace))
//graph export Myanmar_pd.png, replace
`print_control'

twoway (scatteri 50 `=1993' 50 `=1994', bcolor(gs15) recast(area) ) ///
(scatteri 50 `=2006' 50 `=2008', bcolor(gs15) recast(area) ) ///
(line pubdebt year if country == "Cambodia", yaxis(1)) ///
(line igov_gdp year if country == "Cambodia", yaxis(2) ytitle("", axis(1)) ytitle("", axis(2)) title("Cambodia: Public Investment") ///
legend(label (3 "Public Debt, RHS") label(4 "Public Investment, LHS") order (3 4)) name(Cambodia, replace))
graph export Cambodia_pd.png, replace
`print_control'

twoway (scatteri 120 `=1975' 120 `=1976', bcolor(gs15) recast(area) ) ///
(scatteri 120 `=2004' 120 `=2007', bcolor(gs15) recast(area) ) ///
(line pubdebt year if country == "Sri_Lanka", yaxis(1)) ///
(line igov_gdp year if country == "Sri_Lanka", yaxis(2) ytitle("", axis(1)) ytitle("", axis(2)) title("Sri Lanka: Public Investment") ///
legend(label (3 "Public Debt, RHS") label(4 "Public Investment, LHS") order (3 4)) name(Sri_Lanka, replace))
graph export Sri_Lanka_pd.png, replace
`print_control'

twoway (scatteri 100 `=1975' 100 `=1980', bcolor(gs15) recast(area) ) ///
(scatteri 100 `=2005' 100 `=2006', bcolor(gs15) recast(area) ) ///
(line pubdebt year if country == "India", yaxis(1)) ///
(line igov_gdp year if country == "India", yaxis(2) ytitle("", axis(1)) ytitle("", axis(2)) title("India: Public Investment") ///
legend(label (3 "Public Debt, RHS") label(4 "Public Investment, LHS") order (3 4)) name(India, replace))
graph export India_pd.png, replace
`print_control'

twoway (scatteri 100 `=1973' 100 `=1974', bcolor(gs15) recast(area) ) ///
(scatteri 100 `=2001' 100 `=2002', bcolor(gs15) recast(area) ) ///
(line pubdebt year if country == "Indonesia", yaxis(1)) ///
(line igov_gdp year if country == "Indonesia", yaxis(2) ytitle("", axis(1)) ytitle("", axis(2)) title("Indonesia: Public Investment") ///
legend(label (3 "Public Debt, RHS") label(4 "Public Investment, LHS") order (3 4)) name(Indonesia, replace))
graph export Indonesia_pd.png, replace
`print_control'

twoway (scatteri 200 `=1986' 200 `=1989', bcolor(gs15) recast(area) ) ///
(scatteri 200 `=2005' 200 `=2007', bcolor(gs15) recast(area) ) ///
(line pubdebt year if country == "Laos", yaxis(1)) ///
(line igov_gdp year if country == "Laos", yaxis(2) ytitle("", axis(1)) ytitle("", axis(2)) title("Laos: Public Investment") ///
legend(label (3 "Public Debt, RHS") label(4 "Public Investment, LHS") order (3 4)) name(Laos, replace))
graph export Laos_pd.png, replace
`print_control'

twoway (scatteri 120 `=1978' 120 `=1982', bcolor(gs15) recast(area) ) ///
(scatteri 120 `=1990' 120 `=1992', bcolor(gs15) recast(area) ) ///
(scatteri 120 `=1999' 120 `=2001', bcolor(gs15) recast(area) ) ///
(line pubdebt year if country == "Malaysia", yaxis(1)) ///
(line igov_gdp year if country == "Malaysia", yaxis(2) ytitle("", axis(1)) ytitle("", axis(2)) title("Malaysia: Public Investment") ///
legend(label (4 "Public Debt, RHS") label(5 "Public Investment, LHS") order (4 5)) name(Malaysia, replace))
graph export Malaysia_pd.png, replace
`print_control'

twoway (scatteri 100 `=1977' 100 `=1981', bcolor(gs15) recast(area) ) ///
(scatteri 100 `=2005' 100 `=2007', bcolor(gs15) recast(area) ) ///
(line pubdebt year if country == "Maldives", yaxis(1)) ///
(line igov_gdp year if country == "Maldives", yaxis(2) ytitle("", axis(1)) ytitle("", axis(2)) title("Maldives: Public Investment") ///
legend(label (3 "Public Debt, RHS") label(4 "Public Investment, LHS") order (3 4)) name(Maldives, replace))
graph export Maldives_pd.png, replace
`print_control'

twoway (scatteri 80 `=1973' 80 `=1975', bcolor(gs15) recast(area) ) ///
(scatteri 80 `=1981' 80 `=1982', bcolor(gs15) recast(area) ) ///
(line pubdebt year if country == "Nepal", yaxis(1)) ///
(line igov_gdp year if country == "Nepal", yaxis(2) ytitle("", axis(1)) ytitle("", axis(2)) title("Nepal: Public Investment") ///
legend(label (3 "Public Debt, RHS") label(4 "Public Investment, LHS") order (3 4)) name(Nepal, replace))
graph export Nepal_pd.png, replace
`print_control'

twoway (scatteri 80 `=1973' 80 `=1974', bcolor(gs15) recast(area) ) ///
(scatteri 80 `=1988' 80 `=1990', bcolor(gs15) recast(area) ) ///
(scatteri 80 `=2007' 80 `=2008', bcolor(gs15) recast(area) ) ///
(line pubdebt year if country == "Philippines", yaxis(1)) ///
(line igov_gdp year if country == "Philippines", yaxis(2) ytitle("", axis(1)) ytitle("", axis(2)) title("Philippines: Public Investment") ///
legend(label (4 "Public Debt, RHS") label(5 "Public Investment, LHS") order (4 5)) name(Philippines, replace))
graph export Philippines_pd.png, replace
`print_control'

twoway (scatteri 60 `=1975' 60 `=1978', bcolor(gs15) recast(area) ) ///
(scatteri 60 `=1990' 60 `=1996', bcolor(gs15) recast(area) ) ///
(line pubdebt year if country == "Thailand", yaxis(1)) ///
(line igov_gdp year if country == "Thailand", yaxis(2) ytitle("", axis(1)) ytitle("", axis(2)) title("Thailand: Public Investment") ///
legend(label (3 "Public Debt, RHS") label(4 "Public Investment, LHS") order (3 4)) name(Thailand, replace))
graph export Thailand_pd.png, replace
`print_control'

twoway (scatteri 250 `=1991' 250 `=1992', bcolor(gs15) recast(area) ) ///
(scatteri 250 `=1999' 250 `=2001', bcolor(gs15) recast(area) ) ///
(scatteri 250 `=2007' 250 `=2009', bcolor(gs15) recast(area) ) ///
(line pubdebt year if country == "Vietnam", yaxis(1)) ///
(line igov_gdp year if country == "Vietnam", yaxis(2) ytitle("", axis(1)) ytitle("", axis(2)) title("Vietnam: Public Investment") ///
legend(label (4 "Public Debt, RHS") label(5 "Public Investment, LHS") order (4 5)) name(Vietnam, replace))
graph export Vietnam_pd.png, replace
`print_control'

twoway (scatteri 60 `=1975' 60 `=1980', bcolor(gs15) recast(area) ) ///
(scatteri 60 `=1989' 60 `=1991', bcolor(gs15) recast(area) ) ///
(line pubdebt year if country == "Fiji", yaxis(1)) ///
(line igov_gdp year if country == "Fiji", yaxis(2) ytitle("", axis(1)) ytitle("", axis(2)) title("Fiji: Public Investment") ///
legend(label (3 "Public Debt, RHS") label(4 "Public Investment, LHS") order (3 4)) name(Fiji, replace))
graph export Fiji_pd.png, replace
`print_control'

twoway (scatteri 40 `=1984' 40 `=1985', bcolor(gs15) recast(area) ) ///
(scatteri 40 `=1991' 40 `=1994', bcolor(gs15) recast(area) ) ///
(scatteri 40 `=1998' 40 `=1998', bcolor(gs15) recast(area) ) ///
(line pubdebt year if country == "China", yaxis(1)) ///
(line igov_gdp year if country == "China", yaxis(2) ytitle("", axis(1)) ytitle("", axis(2)) title("China: Public Investment") ///
legend(label (4 "Public Debt, RHS") label(5 "Public Investment, LHS") order (4 5)) name(China, replace))
graph export China_pd.png, replace
`print_control'

twoway (scatteri 100 `=1993' 100 `=1994', bcolor(gs15) recast(area) ) ///
(scatteri 100 `=2006' 100 `=2007', bcolor(gs15) recast(area) ) ///
(scatteri 100 `=2010' 100 `=2012', bcolor(gs15) recast(area) ) ///
(line pubdebt year if country == "Mongolia", yaxis(1)) ///
(line igov_gdp year if country == "Mongolia", yaxis(2) ytitle("", axis(1)) ytitle("", axis(2)) title("Mongolia: Public Investment") ///
legend(label (4 "Public Debt, RHS") label(5 "Public Investment, LHS") order (4 5)) name(Mongolia, replace))
graph export Mongolia_pd.png, replace
`print_control'
