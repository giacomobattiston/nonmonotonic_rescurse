clear all
set more off

if "`c(username)'" == "giacomobattiston" { 
        cd "/Users/giacomobattiston/"
        global main "Dropbox/ricerca_dropbox/bbf/technology_conflict/"
		global git "Documents/GitHub/technology_conflict/"
}
else {
	cd "C:\Users\Franceschin\Documents\GitHub\technology_conflict"
	global main "C:\Users\Franceschin\Dropbox\bbf\technology_conflict\"
}

******************************* OIL PRICES *************************************
* Import price deflator data and save as dta
clear all

import delimited ${main}1_data/fred/GDPDEF.csv,clear

* Clean date variable
gen date_aux=date(date,"YMD")
gen year=year(date_aux)

* Turn into yearly dataset
collapse (mean) gdpdef, by (year)

save ${main}2_processed/deflator.dta, replace


clear all

import delimited ${main}1_data/fred/WTISPLC.csv,clear

* Clean date variable
gen date_aux=date(date,"YMD")
gen year=year(date_aux)

* Turn into yearly dataset
collapse (mean) wtisplc, by (year)

* Merge deflator data
merge 1:1 year using ${main}2_processed/deflator.dta

rename wtisplc oil_price
replace oil_price = oil_price/gdpdef
gen oil_price2 = oil_price^2

keep year gdpdef oil_price oil_price2

save ${main}2_processed/oilprice.dta,replace



********************************* UN VOTING ************************************
clear all

use ${main}1_data/UN_votes/affinity_01242010.dta,clear

preserve
* we are interested with affinity with USA, ccode 2
keep if ccodea==2

sort ccodeb year 

* we gen an average affinity based on votes between 1946-1955, as average of the S index presented in Gartzke
* we gen also an average of votes in 1946-1965 to include new states
drop if year>1999
*to be able to have the mean of only years below 1955 and 1966
gen less1956=year<1956
gen less1960=year<1960
gen less1966=year<1966
gen less1970=year<1970

*affinity based on 3 possible votes
by ccodeb: egen avg_affinity99_3=mean(s3un4608i)
bysort ccodeb less1956: egen avg_affinity55_3=mean(s3un4608i)
bysort ccodeb less1960: egen avg_affinity59_3=mean(s3un4608i)
bysort ccodeb less1966: egen avg_affinity65_3=mean(s3un4608i)
bysort ccodeb less1970: egen avg_affinity69_3=mean(s3un4608i)

*affinity based on 2 possible votes

by ccodeb: egen avg_affinity99=mean(s2un4608i)
bysort ccodeb less1956: egen avg_affinity55=mean(s2un4608i)
bysort ccodeb less1960: egen avg_affinity59=mean(s2un4608i)
bysort ccodeb less1966: egen avg_affinity65=mean(s2un4608i)
bysort ccodeb less1970: egen avg_affinity69=mean(s2un4608i)

*keeping one record per country
sort ccodeb year
bysort ccodeb: gen rank=_n
drop if rank>1
replace avg_affinity59=. if year>1959
replace avg_affinity55=. if year>1955
replace avg_affinity65=. if year>1965
replace avg_affinity69=. if year>1969

replace avg_affinity59_3=. if year>1959
replace avg_affinity55_3=. if year>1955
replace avg_affinity65_3=. if year>1965
replace avg_affinity69_3=. if year>1969

*keeping only the useful variables
keep ccodeb avg_affinity*
rename ccodeb ccode

save ${main}2_processed/US_affinity.dta,replace
restore



preserve
* we are interested with affinity with USSR, ccode 365
keep if ccodea==365

sort ccodeb year 

* we gen an average affinity based on votes between 1946-1955, as average of the S index presented in Gartzke
* we gen also an average of votes in 1946-1965 to include new states
drop if year>1999
*to be able to have the mean of only years below 1955 and 1966
gen less1956=year<1956
gen less1960=year<1960
gen less1966=year<1966
gen less1970=year<1970

*affinity based on 3 possible votes
by ccodeb: egen avg_ussraffinity99_3=mean(s3un4608i)
bysort ccodeb less1956: egen avg_ussraffinity55_3=mean(s3un4608i)
bysort ccodeb less1960: egen avg_ussraffinity59_3=mean(s3un4608i)
bysort ccodeb less1966: egen avg_ussraffinity65_3=mean(s3un4608i)
bysort ccodeb less1970: egen avg_ussraffinity69_3=mean(s3un4608i)

*affinity based on 2 possible votes

by ccodeb: egen avg_ussraffinity99=mean(s2un4608i)
bysort ccodeb less1956: egen avg_ussraffinity55=mean(s2un4608i)
bysort ccodeb less1960: egen avg_ussraffinity59=mean(s2un4608i)
bysort ccodeb less1966: egen avg_ussraffinity65=mean(s2un4608i)
bysort ccodeb less1970: egen avg_ussraffinity69=mean(s2un4608i)

*keeping one record per country
sort ccodeb year
bysort ccodeb: gen rank=_n
drop if rank>1
replace avg_ussraffinity59=. if year>1959
replace avg_ussraffinity55=. if year>1955
replace avg_ussraffinity65=. if year>1965
replace avg_ussraffinity69=. if year>1969

replace avg_ussraffinity59_3=. if year>1959
replace avg_ussraffinity55_3=. if year>1955
replace avg_ussraffinity65_3=. if year>1965
replace avg_ussraffinity69_3=. if year>1969

*keeping only the useful variables
keep ccodeb avg_ussraffinity*
rename ccodeb ccode

save ${main}2_processed/USSR_affinity.dta,replace
restore

* Clean data on US bases and arms' trade
clear 

****************************ARMS' IMPORTS FROM THE US***************************

* Construct the dataset on arms' imports from the US
import delimited ${main}1_data/sipri_tiv/TIV-Export-USA-1950-2019_noheader.csv, /// 
	delimiter(";") encoding(ISO-8859-1) varnames(1)

* Adjust discrepancies with distances data in country naming, rebel groups
* international organizations, and past or yet-to-appear countries
rename v1 country
* Drop international organizations
drop if country == "African Union**"
drop if country == "NATO**"
drop if country == "United Nations**"
drop if country == "Regional Security System**"
* Drop rebels
drop if country == "Anti-Castro rebels (Cuba)*"
drop if country == "Armas (Guatemala)*"
drop if country == "Contras (Nicaragua)*"
drop if country == "Haiti rebels*"
drop if country == "Indonesia rebels*"
drop if country == "Mujahedin (Afghanistan)*"
drop if country == "Syria rebels*"
drop if country == "UNITA (Angola)*"
* Drop non-existing countries
drop if country == "Biafra"
drop if country == "Yugoslavia"
drop if country == "Unknown recipient(s)"
drop if country == "Libya GNC"
drop if country == "Libya HoD"
drop if country == "North Yemen"
drop if country == "South Vietnam"
* Rename some countries in dataset
replace country = "Brunei Darussalam" if country == "Brunei"
replace country = "Belgium and Luxembourg" if country == "Belgium"
replace country = "Bosnia and Herzegovina" if country == "Bosnia-Herzegovina"
replace country = "Côte d'Ivoire" if country == "Cote d'Ivoire"
replace country = "Czech Republic" if country == "Czechia"
replace country = "Kazakstan" if country == "Kazakhstan"
replace country = "Lao People's Democratic Republic" if country == "Laos"
replace country = "Libyan Arab Jamahiriya" if country == "Libya"
replace country = "Macedonia (the former Yugoslav Rep. of)" if country == "Macedonia"
replace country = "Micronesia (Federated States of)" if country == "Micronesia"
replace country = "Serbia and Montenegro" if country == "Serbia"
replace country = "Burma" if country == "Myanmar"
replace country = "Korea, Dem. People's Rep. of" if country == "North Korea"
replace country = "Korea" if country == "South Korea"
replace country = "Syrian Arab Republic" if country == "Syria"
replace country = "Tanzania, United Rep. of " if country == "Tanzania"
replace country = "Saint Vincent and the Grenadines" if country == "Saint Vincent"
replace country = "United Arab Emirates" if country == "UAE"
replace country = "Congo (Democratic Republic of the)" if country == "DR Congo"


* armstrade will store overall quantity of armstrade from the US 1950-99
gen armstrade = 0

* Sum over arms trade from 1950 to 99 (each v is a year)
foreach var of varlist v* {
	destring `var', replace
	replace `var' = 0 if `var' == .
	replace armstrade = armstrade + `var'
}

* Sum over arms trade from 1950 to 99 (each v is a year)
gen armstrade1950 = 0
foreach var of varlist v2-v11 {
	di "`var'"
	replace armstrade1950 = armstrade1950 + `var'
}

*rename v2 armstrade1950
drop v*

* Luxemburg and Belgium are put together in distances dataset: sum arms trade
qui sum armstrade if country == "Luxembourg"
replace armstrade = armstrade + `r(mean)' if country == "Belgium and Luxembourg"

* So are Serbia and Montenengro: sum arms trade
qui sum armstrade if country == "Montenegro"
replace armstrade = armstrade + `r(mean)' if country == "Serbia and Montenegro"

* Luxemburg and Belgium are put together in distances dataset: sum arms trade
qui sum armstrade1950 if country == "Luxembourg"
replace armstrade1950 = armstrade1950 + `r(mean)' if country == "Belgium and Luxembourg"
drop if country == "Luxembourg"

* So are Serbia and Montenengro: sum arms trade
qui sum armstrade1950 if country == "Montenegro"
replace armstrade1950 = armstrade1950 + `r(mean)' if country == "Serbia and Montenegro"
drop if country == "Montenegro"

* armstrade dummy
gen armstrade_dummy = 1 if armstrade > 0
keep if armstrade_dummy == 1

save ${main}2_processed/arms_trade.dta, replace


clear
* Use geodist data to collect country names: they will be used in matching
import excel ${main}1_data/geodist/geo_cepii.xls, sheet("geo_cepii") firstrow
keep iso3 country
rename iso3 id_country
duplicates drop id_country, force
save ${main}2_processed/country_names.dta, replace

clear
* Now start constructing the final data. Import distances
import excel ${main}1_data/geodist/dist_cepii.xls, sheet("dist_cepii") firstrow

* Merge with country names
rename iso_d id_country
merge m:1 id_country using ${main}2_processed/country_names.dta
rename _merge _merge1

* Use country names to merge with arms_trade
merge m:1 country using ${main}2_processed/arms_trade.dta
rename id_country iso_d 

* In this long data, keep only couples where destination has arms trade
keep if armstrade_dummy == 1
keep dist iso_o iso_d 
rename dist dist_arms
drop if missing(iso_o)

* Take minimum distance from base for each origin
collapse (min) dist_arms, by(iso_o)

* Use the same procedure above to merge with arms trade in millions
rename iso_o id_country
merge m:1 id_country using ${main}2_processed/country_names.dta
rename _merge _merge3
merge m:1 country using ${main}2_processed/arms_trade.dta
rename _merge _merge4
rename id_country iso_3

* Use country package to generate COW country codes
* DRC has old code in geodist. Change to new:
replace iso_3 = "COD" if iso_3 == "ZAR"

* ssc install kountry
kountry iso_3, from(iso3c) to(cown)
rename _COWN_ ccode
* Yemen has wrong code
* Romania
replace ccode = 360 if iso_3 == "ROM"

keep ccode dist_arms armstrade armstrade1950
keep if !missing(ccode) &  !missing(dist)
replace armstrade = 0 if missing(armstrade)
replace armstrade1950 = 0 if missing(armstrade1950)
save ${main}2_processed/dist_arms.dta, replace


clear
****************************ARMS' IMPORTS FROM USSR***************************

* Construct the dataset on arms' imports from USSR
import delimited ${main}1_data/sipri_tiv/TIV-Export-USR-1950-1999_noheader.csv, /// 
	delimiter(",") encoding(ISO-8859-1) varnames(1)

	
* Adjust discrepancies with distances data in country naming, rebel groups
* international organizations, and past or yet-to-appear countries
rename v1 country
* Drop rebels
drop if country == "ANC (South Africa)*"
drop if country == "PLO (Israel)*"
drop if country == "Viet Cong (South Vietnam)*"
drop if country == "ZAPU (Zimbabwe)*"
drop if country == "ZAPU (Zimbabwe)*"
* Drop non-existing countries
drop if country == "Western Sahara"
drop if country == "Yugoslavia"
drop if country == "Czechoslovakia"
drop if country == "East Germany (GDR)"
drop if country == "Unknown recipient(s)"
drop if country == "Libya GNC"
drop if country == "Libya HoD"
drop if country == "North Yemen"
* Rename some countries in dataset
replace country = "Cape Verde" if country == "Cabo Verde"
replace country = "Lao People's Democratic Republic" if country == "Laos"
replace country = "Libyan Arab Jamahiriya" if country == "Libya"
replace country = "Burma" if country == "Myanmar"
replace country = "Korea, Dem. People's Rep. of" if country == "North Korea"
replace country = "Syrian Arab Republic" if country == "Syria"
replace country = "Tanzania, United Rep. of " if country == "Tanzania"
replace country = "United Arab Emirates" if country == "UAE"
replace country = "Cape Verde" if country == "Cabo Verde"

drop if country == " "
drop if country == "Total"

* armstrade will store overall quantity of armstrade from the US 1950-99
gen armstrade_ussr = 0

* Sum over arms trade from 1950 to 99 (each v is a year)
foreach var of varlist v* {
	destring `var', replace
	replace `var' = 0 if `var' == .
	replace armstrade_ussr = armstrade_ussr + `var'
}


* Sum over arms trade from 1950 to 59 (each v is a year)
gen armstrade_ussr1950 = 0
foreach var of varlist v2-v11 {
	di "`var'"
	replace armstrade_ussr1950 = armstrade_ussr1950 + `var'
}

drop v*

qui sum armstrade_ussr1950 if country == "South Yemen"
replace armstrade_ussr1950 = armstrade_ussr1950 + `r(mean)' if country == "Yemen"
drop if country == "South Yemen"

qui sum armstrade_ussr1950 if country == "Yemen Arab Republic"
replace armstrade_ussr1950 = armstrade_ussr1950 + `r(mean)' if country == "Yemen"
drop if country == "Yemen Arab Republic"

* armstrade dummy
gen armstrade_dummy_ussr = 1 if armstrade_ussr > 0
keep if armstrade_dummy_ussr == 1

save ${main}2_processed/arms_trade_USSR.dta, replace


clear
* Now start constructing the final data. Import distances
import excel ${main}1_data/geodist/dist_cepii.xls, sheet("dist_cepii") firstrow

* Merge with country names
rename iso_d id_country
merge m:1 id_country using ${main}2_processed/country_names.dta
rename _merge _merge1


* Use country names to merge with arms_trade
merge m:1 country using ${main}2_processed/arms_trade_USSR.dta
rename id_country iso_d 

* In this long data, keep only couples where destination has arms trade
keep if armstrade_dummy_ussr == 1
keep dist iso_o iso_d 
rename dist dist_arms_ussr
drop if missing(iso_o)

* Take minimum distance from base for each origin
collapse (min) dist_arms_ussr, by(iso_o)

* Use the same procedure above to merge with arms trade in millions
rename iso_o id_country
merge m:1 id_country using ${main}2_processed/country_names.dta
rename _merge _merge3
merge m:1 country using ${main}2_processed/arms_trade_USSR.dta
rename _merge _merge4
rename id_country iso_3

* Use country package to generate COW country codes
* DRC has old code in geodist. Change to new:
replace iso_3 = "COD" if iso_3 == "ZAR"
* ssc install kountry
kountry iso_3, from(iso3c) to(cown)
rename _COWN_ ccode
* Yemen has wrong code
* Romania
replace ccode = 360 if iso_3 == "ROM"

keep ccode dist_arms_ussr armstrade_ussr1950
keep if !missing(ccode) &  !missing(dist)
replace armstrade_ussr = 0 if missing(armstrade_ussr)
save ${main}2_processed/dist_arms_USSR.dta, replace


**********************Department of Defence Personnel***************************

****CONTIGUITY BASES 1950

clear
* Now start constructing the final data. Import distances
import excel ${main}1_data/geodist/dist_cepii.xls, sheet("dist_cepii") firstrow


*max km distance traveled in a day by US troops
*321.869

destring distw, replace

*try with distances
replace contig = dist < 1000

* Countries are contiguous to themselves
replace contig = 1 if iso_o == iso_d

* Merge with country names
rename iso_d id_country
merge m:1 id_country using ${main}2_processed/country_names.dta
rename _merge _merge1

* bases data from https://www.rand.org/pubs/research_reports/RR1906.html
gen dod1950 = .
replace dod1950 = 100 if country == "Greenland"
replace dod1950 = 100 if country == "Peru"
replace dod1950 = 100 if country == "Brazil"
replace dod1950 = 100 if country == "Portugal"
replace dod1950 = 100 if country == "France"
replace dod1950 = 100 if country == "Libyan Arab Jamahiriya"
replace dod1950 = 100 if country == "Eritrea"
replace dod1950 = 100 if country == "Turkey"
replace dod1950 = 100 if country == "Saudi Arabia"
replace dod1950 = 100 if country == "Korea"
replace dod1950 = 1000 if country == "Canada"
replace dod1950 = 1000 if country == "United Kingdom"
replace dod1950 = 1000 if country == "Italy"
replace dod1950 = 10000 if country == "Philippines"
replace dod1950 = 10000 if country == "Germany"
replace dod1950 = 100000 if country == "Japan"
replace dod1950 = 100000 if country == "United States of America"

* In this long data, keep only couples where destination has arms trade
keep if dod1950 != .
keep contig iso_o 
rename contig contig50bases
drop if missing(iso_o)

* Take minimum distance from base for each origin
collapse (max) contig50bases, by(iso_o)

rename iso_o iso_3
* Use country package to generate COW country codes
* DRC has old code in geodist. Change to new:
replace iso_3 = "COD" if iso_3 == "ZAR"
* ssc install kountry
kountry iso_3, from(iso3c) to(cown)
rename _COWN_ ccode
* Yemen has wrong code
* Romania
replace ccode = 360 if iso_3 == "ROM"

keep ccode contig50bases
keep if !missing(ccode) &  !missing(contig50bases)
save ${main}2_processed/contig50bases.dta, replace


*************************** DISTANCE FROM THE US *******************************

clear
* Now start constructing the final data. Import distances
import excel ${main}1_data/geodist/dist_cepii.xls, sheet("dist_cepii") firstrow

keep if iso_d == "USA"

rename iso_o iso_3
* Use country package to generate COW country codes
* DRC has old code in geodist. Change to new:
replace iso_3 = "COD" if iso_3 == "ZAR"
* ssc install kountry
kountry iso_3, from(iso3c) to(cown)
rename _COWN_ ccode
* Yemen has wrong code
* Romania
replace ccode = 360 if iso_3 == "ROM"

rename dist distus

keep ccode distus
keep if !missing(ccode) &  !missing(distus)
save ${main}2_processed/distus.dta, replace





***************************IMPORT DATA FOR ANALYSIS*****************************

* Import data from Hunzicker&al and creating dta file
import delimited ${main}1_data/hunziker_replication/data/country_cs.csv, clear 
rename cowid ccode
drop year
save ${main}2_processed/hunzicker_data.dta,replace

* Import data from Ashraf&Galor for geographical/climatical variables
use ${main}1_data/galor_replication/country.dta,clear
* Assign the Gleditsch-Ward numbers to the country with do-file in local
gen ccode=.
do ${git}gwno.do
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
do ${git}gwno.do

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
merge m:1 ccode using ${main}2_processed/contig50bases.dta
rename _merge mergeBASES50

* Merge with data about arms trade
merge m:1 ccode using ${main}2_processed/dist_arms_USSR.dta
rename _merge mergeARMS_USSR

* Merge with UN data
merge m:1 ccode using ${main}2_processed/US_affinity.dta
rename _merge mergeUN

* Merge with UN data
merge m:1 ccode using ${main}2_processed/distus.dta
rename _merge mergeDISTUS

* Drop Germany, GFR
drop if ccode == 260
*GDR
drop if ccode == 265
*Drop China
drop if ccode == 710

* Define US arms trade dummy taking value 1 for values above 90th percentile
qui sum armstrade, detail
gen armstrade90 = armstrade >  `r(p90)' if !missing(armstrade)

* Define US arms trade dummy taking value 1 for larger than 0
gen armstrade0 = armstrade >  0 if !missing(armstrade)

* Define US arms trade dummy taking value 1 for larger than 0
qui sum armstrade1950, detail
replace armstrade1950 = armstrade1950 >  0 if !missing(armstrade1950)

* Define USSR arms trade dummy taking value 1 for larger than 0
qui sum armstrade_ussr1950, detail
replace armstrade_ussr1950 = armstrade_ussr1950 >  0 if !missing(armstrade_ussr1950)


* Define US distance dummy 
sum distus, de
gen distusless75 = distus <  `r(p75)' if !missing(distus)

* Define affinity dummies
qui sum avg_affinity65, detail
gen affinity0_65 = avg_affinity65 >  0 if !missing(avg_affinity65)

qui sum avg_affinity65_3, detail
gen affinity0_65_3 = avg_affinity65_3 >  0 if !missing(avg_affinity65_3)

* Generate variable recording total conflict years
egen conf_years = sum(conflict), by(ccode)

* Merge oil prices
merge m:1 year using ${main}2_processed/oilprice.dta

*label controls used in 
la var lnarea "Area, (log Km\(^2\))"
la var abslat "Absolute latitude"
la var elevavg "Average altitude (Km)"
la var elevstd "Dispersion in altitude"
la var temp "Average temperature (C)"
la var prec "Average precipitation (mm)"
la var lnpop14 "Population, logs"
la var armstrade90 "US arms imports above the 90th percentile"
la var armstrade0 "US arms imports above 0"
la var armstrade "US arms imports above"
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
la var gdpdef "Deflator, relative to 2012"
la var oil_price "Oil price (WTI), in 2012 dollars"
la var oil_price2 "Oil price (WTI) squared, in 2012 dollars"
la var conflict "Conflict, at l. 25 deaths"
la var conflict2 "Conflict, at l. 1000\ deaths"
la var contig50bases "Close to US base"
la var armstrade1950 "Traded arms with US"
la var affinity0_65 "UNGA voting affinity"
la var affinity0_65_3 "UNGA voting affinity (3 votes)"
la var distus "Distance from the US (Km)"


* Sample from 1950 to 1999
keep if year < 2000


* Conflict onset
xtset ccode year



keep year region lnarea abslat elevavg elevstd temp prec lnpop14 ///
	conflict conflict2 sedvol sedvol2 coal coal2 gas gas2 oil oil oil2  ///
	armstrade90 armstrade ccode conf_years ///
	armstrade0 gdpdef oil_price oil_price2 gdpdef ///
	legor_uk legor_fr legor_so legor_ge legor_sc pmuslim pcatholic pprotest ///
	contig50bases armstrade1950 armstrade_ussr1950 affinity* distus* 

save ${main}2_processed/data_regressions.dta, replace

* prova con fraction conflict
collapse region lnarea abslat elevavg elevstd temp prec lnpop14 ///
	conflict conflict2 sedvol sedvol2 coal coal2 gas gas2 oil oil2  ///
	armstrade90 armstrade conf_years ///
	armstrade0 gdpdef oil_price oil_price2 ///
	legor_uk legor_fr legor_so legor_ge legor_sc pmuslim pcatholic pprotest ///
	contig50bases armstrade1950 armstrade_ussr1950 affinity* distus* (min) year, by(ccode)

replace year = 1950
*fino a qui sopra	
	
**********************************ANALYSIS**************************************

gen thirdparty = .

global outcome_list "conflict conflict2"
local controls "lnarea  abslat elevavg elevstd temp precip lnpop14"
	
	
			
* Table 1: Conflict and resources, disaggregated resources

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
forval i_indep = 1/2 {
	if (`i_indep' == 1) {
		gen x = oil
		gen x2 = oil2
		local independent "c.x c.x2 c.gas c.gas2 c.coal c.coal2"
	}
	else {
		gen x = sedvol
		gen x2 = sedvol2
		local independent "x x2"
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
			
			if (`i_indep' == 1) {
				
				estadd local gas = "Yes"
				estadd local coal = "Yes"
			
				estadd scalar peak = -_b[c.x]/(2*_b[c.x2])
				
				* Test for inverse-U shaped relation
				utest x x2, quadratic
				
				}
				
				else {
				
				estadd local gas = "No"
				estadd local coal = "No"
				
				estadd scalar peak = -_b[c.x]/(2*_b[c.x2])
				
				* Test for inverse-U shaped relation
				utest x x2, quadratic
				
				}
				
		
				local putest_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putest =  "`putest_aux'"
					if (`r(p)' < 0.1) {
						local putest =  "`putest_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putest =  "`putest_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putest =  "`putest_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local putest = "`putest'"
				
				estadd local space = " "
				
				est sto reg`counter'
		}

}
	drop x x2
}

esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
${main}5_output/tables/prioallred.tex, replace ///
coeflabels(x "Res. Value" x2 "Res. Value\(^2\)") se ///
starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
 nobaselevels ///
 mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 drop(`controls' gas* coal*) ///
 	stats(space putest space gas coal yearfe continentfe geocontrols   peak N, fmt(s s s s s s a2 a2) ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{H0: No inv.-U shape}"' `"\qquad \emph{p-value}"' `" "' `"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' `"Year FEs"' `"Continent FEs"'  `"Geo Controls"' `"Peak"' `"\(N\)"')) ///
		mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
			postfoot("\hline\hline \end{tabular}}")	
			
		
			
* Table 2: WB resources and sedimentary basins, by contiguity to US bases

global thirdparty_list "contig50bases"
local counter 0

gen x = sedvol
gen x2 = sedvol2
* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				
				* Test for inverse-U shaped relation with interaction
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#0.thirdparty   c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putestint_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putestint =  "`putestint_aux'"
					if (`r(p)' < 0.1) {
						local putestint =  "`putestint_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putestint =  "`putestint_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putestint =  "`putestint_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putestint ="."
				}
				
				
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 ///
					c.x2#i.thirdparty i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.year i.region `controls', ///
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
				local  b1 = _b[c.x] + _b[c.x#1.thirdparty]
				qui lincom c.x + c.x#1.thirdparty
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
				local  b2 = _b[c.x2] + _b[c.x2#1.thirdparty]
				qui lincom c.x2 + c.x2#1.thirdparty
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
				
				* Test for inverse-U shaped relation with no interaction
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putest_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putest =  "`putest_aux'"
					if (`r(p)' < 0.1) {
						local putest =  "`putest_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putest =  "`putest_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putest =  "`putest_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putest = "."
				}
				
				estadd local putest = "`putest'"
				estadd local putestint = "`putestint'"
				
				* Save resource controls indicators
				estadd local gascoal = "No"
				estadd local gascoalsq = "No"
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				est sto reg`counter'
			}

}
}

drop x x2



gen x = oil
gen x2 = oil2
* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				
				* Test for inverse-U shaped relation with interaction
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#0.thirdparty   c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putestint_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putestint =  "`putestint_aux'"
					if (`r(p)' < 0.1) {
						local putestint =  "`putestint_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putestint =  "`putestint_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putestint =  "`putestint_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putestint ="."
				}
				
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#i.thirdparty   c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
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
				local  b1 = _b[c.x] + _b[c.x#1.thirdparty]
				qui lincom c.x + c.x#1.thirdparty
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
				local  b2 = _b[c.x2] + _b[c.x2#1.thirdparty]
				qui lincom c.x2 + c.x2#1.thirdparty
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
				
				* Test for inverse-U shaped relation with no interaction
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putest_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putest =  "`putest_aux'"
					if (`r(p)' < 0.1) {
						local putest =  "`putest_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putest =  "`putest_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putest =  "`putest_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putest = "."
				}
				
				estadd local putest = "`putest'"
				estadd local putestint = "`putestint'"
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				est sto reg`counter'
			}

}
}

drop x x2

esttab reg5 reg6 reg7 reg8 reg1 reg2 reg3 reg4 using ///
${main}5_output/tables/prio_int_bases.tex, replace ///
 drop(`controls'  1.thirdparty 1.thirdparty#c.x 1.thirdparty#c.x2 ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil \(\times\) Third Party" 1.thirdparty#c.oil "Oil \(\times\) Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) \(\times\) Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) \(\times\) Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq yearfe continentfe geocontrols thirdpartyfe N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s  s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"\emph{H0: No inv.-U shape}"' `"\qquad \emph{Base Coeff. p-value}"' `"\qquad \emph{Base + Inter. Coeff. p-value}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"' `"Third Party"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")



	
			
* Table 3: WB resources and sedimentary basins, by US armstrade

global thirdparty_list "armstrade1950"
local counter 0

gen x = sedvol
gen x2 = sedvol2
* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				
				* Test for inverse-U shaped relation with interaction
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#0.thirdparty   c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putestint_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putestint =  "`putestint_aux'"
					if (`r(p)' < 0.1) {
						local putestint =  "`putestint_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putestint =  "`putestint_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putestint =  "`putestint_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putestint ="."
				}
				
				
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 ///
					c.x2#i.thirdparty i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.year i.region `controls', ///
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
				local  b1 = _b[c.x] + _b[c.x#1.thirdparty]
				qui lincom c.x + c.x#1.thirdparty
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
				local  b2 = _b[c.x2] + _b[c.x2#1.thirdparty]
				qui lincom c.x2 + c.x2#1.thirdparty
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
				
				* Test for inverse-U shaped relation with no interaction
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putest_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putest =  "`putest_aux'"
					if (`r(p)' < 0.1) {
						local putest =  "`putest_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putest =  "`putest_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putest =  "`putest_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putest = "."
				}
				
				estadd local putest = "`putest'"
				estadd local putestint = "`putestint'"
				
				* Save resource controls indicators
				estadd local gascoal = "No"
				estadd local gascoalsq = "No"
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				est sto reg`counter'
			}
		}
}


drop x x2



gen x = oil
gen x2 = oil2
* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				
				* Test for inverse-U shaped relation with interaction
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#0.thirdparty   c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putestint_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putestint =  "`putestint_aux'"
					if (`r(p)' < 0.1) {
						local putestint =  "`putestint_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putestint =  "`putestint_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putestint =  "`putestint_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putestint ="."
				}
				
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#i.thirdparty   c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
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
				local  b1 = _b[c.x] + _b[c.x#1.thirdparty]
				qui lincom c.x + c.x#1.thirdparty
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
				local  b2 = _b[c.x2] + _b[c.x2#1.thirdparty]
				qui lincom c.x2 + c.x2#1.thirdparty
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
				
				* Test for inverse-U shaped relation with no interaction
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putest_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putest =  "`putest_aux'"
					if (`r(p)' < 0.1) {
						local putest =  "`putest_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putest =  "`putest_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putest =  "`putest_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putest = "."
				}
				
				estadd local putest = "`putest'"
				estadd local putestint = "`putestint'"
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				est sto reg`counter'
			}

}
}

drop x x2

esttab reg5 reg6 reg7 reg8 reg1 reg2 reg3 reg4 using ///
${main}5_output/tables/prio_int_armstrade.tex, replace ///
 drop(`controls'  1.thirdparty 1.thirdparty#c.x 1.thirdparty#c.x2 ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil \(\times\) Third Party" 1.thirdparty#c.oil "Oil \(\times\) Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) \(\times\) Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) \(\times\) Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq yearfe continentfe geocontrols thirdpartyfe N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s  s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"\emph{H0: No inv.-U shape}"' `"\qquad \emph{Base Coeff. p-value}"' `"\qquad \emph{Base + Inter. Coeff. p-value}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"' `"Third Party"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")

	
	
		
*TABLE A1: summary

	estpost tabstat sedvol oil gas coal lnarea  abslat elevavg elevstd temp ///
	precip lnpop14 conflict conflict2 contig50bases armstrade1950 affinity0_65 distus, stat(mean sd min p50  max n) col(stat) 
	*esttab, cells("mean sd p25 p50  p75 count") label
	matrix summary = e(mean)',  e(sd)' , e(min)', e(p50)',  e(max)', e(count)'

	esttab using ${main}5_output/tables/summary.tex, cells("mean(fmt(%9.3g) label(Mean)) sd(fmt(%9.3g) label(sd)) min(fmt(%9.3g) label(Min)) p50(fmt(%9.3g) label(Median))  max(fmt(a1) label(Max)) count(fmt(%9.0g) label(N))") label noobs nonumber replace 

	estpost tabstat sedvol oil gas coal , stat(mean sd min p50  max n) col(stat) 
	*esttab, cells("mean sd p25 p50  p75 count") label
	matrix summary = e(mean)',  e(sd)' , e(min)', e(p50)',  e(max)', e(count)'

	esttab using ${main}5_output/tables/summarya.tex, cells("mean(fmt(%9.3g) label(\quad)) sd(fmt(%9.3g) label(\quad)) min(fmt(%9.3g) label(\quad)) p50(fmt(%9.3g) label(\quad))  max(fmt(a1) label(\quad)) count(fmt(%9.0g) label(\quad))") label noobs nomtitles nonumber replace prehead("") posthead(" ") postfoot("")

	
		estpost tabstat lnarea  abslat elevavg elevstd temp precip lnpop14, stat(mean sd min p50  max n) col(stat) 
	*esttab, cells("mean sd p25 p50  p75 count") label
	matrix summary = e(mean)',  e(sd)' , e(min)', e(p50)',  e(max)', e(count)'

	esttab using ${main}5_output/tables/summaryb.tex, cells("mean(fmt(%9.3g) label(\quad)) sd(fmt(%9.3g) label(\quad)) min(fmt(%9.3g) label(\quad)) p50(fmt(%9.3g) label(\quad))  max(fmt(a1) label(\quad)) count(fmt(%9.0g) label(\quad))") label noobs nomtitles nonumber replace prehead("") posthead(" ") postfoot("")

	
		estpost tabstat conflict conflict2 , stat(mean sd min p50  max n) col(stat) 
	*esttab, cells("mean sd p25 p50  p75 count") label
	matrix summary = e(mean)',  e(sd)' , e(min)', e(p50)',  e(max)', e(count)'

	esttab using ${main}5_output/tables/summaryc.tex, cells("mean(fmt(%9.3g) label(\quad)) sd(fmt(%9.3g) label(\quad)) min(fmt(%9.3g) label(\quad)) p50(fmt(%9.3g) label(\quad))  max(fmt(a1) label(\quad)) count(fmt(%9.0g) label(\quad))") label noobs nomtitles nonumber replace prehead("") posthead(" ") postfoot("")


		estpost tabstat contig50bases armstrade1950 affinity0_65 distus, stat(mean sd min p50  max n) col(stat) 
	*esttab, cells("mean sd p25 p50  p75 count") label
	matrix summary = e(mean)',  e(sd)' , e(min)', e(p50)',  e(max)', e(count)'

	esttab using ${main}5_output/tables/summaryd.tex, cells("mean(fmt(%9.3g) label(\quad)) sd(fmt(%9.3g) label(\quad)) min(fmt(%9.3g) label(\quad)) p50(fmt(%9.3g) label(\quad))  max(fmt(a1) label(\quad)) count(fmt(%9.0g) label(\quad))") label noobs nomtitles nonumber replace prehead("") posthead(" ") postfoot("")


			
* Table A2: Determinants of third party presence
ivreg2 contig50bases    `controls' if year == 1950
est sto reg1
ivreg2 armstrade1950     `controls' if year == 1950
est sto reg2

esttab reg1 reg2 using ///
${main}5_output/tables/balance.tex, replace ///
label se ///
starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
 nobaselevels nonumbers ///
		mtitles("Bases" "Arms' Trade" ) ///
			postfoot("\hline\hline \end{tabular}}")


			
* Table A3: Conflict and resources		

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
			
			if (`i_indep' == 1) {
				estadd scalar peak = -_b[c.oil]/(2*_b[c.oil2])
				
				* Test for inverse-U shaped relation
				utest oil oil2, quadratic
				
				}
				
				else {
				estadd scalar peak = -_b[c.sedvol]/(2*_b[c.sedvol2])
				
				* Test for inverse-U shaped relation
				utest sedvol sedvol2, quadratic
				
				}
				
		
				local putest_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putest =  "`putest_aux'"
					if (`r(p)' < 0.1) {
						local putest =  "`putest_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putest =  "`putest_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putest =  "`putest_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local putest = "`putest'"
				
				estadd local space = " "
				
				est sto reg`counter'
		}

}
}

esttab reg* using ///
${main}5_output/tables/prioall.tex, replace ///
coeflabels(sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)" oil "Oil" oil2 "Oil\(^2\)" gas "Gas" gas2 "Gas\(^2\)" coal "Coal" coal2 "Coal\(^2\)") se ///
starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
 nobaselevels ///
 drop(`controls') ///
 	stats(space putest space yearfe continentfe geocontrols  peak N, fmt(s s s s s s a2 a2) ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{H0: No inv.-U shape}"' `"\qquad \emph{p-value}"' `" "' `"Year FEs"' `"Continent FEs"' `"Geo Controls"' `"Peak"' `"\(N\)"')) ///
		mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
			postfoot("\hline\hline \end{tabular}}")	


			
* Table A4: WB resources and sedimentary basins, by UN affinity '65 (0 thresholds)

global thirdparty_list "affinity0_65"
local counter 0



gen x = sedvol
gen x2 = sedvol2
* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				
				* Test for inverse-U shaped relation with interaction
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#0.thirdparty   c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putestint_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putestint =  "`putestint_aux'"
					if (`r(p)' < 0.1) {
						local putestint =  "`putestint_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putestint =  "`putestint_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putestint =  "`putestint_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putestint ="."
				}
				
				
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 ///
					c.x2#i.thirdparty i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.year i.region `controls', ///
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
				local  b1 = _b[c.x] + _b[c.x#1.thirdparty]
				qui lincom c.x + c.x#1.thirdparty
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
				local  b2 = _b[c.x2] + _b[c.x2#1.thirdparty]
				qui lincom c.x2 + c.x2#1.thirdparty
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
				
				* Test for inverse-U shaped relation with no interaction
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putest_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putest =  "`putest_aux'"
					if (`r(p)' < 0.1) {
						local putest =  "`putest_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putest =  "`putest_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putest =  "`putest_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putest = "."
				}
				
				estadd local putest = "`putest'"
				estadd local putestint = "`putestint'"
				
				* Save resource controls indicators
				estadd local gascoal = "No"
				estadd local gascoalsq = "No"
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				est sto reg`counter'
			}

}
}

drop x x2


gen x = oil
gen x2 = oil2
* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				
				* Test for inverse-U shaped relation with interaction
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#0.thirdparty   c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putestint_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putestint =  "`putestint_aux'"
					if (`r(p)' < 0.1) {
						local putestint =  "`putestint_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putestint =  "`putestint_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putestint =  "`putestint_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putestint ="."
				}
				
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#i.thirdparty   c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
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
				local  b1 = _b[c.x] + _b[c.x#1.thirdparty]
				qui lincom c.x + c.x#1.thirdparty
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
				local  b2 = _b[c.x2] + _b[c.x2#1.thirdparty]
				qui lincom c.x2 + c.x2#1.thirdparty
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
				
				* Test for inverse-U shaped relation with no interaction
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putest_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putest =  "`putest_aux'"
					if (`r(p)' < 0.1) {
						local putest =  "`putest_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putest =  "`putest_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putest =  "`putest_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putest = "."
				}
				
				estadd local putest = "`putest'"
				estadd local putestint = "`putestint'"
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				est sto reg`counter'
			}

}
}

drop x x2

esttab reg5 reg6 reg7 reg8 reg1 reg2 reg3 reg4 using ///
${main}5_output/tables/prio_int_unus065.tex, replace ///
 drop(`controls'  1.thirdparty 1.thirdparty#c.x 1.thirdparty#c.x2 ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil \(\times\) Third Party" 1.thirdparty#c.oil "Oil \(\times\) Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) \(\times\) Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) \(\times\) Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq yearfe continentfe geocontrols thirdpartyfe N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s  s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"\emph{H0: No inv.-U shape}"' `"\qquad \emph{Base Coeff. p-value}"' `"\qquad \emph{Base + Inter. Coeff. p-value}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"' `"Third Party"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")




* Table A5: Resources and conflict, with third party presence
* Close to the US

global thirdparty_list "distusless75"
local counter 0


gen x = sedvol
gen x2 = sedvol2
* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				
				* Test for inverse-U shaped relation with interaction
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#0.thirdparty   c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putestint_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putestint =  "`putestint_aux'"
					if (`r(p)' < 0.1) {
						local putestint =  "`putestint_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putestint =  "`putestint_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putestint =  "`putestint_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putestint ="."
				}
				
				
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 ///
					c.x2#i.thirdparty i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.year i.region `controls', ///
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
				local  b1 = _b[c.x] + _b[c.x#1.thirdparty]
				qui lincom c.x + c.x#1.thirdparty
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
				local  b2 = _b[c.x2] + _b[c.x2#1.thirdparty]
				qui lincom c.x2 + c.x2#1.thirdparty
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
				
				* Test for inverse-U shaped relation with no interaction
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putest_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putest =  "`putest_aux'"
					if (`r(p)' < 0.1) {
						local putest =  "`putest_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putest =  "`putest_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putest =  "`putest_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putest = "."
				}
				
				estadd local putest = "`putest'"
				estadd local putestint = "`putestint'"
				
				* Save resource controls indicators
				estadd local gascoal = "No"
				estadd local gascoalsq = "No"
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				est sto reg`counter'
			}

}
}

drop x x2



gen x = oil
gen x2 = oil2
* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				
				* Test for inverse-U shaped relation with interaction
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#0.thirdparty   c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putestint_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putestint =  "`putestint_aux'"
					if (`r(p)' < 0.1) {
						local putestint =  "`putestint_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putestint =  "`putestint_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putestint =  "`putestint_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putestint ="."
				}
				
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#i.thirdparty   c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
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
				local  b1 = _b[c.x] + _b[c.x#1.thirdparty]
				qui lincom c.x + c.x#1.thirdparty
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
				local  b2 = _b[c.x2] + _b[c.x2#1.thirdparty]
				qui lincom c.x2 + c.x2#1.thirdparty
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
				
				* Test for inverse-U shaped relation with no interaction
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putest_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putest =  "`putest_aux'"
					if (`r(p)' < 0.1) {
						local putest =  "`putest_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putest =  "`putest_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putest =  "`putest_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putest = "."
				}
				
				estadd local putest = "`putest'"
				estadd local putestint = "`putestint'"
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				est sto reg`counter'
			}

}
}

drop x x2

esttab reg5 reg6 reg7 reg8 reg1 reg2 reg3 reg4 using ///
${main}5_output/tables/prio_int_arms_closeus.tex, replace ///
 drop(`controls'  1.thirdparty 1.thirdparty#c.x 1.thirdparty#c.x2 ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil \(\times\) Third Party" 1.thirdparty#c.oil "Oil \(\times\) Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) \(\times\) Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) \(\times\) Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq yearfe continentfe geocontrols thirdpartyfe N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s  s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"\emph{H0: No inv.-U shape}"' `"\qquad \emph{Base Coeff. p-value}"' `"\qquad \emph{Base + Inter. Coeff. p-value}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"' `"Third Party"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")

			
* Table A6: Sedimentary bases presence and conflict, with third party presence
* Russia armstrade

global thirdparty_list "armstrade_ussr1950"
local counter 0

gen x = sedvol
gen x2 = sedvol2
* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				
				* Test for inverse-U shaped relation with interaction
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#0.thirdparty   c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putestint_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putestint =  "`putestint_aux'"
					if (`r(p)' < 0.1) {
						local putestint =  "`putestint_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putestint =  "`putestint_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putestint =  "`putestint_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putestint ="."
				}
				
				
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 ///
					c.x2#i.thirdparty i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.year i.region `controls', ///
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
				local  b1 = _b[c.x] + _b[c.x#1.thirdparty]
				qui lincom c.x + c.x#1.thirdparty
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
				local  b2 = _b[c.x2] + _b[c.x2#1.thirdparty]
				qui lincom c.x2 + c.x2#1.thirdparty
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
				
				* Test for inverse-U shaped relation with no interaction
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putest_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putest =  "`putest_aux'"
					if (`r(p)' < 0.1) {
						local putest =  "`putest_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putest =  "`putest_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putest =  "`putest_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putest = "."
				}
				
				estadd local putest = "`putest'"
				estadd local putestint = "`putestint'"
				
				* Save resource controls indicators
				estadd local gascoal = "No"
				estadd local gascoalsq = "No"
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				est sto reg`counter'
			}

}
}

drop x x2

gen x = oil
gen x2 = oil2
* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				
				* Test for inverse-U shaped relation with interaction
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#0.thirdparty   c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region `controls', ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putestint_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putestint =  "`putestint_aux'"
					if (`r(p)' < 0.1) {
						local putestint =  "`putestint_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putestint =  "`putestint_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putestint =  "`putestint_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putestint ="."
				}
				
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#i.thirdparty   c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
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
				local  b1 = _b[c.x] + _b[c.x#1.thirdparty]
				qui lincom c.x + c.x#1.thirdparty
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
				local  b2 = _b[c.x2] + _b[c.x2#1.thirdparty]
				qui lincom c.x2 + c.x2#1.thirdparty
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
				
				* Test for inverse-U shaped relation with no interaction
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putest_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putest =  "`putest_aux'"
					if (`r(p)' < 0.1) {
						local putest =  "`putest_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putest =  "`putest_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putest =  "`putest_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putest = "."
				}
				
				estadd local putest = "`putest'"
				estadd local putestint = "`putestint'"
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				est sto reg`counter'
			}

}
}

drop x x2

esttab reg5 reg6 reg7 reg8 reg1 reg2 reg3 reg4 using ///
${main}5_output/tables/prio_int_arms_ussr.tex, replace ///
 drop(`controls'  1.thirdparty 1.thirdparty#c.x 1.thirdparty#c.x2 ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil \(\times\) Third Party" 1.thirdparty#c.oil "Oil \(\times\) Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) \(\times\) Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) \(\times\) Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq yearfe continentfe geocontrols thirdpartyfe N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s  s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"\emph{H0: No inv.-U shape}"' `"\qquad \emph{Base Coeff. p-value}"' `"\qquad \emph{Base + Inter. Coeff. p-value}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"' `"Third Party"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")


	
* Table A7: impact of resources on conflict, no Australia

local counter 0
* For loop for regressions: iterates over third party measure, outcome, controls
forval i_indep = 1/2 {
	if (`i_indep' == 1) {
		gen x = oil
		gen x2 = oil2
		local independent "c.x c.x2 c.gas c.gas2 c.coal c.coal2"
	}
	else {
		gen x = sedvol
		gen x2 = sedvol2
		local independent "x x2"
	}
	foreach outcome of varlist $outcome_list {
		forval i_con = 1/2 {
			local counter = `counter' + 1
			if (`i_con' == 1) {
				ivreg2 `outcome' `independent' i.year i.region if ccode != 900, cluster(ccode) partial(i.year i.region)
				* Save geographic controls indicator
				estadd local geocontrols = "No"
			}
			else {
				ivreg2 `outcome' `independent' `controls' i.year i.region if ccode != 900, cluster(ccode) partial(i.year i.region)
				* Save geographic controls indicator
				estadd local geocontrols = "Yes"
			}
			
			* Save time controls indicators
			estadd local yearfe = "Yes"
			estadd local continentfe = "Yes"
			* Save auxiliary indicator for esttab
			estadd local space = " "
			
			if (`i_indep' == 1) {
				
				estadd local gas = "Yes"
				estadd local coal = "Yes"
			
				estadd scalar peak = -_b[c.x]/(2*_b[c.x2])
				
				* Test for inverse-U shaped relation
				utest x x2, quadratic
				
				}
				
				else {
				
				estadd local gas = "Yes"
				estadd local coal = "Yes"
				
				estadd scalar peak = -_b[c.x]/(2*_b[c.x2])
				
				* Test for inverse-U shaped relation
				utest x x2, quadratic
				
				}
				
		
				local putest_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putest =  "`putest_aux'"
					if (`r(p)' < 0.1) {
						local putest =  "`putest_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putest =  "`putest_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putest =  "`putest_aux'" + "\sym{***}"
							}
						}
					}
				}
				estadd local putest = "`putest'"
				
				estadd local space = " "
				
				est sto reg`counter'
		}

}
	drop x x2
}

esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
${main}5_output/tables/prioallred_noaus.tex, replace ///
coeflabels(x "Res. Value" x2 "Res. Value\(^2\)") se ///
starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
 nobaselevels ///
 mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 drop(`controls' gas* coal*) ///
 	stats(space putest space gas coal yearfe continentfe geocontrols peak N, fmt(s s s s s s a2 a2) ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{H0: No inv.-U shape}"' `"\qquad \emph{p-value}"' `" "' `"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' `"Year FEs"' `"Continent FEs"' `"Geo Controls"' `"Peak"' `"\(N\)"')) ///
		mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
			postfoot("\hline\hline \end{tabular}}")	



		
* Table A8: WB resources and sedimentary basins, by contig bases (no australia)

global thirdparty_list "contig50bases"
local counter 0



gen x = sedvol
gen x2 = sedvol2
* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				
				* Test for inverse-U shaped relation with interaction
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#0.thirdparty   c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.year i.region if ccode != 900, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.year i.region `controls' if ccode != 900, ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putestint_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putestint =  "`putestint_aux'"
					if (`r(p)' < 0.1) {
						local putestint =  "`putestint_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putestint =  "`putestint_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putestint =  "`putestint_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putestint ="."
				}
				
				
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 ///
					c.x2#i.thirdparty i.thirdparty ///
					i.year i.region if ccode != 900, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.year i.region `controls' if ccode != 900, ///
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
				local  b1 = _b[c.x] + _b[c.x#1.thirdparty]
				qui lincom c.x + c.x#1.thirdparty
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
				local  b2 = _b[c.x2] + _b[c.x2#1.thirdparty]
				qui lincom c.x2 + c.x2#1.thirdparty
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
				
				* Test for inverse-U shaped relation with no interaction
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putest_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putest =  "`putest_aux'"
					if (`r(p)' < 0.1) {
						local putest =  "`putest_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putest =  "`putest_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putest =  "`putest_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putest = "."
				}
				
				estadd local putest = "`putest'"
				estadd local putestint = "`putestint'"
				
				* Save resource controls indicators
				estadd local gascoal = "No"
				estadd local gascoalsq = "No"
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				est sto reg`counter'
			}

}
}

drop x x2



gen x = oil
gen x2 = oil2
* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				
				* Test for inverse-U shaped relation with interaction
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#0.thirdparty   c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region if ccode != 900, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region `controls' if ccode != 900, ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putestint_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putestint =  "`putestint_aux'"
					if (`r(p)' < 0.1) {
						local putestint =  "`putestint_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putestint =  "`putestint_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putestint =  "`putestint_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putestint ="."
				}
				
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#i.thirdparty   c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region if ccode != 900, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
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
				local  b1 = _b[c.x] + _b[c.x#1.thirdparty]
				qui lincom c.x + c.x#1.thirdparty
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
				local  b2 = _b[c.x2] + _b[c.x2#1.thirdparty]
				qui lincom c.x2 + c.x2#1.thirdparty
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
				
				* Test for inverse-U shaped relation with no interaction
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putest_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putest =  "`putest_aux'"
					if (`r(p)' < 0.1) {
						local putest =  "`putest_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putest =  "`putest_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putest =  "`putest_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putest = "."
				}
				
				estadd local putest = "`putest'"
				estadd local putestint = "`putestint'"
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				est sto reg`counter'
			}

}
}

drop x x2

esttab reg5 reg6 reg7 reg8 reg1 reg2 reg3 reg4 using ///
${main}5_output/tables/prio_int_bases_noaus.tex, replace ///
 drop(`controls'  1.thirdparty 1.thirdparty#c.x 1.thirdparty#c.x2 ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil \(\times\) Third Party" 1.thirdparty#c.oil "Oil \(\times\) Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) \(\times\) Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) \(\times\) Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq yearfe continentfe geocontrols thirdpartyfe N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s  s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"\emph{H0: No inv.-U shape}"' `"\qquad \emph{Base Coeff. p-value}"' `"\qquad \emph{Base + Inter. Coeff. p-value}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"' `"Third Party"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")

	
			
* Table A9: WB resources and sedimentary basins, by armstrade (no australia)

global thirdparty_list "armstrade1950"
local counter 0



gen x = sedvol
gen x2 = sedvol2
* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				
				* Test for inverse-U shaped relation with interaction
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#0.thirdparty   c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.year i.region if ccode != 900, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.year i.region `controls' if ccode != 900, ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putestint_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putestint =  "`putestint_aux'"
					if (`r(p)' < 0.1) {
						local putestint =  "`putestint_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putestint =  "`putestint_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putestint =  "`putestint_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putestint ="."
				}
				
				
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 ///
					c.x2#i.thirdparty i.thirdparty ///
					i.year i.region if ccode != 900, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.year i.region `controls' if ccode != 900, ///
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
				local  b1 = _b[c.x] + _b[c.x#1.thirdparty]
				qui lincom c.x + c.x#1.thirdparty
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
				local  b2 = _b[c.x2] + _b[c.x2#1.thirdparty]
				qui lincom c.x2 + c.x2#1.thirdparty
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
				
				* Test for inverse-U shaped relation with no interaction
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putest_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putest =  "`putest_aux'"
					if (`r(p)' < 0.1) {
						local putest =  "`putest_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putest =  "`putest_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putest =  "`putest_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putest = "."
				}
				
				estadd local putest = "`putest'"
				estadd local putestint = "`putestint'"
				
				* Save resource controls indicators
				estadd local gascoal = "No"
				estadd local gascoalsq = "No"
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				est sto reg`counter'
			}

}
}

drop x x2



gen x = oil
gen x2 = oil2
* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				
				* Test for inverse-U shaped relation with interaction
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#0.thirdparty   c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region if ccode != 900, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region `controls' if ccode != 900, ///
					cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putestint_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putestint =  "`putestint_aux'"
					if (`r(p)' < 0.1) {
						local putestint =  "`putestint_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putestint =  "`putestint_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putestint =  "`putestint_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putestint ="."
				}
				
				if (`i_con' == 1) {
					ivreg2 `outcome' c.x c.x#i.thirdparty   c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.year i.region if ccode != 900, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
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
				local  b1 = _b[c.x] + _b[c.x#1.thirdparty]
				qui lincom c.x + c.x#1.thirdparty
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
				local  b2 = _b[c.x2] + _b[c.x2#1.thirdparty]
				qui lincom c.x2 + c.x2#1.thirdparty
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
				
				* Test for inverse-U shaped relation with no interaction
				utest x x2, quadratic
				
				if `r(p)' != . & _b[c.x2] < 0 {
				local putest_aux : di %6.3f scalar(`r(p)')
				if (`r(p)' <= 1) {
					local putest =  "`putest_aux'"
					if (`r(p)' < 0.1) {
						local putest =  "`putest_aux'" + "\sym{*}"
						if (`r(p)' < 0.05) {
							local putest =  "`putest_aux'" + "\sym{**}"
							if (`r(p)' < 0.01) {
								local putest =  "`putest_aux'" + "\sym{***}"
							}
						}
					}
				}
				}
				else {
					local putest = "."
				}
				
				estadd local putest = "`putest'"
				estadd local putestint = "`putestint'"
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				est sto reg`counter'
			}

}
}

drop x x2

esttab reg5 reg6 reg7 reg8 reg1 reg2 reg3 reg4 using ///
${main}5_output/tables/prio_int_armstrade_noaus.tex, replace ///
 drop(`controls'  1.thirdparty 1.thirdparty#c.x 1.thirdparty#c.x2 ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil \(\times\) Third Party" 1.thirdparty#c.oil "Oil \(\times\) Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) \(\times\) Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) \(\times\) Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq yearfe continentfe geocontrols thirdpartyfe N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s  s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"\emph{H0: No inv.-U shape}"' `"\qquad \emph{Base Coeff. p-value}"' `"\qquad \emph{Base + Inter. Coeff. p-value}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"' `"Third Party"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")


	
	
* Table A10: Conflict and all resources
* Logit

est clear

local counter 0
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
		

	
	
est clear
	
global outcome_list "conflict conflict2"
local controls "lnarea  abslat elevavg elevstd temp precip lnpop14  "
			
* Table A11: Conflict and resources, exposure design with prices	

* For loop for regressions: iterates over third party measure, outcome, controls

foreach outcome of varlist $outcome_list {
	forval i_con = 1/2 {
		local counter = `counter' + 1
		if (`i_con' == 1) {
			ivreg2 `outcome' c.sedvol#c.oil_price c.sedvol2#c.oil_price2 i.year i.ccode, cluster(ccode) partial(i.year i.ccode)
			* Save geographic controls indicator
			estadd local geocontrols = "No"
		}
		else {
			ivreg2 `outcome' c.sedvol#c.oil_price c.sedvol2#c.oil_price2 `controls' i.year i.ccode, cluster(ccode) partial(i.year i.ccode)
			* Save geographic controls indicator
			estadd local geocontrols = "Yes"
		}
		
		* Save time controls indicators
		estadd local yearfe = "Yes"
		estadd local countryfe = "Yes"
		* Save auxiliary indicator for esttab
		estadd local space = " "
		
		est sto reg`counter'
		
		estadd scalar peak = -_b[c.sedvol#c.oil_price]/(2*_b[c.sedvol2#c.oil_price2])
			
	}

}

esttab reg* using ///
${main}5_output/tables/prioallprices.tex, replace ///
coeflabels(c.sedvol#c.oil_price  "Sed. Vol. \(\times\) Oil Price" c.sedvol2#c.oil_price2  "Sed. Vol.\(^2\) \(\times\) Oil Price\(^2\)") se ///
starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
 nobaselevels ///
 drop(`controls') ///
 	stats(yearfe countryfe geocontrols  peak N, fmt(s s s a2 a2) ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"Year FEs"' `"Country FEs"' `"Geo Controls"' `"Peak"' `"\(N\)"')) ///
		mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
			postfoot("\hline\hline \end{tabular}}")	

			
********* Maps

* Figure 1a
use ${main}2_processed/data_regressions.dta, clear
kountry ccode, from(cown) to(iso3c)
rename _ISO3C_ ISO_A3
merge m:m ISO_A3 using  ${main}1_data/maps_utilities/worlddata_cleaned.dta
duplicates drop ISO_A3, force
spmap oil using ${main}1_data/maps_utilities/worldcoor.dta, id(id) fcolor(Greens2)
graph export ${main}5_output/figures/oil.png, replace

* Figure 1b
use ${main}2_processed/data_regressions.dta, clear
kountry ccode, from(cown) to(iso3c)
rename _ISO3C_ ISO_A3
merge m:m ISO_A3 using  ${main}1_data/maps_utilities/worlddata_cleaned.dta
duplicates drop ISO_A3, force
spmap sedvol using ${main}1_data/maps_utilities/worldcoor.dta, id(id) fcolor(Greens2)
graph export ${main}5_output/figures/sedvol.png, replace

* Figure 1c
use ${main}2_processed/data_regressions.dta, clear
kountry ccode, from(cown) to(iso3c)
rename _ISO3C_ ISO_A3
merge m:m ISO_A3 using  ${main}1_data/maps_utilities/worlddata_cleaned.dta
duplicates drop ISO_A3, force
spmap contig50bases using ${main}1_data/maps_utilities/worldcoor.dta, id(id) fcolor(Greens2)
graph export ${main}5_output/figures/bases50.png, replace

* Figure 1d
use ${main}2_processed/data_regressions.dta, clear
kountry ccode, from(cown) to(iso3c)
rename _ISO3C_ ISO_A3
merge m:m ISO_A3 using  ${main}1_data/maps_utilities/worlddata_cleaned.dta
duplicates drop ISO_A3, force
spmap armstrade1950 using ${main}1_data/maps_utilities/worldcoor.dta, id(id) fcolor(Greens2)
graph export ${main}5_output/figures/armstrade1950.png, replace

* Figure 2
use ${main}2_processed/data_regressions.dta, clear
kountry ccode, from(cown) to(iso3c)
rename _ISO3C_ ISO_A3
merge m:m ISO_A3 using  ${main}1_data/maps_utilities/worlddata_cleaned.dta
duplicates drop ISO_A3, force
spmap conf_years using ${main}1_data/maps_utilities/worldcoor.dta, id(id) fcolor(Greens2)
graph export ${main}5_output/figures/conflict_years.png, replace


	
