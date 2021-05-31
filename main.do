clear all
set more off

cd "C:\Users\BattistonG\Documents\GitHub\technology_conflict"

global main "C:\Users\BattistonG\Dropbox\ricerca_dropbox\bbf\technology_conflict\"
*global main "/Users/giacomobattiston/Dropbox/ricerca_dropbox/bbf/technology_conflict/"
*global main "C:\Users\Franceschin\Dropbox\bbf\technology_conflict\"

* Clean data on US bases and arms' trade
do thirdparty.do

* Import data from Hunzicker&al and creating dta file
import delimited ${main}1_data/hunziker_replication/data/country_cs.csv, clear 
rename cowid ccode
drop year
save ${main}2_processed/hunzicker_data.dta,replace

* Import data from Ashraf&Galor for geographical/climatical variables
use ${main}1_data/galor_replication/country.dta,clear
* Assign the Gleditsch-Ward numbers to the country with do-file in local
gen ccode=.
do gwno.do
* Drop small countries that are not present in the GW list
drop if missing(ccode)
save ${main}2_processed/country_galor.dta,replace

* Importing raw data of resources from World Bank and creating file
import delimited ${main}1_data/world_bank/Wealth-AccountsData.csv, varnames(1) clear 
* Keeping resources of interest
keep if indicatorcode=="NW.NCA.TO"|indicatorcode=="NW.NCA.PC"| ///
		indicatorcode=="NW.NCA.SAOI.PC"| ///
		indicatorcode=="NW.NCA.SAGA.PC"|indicatorcode=="NW.NCA.SACO.PC"

* Prepare the dataset for reshaping
rename v9 a14
drop indicatorcode
encode indicatorname,gen(m)
drop v5 v6 v7 v8 v10
* Reshape dataset
reshape wide a14 indicatorname, i(countrycode) j(m)

* Give meaningful name to resources, start with natural capital
rename a141 naturalcap14
* Natural capital per capita
rename a142 naturalcap_pc14
* Coal per capita
rename a143 coal_pc14
* Gas per capita
rename a144 gas_pc14
* Oil per capita
rename a145 oil_pc14

* Derive the population from the total amount and the per-capita amount
gen pop14=naturalcap14/naturalcap_pc14
* Drop resource names in long form
drop indicatorname1 indicatorname2 indicatorname3 indicatorname4 indicatorname5 
* Change the name of Congo to match with other dataset
replace countrycode="ZAR" if countrycode=="COD"
rename countrycode code
gen ccode=.

* Set the Gleditsch-Ward numbers for the country
do gwno.do

* Drop non-country World Bank aggregate data (continents or other international groups)
drop if ccode==.
drop code
save ${main}2_processed/resources.dta,replace
keep ccode
* Retain a list of countries in the WB dataset
save ${main}2_processed/list_countries_WB.dta,replace

* Load data from PRIO
use ${main}1_data/PRIO/ucdp-prio-acd-201.dta,clear

* PRIO reports potentially more than one location for a conflict  (at most 6),
* recorded in the same string. We separate them to have one location per row.
* Generate separate variables for different locations
split gwno_loc, gen(loc) parse(",")
* Create different rows when there is more than 1 location
expand 2 if loc2!=""
bysort _all: gen rank=_n
* Record the code of just one location in gwno_loc
* For different rows we use different codes
replace gwno_loc=loc1 if rank==1
replace gwno_loc=loc2 if rank==2
* Repeat the steps for other multiple locations
expand 2 if loc3!=""&rank==2
drop rank
bysort _all: gen rank=_n
replace gwno_loc=loc3 if rank==2
expand 2 if loc4!=""&rank==2
drop rank
bysort _all: gen rank=_n
replace gwno_loc=loc4 if rank==2
expand 2 if loc5!=""&rank==2
drop rank
bysort _all: gen rank=_n
replace gwno_loc=loc5 if rank==2
expand 2 if loc6!=""&rank==2
drop rank
bysort _all: gen rank=_n
replace gwno_loc=loc6 if rank==2
drop rank
* We now have 1 row for 1 location
destring gwno_loc,replace

* Yemen took two different values over time, we consider them as one
replace gwno_loc=678 if gwno_loc==680
* Sudan took two different values over time, we consider them as one
replace gwno_loc=625 if gwno_loc==626

* Record total number of conflict in a given year/location
gen conflict=1
bysort year gwno_loc: egen nconf=total(conflict)
* Set maxint recording the maximum of conflict intensity in year/location
by year gwno_loc: egen maxint=max(intensity)
bysort year gwno_loc: gen rank=_n
keep if rank==1
drop rank

rename gwno_loc ccode

* Merge with the list of countries from WB in order to fill the panel 
* country-year with the zeros for years with no conflict
merge m:1 ccode using ${main}2_processed/list_countries_WB.dta
replace conflict=0 if _merge==2

*drop G8 countries
drop if ccode==2
drop if ccode==20
drop if ccode==740
drop if ccode==325
drop if ccode==220
drop if ccode==260
drop if ccode==200
drop if ccode==365
drop if ccode==255

* Give panel shape
tsset ccode year
* We put a random year for missing countries, then it will be filled anyway
replace year=1950 if _merge==2
drop _merge
tsfill, full
*if not reported, we assume no conflict
replace conflict=0 if conflict==.
replace nconf=0 if nconf==.
replace maxint=intensity if maxint==.
replace maxint=0 if maxint==.

* Merge with the resources from the World Bank
merge m:1 ccode using ${main}2_processed/resources.dta
rename _merge mergeWB

* Merge with the resources from Hunzicker&Cederman
merge m:1 ccode using ${main}2_processed/hunzicker_data.dta
rename _merge mergeHUNZ

* Merge with the controls from Out of Africa
merge m:1 ccode using ${main}2_processed/country_galor.dta
rename _merge mergeGALOR

* Drop countries that were not in the WB database
drop if mergeGALOR==2 | mergeHUNZ==2

* Dropping USA, Canada and China
drop if year==.
drop if ccode==710

* Define regions, start with Europe
replace region="1" if ccode<396&ccode>199
* Define Middle East
replace region="2" if ccode<699&ccode>629&ccode!=651
* Define East Asia and Oceania
replace region="3" if ccode<991&ccode>699
* Define Africa
replace region="4" if (ccode<627&ccode>399)|ccode==651
* Define America
replace region="5" if ccode<166
* Create numeric variable for region
destring region, replace
* Label regions
label define continent 1 "Europe" 2 "Middle East" 3 "East Asia and Oceania" 4 "Africa" 5 "America"

* We drop the country if we have no information in sedvol or no information in 
* natural cap. If instead we have info on natural capital, we assume that 
* missing values in other resources (oil for example) are 0, as it is implicitly
* assumed in the World Bank dataset when creating aggregate categories.
drop if missing(naturalcap14) | missing(lnsedvol)

* Set the local to be used in windosirizing resource variables at the 97.5 percentile
local perc 97.5

* Generate oil variable
gen oil=(oil_pc14)
* Replace 0 for missing oil (see above)
replace oil=0 if missing(oil)
* Extract percentile
_pctile oil,  p(`perc')
* Perform winsorization
replace oil = `r(r1)' if oil > `r(r1)' & !missing(oil)
* Rescale
replace oil=oil/(10^6)
* Generate the squared term
gen oil2=oil^2

* Generate gas variable
gen gas=gas_pc14
* Replace 0 for missing gas (see above)
replace gas=0 if missing(gas)
* Extract percentile
_pctile gas,  p(`perc')
* Perform winsorization
replace gas = `r(r1)' if gas > `r(r1)' & !missing(gas)
* Rescale
replace gas=gas/(10^6)
* Generate the squared term
gen gas2=gas^2

* Generate coal variable
gen coal=coal_pc14
replace coal=0 if missing(coal)
* Extract percentile
_pctile coal,  p(`perc')
* Perform winsorization
replace coal = `r(r1)' if coal > `r(r1)' & !missing(coal)
* Rescale
replace coal=coal/(10^6)
* Generate the squared term
gen coal2=coal^2

* Generate sed. vol. variable
gen sedvol=exp(lnsedvol)
* Extract percentile
_pctile sedvol,  p(`perc')
* Perform winsorization
replace sedvol = `r(r1)' if sedvol > `r(r1)' & !missing(sedvol)
* Rescale 
replace sedvol = sedvol/(10^3)
* Generate the squared term
gen sedvol2=(sedvol^2)

* Rescale area variable.
replace area=area/(10^9)

* Generate high conflict indicator
gen conflict2 = maxint == 2
replace conflict2 = 0 if maxint==.

* Generate log population variable
gen lnpop14 = ln(pop14)

* Merge with data about arms trade
merge m:1 ccode using ${main}2_processed/dist_arms.dta
rename _merge mergeARMS

* Merge with data about US bases
merge m:1 ccode using ${main}2_processed/contig_bases1000.dta
rename _merge mergeBASES

* Merge with data about arms trade
merge m:1 ccode using ${main}2_processed/dist_arms_UKR.dta
rename _merge mergeARMS_UKR

* Drop Germany, GFR
drop if ccode == 260
*GDR
drop if ccode == 265
*Drop China
drop if ccode == 710

* Define US arms trade dummy taking value 1 for values above 90th percentile
qui sum armstrade, detail
gen armstrade90 = armstrade >  `r(p90)' if !missing(armstrade)

* Define US arms trade dummy taking value 1 for other percentiles
gen armstrade50 = armstrade >  `r(p50)' if !missing(armstrade)
gen armstrade75 = armstrade >  `r(p75)' if !missing(armstrade)
gen armstrade95 = armstrade >  `r(p95)' if !missing(armstrade)
gen armstrade0 = armstrade >  0 if !missing(armstrade)

* Define Ukraine's arms trade dummy taking value 1 for values above 90th percentile
qui sum armstrade_ukr, detail
gen armstrade90_ukr = armstrade >  `r(p90)' if !missing(armstrade)

* Define Ukraine's arms trade dummy taking value 1 for other percentiles
gen armstrade50_ukr = armstrade_ukr >  `r(p50)' if !missing(armstrade_ukr)
gen armstrade75_ukr = armstrade_ukr >  `r(p75)' if !missing(armstrade_ukr)
gen armstrade95_ukr = armstrade_ukr >  `r(p95)' if !missing(armstrade_ukr)
gen armstrade0_ukr = armstrade_ukr >  0 if !missing(armstrade_ukr)

* Generate variable recording total conflict years
egen conf_years = sum(conflict), by(ccode)

*label controls used in 
la var lnarea "Area, log Km\(^2\)"
la var abslat "Absolute latitude"
la var elevavg "Average altitude, Km"
la var elevstd "Dispersion in altitude"
la var temp "Average temperature, Celsius degrees"
la var prec "Average precipitation, mm"
la var lnpop14 "Population, logs"
la var armstrade90 "US arms imports above the 90th percentile"
la var armstrade50 "US arms imports above the 50th percentile"
la var armstrade75 "US arms imports above the 75th percentile"
la var armstrade95 "US arms imports above the 95th percentile"
la var armstrade0 "US arms imports above 0"
la var armstrade90_ukr "Ukraine's arms imports above the 90th percentile"
la var armstrade50_ukr "Ukraine's arms imports above the 50th percentile"
la var armstrade75_ukr "Ukraine's arms imports above the 75th percentile"
la var armstrade95_ukr "Ukraine's arms imports above the 95th percentile"
la var armstrade0_ukr "Ukraine's arms imports above 0"
la var contig_bases1000 "Country with or contig. to US base (1000p)"
la var sedvol "Sedimentary basins volume"
la var sedvol2 "Sedimentary basins volume squared"
la var oil "Oil value pc"
la var oil2 "Oil value pc squared"
la var gas "Gas value pc"
la var gas2 "Gas value pc squared"
la var coal "Coal value pc"
la var coal2 "Coal value pc squared"
la var ccode "Country code"
la var conf_years "Years of conflict in country"

* Sample from 1950 to 1999
keep if year < 2000

keep year region lnarea abslat elevavg elevstd temp prec lnpop14 ///
	conflict conflict2 sedvol sedvol2 coal coal2 gas gas2 oil oil oil2  ///
	contig_bases1000 armstrade90 ccode conf_years armstrade50 ///
	armstrade75 armstrade95 armstrade0 armstrade0_ukr armstrade50_ukr ///
	armstrade75_ukr armstrade95_ukr armstrade0_ukr

save ${main}2_processed/data_regressions.dta, replace

******ANALYSIS

gen thirdparty = .

local controls "lnarea  abslat elevavg elevstd temp precip lnpop14  "

			
* Table 1: Conflict and resources		


* For loop for regressions: iterates over third party measure, outcome, controls
forval i_indep = 1/2 {
	if (`i_indep' == 1) {
		local independent "c.oil c.oil2 c.gas c.gas2 c.coal c.coal2"
	}
	else {
		local independent "sedvol sedvol2"
	}
	foreach outcome of varlist $outcome_list {
		forval i_con = 1/2 {
			local counter = `counter' + 1
			if (`i_con' == 1) {
				ivreg2 `outcome' `independent' i.year i.region, cluster(ccode) partial(i.year i.region)
				* Save geographic controls indicator
				estadd local geocontrols = "No"
			}
			else {
				ivreg2 `outcome' `independent' `controls' i.year i.region, cluster(ccode) partial(i.year i.region)
				* Save geographic controls indicator
				estadd local geocontrols = "Yes"
			}
			
			* Save time controls indicators
			estadd local yearfe = "Yes"
			estadd local continentfe = "Yes"
			* Save auxiliary indicator for esttab
			estadd local space = " "
			
			est sto reg`counter'
			if (`i_indep' == 1) {
				estadd scalar peak = -_b[c.oil]/(2*_b[c.oil2])
			}
				else {
				estadd scalar peak = -_b[c.sedvol]/(2*_b[c.sedvol2])
				}
		}

}
}

esttab reg* using ///
${main}5_output/tables/prioall.tex, replace ///
coeflabels(sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)" oil "Oil" oil2 "Oil\(^2\)" gas "Gas" gas2 "Gas\(^2\)" coal "Coal" coal2 "Coal\(^2\)") se ///
starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
 nobaselevels ///
 drop(`controls') ///
 	stats(yearfe continentfe geocontrols  peak N, fmt(s s s a2 a2) ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"Year FEs"' `"Continent FEs"' `"Geo Controls"' `"Peak"' `"\(N\)"')) ///
		mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
			postfoot("\hline\hline \end{tabular}}")	

* Table 2: Predictors of third party presence
ivreg2 contig_bases1000    `controls' if year == 1950
est sto reg1
ivreg2 armstrade90     `controls' if year == 1950
est sto reg2

esttab reg1 reg2 using ///
${main}5_output/tables/balance.tex, replace ///
label se ///
starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
 nobaselevels nonumbers ///
		mtitles("Bases" "Arms' Trade" ) ///
			postfoot("\hline\hline \end{tabular}}")

* Globals for regression loops
global thirdparty_list "contig_bases1000 armstrade90"
global outcome_list "conflict conflict2"

* Table 3: Sedimentary bases presence and conflict, with third party presence

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.sedvol##i.thirdparty c.sedvol2##i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.sedvol##i.thirdparty ///
					c.sedvol2##i.thirdparty i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.sedvol] + _b[c.sedvol#1.thirdparty]
				qui lincom c.sedvol + c.sedvol#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.sedvol2] + _b[c.sedvol2#1.thirdparty]
				qui lincom c.sedvol2 + c.sedvol2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}

esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
	${main}5_output/tables/prio_sedint.tex, replace ///
	drop(`controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	
* Table 4: WB resources presence and conflict, with third party presence

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.oil##i.thirdparty   c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty   ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.oil##i.thirdparty c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save resource controls indicators
				estadd local gascoal = "Yes"
				estadd local gascoalsq = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.oil] + _b[c.oil#1.thirdparty]
				qui lincom c.oil + c.oil#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.oil2] + _b[c.oil2#1.thirdparty]
				qui lincom c.oil2 + c.oil2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}


esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
${main}5_output/tables/prio_oilint.tex, replace ///
 drop(`controls' 1.thirdparty#c.gas 1.thirdparty#c.gas2 ///
	gas gas2 1.thirdparty#c.coal ///
	1.thirdparty#c.coal2 coal coal2) /// 
	coeflabels(1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil X Third Party" 1.thirdparty#c.oil "Oil X Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) X Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) X Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space gascoal gascoalsq yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"Gas, Coal X Third Party"' `"Gas\(^2\), Coal\(^2\) X Third Party"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	
	
* New tables without Australia

local counter 0
* Table 5: Conflict and all resources
forval i_indep = 1/2 {
	if (`i_indep' == 1) {
		local independent "c.oil c.oil2 c.gas c.gas2 c.coal c.coal2"
	}
	else {
		local independent "sedvol sedvol2"
	}
	foreach outcome of varlist $outcome_list {
		forval i_con = 1/2 {
			local counter = `counter' + 1
			if (`i_con' == 1) {
				ivreg2 `outcome' `independent' i.year i.region ///
				if ccode != 900, cluster(ccode) partial(i.year i.region)
				* Save geographic controls indicator
				estadd local geocontrols = "No"
			}
			else {
				ivreg2 `outcome' `independent' `controls' i.year i.region ///
				if ccode != 900, cluster(ccode) partial(i.year i.region)
				* Save geographic controls indicator
				estadd local geocontrols = "Yes"
			}
			
			* Save time controls indicators
			estadd local yearfe = "Yes"
			estadd local continentfe = "Yes"
			* Save auxiliary indicator for esttab
			estadd local space = " "
			
			est sto reg`counter'
			if (`i_indep' == 1) {
				estadd scalar peak = -_b[c.oil]/(2*_b[c.oil2])
			}
				else {
				estadd scalar peak = -_b[c.sedvol]/(2*_b[c.sedvol2])
				}
			est sto reg`counter'
		}

}
}

esttab reg* using ///
${main}5_output/tables/prioall_noaus.tex, replace ///
coeflabels(sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)" oil "Oil" oil2 "Oil\(^2\)" gas "Gas" gas2 "Gas\(^2\)" coal "Coal" coal2 "Coal\(^2\)") se ///
starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
 nobaselevels ///
 drop(`controls') ///
 	stats(yearfe continentfe geocontrols  peak N, fmt(s s s a2 a2) ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"Year FEs"' `"Continent FEs"' `"Geo Controls"' `"Peak"' `"\(N\)"')) ///
		mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
			postfoot("\hline\hline \end{tabular}}")	
		


* Table 6: Sedimentary bases presence and conflict, with third party presence
* No Australia

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.sedvol##i.thirdparty c.sedvol2##i.thirdparty ///
					i.year i.region if ccode != 900, ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.sedvol##i.thirdparty ///
					c.sedvol2##i.thirdparty i.year i.region `controls' ///
					if ccode != 900, ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.sedvol] + _b[c.sedvol#1.thirdparty]
				qui lincom c.sedvol + c.sedvol#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.sedvol2] + _b[c.sedvol2#1.thirdparty]
				qui lincom c.sedvol2 + c.sedvol2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}

esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
	${main}5_output/tables/prio_sedint_noaus.tex, replace ///
	drop(`controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	
* Table 7: WB resources presence and conflict, with third party presence
* No Australia

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.oil##i.thirdparty   c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty   ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region if ccode != 900, cluster(ccode) ///
					partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.oil##i.thirdparty c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region `controls' if ccode != 900, ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save resource controls indicators
				estadd local gascoal = "Yes"
				estadd local gascoalsq = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.oil] + _b[c.oil#1.thirdparty]
				qui lincom c.oil + c.oil#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.oil2] + _b[c.oil2#1.thirdparty]
				qui lincom c.oil2 + c.oil2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}


esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
${main}5_output/tables/prio_oilint_noaus.tex, replace ///
 drop(`controls' 1.thirdparty#c.gas 1.thirdparty#c.gas2 ///
	gas gas2 1.thirdparty#c.coal ///
	1.thirdparty#c.coal2 coal coal2) /// 
	coeflabels(1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil X Third Party" 1.thirdparty#c.oil "Oil X Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) X Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) X Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space gascoal gascoalsq yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"Gas, Coal X Third Party"' `"Gas\(^2\), Coal\(^2\) X Third Party"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	

* Logit Tables


local counter 0
* Table 7: Conflict and all resources
forval i_indep = 1/2 {
	if (`i_indep' == 1) {
		local independent "c.oil c.oil2 c.gas c.gas2 c.coal c.coal2"
	}
	else {
		local independent "sedvol sedvol2"
	}
	foreach outcome of varlist $outcome_list {
		forval i_con = 1/2 {
			local counter = `counter' + 1
			if (`i_con' == 1) {
				logit `outcome' `independent' i.year i.region, cluster(ccode)
				* Save geographic controls indicator
				estadd local geocontrols = "No"
			}
			else {
				logit `outcome' `independent' `controls' i.year i.region, cluster(ccode)
				* Save geographic controls indicator
				estadd local geocontrols = "Yes"
			}
			
			* Save time controls indicators
			estadd local yearfe = "Yes"
			estadd local continentfe = "Yes"
			* Save auxiliary indicator for esttab
			estadd local space = " "
			
			est sto reg`counter'
			if (`i_indep' == 1) {
				estadd scalar peak = -_b[c.oil]/(2*_b[c.oil2])
			}
				else {
				estadd scalar peak = -_b[c.sedvol]/(2*_b[c.sedvol2])
				}
			est sto reg`counter'
		}

}
}

esttab reg* using ///
${main}5_output/tables/prioall_logit.tex, replace ///
keep(oil oil2 gas gas2 coal coal2 sedvol sedvol2) ///
coeflabels(sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)" oil "Oil" oil2 "Oil\(^2\)" gas "Gas" gas2 "Gas\(^2\)" coal "Coal" coal2 "Coal\(^2\)") se ///
starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
 nobaselevels ///
 	stats(yearfe continentfe geocontrols  peak N, fmt(s s s a2 a2) ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"Year FEs"' `"Continent FEs"' `"Geo Controls"' `"Peak"' `"\(N\)"')) ///
		mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
			postfoot("\hline\hline \end{tabular}}")	
		


* Table 8: Sedimentary bases presence and conflict, with third party presence
* Logit

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					logit `outcome' c.sedvol##i.thirdparty c.sedvol2##i.thirdparty ///
					i.year i.region, cluster(ccode) 
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					logit `outcome' c.sedvol##i.thirdparty ///
					c.sedvol2##i.thirdparty i.year i.region `controls', ///
					cluster(ccode) 
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.sedvol] + _b[c.sedvol#1.thirdparty]
				qui lincom c.sedvol + c.sedvol#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.sedvol2] + _b[c.sedvol2#1.thirdparty]
				qui lincom c.sedvol2 + c.sedvol2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}

esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
	${main}5_output/tables/prio_sedint_logit.tex, replace ///
	drop(_cons *.year *.region `controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")

	
* Table 9: WB resources presence and conflict, with third party presence
* Logit

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					logit `outcome' c.oil##i.thirdparty   c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty   ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region, cluster(ccode)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					logit `outcome' c.oil##i.thirdparty c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region `controls', ///
					cluster(ccode)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save resource controls indicators
				estadd local gascoal = "Yes"
				estadd local gascoalsq = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.oil] + _b[c.oil#1.thirdparty]
				qui lincom c.oil + c.oil#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.oil2] + _b[c.oil2#1.thirdparty]
				qui lincom c.oil2 + c.oil2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}


esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
${main}5_output/tables/prio_oilint_logit.tex, replace ///
 drop(*.year *.region `controls' 1.thirdparty#c.gas 1.thirdparty#c.gas2 ///
	gas gas2 1.thirdparty#c.coal ///
	1.thirdparty#c.coal2 coal coal2) /// 
	coeflabels(1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil X Third Party" 1.thirdparty#c.oil "Oil X Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) X Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) X Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space gascoal gascoalsq yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"Gas, Coal X Third Party"' `"Gas\(^2\), Coal\(^2\) X Third Party"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	

	

global thirdparty_list "contig_bases1000 armstrade50"
	
* Table 10: Sedimentary bases presence and conflict, with third party presence
* armstrade50

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.sedvol##i.thirdparty c.sedvol2##i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.sedvol##i.thirdparty ///
					c.sedvol2##i.thirdparty i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.sedvol] + _b[c.sedvol#1.thirdparty]
				qui lincom c.sedvol + c.sedvol#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.sedvol2] + _b[c.sedvol2#1.thirdparty]
				qui lincom c.sedvol2 + c.sedvol2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}

esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
	${main}5_output/tables/prio_sedint_arms50.tex, replace ///
	drop(`controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	
* Table 11: WB resources presence and conflict, with third party presence
* armstrade50

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.oil##i.thirdparty   c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty   ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.oil##i.thirdparty c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save resource controls indicators
				estadd local gascoal = "Yes"
				estadd local gascoalsq = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.oil] + _b[c.oil#1.thirdparty]
				qui lincom c.oil + c.oil#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.oil2] + _b[c.oil2#1.thirdparty]
				qui lincom c.oil2 + c.oil2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}


esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
${main}5_output/tables/prio_oilint_arms50.tex, replace ///
 drop(`controls' 1.thirdparty#c.gas 1.thirdparty#c.gas2 ///
	gas gas2 1.thirdparty#c.coal ///
	1.thirdparty#c.coal2 coal coal2) /// 
	coeflabels(1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil X Third Party" 1.thirdparty#c.oil "Oil X Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) X Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) X Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space gascoal gascoalsq yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"Gas, Coal X Third Party"' `"Gas\(^2\), Coal\(^2\) X Third Party"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	

	
	
	
global thirdparty_list "contig_bases1000 armstrade75"
	
* Table 12: Sedimentary bases presence and conflict, with third party presence
* armstrade50

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.sedvol##i.thirdparty c.sedvol2##i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.sedvol##i.thirdparty ///
					c.sedvol2##i.thirdparty i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.sedvol] + _b[c.sedvol#1.thirdparty]
				qui lincom c.sedvol + c.sedvol#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.sedvol2] + _b[c.sedvol2#1.thirdparty]
				qui lincom c.sedvol2 + c.sedvol2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}

esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
	${main}5_output/tables/prio_sedint_arms75.tex, replace ///
	drop(`controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	
* Table 13: WB resources presence and conflict, with third party presence
* armstrade50

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.oil##i.thirdparty   c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty   ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.oil##i.thirdparty c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save resource controls indicators
				estadd local gascoal = "Yes"
				estadd local gascoalsq = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.oil] + _b[c.oil#1.thirdparty]
				qui lincom c.oil + c.oil#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.oil2] + _b[c.oil2#1.thirdparty]
				qui lincom c.oil2 + c.oil2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}


esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
${main}5_output/tables/prio_oilint_arms75.tex, replace ///
 drop(`controls' 1.thirdparty#c.gas 1.thirdparty#c.gas2 ///
	gas gas2 1.thirdparty#c.coal ///
	1.thirdparty#c.coal2 coal coal2) /// 
	coeflabels(1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil X Third Party" 1.thirdparty#c.oil "Oil X Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) X Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) X Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space gascoal gascoalsq yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"Gas, Coal X Third Party"' `"Gas\(^2\), Coal\(^2\) X Third Party"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	

global thirdparty_list "contig_bases1000 armstrade95"
	
* Table 14: Sedimentary bases presence and conflict, with third party presence
* armstrade50

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.sedvol##i.thirdparty c.sedvol2##i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.sedvol##i.thirdparty ///
					c.sedvol2##i.thirdparty i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.sedvol] + _b[c.sedvol#1.thirdparty]
				qui lincom c.sedvol + c.sedvol#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.sedvol2] + _b[c.sedvol2#1.thirdparty]
				qui lincom c.sedvol2 + c.sedvol2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}

esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
	${main}5_output/tables/prio_sedint_arms95.tex, replace ///
	drop(`controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	
* Table 15: WB resources presence and conflict, with third party presence
* armstrade50

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.oil##i.thirdparty   c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty   ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.oil##i.thirdparty c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save resource controls indicators
				estadd local gascoal = "Yes"
				estadd local gascoalsq = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.oil] + _b[c.oil#1.thirdparty]
				qui lincom c.oil + c.oil#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.oil2] + _b[c.oil2#1.thirdparty]
				qui lincom c.oil2 + c.oil2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}


esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
${main}5_output/tables/prio_oilint_arms95.tex, replace ///
 drop(`controls' 1.thirdparty#c.gas 1.thirdparty#c.gas2 ///
	gas gas2 1.thirdparty#c.coal ///
	1.thirdparty#c.coal2 coal coal2) /// 
	coeflabels(1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil X Third Party" 1.thirdparty#c.oil "Oil X Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) X Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) X Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space gascoal gascoalsq yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"Gas, Coal X Third Party"' `"Gas\(^2\), Coal\(^2\) X Third Party"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")

	
global thirdparty_list "contig_bases1000 armstrade0"

* Table 16: Sedimentary bases presence and conflict, with third party presence
* armstrade0

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.sedvol##i.thirdparty c.sedvol2##i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.sedvol##i.thirdparty ///
					c.sedvol2##i.thirdparty i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.sedvol] + _b[c.sedvol#1.thirdparty]
				qui lincom c.sedvol + c.sedvol#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.sedvol2] + _b[c.sedvol2#1.thirdparty]
				qui lincom c.sedvol2 + c.sedvol2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}

esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
	${main}5_output/tables/prio_sedint_arms0.tex, replace ///
	drop(`controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	
* Table 17: WB resources presence and conflict, with third party presence
* armstrade0

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.oil##i.thirdparty   c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty   ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.oil##i.thirdparty c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save resource controls indicators
				estadd local gascoal = "Yes"
				estadd local gascoalsq = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.oil] + _b[c.oil#1.thirdparty]
				qui lincom c.oil + c.oil#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.oil2] + _b[c.oil2#1.thirdparty]
				qui lincom c.oil2 + c.oil2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}


esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
${main}5_output/tables/prio_oilint_arms0.tex, replace ///
 drop(`controls' 1.thirdparty#c.gas 1.thirdparty#c.gas2 ///
	gas gas2 1.thirdparty#c.coal ///
	1.thirdparty#c.coal2 coal coal2) /// 
	coeflabels(1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil X Third Party" 1.thirdparty#c.oil "Oil X Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) X Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) X Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space gascoal gascoalsq yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"Gas, Coal X Third Party"' `"Gas\(^2\), Coal\(^2\) X Third Party"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	


global thirdparty_list "contig_bases1000 armstrade75"
	
* Table 18: Sedimentary bases presence and conflict, with third party presence
* Ukraine's armstrade75

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.sedvol##i.thirdparty c.sedvol2##i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.sedvol##i.thirdparty ///
					c.sedvol2##i.thirdparty i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.sedvol] + _b[c.sedvol#1.thirdparty]
				qui lincom c.sedvol + c.sedvol#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.sedvol2] + _b[c.sedvol2#1.thirdparty]
				qui lincom c.sedvol2 + c.sedvol2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}

esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
	${main}5_output/tables/prio_sedint_arms75.tex, replace ///
	drop(`controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	
* Table 19: WB resources presence and conflict, with third party presence
* Ukraine's armstrade75

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.oil##i.thirdparty   c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty   ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.oil##i.thirdparty c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save resource controls indicators
				estadd local gascoal = "Yes"
				estadd local gascoalsq = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.oil] + _b[c.oil#1.thirdparty]
				qui lincom c.oil + c.oil#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.oil2] + _b[c.oil2#1.thirdparty]
				qui lincom c.oil2 + c.oil2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}


esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
${main}5_output/tables/prio_oilint_arms75_ukr.tex, replace ///
 drop(`controls' 1.thirdparty#c.gas 1.thirdparty#c.gas2 ///
	gas gas2 1.thirdparty#c.coal ///
	1.thirdparty#c.coal2 coal coal2) /// 
	coeflabels(1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil X Third Party" 1.thirdparty#c.oil "Oil X Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) X Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) X Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space gascoal gascoalsq yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"Gas, Coal X Third Party"' `"Gas\(^2\), Coal\(^2\) X Third Party"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	

global thirdparty_list "contig_bases1000 armstrade95_ukr"
	
* Table 20: Sedimentary bases presence and conflict, with third party presence
* Ukraine's armstrade95

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.sedvol##i.thirdparty c.sedvol2##i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.sedvol##i.thirdparty ///
					c.sedvol2##i.thirdparty i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.sedvol] + _b[c.sedvol#1.thirdparty]
				qui lincom c.sedvol + c.sedvol#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.sedvol2] + _b[c.sedvol2#1.thirdparty]
				qui lincom c.sedvol2 + c.sedvol2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}

esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
	${main}5_output/tables/prio_sedint_arms95_ukr.tex, replace ///
	drop(`controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	
* Table 21: WB resources presence and conflict, with third party presence
* Ukraine's armstrade50

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.oil##i.thirdparty   c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty   ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.oil##i.thirdparty c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save resource controls indicators
				estadd local gascoal = "Yes"
				estadd local gascoalsq = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.oil] + _b[c.oil#1.thirdparty]
				qui lincom c.oil + c.oil#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.oil2] + _b[c.oil2#1.thirdparty]
				qui lincom c.oil2 + c.oil2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}


esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
${main}5_output/tables/prio_oilint_arms95_ukr.tex, replace ///
 drop(`controls' 1.thirdparty#c.gas 1.thirdparty#c.gas2 ///
	gas gas2 1.thirdparty#c.coal ///
	1.thirdparty#c.coal2 coal coal2) /// 
	coeflabels(1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil X Third Party" 1.thirdparty#c.oil "Oil X Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) X Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) X Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space gascoal gascoalsq yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"Gas, Coal X Third Party"' `"Gas\(^2\), Coal\(^2\) X Third Party"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")

	
global thirdparty_list "contig_bases1000 armstrade0_ukr"

* Table 22: Sedimentary bases presence and conflict, with third party presence
* Ukraine's armstrade0

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.sedvol##i.thirdparty c.sedvol2##i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.sedvol##i.thirdparty ///
					c.sedvol2##i.thirdparty i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.sedvol] + _b[c.sedvol#1.thirdparty]
				qui lincom c.sedvol + c.sedvol#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.sedvol2] + _b[c.sedvol2#1.thirdparty]
				qui lincom c.sedvol2 + c.sedvol2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}

esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
	${main}5_output/tables/prio_sedint_arms0_ukr.tex, replace ///
	drop(`controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	
* Table 23: WB resources presence and conflict, with third party presence
* Ukraine's armstrade0

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.oil##i.thirdparty   c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty   ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.oil##i.thirdparty c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save resource controls indicators
				estadd local gascoal = "Yes"
				estadd local gascoalsq = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.oil] + _b[c.oil#1.thirdparty]
				qui lincom c.oil + c.oil#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.oil2] + _b[c.oil2#1.thirdparty]
				qui lincom c.oil2 + c.oil2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}


esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
${main}5_output/tables/prio_oilint_arms0_ukr.tex, replace ///
 drop(`controls' 1.thirdparty#c.gas 1.thirdparty#c.gas2 ///
	gas gas2 1.thirdparty#c.coal ///
	1.thirdparty#c.coal2 coal coal2) /// 
	coeflabels(1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil X Third Party" 1.thirdparty#c.oil "Oil X Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) X Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) X Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space gascoal gascoalsq yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"Gas, Coal X Third Party"' `"Gas\(^2\), Coal\(^2\) X Third Party"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	

global thirdparty_list "contig_bases1000 armstrade90_ukr"

* Table 24: Sedimentary bases presence and conflict, with third party presence
* Ukraine's armstrade90

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.sedvol##i.thirdparty c.sedvol2##i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.sedvol##i.thirdparty ///
					c.sedvol2##i.thirdparty i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.sedvol] + _b[c.sedvol#1.thirdparty]
				qui lincom c.sedvol + c.sedvol#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.sedvol2] + _b[c.sedvol2#1.thirdparty]
				qui lincom c.sedvol2 + c.sedvol2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}

esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
	${main}5_output/tables/prio_sedint_arms90_ukr.tex, replace ///
	drop(`controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	
* Table 25: WB resources presence and conflict, with third party presence
* Ukraine's armstrade0

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.oil##i.thirdparty   c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty   ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.oil##i.thirdparty c.oil2##i.thirdparty ///
					c.gas##i.thirdparty c.gas2##i.thirdparty ///
					c.coal##i.thirdparty c.coal2##i.thirdparty ///
					i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				estadd local yearfe = "Yes"
				estadd local continentfe = "Yes"
				* Save resource controls indicators
				estadd local gascoal = "Yes"
				estadd local gascoalsq = "Yes"
				* Save auxiliary indicator for esttab
				estadd local space = " "

				* Save coefficients and p-values for linear combinations of linear term
				local  b1 = _b[c.oil] + _b[c.oil#1.thirdparty]
				qui lincom c.oil + c.oil#1.thirdparty
				local p1_aux : di %6.3g scalar(`r(p)')
				estadd scalar p1 = `p1_aux'
				local b1s_aux : di %6.4f scalar(`b1')
				if (`r(p)' <= 1) {
					local b1s =  "`b1s_aux'"
					if (`r(p)' < 0.1) {
						local b1s =  "`b1s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b1s =  "`b1s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b1s =  "`b1s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b1s = "`b1s'"
				local se1 = `r(se)'

				* Save coefficients and p-values for linear combinations of quadratic term
				local  b2 = _b[c.oil2] + _b[c.oil2#1.thirdparty]
				qui lincom c.oil2 + c.oil2#1.thirdparty
				local p2_aux : di %6.3g scalar(`r(p)')
				estadd scalar p2 = `p2_aux'
				local b2s_aux : di %6.4f scalar(`b2')
				if (`r(p)' <= 1) {
					local b2s =  "`b2s_aux'"
					if (`r(p)' < 0.1) {
						local b2s =  "`b2s_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local b2s =  "`b2s_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local b2s =  "`b2s_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local b2s = "`b2s'"
				
				est sto reg`counter'
			}

}
}


esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
${main}5_output/tables/prio_oilint_arms90_ukr.tex, replace ///
 drop(`controls' 1.thirdparty#c.gas 1.thirdparty#c.gas2 ///
	gas gas2 1.thirdparty#c.coal ///
	1.thirdparty#c.coal2 coal coal2) /// 
	coeflabels(1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil X Third Party" 1.thirdparty#c.oil "Oil X Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) X Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) X Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space gascoal gascoalsq yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"Gas, Coal X Third Party"' `"Gas\(^2\), Coal\(^2\) X Third Party"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	
	
	
********* Maps
*ssc install spmap
*ssc install shp2dta
*ssc install mif2dta

use ${main}2_processed/data_regressions.dta, clear
kountry ccode, from(cown) to(iso3c)
rename _ISO3C_ ISO_A3
merge m:m ISO_A3 using  ${main}1_data/maps_utilities/worlddata_cleaned.dta
duplicates drop ISO_A3, force
spmap armstrade90 using ${main}1_data/maps_utilities/worldcoor.dta, id(id) fcolor(Greens2)
graph export ${main}5_output/figures/armstrade90.png, replace

use ${main}2_processed/data_regressions.dta, clear
kountry ccode, from(cown) to(iso3c)
rename _ISO3C_ ISO_A3
merge m:m ISO_A3 using  ${main}1_data/maps_utilities/worlddata_cleaned.dta
duplicates drop ISO_A3, force
spmap contig_bases1000 using ${main}1_data/maps_utilities/worldcoor.dta, id(id) fcolor(Greens2)
graph export ${main}5_output/figures/bases1000.png, replace

use ${main}2_processed/data_regressions.dta, clear
kountry ccode, from(cown) to(iso3c)
rename _ISO3C_ ISO_A3
merge m:m ISO_A3 using  ${main}1_data/maps_utilities/worlddata_cleaned.dta
duplicates drop ISO_A3, force
spmap sedvol using ${main}1_data/maps_utilities/worldcoor.dta, id(id) fcolor(Greens2)
graph export ${main}5_output/figures/sedvol.png, replace

use ${main}2_processed/data_regressions.dta, clear
kountry ccode, from(cown) to(iso3c)
rename _ISO3C_ ISO_A3
merge m:m ISO_A3 using  ${main}1_data/maps_utilities/worlddata_cleaned.dta
duplicates drop ISO_A3, force
spmap oil using ${main}1_data/maps_utilities/worldcoor.dta, id(id) fcolor(Greens2)
graph export ${main}5_output/figures/oil.png, replace

use ${main}2_processed/data_regressions.dta, clear
kountry ccode, from(cown) to(iso3c)
rename _ISO3C_ ISO_A3
merge m:m ISO_A3 using  ${main}1_data/maps_utilities/worlddata_cleaned.dta
duplicates drop ISO_A3, force
spmap conf_years using ${main}1_data/maps_utilities/worldcoor.dta, id(id) fcolor(Greens2)
graph export ${main}5_output/figures/conflict_years.png, replace

use ${main}2_processed/data_regressions.dta, clear
kountry ccode, from(cown) to(iso3c)
rename _ISO3C_ ISO_A3
merge m:m ISO_A3 using  ${main}1_data/maps_utilities/worlddata_cleaned.dta
duplicates drop ISO_A3, force
spmap armstrade50 using ${main}1_data/maps_utilities/worldcoor.dta, id(id) fcolor(Greens2)
graph export ${main}5_output/figures/armstrade50.png, replace

use ${main}2_processed/data_regressions.dta, clear
kountry ccode, from(cown) to(iso3c)
rename _ISO3C_ ISO_A3
merge m:m ISO_A3 using  ${main}1_data/maps_utilities/worlddata_cleaned.dta
duplicates drop ISO_A3, force
spmap armstrade50 using ${main}1_data/maps_utilities/worldcoor.dta, id(id) fcolor(Greens2)
graph export ${main}5_output/figures/armstrade0.png, replace
	
