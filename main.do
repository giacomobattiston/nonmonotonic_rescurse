clear all
set more off

if "`c(username)'" == "giacomobattiston" { 
        cd "/Users/giacomobattiston/"
        global main "Dropbox/ricerca_dropbox/bbf/technology_conflict/"
		global git "PycharmProjects/technology_conflict/"
}
else {
	cd "C:\Users\Franceschin\Documents\GitHub\technology_conflict"
	global main "C:\Users\Franceschin\Dropbox\bbf\technology_conflict\"
}

do ${git}cdsy.ado

******************************* OIL PRICES *************************************
* Import price deflator data and save as dta
clear

import delimited ${main}1_data/fred/GDPDEF.csv,clear

* Clean date variable
gen date_aux=date(date,"YMD")
gen year=year(date_aux)

* Turn into yearly dataset
collapse (mean) gdpdef, by (year)

save ${main}2_processed/deflator.dta, replace


clear

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
clear

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



****************************ARMS' IMPORTS FROM THE US***************************
* Clean data on US bases and arms' trade

clear
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
keep if !missing(ccode) &  !missing(dist_arms)
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
keep if !missing(ccode) &  !missing(dist_arms_ussr)
replace armstrade_ussr1950 = 0 if missing(armstrade_ussr1950)
save ${main}2_processed/dist_arms_USSR.dta, replace


*****************************MILITARY INTERVENTIONS******************************

**creating database of USA interventions
use ${main}1_data/Koga/KOGA_ISQ2011.dta,clear

*keep if mili_intervention == 1
*keep if typeint == 2

* keep only US interventions
keep if ccode2==2
collapse (mean) govmil (mean) mili_intervention, by(year ccode1)
keep ccode1 year govmil mili_intervention 
*typeint ///
*distance ethnictie con_polity lratio premilint ethltie reb_relstr regime
rename ccode1 ccode
 
*replace Vietnam with same number we use in other dataset
replace ccode=816 if ccode==817
sort ccode year
save ${main}2_processed/US_interventions.dta,replace


**creating database of USA interventions
use ${main}1_data/Koga/KOGA_ISQ2011.dta,clear

*keep if mili_intervention == 1
*keep if typeint == 2

* keep only US and Russian interventions
keep if ccode2==2 | ccode2==365
collapse (mean) govmil (mean) mili_intervention, by(year ccode1)
keep ccode1 year govmil mili_intervention 
*typeint ///
*distance ethnictie con_polity lratio premilint ethltie reb_relstr regime
rename ccode1 ccode
 
*replace Vietnam with same number we use in other dataset
replace ccode=816 if ccode==817
sort ccode year
rename govmil govmil_all
rename mili_intervention mili_intervention_all 

save ${main}2_processed/USUSSR_interventions.dta,replace

******************************MILITARY EXPENDITURE******************************

clear
import excel ${main}1_data/sipri_milex/SIPRI-Milex-data-1949-2021.xlsx, sheet("Current US$") cellrange(A6:BW198) firstrow

drop Notes
rename Country country

qui ds

foreach var in `r(varlist)' {
	if ("`var'" != "country") {
		local lab: variable label `var'
		rename `var' milex`lab'
	}
}

reshape long milex, i(country) j(year)
destring milex, replace force

drop if year > 1999

collapse milex, by(country)
drop if milex == .

* Drop non-existing countries
drop if country == "Yugoslavia"
drop if country == "Yemen, North"
drop if country == "Czechoslovakia"
drop if country == "German Democratic Republic"
* Rename some countries in dataset
replace country = "Brunei Darussalam" if country == "Brunei"
replace country = "Belgium and Luxembourg" if country == "Belgium"
replace country = "Côte d'Ivoire" if country == "Cote d'Ivoire"
replace country = "Czech Republic" if country == "Czechia"
replace country = "Kazakstan" if country == "Kazakhstan"
replace country = "Lao People's Democratic Republic" if country == "Laos"
replace country = "Libyan Arab Jamahiriya" if country == "Libya"
replace country = "Serbia and Montenegro" if country == "Serbia"
replace country = "Burma" if country == "Myanmar"
replace country = "Tanzania, United Rep. of " if country == "Tanzania"
replace country = "Moldova, Rep.of" if country == "Moldova"

replace country = "Congo (Democratic Republic of the)" if country == "Congo, DR"
replace country = "Swaziland" if country == "Eswatini"
replace country = "Gambia" if country == "Gambia, The"
replace country = "Korea, Dem. People's Rep. of" if country == "Korea, North"
replace country = "Korea" if country == "Korea, South"
replace country = "Kyrgyzstan" if country == "Kyrgyz Republic"
replace country = "Macedonia (the former Yugoslav Rep. of)" if country == "North Macedonia"
replace country = "Syrian Arab Republic" if country == "Syria"
replace country = "Russian Federation" if country == "Russia"
replace country = "Congo" if country == "Congo, Republic"

*russia not merged entirely because of name change, but it does not matter because it's dropped in the analysis

merge m:1 country using ${main}2_processed/country_names.dta

keep if _merge == 3
drop _merge

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

keep ccode milex

save ${main}2_processed/arms_exp.dta, replace




****************Department of Defence Personnel (Baseline, KM 1000)*************

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

* troops data from https://www.rand.org/pubs/research_reports/RR1906.html
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


local distlist "500 750 1250 1500 1750"
*local distlist "500 800 1200 1400 1600 1800"

foreach dist in `distlist' {

	****CONTIGUITY TROOPS 1950, OTHER DISTANCES FOR ROBUSTNESS

	clear
	* Now start constructing the final data. Import distances
	import excel ${main}1_data/geodist/dist_cepii.xls, sheet("dist_cepii") firstrow


	*max km distance traveled in a day by US troops
	*321.869

	destring distw, replace

	*try with distances
	replace contig = dist < `dist'

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
	rename contig50bases contig50bases`dist'
	save ${main}2_processed/contig50bases`dist'.dta, replace
	

}


******************************OIL EXPORTS***************************************


forvalues i=62(1)100{
use ${main}1_data/WTF/wtf`i'.dta, clear

keep if sitc4=="3330"
g ccode1=.
g ccode2=.

local two_var ="exporter importer"
local num=0
foreach variable of local two_var{
local num=`num'+1
		*******`variable's*********
		replace ccode`num'= 0 if `variable' == "World"
		replace ccode`num'=  2 if `variable'=="USA";
		replace ccode`num'= 20 if `variable'=="Canada";
		replace ccode`num'= 31 if `variable'=="Bahamas";
		replace ccode`num'= 40 if `variable'=="Cuba";
		replace ccode`num'= 41 if `variable'=="Haiti";
		replace ccode`num'= 42 if `variable'=="Dominica";
		replace ccode`num'= 51 if `variable'=="Jamaica";
		replace ccode`num'= 52 if `variable'=="Trinidad Tbg";
		replace ccode`num'= 53 if `variable'=="Barbados";
		replace ccode`num'= 60 if `variable'=="St.Kt-Nev-An";
		replace ccode`num'= 70 if `variable'=="Mexico";
		replace ccode`num'= 80 if `variable'=="Belize";
		replace ccode`num'= 90 if `variable'=="Guatemala";
		replace ccode`num'= 91 if `variable'=="Honduras";
		replace ccode`num'= 92 if `variable'=="El Salvador";
		replace ccode`num'= 93 if `variable'=="Nicaragua";
		replace ccode`num'= 95 if `variable'=="Panama";
		replace ccode`num'=100 if `variable'=="Colombia";
		replace ccode`num'=101 if `variable'=="Venezuela";
		replace ccode`num'=110 if `variable'=="Guyana";
		replace ccode`num'=115 if `variable'=="Suriname";
		replace ccode`num'=130 if `variable'=="Ecuador";
		replace ccode`num'=135 if `variable'=="Peru";
		replace ccode`num'=140 if `variable'=="Brazil";
		replace ccode`num'=145 if `variable'=="Bolivia";

		replace ccode`num'=150 if `variable'=="Paraguay";
		replace ccode`num'=155 if `variable'=="Chile";
		replace ccode`num'=160 if `variable'=="Argentina";
		replace ccode`num'=165 if `variable'=="Uruguay";
		replace ccode`num'=200 if `variable'=="UK";
		replace ccode`num'=205 if `variable'=="Ireland";
		replace ccode`num'=210 if `variable'=="Netherlands";
		replace ccode`num'=211 if `variable'=="Belgium-Lux";
		replace ccode`num'=220 if `variable'=="France";
		replace ccode`num'=220 if `variable'=="France,Monac";
		replace ccode`num'=225 if `variable'=="CHE";
		replace ccode`num'=230 if `variable'=="Spain";
		replace ccode`num'=235 if `variable'=="Portugal";
		replace ccode`num'=255 if `variable'=="Germany";
		replace ccode`num'=255 if `variable'=="Fm German FR";
		replace ccode`num'=290 if `variable'=="Poland";
		replace ccode`num'=305 if `variable'=="Austria";
		replace ccode`num'=310 if `variable'=="Hungary";
		replace ccode`num'=316 if `variable'=="Czechoslav";
		replace ccode`num'=316 if `variable'=="Czech Republic";
		replace ccode`num'=317 if `variable'=="Slovak Republic";
		replace ccode`num'=325 if `variable'=="Italy";
		replace ccode`num'=338 if `variable'=="Malta";
		replace ccode`num'=339 if `variable'=="Albania";
		replace ccode`num'=343 if `variable'=="Macedonia";
		replace ccode`num'=344 if `variable'=="Croatia";
		replace ccode`num'=345 if `variable'=="Fm Yugoslav";
		replace ccode`num'=346 if `variable'=="Bosnia";
		replace ccode`num'=349 if `variable'=="Slovenia";
		replace ccode`num'=350 if `variable'=="Greece";
		replace ccode`num'=352 if `variable'=="Cyprus";
		replace ccode`num'=355 if `variable'=="Bulgaria";
		replace ccode`num'=359 if `variable'=="Moldavia";
		replace ccode`num'=360 if `variable'=="Romania";
		replace ccode`num'=365 if `variable'=="Russia";
		replace ccode`num'=365 if `variable'=="Fm USSR";
		replace ccode`num'=366 if `variable'=="Estonia";
		replace ccode`num'=367 if `variable'=="Latvia";
		replace ccode`num'=368 if `variable'=="Lituania";
		replace ccode`num'=369 if `variable'=="Ukraine";
		replace ccode`num'=370 if `variable'=="Belarus";
		replace ccode`num'=371 if `variable'=="Armenia";
		replace ccode`num'=372 if `variable'=="Georgia";
		replace ccode`num'=373 if `variable'=="Azerbajan";
		replace ccode`num'=375 if `variable'=="Finland";
		replace ccode`num'=380 if `variable'=="Sweden";
		replace ccode`num'=385 if `variable'=="Norway";
		replace ccode`num'=390 if `variable'=="Denmark";
		replace ccode`num'=395 if `variable'=="Iceland";
		replace ccode`num' = 396 if `variable' == "Abkhazia"
		replace ccode`num' = 700 if `variable' == "Afghanistan"
		replace ccode`num' = 700 if `variable' == "Afganistan"
		replace ccode`num' = 700 if `variable' == "Afghanistan, Islamic Republic of"
	    replace ccode`num' = 700 if `variable' == "Afghanistan, Islamic Rep. of (Afghanistan)"
		replace ccode`num' = 700 if `variable' == "Afghanistan(1992-)"
		replace ccode`num' = 339 if `variable' == "Albania"
		replace ccode`num' = 615 if `variable' == "Algeria"
		replace ccode`num' = 232 if `variable' == "Andorra"
		replace ccode`num' = 540 if `variable' == "Angola"
		replace ccode`num' = .   if `variable' == "Anguilla"
		replace ccode`num' = 58  if `variable' == "Antigua and Barbuda"
		replace ccode`num' = 58  if `variable' == "Antigua"
		replace ccode`num' = 58  if `variable' == "Antigua & Barbuda"
		replace ccode`num' = 58  if `variable' == "Antigua & B"
		replace ccode`num' = 160 if `variable' == "Argentina"
		replace ccode`num' = 160 if `variable' == "Argentin"
		replace ccode`num' = 371 if `variable' == "Armenia"
		replace ccode`num' = 371 if `variable' == "Armenia, Republic of"
		replace ccode`num' = .   if `variable' == "Aruba"
		replace ccode`num' = 900 if `variable' == "Australia"
		replace ccode`num' = 900 if `variable' == "Australia*"
		replace ccode`num' = 305 if `variable' == "Austria"
		replace ccode`num' = 305 if `variable' == "Austria*"
		replace ccode`num' = 300 if `variable' == "Austria-Hungary"
		replace ccode`num' = 373 if `variable' == "Azerbaijan"
		replace ccode`num' = 373 if `variable' == "Azerbaijan, Republic of"

		/***************************
		ccode numbers for B-countries 
		****************************/

		replace ccode`num' = 267 if `variable' == "Baden"
		replace ccode`num' = 31  if `variable' == "Bahamas"
		replace ccode`num' = 31  if `variable' == "Bahamas, The"
		replace ccode`num' = 692 if `variable' == "Bahrain"
		replace ccode`num' = 692 if `variable' == "Bahrain, Kingdom of"
		replace ccode`num' = 692 if `variable' == "Bahrein"
		replace ccode`num' = 771 if `variable' == "Bangladesh"
		replace ccode`num' = 53  if `variable' == "Barbados"
		replace ccode`num' = 245 if `variable' == "Bavaria"
		replace ccode`num' = 370 if `variable' == "Belarus"
		replace ccode`num' = 370 if `variable' == "Byelorussia"
		replace ccode`num' = 211 if `variable' == "Belgium"
		replace ccode`num' = 211 if `variable' == "Belgo-Luxembourg Economic Union"
		replace ccode`num' = 80  if `variable' == "Belize"
		replace ccode`num' = 434 if `variable' == "Benin"
		replace ccode`num' = 434 if `variable' == "Benin (Dahomey)"
		replace ccode`num' = 760 if `variable' == "Bhutan"
		replace ccode`num' = 145 if `variable' == "Bolivia"
		replace ccode`num' = 346 if `variable' == "Bosnia"
		replace ccode`num' = 346 if `variable' == "Bosnia Herzg"
		replace ccode`num' = 346 if `variable' == "Bosnia-Hercegovina"
		replace ccode`num' = 346 if `variable' == "Bosnia-Hercegovenia"
		replace ccode`num' = 346 if `variable' == "Bosnia-Herz"
		replace ccode`num' = 346 if `variable' == "Bosnia-Herzegovina"
		replace ccode`num' = 346 if `variable' == "Bosnia-Herz."
		replace ccode`num' = 346 if `variable' == "Bosnia and Herzegovina"
		replace ccode`num' = 346 if `variable' == "Bosnia & Herzegovina"
		replace ccode`num' = 346 if `variable' == "Bosnia Herzegovenia"
		replace ccode`num' = 571 if `variable' == "Botswana"
		replace ccode`num' = 140 if `variable' == "Brazil"
		replace ccode`num' = 835 if `variable' == "Brunei"
		replace ccode`num' = 835 if `variable' == "Brunei Darussalam"
		replace ccode`num' = 355 if `variable' == "Bulgaria"
		replace ccode`num' = 439 if `variable' == "Burkina Faso"
		replace ccode`num' = 439 if `variable' == "Burkina Faso (Upper Volta)"
		replace ccode`num' = 516 if `variable' == "Burundi"

		/***************************
		ccode numbers for C-countries 
		****************************/

		replace ccode`num' = 811 if `variable' == "Cambodia"
		replace ccode`num' = 811 if `variable' == "Kampuchea"
		replace ccode`num' = 811 if `variable' == "Kampuchea, Democratic"
		replace ccode`num' = 811 if `variable' == "Cambodia (Kampuchea)"
		replace ccode`num' = 471 if `variable' == "Cameroon"
		replace ccode`num' = 471 if `variable' == "Cameroun"
		replace ccode`num' = 20  if `variable' == "Canada"
		replace ccode`num' = 402 if `variable' == "Cape Verde Is"
		replace ccode`num' = 402 if `variable' == "Cape Verde Is."
		replace ccode`num' = 402 if `variable' == "Cape Verde"
		replace ccode`num' = 402 if `variable' == "C. Verde Is."
		replace ccode`num' = 482 if `variable' == "Central African Republic"
		replace ccode`num' = 482 if `variable' == "Central African Rep"
		replace ccode`num' = 482 if `variable' == "Central African Rep."
		replace ccode`num' = 482 if `variable' == "Cent. Af. Rep."
		replace ccode`num' = 482 if `variable' == "Cen African Rep"
		replace ccode`num' = 482 if `variable' == "C.A.R."
		replace ccode`num' = 483 if `variable' == "Chad"
		replace ccode`num' = 155 if `variable' == "Chile"
		replace ccode`num' = 710 if `variable' == "China"
		replace ccode`num' = 710 if `variable' == "China P Rep"
		replace ccode`num' = 710 if `variable' == "China, PR"
		replace ccode`num' = 710 if `variable' == "China, P.R.: Mainland"
		replace ccode`num' = 710 if `variable' == "PRC"
		replace ccode`num' = 100 if `variable' == "Colombia"
		replace ccode`num' = 100 if `variable' == "Columbia"
		replace ccode`num' = 581 if `variable' == "Comoros"
		replace ccode`num' = 581 if `variable' == "Comoro Is."
		replace ccode`num' = 581 if `variable' == "Comoro Is"
		replace ccode`num' = 484 if `variable' == "Congo"
		replace ccode`num' = 484 if `variable' == "Congo, Rep."
		replace ccode`num' = 484 if `variable' == "Congo, Rep. of"
		replace ccode`num' = 484 if `variable' == "Congo, Republic of"
		replace ccode`num' = 484 if `variable' == "Congo Republic"
		replace ccode`num' = 484 if `variable' == "Congo (Republic)"
		replace ccode`num' = 484 if `variable' == "Rep. Congo"
		replace ccode`num' = 484 if `variable' == "Congo, Rep. of the"
		replace ccode`num' = 484 if `variable' == "CongoRep"
		replace ccode`num' = 484 if `variable' == "Congo (Brazzaville)"
		replace ccode`num' = 484 if `variable' == "Congo, Brazzaville"
		replace ccode`num' = 484 if `variable' == "Congo Brazzaville"
		replace ccode`num' = 484 if `variable' == "Congo (Brazzaville,Rep. of Congo)"
		replace ccode`num' = 484 if `variable' == "Congo (Brazzaville, Republic of Congo)"
		replace ccode`num' = 484 if `variable' == "Congo, Republic of (Brazzaville)"
		replace ccode`num' = 490 if `variable' == "Congo (Kinshasa)"
		replace ccode`num' = 490 if `variable' == "Congo Kinshasa"
		replace ccode`num' = 490 if `variable' == "Congo, Kinshasa"
		replace ccode`num' = 490 if `variable' == "Dem.Rp.Congo"
		replace ccode`num' = 490 if `variable' == "Congo, Democratic Republic of"
		replace ccode`num' = 490 if `variable' == "Congo, Democratic Republic"
		replace ccode`num' = 490 if `variable' == "Congo, the Democratic Republic of the"
		replace ccode`num' = 490 if `variable' == "Congo, Dem. Rep."
		replace ccode`num' = 490 if `variable' == "Congo (Democratic Republic)"
		replace ccode`num' = 490 if `variable' == "Congo/Zaire"
		replace ccode`num' = 490 if `variable' == "Congo, Democratic Republic of (Zaire)" 
		replace ccode`num' = 490 if `variable' == "Congo, Democratic Republic of the Za?re)" 
		replace ccode`num' = 490 if `variable' == "CongoDemRep"
		replace ccode`num' = 490 if `variable' == "Democratic Republic of the Congo"
		replace ccode`num' = 490 if `variable' == "Zaire"
		replace ccode`num' = 490 if `variable' == "Zaire/Congo Dem Rep"
		replace ccode`num' = 490 if `variable' == "Zaire (Democ Republic Congo)"
		replace ccode`num' = 490 if `variable' == "Zaire (Congo after 1997)"
		replace ccode`num' = 94  if `variable' == "Costa Rica"
		replace ccode`num' = 437 if `variable' == "Cote Divoire"
		replace ccode`num' = 437 if `variable' == "Cote d'Ivoire"
		replace ccode`num' = 437 if `variable' == "Côte d'Ivoire"
		replace ccode`num' = 437 if `variable' == "Cote d`Ivoire"
		replace ccode`num' = 437 if `variable' == "Cote D'Ivoire"
		replace ccode`num' = 437 if `variable' == "C?e d'Ivoire"
		replace ccode`num' = 437 if `variable' == "C?te d'Ivoire (Ivory Coast)"
		replace ccode`num' = 437 if `variable' == "C??te d'Ivoire"
		replace ccode`num' = 437 if `variable' == "Cote dIvoire"
		replace ccode`num' = 437 if `variable' == "Ivory Coast"
		replace ccode`num' = 344 if `variable' == "Croatia"
		replace ccode`num' = 40  if `variable' == "Cuba"
		replace ccode`num' = 352 if `variable' == "Cyprus"
		replace ccode`num' = 352 if `variable' == "Cyprus (Greek)"
		replace ccode`num' = 352 if `variable' == "Cyprus (G)"
		replace ccode`num' = .   if `variable' == "Cyprus (Turkey)"
		replace ccode`num' = .   if `variable' == "Turk Cyprus"
		replace ccode`num' = 315 if `variable' == "Czechoslovak"
		replace ccode`num' = 315 if `variable' == "Czechoslovakia"
		replace ccode`num' = 315 if `variable' == "Czechoslavakia"
		replace ccode`num' = 315 if `variable' == "Former Czechoslovakia"
		replace ccode`num' = 316 if `variable' == "Czech Rep"
		replace ccode`num' = 316 if `variable' == "Czech Rep."
		replace ccode`num' = 316 if `variable' == "Czech Republic"
		replace ccode`num' = 316 if `variable' == "CzechRepublic"
		replace ccode`num' = 316 if `variable' == "Czech Rep (C-Slv.)"

		/***************************
		ccode numbers for D-countries 
		****************************/

		replace ccode`num' = 390 if `variable' == "Denmark"
		replace ccode`num' = 390 if `variable' == "Denmark*"
		replace ccode`num' = 522 if `variable' == "Djibouti"
		replace ccode`num' = 54  if `variable' == "Dominica"
		replace ccode`num' = 42  if `variable' == "Dom. Rep."
		replace ccode`num' = 42  if `variable' == "Dom Rep"
		replace ccode`num' = 42  if `variable' == "Dominican Rep"
		replace ccode`num' = 42  if `variable' == "Dominican Republic"
		replace ccode`num' = 42  if `variable' == "Dominican Rep."
		replace ccode`num' = 42  if `variable' == "Dominican Rp"

		/***************************
		ccode numbers for E-countries 
		****************************/

		replace ccode`num' = 860 if `variable' == "East Timor"
		replace ccode`num' = 860 if `variable' == "East Timor (Timor-Leste)"
		replace ccode`num' = 860 if `variable' == "Timor-Leste"
		replace ccode`num' = 860 if `variable' == "Timor-Leste, Dem. Rep. of"
		replace ccode`num' = 860 if `variable' == "TimorLeste"
		replace ccode`num' = 860 if `variable' == "Timor-Leste (East Timor)"
		replace ccode`num' = 130 if `variable' == "Ecuador"
		replace ccode`num' = 651 if `variable' == "Egypt"
		replace ccode`num' = 651 if `variable' == "Egypt, Arab Rep."
		replace ccode`num' = 651 if `variable' == "EgyptArabRep"
		replace ccode`num' = 92  if `variable' == "El Salvador"
		replace ccode`num' = 92  if `variable' == "ElSalvador"
		replace ccode`num' = 92  if `variable' == "Salvador"
		replace ccode`num' = 411 if `variable' == "Equatorial Guinea"
		replace ccode`num' = 411 if `variable' == "Eq.Guinea"
		replace ccode`num' = 411 if `variable' == "Eq. Guinea"
		replace ccode`num' = 531 if `variable' == "Eritrea"
		replace ccode`num' = 366 if `variable' == "Estonia"
		replace ccode`num' = 530 if `variable' == "Ethiopia (former)"
		replace ccode`num' = 530 if `variable' == "Ethiopia"

		/***************************
		ccode numbers for F-countries 
		****************************/

		replace ccode`num' = 987 if `variable' == "Federated States of Micronesia"
		replace ccode`num' = 950 if `variable' == "Fiji"
		replace ccode`num' = 375 if `variable' == "Finland"
		replace ccode`num' = 220 if `variable' == "France"

		/***************************
		ccode numbers for G-countries 
		****************************/

		replace ccode`num' = 481 if `variable' == "Gabon"
		replace ccode`num' = 420 if `variable' == "Gambia"
		replace ccode`num' = 420 if `variable' == "Gambia The"
		replace ccode`num' = 420 if `variable' == "Gambia, The"
		replace ccode`num' = 372 if `variable' == "Georgia"
		replace ccode`num' = 260 if `variable' == "Germany" 
		replace ccode`num' = 260 if `variable' == "Germany Fed Rep"
		replace ccode`num' = 260 if `variable' == "German Federal Republic"
		replace ccode`num' = 260 if `variable' == "FRG/Germany"
		replace ccode`num' = 260 if `variable' == "Germany, W."
		replace ccode`num' = 260 if `variable' == "Germany West"
		replace ccode`num' = 260 if `variable' == "Germany, FR"
		replace ccode`num' = 260 if `variable' == "FR Germany"
		replace ccode`num' = 265 if `variable' == "Germany Dem Rep"
		replace ccode`num' = 265 if `variable' == "Germany DR"
		replace ccode`num' = 265 if `variable' == "Fm German DR"
		replace ccode`num' = 265 if `variable' == "GDR"
		replace ccode`num' = 265 if `variable' == "Germany, E."
		replace ccode`num' = 265 if `variable' == "East Germany"
		replace ccode`num' = 265 if `variable' == "Germany East"
		replace ccode`num' = 265 if `variable' == "German Democratic Republic"
		replace ccode`num' = 260 if ccode`num' == 255 & year < 1946 /*pre-WWII, Germany/Prussia has a different number*/
		replace ccode`num' = 452 if `variable' == "Ghana"
		replace ccode`num' = 99  if `variable' == "Great Colombia"
		replace ccode`num' = 99  if `variable' == "Gran Colombia"
		replace ccode`num' = 350 if `variable' == "Greece"
		replace ccode`num' = 55  if `variable' == "Grenada"
		replace ccode`num' = 90  if `variable' == "Guatemala"
		replace ccode`num' = 438 if `variable' == "Guinea"
		replace ccode`num' = 438 if `variable' == "Guineau"
		replace ccode`num' = 404 if `variable' == "GuineaBissau"
		replace ccode`num' = 404 if `variable' == "Guinea Bissau"
		replace ccode`num' = 404 if `variable' == "Guinea-Bissau"
		replace ccode`num' = 404 if `variable' == "Guinea-Bisau"
		replace ccode`num' = 110 if `variable' == "Guyana"

		/***************************
		ccode numbers for H-countries 
		****************************/

		replace ccode`num' = 41   if `variable' == "Haiti"
		replace ccode`num' = 240  if `variable' == "Hanover"
		replace ccode`num' = 273  if `variable' == "Hesse Electoral"
		replace ccode`num' = 273  if `variable' == "Hesse-Kassel"
		replace ccode`num' = 275  if `variable' == "Hesse Grand Ducal"
		replace ccode`num' = 275  if `variable' == "Hesse-Darmstadt"
		replace ccode`num' = 91   if `variable' == "Honduras"
		replace ccode`num' = 708 if `variable' == "Hong Kong"
		replace ccode`num' = 708 if `variable' == "Hong-Kong"
		replace ccode`num' = 708 if `variable' == "Hong Kong (SAR China)"
		replace ccode`num' = 708 if `variable' == "HongKong"
		replace ccode`num' = 708 if `variable' == "Hong Kong (China)"
		replace ccode`num' = 708 if `variable' == "Hong Kong, China"
		replace ccode`num' = 708 if `variable' == "China, P.R.: Hong Kong"
		replace ccode`num' = 708 if `variable' == "China,P.R.:Hong Kong"
		replace ccode`num' = 708 if `variable' == "Hong Kong, China"
		replace ccode`num' = 708 if `variable' == "HongKongSARChina"
		replace ccode`num' = 708 if `variable' == "Hong Kong SAR, China"
		replace ccode`num' = 708 if `variable' == "China, Hong Kong Special Administrative Region"
		replace ccode`num' = 310  if `variable' == "Hungary"

		/***************************
		ccode numbers for I-countries 
		****************************/

		replace ccode`num' = 395 if `variable' == "Iceland"
		replace ccode`num' = 750 if `variable' == "India"
		replace ccode`num' = 850 if `variable' == "Indonesia"
		replace ccode`num' = 850 if `variable' == "Indonesia including East Timor"
		replace ccode`num' = 630 if `variable' == "Iran"
		replace ccode`num' = 630 if `variable' == "Iran (Persia)"
		replace ccode`num' = 630 if `variable' == "Iran Islam Rep"
		replace ccode`num' = 630 if `variable' == "Iran, Islamic Rep."
		replace ccode`num' = 630 if `variable' == "Iran, Islamic Republic of"
		replace ccode`num' = 630 if `variable' == "Iran, Islamic Republic of (Iran)"
		replace ccode`num' = 630 if `variable' == "Iran, I.R. of"
		replace ccode`num' = 630 if `variable' == "Islamic Rep. of Iran"
		replace ccode`num' = 630 if `variable' == "IranIslamicRep"
		replace ccode`num' = 630 if `variable' == "Iran (Islamic Republic of)"
		replace ccode`num' = 645 if `variable' == "Iraq"
		replace ccode`num' = 205 if `variable' == "Ireland"
		replace ccode`num' = 666 if `variable' == "Israel"
		replace ccode`num' = 325 if `variable' == "Italy"
		replace ccode`num' = 325 if `variable' == "Italy*"
		replace ccode`num' = 325 if `variable' == "Italy/Sardinia"

		/***************************
		ccode numbers for J-countries 
		****************************/

		replace ccode`num' = 51  if `variable' == "Jamaica"
		replace ccode`num' = 740 if `variable' == "Japan"
		replace ccode`num' = 663 if `variable' == "Jordan"

		/***************************
		ccode numbers for K-countries 
		****************************/

		replace ccode`num' = 705 if `variable' == "Kazakhstan"
		replace ccode`num' = 705 if `variable' == "Khazakhstan"
		replace ccode`num' = 501 if `variable' == "Kenya"
		replace ccode`num' = 970 if `variable' == "Kiribati"
		replace ccode`num' = 730 if `variable' == "Korea"
		replace ccode`num' = 731 if `variable' == "Korea, North"
		replace ccode`num' = 731 if `variable' == "Korea, N"
		replace ccode`num' = 731 if `variable' == "Korea (North)"
		replace ccode`num' = 731 if `variable' == "Korea North"
		replace ccode`num' = 731 if `variable' == "Korea D P Rp"
		replace ccode`num' = 731 if `variable' == "Korea Dem P Rep"
		replace ccode`num' = 731 if `variable' == "Korea, Dem. Rep."
		replace ccode`num' = 731 if `variable' == "Korea, Dem. People's Rep. of"
		replace ccode`num' = 731 if `variable' == "Dem. People's Rep. Korea"
		replace ccode`num' = 731 if `variable' == "Korea, Democratic People's Republic of"
		replace ccode`num' = 731 if `variable' == "Korea, DPR"
		replace ccode`num' = 731 if `variable' == "North Korea"
		replace ccode`num' = 731 if `variable' == "Democratic People's Republic of Korea"
		replace ccode`num' = 731 if `variable' == "PRK"
		replace ccode`num' = 732 if `variable' == "Korea (South)"
		replace ccode`num' = 730 if `variable' == "Korea"
		replace ccode`num' = 730 if `variable' == "Korea Rep."
		replace ccode`num' = 732 if `variable' == "Korea, South"
		replace ccode`num' = 732 if `variable' == "Korea, S"
		replace ccode`num' = 732 if `variable' == "Korea South"
		replace ccode`num' = 732 if `variable' == "Korea Rep"
		replace ccode`num' = 732 if `variable' == "Korea, Republic of"
		replace ccode`num' = 732 if `variable' == "Korea, Rep."
		replace ccode`num' = 732 if `variable' == "South Korea"
		replace ccode`num' = 732 if `variable' == "ROK"
		replace ccode`num' = 732 if `variable' == "Republic of Korea"
		replace ccode`num' = 732 if `variable' == "Korea, Republic Of"
		replace ccode`num' = 347 if `variable' == "Kosovo"
		replace ccode`num' = 690 if `variable' == "Kuwait"
		replace ccode`num' = 703 if `variable' == "Kyrgyzstan"
		replace ccode`num' = 703 if `variable' == "Kyrgyz Republic"
		replace ccode`num' = 703 if `variable' == "Kyrgyz Republic (Kyrgyzstan)"

		/***************************
		ccode numbers for L-countries 
		****************************/

		replace ccode`num' = 812 if `variable' == "Laos"
		replace ccode`num' = 812 if `variable' == "Lao PDR"
		replace ccode`num' = 812 if `variable' == "Lao P Dem Rep"
		replace ccode`num' = 812 if `variable' == "Lao P.Dem.Rep"
		replace ccode`num' = 812 if `variable' == "Lao P.Dem.R"
		replace ccode`num' = 812 if `variable' == "Lao People's Democratic Republic"
		replace ccode`num' = 812 if `variable' == "Lao People's Democratic Republic (Laos)"
		replace ccode`num' = 367 if `variable' == "Latvia"
		replace ccode`num' = 660 if `variable' == "Lebanon"
		replace ccode`num' = 570 if `variable' == "Lesotho"
		replace ccode`num' = 450 if `variable' == "Liberia"
		replace ccode`num' = 620 if `variable' == "Libya"
		replace ccode`num' = 620 if `variable' == "Libyan Arab Jamah"
		replace ccode`num' = 620 if `variable' == "Libya Arab Jamahiriy"
		replace ccode`num' = 620 if `variable' == "Libyan Arab Jamahiriya"
		replace ccode`num' = 223 if `variable' == "Liechtenstein"
		replace ccode`num' = 368 if `variable' == "Lithuania"
		replace ccode`num' = 212 if `variable' == "Luxembourg"

		/***************************
		ccode numbers for M-countries 
		****************************/

		replace ccode`num' = 709 if `variable' == "Macao SAR, China"
		replace ccode`num' = 709 if `variable' == "Macao"
		replace ccode`num' = 709 if `variable' == "Macao (SAR China)"
		replace ccode`num' = 709 if `variable' == "China, P.R.: Macao"
		replace ccode`num' = 709 if `variable' == "China, Macao Special Administrative Region"
		replace ccode`num' = 343 if `variable' == "Macedonia"
		replace ccode`num' = 343 if `variable' == "TFYR of Macedonia"
		replace ccode`num' = 343 if `variable' == "TFYR Macedna"
		replace ccode`num' = 343 if `variable' == "Macedonia FRY"
		replace ccode`num' = 343 if `variable' == "Macedonia, FYR"
		replace ccode`num' = 343 if `variable' == "FYR Macedonia"
		replace ccode`num' = 343 if `variable' == "Macedonia, the Former Yugoslav Republic of"
		replace ccode`num' = 343 if `variable' == "Macedonia, former Yugoslav Republic of"
		replace ccode`num' = 580 if `variable' == "Madagascar"
		replace ccode`num' = 580 if `variable' == "Madagascar (Malagasy Republic)"
		replace ccode`num' = 580 if `variable' == "Madagascar (Malagasy)"
		replace ccode`num' = 553 if `variable' == "Malawi"
		replace ccode`num' = 820 if `variable' == "Malaysia"
		replace ccode`num' = 820 if `variable' == "Malaysia (Malaya)"
		replace ccode`num' = 781 if `variable' == "Maldives"
		replace ccode`num' = 432 if `variable' == "Mali"
		replace ccode`num' = 432 if `variable' == "Marli"
		replace ccode`num' = 338 if `variable' == "Malta"
		replace ccode`num' = 983 if `variable' == "Marshall Is"
		replace ccode`num' = 983 if `variable' == "Marshall Islands"
		replace ccode`num' = 983 if `variable' == "Marshall Islan"
		replace ccode`num' = 983 if `variable' == "Marshall Islands, Republic of"
		replace ccode`num' = 435 if `variable' == "Mauritania"
		replace ccode`num' = 590 if `variable' == "Mauritius"
		replace ccode`num' = 280 if `variable' == "Mecklenburg Schwerin"
		replace ccode`num' = 70  if `variable' == "Mexico"
		replace ccode`num' = 987 if `variable' == "Micronesia"
		replace ccode`num' = 987 if `variable' == "Micronesia Fed States"
		replace ccode`num' = 987 if `variable' == "Micronesia, Fed. States"
		replace ccode`num' = 987 if `variable' == "Micronesia, Fed. Sts."
		replace ccode`num' = 987 if `variable' == "Micronesia, Fed Stat"
		replace ccode`num' = 987 if `variable' == "Micronesia, Federated States of"
		replace ccode`num' = 987 if `variable' == "Federated States of Micronesia"
		replace ccode`num' = 332 if `variable' == "Modena"
		replace ccode`num' = 359 if `variable' == "Moldova"
		replace ccode`num' = 359 if `variable' == "Republic of Moldova"
		replace ccode`num' = 359 if `variable' == "Moldova Rep"
		replace ccode`num' = 359 if `variable' == "Moldova, Republic Of"
		replace ccode`num' = 359 if `variable' == "Republic Of Moldova"
		replace ccode`num' = 221 if `variable' == "Monaco"
		replace ccode`num' = 712 if `variable' == "Mongolia"
		replace ccode`num' = 341 if `variable' == "Montenegro"
		replace ccode`num' = .   if `variable' == "Montserrat"
		replace ccode`num' = 600 if `variable' == "Morocco"
		replace ccode`num' = 541 if `variable' == "Mozambique"
		replace ccode`num' = 775 if `variable' == "Myanmar"
		replace ccode`num' = 775 if `variable' == "Myanmar (Burma)"
		replace ccode`num' = 775 if `variable' == "Myanmar(Burma)"
		replace ccode`num' = 775 if `variable' == "Burma (Myanmar)"
		replace ccode`num' = 775 if `variable' == "Burma"

		/***************************
		ccode numbers for N-countries 
		****************************/

		replace ccode`num' = 565 if `variable' == "Namibia"
		replace ccode`num' = 971 if `variable' == "Nauru"
		replace ccode`num' = 790 if `variable' == "Nepal"
		replace ccode`num' = 210 if `variable' == "Netherlands"
		replace ccode`num' = . if `variable' == "Netherlands Antilles"
		replace ccode`num' = 920 if `variable' == "New Zealand"	
		replace ccode`num' = 93  if `variable' == "Nicaragua"
		replace ccode`num' = 436 if `variable' == "Niger"
		replace ccode`num' = 475 if `variable' == "Nigeria"
		replace ccode`num' = 385 if `variable' == "Norway"

		/***************************
		ccode numbers for O and P counttries 
		****************************/

		replace ccode`num' = 698 if `variable' == "Oman"
		replace ccode`num' = 564 if `variable' == "Orange Free State"

		replace ccode`num' = 770 if `variable' == "Pakistan"
		replace ccode`num' = 770 if `variable' == "Pakistan, (1972-)"
		replace ccode`num' = 986 if `variable' == "Palau"
		replace ccode`num' = 95  if `variable' == "Panama"
		replace ccode`num' = 95  if `variable' == "Panama Canal Zone"
		replace ccode`num' = 327 if `variable' == "Papal States"
		replace ccode`num' = 910 if `variable' == "Papua New Guinea"
		replace ccode`num' = 910 if `variable' == "Papua New Guinea"
		replace ccode`num' = 910 if `variable' == "Papua N.Guin"
		replace ccode`num' = 910 if `variable' == "P. N. Guinea"
		replace ccode`num' = 150 if `variable' == "Paraguay"
		replace ccode`num' = 335 if `variable' == "Parma"
		replace ccode`num' = 135 if `variable' == "Peru"
		replace ccode`num' = 840 if `variable' == "Philipines"
		replace ccode`num' = 840 if `variable' == "Philippines" 
		replace ccode`num' = 840 if `variable' == "Phillippines"
		replace ccode`num' = 840 if `variable' == "Philippi"
		replace ccode`num' = 290 if `variable' == "Poland"
		replace ccode`num' = 235 if `variable' == "Portugal"
		replace ccode`num' = 255 if `variable' == "Prussia"

		/***************************
		ccode numbers for Q and R-countries 
		****************************/

		replace ccode`num' = 694 if `variable' == "Qatar"

		replace ccode`num' = 360 if `variable' == "Romania"
		replace ccode`num' = 360 if `variable' == "Rumania"
		replace ccode`num' = 365 if `variable' == "Russia"
		replace ccode`num' = 365 if `variable' == "Russian Fed"
		replace ccode`num' = 365 if `variable' == "Russian Federation"
		replace ccode`num' = 365 if `variable' == "USSR"
		replace ccode`num' = 365 if `variable' == "U.S.S.R."
		replace ccode`num' = 365 if `variable' == "Soviet Union"
		replace ccode`num' = 365 if `variable' == "Russia (Soviet Union)"
		replace ccode`num' = 365 if `variable' == "Russia (USSR)"
		replace ccode`num' = 517 if `variable' == "Rwanda"

		/***************************
		ccode numbers for S-countries 
		****************************/

		replace ccode`num' = 403 if `variable' == "Sao Tome et Principe"
		replace ccode`num' = 403 if `variable' == "Sao Tome and principe"
		replace ccode`num' = 403 if `variable' == "Sao Tome"
		replace ccode`num' = 403 if `variable' == "S? Tom�and Principe"
		replace ccode`num' = 403 if `variable' == "Sao Tome & Principe"
		replace ccode`num' = 403 if `variable' == "Sao Tome & P"
		replace ccode`num' = 403 if `variable' == "Sao Tome and Principe"
		replace ccode`num' = 403 if `variable' == "S?o Tom? and Principe"
		replace ccode`num' = 403 if `variable' == "Sao Tom?E and Principe"
		replace ccode`num' = 403 if `variable' == "S?o Tom? and Pr?ncipe"
		replace ccode`num' = 60  if `variable' == "Saint Kitts and Nevis"
		replace ccode`num' = 60  if `variable' == "St. Kitts and Nevis"
		replace ccode`num' = 60  if `variable' == "St Kitts and Nevis"
		replace ccode`num' = 60  if `variable' == "St. Kitts & Nevis"
		replace ccode`num' = 60  if `variable' == "St. Kitts & N"
		replace ccode`num' = 56  if `variable' == "Saint Lucia"
		replace ccode`num' = 56  if `variable' == "St. Lucia"
		replace ccode`num' = 56  if `variable' == "St Lucia"
		replace ccode`num' = 56  if `variable' == "StLucia"
		replace ccode`num' = 57  if `variable' == "Saint Vincent and the Grenadines"
		replace ccode`num' = 57  if `variable' == "St.Vincent & Grenadines"
		replace ccode`num' = 57  if `variable' == "St. Vin. & G"
		replace ccode`num' = 57  if `variable' == "St. Vincent and the Grenadines"
		replace ccode`num' = 57  if `variable' == "St. Vincent & Grenadine"
		replace ccode`num' = 57  if `variable' == "St. Vincent & Grenadines"
		replace ccode`num' = 57  if `variable' == "St Vincent and The Grenadines"
		replace ccode`num' = 57  if `variable' == "St Vincent and the Grenadines"
		replace ccode`num' = 57  if `variable' == "StVincentandtheGrenadines"
		replace ccode`num' = 57  if `variable' == "StVincentand"
		replace ccode`num' = 57  if `variable' == "St Vincent"
		replace ccode`num' = 990 if `variable' == "Samoa"
		replace ccode`num' = 990 if `variable' == "W. Samoa"
		replace ccode`num' = 990 if `variable' == "W Samoa"
		replace ccode`num' = 990 if `variable' == "Western Samoa"
		replace ccode`num' = 990 if `variable' == "Samoa (Western Samoa)"
		replace ccode`num' = 331 if `variable' == "San Marino"
		replace ccode`num' = 670 if `variable' == "Saudi Arabia"
		replace ccode`num' = 269 if `variable' == "Saxony"
		replace ccode`num' = 433 if `variable' == "Senegal"
		replace ccode`num' = 340 if `variable' == "Serbia" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
		replace ccode`num' = 340 if `variable' == "Serbia, Republic of" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
		replace ccode`num' = 340 if `variable' == "Serbia Montenegro" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
		replace ccode`num' = 340 if `variable' == "Serbia & Montenegro" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
		replace ccode`num' = 340 if `variable' == "SerbiaandMontenegro" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
		replace ccode`num' = 340 if `variable' == "Serbia and Montenegro" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
		replace ccode`num' = 340 if `variable' == "Serbia-Montenegro" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
		replace ccode`num' = 340 if `variable' == "Serbia" & ((year < 1918 & year > 1877) | (year > 2006 & year != .)) 
		replace ccode`num' = 340 if `variable' == "SERBIA, REPUBLIC OF" & ((year < 1918 & year > 1877) | (year > 2006 & year != .)) 
		replace ccode`num' = 340 if `variable' == "Yugoslavia" & ((year < 1918 & year > 1877) | (year > 2006 & year != .)) 


		// For observations that should be Yugoslavia 
		replace ccode`num' = 345 if `variable' == "Serbia" & year > 1917 & year < 2007
		replace ccode`num' = 345 if `variable' == "Serbia, Republic of" & year > 1917 & year < 2007
		replace ccode`num' = 345 if `variable' == "Serbia Montenegro" & year > 1917 & year < 2007
		replace ccode`num' = 345 if `variable' == "Serbia & Montenegro" & year > 1917 & year < 2007
		replace ccode`num' = 345 if `variable' == "SerbiaandMontenegro" & year > 1917 & year < 2007
		replace ccode`num' = 345 if `variable' == "Serbia and Montenegro" & year > 1917 & year < 2007
		replace ccode`num' = 345 if `variable' == "Yugoslavia" & year > 1917 & year < 2007
		replace ccode`num' = 345 if `variable' == "Serbia" & year > 1917 & year < 2007
		replace ccode`num' = 345 if `variable' == "SERBIA, REPUBLIC OF" & year > 1917 & year < 2007
		replace ccode`num' = 345 if `variable' == "Serbia and Montenegro" & year > 1917 & year < 2007

		replace ccode`num' = 591 if `variable' == "Seychelles"
		replace ccode`num' = 591 if `variable' == "Seychelle"
		replace ccode`num' = 451 if `variable' == "Sierra Leone"
		replace ccode`num' = 830 if `variable' == "Singapore"
		replace ccode`num' = 317 if `variable' == "Slovak Republic"
		replace ccode`num' = 317 if `variable' == "Slovakia"
		replace ccode`num' = 349 if `variable' == "Slovenia"
		replace ccode`num' = 940 if `variable' == "Solomon Is"
		replace ccode`num' = 940 if `variable' == "Solomon Is."
		replace ccode`num' = 940 if `variable' == "Solomon Islands"
		replace ccode`num' = 520 if `variable' == "Somalia"
		replace ccode`num' = 560 if `variable' == "South Africa"
		replace ccode`num' = 560 if `variable' == "SouthAfrica"
		replace ccode`num' = 560 if `variable' == "S. Africa"
		replace ccode`num' = 397 if `variable' == "South Ossetia"
		replace ccode`num' = 626 if `variable' == "South Sudan"
		replace ccode`num' = 626 if `variable' == "S. Sudan"
		replace ccode`num' = 626 if `variable' == "Sudan (South)"
		replace ccode`num' = 365 if `variable' == "Soviet Union"
		replace ccode`num' = 230 if `variable' == "Spain"
		replace ccode`num' = 780 if `variable' == "Sri Lanka"
		replace ccode`num' = 780 if `variable' == "Sri Lanka (Ceylon)"
		replace ccode`num' = 780 if `variable' == "SriLanka"
		replace ccode`num' = 625 if `variable' == "Sudan"
		replace ccode`num' = 115 if `variable' == "Suriname"
		replace ccode`num' = 115 if `variable' == "Surinam"
		replace ccode`num' = 572 if `variable' == "Swaziland"
		replace ccode`num' = 380 if `variable' == "Sweden"
		replace ccode`num' = 225 if `variable' == "Switzerland"
		replace ccode`num' = 225 if `variable' == "Switz.Liecht"
		replace ccode`num' = 652 if `variable' == "Syria"
		replace ccode`num' = 652 if `variable' == "Syrian Arab Rep"
		replace ccode`num' = 652 if `variable' == "Syrian Arab Republic"
		replace ccode`num' = 652 if `variable' == "SyrianArabRep"
		replace ccode`num' = 652 if `variable' == "Syrian Arab Republic (Syria)"

		/***************************
		ccode numbers for T-countries 
		****************************/

		replace ccode`num' = 713 if `variable' == "Taiwan"
		replace ccode`num' = 713 if `variable' == "Taiwan (China)"
		replace ccode`num' = 713 if `variable' == "Taiwan, China"
		replace ccode`num' = 713 if `variable' == "Taiwan Province of China"
		replace ccode`num' = 713 if `variable' == "Taiwan, Republic of China on"   
		replace ccode`num' = 713 if `variable' == "TaiwanChina"
		replace ccode`num' = 713 if `variable' == "China, Taiwan Province of"
		replace ccode`num' = 713 if `variable' == "Chinese Taipei"
		replace ccode`num' = 702 if `variable' == "Tajikistan"
		replace ccode`num' = 510 if `variable' == "Tanzania"
		replace ccode`num' = 510 if `variable' == "Tanzania (Tanganyika)"
		replace ccode`num' = 510 if `variable' == "Tanzania Uni Rep"
		replace ccode`num' = 510 if `variable' == "Tanzania, United Rep. of"
		replace ccode`num' = 510 if `variable' == "Tanzania, United Rep.of"
		replace ccode`num' = 510 if `variable' == "Tanzania, United Rep. of "
		replace ccode`num' = 510 if `variable' == "Tanzania, United Rep. of "
		replace ccode`num' = 510 if `variable' == "Tanzania, United Republic of"
		replace ccode`num' = 510 if `variable' == "United Rep. of Tanzania"
		replace ccode`num' = 510 if `variable' == "United Republic of Tanzania"
		replace ccode`num' = 800 if `variable' == "Thailand"
		replace ccode`num' = 800 if `variable' == "Thailand (Siam)"
		replace ccode`num' = 711 if `variable' == "Tibet"
		replace ccode`num' = 461 if `variable' == "Togo"
		replace ccode`num' = 972 if `variable' == "Tonga"
		replace ccode`num' = 563 if `variable' == "Transvaal"
		replace ccode`num' = 52  if `variable' == "Trinidad-Tobago"
		replace ccode`num' = 52  if `variable' == "Trinidad and Tobago"
		replace ccode`num' = 52  if `variable' == "Trinidad & Tobago"
		replace ccode`num' = 52  if `variable' == "Trinidad & T"
		replace ccode`num' = 52  if `variable' == "Trinidad"
		replace ccode`num' = 616 if `variable' == "Tunisia"
		replace ccode`num' = 640 if `variable' == "Turkey"
		replace ccode`num' = 640 if `variable' == "Turkey/Ottoman Empire"
		replace ccode`num' = 640 if `variable' == "Turkey (Ottoman Empire)"
		replace ccode`num' = 701 if `variable' == "Turkmenistan"
		replace ccode`num' = 337 if `variable' == "Tuscany"
		replace ccode`num' = 973 if `variable' == "Tuvalu"
		replace ccode`num' = 329 if `variable' == "Two Sicilies"


		/***************************
		ccode numbers for U-countries 
		****************************/

		replace ccode`num' = 500 if `variable' == "Uganda"
		replace ccode`num' = 500 if `variable' == "Ugandan"
		replace ccode`num' = 500 if `variable' == "Nogeria"
		replace ccode`num' = 369 if `variable' == "Ukraine"
		replace ccode`num' = 696 if `variable' == "United Arab Emirates"
		replace ccode`num' = 696 if `variable' == "Un. Arab Em."
		replace ccode`num' = 696 if `variable' == "Untd Arab Em"
		replace ccode`num' = 696 if `variable' == "UnitedArabEmirates"
		replace ccode`num' = 696 if `variable' == "UAE"
		replace ccode`num' = 696 if `variable' == "U.A.E."
		replace ccode`num' = 200 if `variable' == "United Kingdom"
		replace ccode`num' = 200 if `variable' == "UnitedKingdom"
		replace ccode`num' = 200 if `variable' == "UK"
		replace ccode`num' = 200 if `variable' == "U.K."
		replace ccode`num' = 89 if `variable' == "United Provinces of Central America"
		replace ccode`num' = 89 if `variable' == "United Province CA"
		replace ccode`num' = 2 	 if `variable' == "United States"
		replace ccode`num' = 2   if `variable' == "UnitedStates"
		replace ccode`num' = 2 	 if `variable' == "United States of America"
		replace ccode`num' = 2 	 if `variable' == "United States, America"
		replace ccode`num' = 2   if `variable' == "USA"
		replace ccode`num' = 165 if `variable' == "Uruguay"
		replace ccode`num' = 704 if `variable' == "Uzbekistan"


		/***************************
		ccode numbers for V and W-countries 
		****************************/

		replace ccode`num' = 935 if `variable' == "Vanuatu"
		replace ccode`num' = . if `variable' == "Vatican City"
		replace ccode`num' = 101 if `variable' == "Venezuela"
		replace ccode`num' = 101 if `variable' == "Venezuela, RB"
		replace ccode`num' = 101 if `variable' == "Venezuela, R.B."
		replace ccode`num' = 101 if `variable' == "VenezuelaRB"
		replace ccode`num' = 101 if `variable' == "Venezuela (Bolivarian Republic of)"
		replace ccode`num' = 101 if `variable' == "Venezuela, Republica Bolivariana de"
		replace ccode`num' = 101 if `variable' == "Venezuela, Rep?blica Bolivariana de"
		replace ccode`num' = 816 if `variable' == "Vietnam, Democratic Republic of"
		replace ccode`num' = 816 if `variable' == "Vietnam, N."
		replace ccode`num' = 816 if `variable' == "Vietnam, North"
		replace ccode`num' = 816 if `variable' == "Vietnam, N"
		replace ccode`num' = 816 if `variable' == "N. Vietnam"
		replace ccode`num' = 816 if `variable' == "Vietnam North"
		replace ccode`num' = 816 if `variable' == "Vietnam, Socialist Republic of"  
		replace ccode`num' = 816 if `variable' == "Viet Nam"  
		replace ccode`num' = 816 if `variable' == "Vietnam"  
		replace ccode`num' = 817 if `variable' == "Vietnam, Republic of"
		replace ccode`num' = 817 if `variable' == "Vietnam, Republic of (South Vietnam)"
		replace ccode`num' = 817 if `variable' == "Vietnam, S."
		replace ccode`num' = 817 if `variable' == "Vietnam, S"
		replace ccode`num' = 817 if `variable' == "Vietnam South"
		replace ccode`num' = 817 if `variable' == "Vietnam, South"
		replace ccode`num' = 817 if `variable' == "S. Vietnam"
		replace ccode`num' = 817 if `variable' == "Republic of Vietnam"
		// This is for Vietnam before French occupation
		replace `variable' = "Vietnam" if ccode`num'==816
		replace ccode`num' = 815 if `variable' == "Vietnam (Annam/Cochin China/Tonkin)"
		replace ccode`num' = 815 if `variable' == "Vietnam/Annam/Cochin China/Tonkin"
		replace ccode`num' = 815 if `variable' =="Vietnam" & year<1893 
		replace ccode`num' = 816 if ccode`num' == 815 & year < 1893 /*because vietnam has a different ccode during this period*/

		replace ccode`num' = 271 if `variable' == "Wuerttemburg"

		/***************************
		ccode numbers for Y-countries 
		****************************/

		replace ccode`num' = 678 if `variable' == "Yemen"
		replace ccode`num' = 678 if `variable' == "Fm Yemen Dm"
		replace ccode`num' = 678 if `variable' == "Yemen Arab Rep"
		replace ccode`num' = 678 if `variable' == "Yemen Arab Rep."
		replace ccode`num' = 678 if `variable' == "Yemen Arab Republic"
		replace ccode`num' = 678 if `variable' == "Yemen (AR)"
		replace ccode`num' = 678 if `variable' == "Yemen, N."
		replace ccode`num' = 678 if `variable' == "Yemen, N"
		replace ccode`num' = 678 if `variable' == "Yemen North"
		replace ccode`num' = 678 if `variable' == "Yemen, Rep."
		replace ccode`num' = 678 if `variable' == "Yemen, Republic of"
		replace ccode`num' = 678 if `variable' == "Republic of (Southern Yemen))"
		replace ccode`num' = 680 if `variable' == "Yemen, S."
		replace ccode`num' = 680 if `variable' == "Yemen, S"
		replace ccode`num' = 680 if `variable' == "Yemen South"
		replace ccode`num' = 680 if `variable' == "Yemen, South"
		replace ccode`num' = 680 if `variable' == "S. Yemen"
		replace ccode`num' = 680 if `variable' == "Yemen P Dem Rep"
		replace ccode`num' = 680 if `variable' == "Yemen People's Republic"
		replace ccode`num' = 680 if `variable' == "Yemen, People's Democratic"
		replace ccode`num' = 680 if `variable' == "Yemen (PDR)"
		replace ccode`num' = 680 if `variable' == "Yemen, P.D.R."
		replace ccode`num' = 680 if `variable' == "Fm Yemen AR"
		replace ccode`num' = 345 if `variable' == "Yugoslavia" & year > 1917 & year < 2007
		replace ccode`num' = 345 if `variable' == "Yugoslav" & year > 1917 & year < 2007
		replace ccode`num' = 345 if `variable' == "Yugoslavia (FRY)" & year > 1917 & year < 2007
		replace ccode`num' = 345 if `variable' == "Yugoslavia, FR" & year > 1917 & year < 2007
		replace ccode`num' = 345 if `variable' == "Yugoslavia, SFR" & year > 1917 & year < 2007
		replace ccode`num' = 345 if `variable' == "Yugoslavia, Federal Republic of" & year > 1917 & year < 2007
		replace ccode`num' = 345 if `variable' == "Former Yugoslavia, Socialist Fed. Rep." & year > 1917 & year < 2007
		replace ccode`num' = 345 if `variable' == "Serbia/Yugoslavia" & year > 1917 & year < 2007
		replace ccode`num' = 345 if `variable' == "Yugoslavia (Serbia)" & year > 1917 & year < 2007
		replace ccode`num' = 345 if `variable' == "SFR of Yugoslavia (former)" & year > 1917 & year < 2007
		replace ccode`num' = 345 if `variable' == "Yugoslavia -91" & year > 1917 & year < 2007

		// For observations that should be Serbia
		replace ccode`num' = 340 if `variable' == "Yugoslavia" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
		replace ccode`num' = 340 if `variable' == "Yugoslav" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
		replace ccode`num' = 340 if `variable' == "Yugoslavia (FRY)" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
		replace ccode`num' = 340 if `variable' == "Yugoslavia, FR" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
		replace ccode`num' = 340 if `variable' == "Yugoslavia, SFR" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
		replace ccode`num' = 340 if `variable' == "Yugoslavia, Federal Republic of" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
		replace ccode`num' = 340 if `variable' == "Former Yugoslavia, Socialist Fed. Rep." & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
		replace ccode`num' = 340 if `variable' == "Serbia/Yugoslavia" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
		replace ccode`num' = 340 if `variable' == "Yugoslavia (Serbia)" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
		replace ccode`num' = 340 if `variable' == "SFR of Yugoslavia (former)" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
		replace ccode`num' = 340 if `variable' == "Yugoslavia -91" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))

		/***************************
		ccode numbers for Z-countries 
		****************************/

		replace ccode`num' = 551 if `variable' == "Zambia"
		replace ccode`num' = 511 if `variable' == "Zanzibar"
		replace ccode`num' = 552 if `variable' == "Zimbabwe"
		replace ccode`num' = 552 if `variable' == "Zimbabwe (Rhodesia)"

		}
drop if ccode1==.
drop if ccode2==.
**somma unit
bysort ccode1 ccode2: egen tot_value=sum(value)


***** creating the dummy for being a net exporter and net exporter to US
bysort ccode1: egen tot_export=max(tot_value)
replace ccode1=ccode2 if ccode1==0
g tot_imp=.
replace tot_imp=tot_value if ccode1==ccode2
bysort ccode1: egen tot_import=max(tot_imp)
replace tot_import=0 if tot_import==. 
replace ccode1=0 if ccode1==ccode2

g imp_usa=.
replace imp_usa=tot_value if ccode2==2
bysort ccode1: egen import_usa=max(imp_usa)
replace import_usa=0 if import_usa==.

g exp_usa=.
replace ccode1=ccode2 if ccode1==2
replace exp_usa=tot_value if ccode1==ccode2
bysort ccode1: egen export_usa=max(exp_usa)
replace export_usa=0 if export_usa==. 
replace ccode1=2 if ccode1==ccode2&exporter!="World"



g net_exp=tot_export-tot_import
g net_exp_usa=import_usa-export_usa
rename ccode1 ccode
collapse year net_exp net_exp_usa tot_export tot_import import_usa export_usa, ///
 by(ccode)

save wtf`i'_cleaned.dta,replace
}

use wtf62_cleaned.dta, clear

forvalues i=63(1)99{
	append  using wtf`i'_cleaned.dta

	}
	
gen net_exp_dummy=net_exp >0 if !missing(net_exp)

gen net_exp_usa_dummy=net_exp_usa >0 if !missing(net_exp_usa)

keep ccode year net_exp_dummy net_exp_usa_dummy tot_export tot_import
drop if ccode==0
save ${main}/2_processed/wtf_all.dta,replace



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
by year gwno_loc: egen maxint=max(intensity_level)
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
replace maxint=intensity_level if maxint==.
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
gen oil0 = oil == 0
*standardized variable
qui sum oil
replace oil = (oil - `r(mean)')/`r(sd)'
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
* Standardized variable
qui sum gas
replace gas = (gas - `r(mean)')/`r(sd)'
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
* Standardized variable
qui sum coal
replace coal = (coal - `r(mean)')/`r(sd)'
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

gen sedvol0 = lnsedvol == 0
* Standardized variable
qui sum sedvol
replace sedvol = (sedvol - `r(mean)')/`r(sd)'
* Generate the squared term
gen sedvol2=(sedvol^2)

* Rescale area variable.
replace area=area/(10^9)

* Merge with oil exports data-1949-2021
merge 1:1 year ccode using ${main}2_processed/wtf_all.dta
rename _merge mergeOILEXP

drop if mergeOILEXP == 2

replace net_exp_dummy = 0 if mergeOILEXP == 1 & year > 1961
replace net_exp_usa_dummy = 0 if mergeOILEXP == 1 & year > 1961

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

* Merge with data about US bases dist
foreach dist in `distlist' {
	merge m:1 ccode using ${main}2_processed/contig50bases`dist'.dta
	rename _merge mergeBASES50`dist'
}

* Merge with data about arms trade
merge m:1 ccode using ${main}2_processed/dist_arms_USSR.dta
rename _merge mergeARMS_USSR

* Merge with UN data
merge m:1 ccode using ${main}2_processed/US_affinity.dta
rename _merge mergeUN

* Merge with UN data
merge m:1 ccode using ${main}2_processed/distus.dta
rename _merge mergeDISTUS

* Merge with arms data
merge m:1 ccode using ${main}2_processed/arms_exp.dta
rename _merge mergeARMSEXP

* Compute military expenditure per capita
* measure military expenditures from millions to thousand dollars
replace milex = milex*1000
gen milexpc = milex/exp(lnpop14)
gen milexpc2 = milexpc^2

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
gen distus1000 = distus/1000
	
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
la var precip "Average precipitation (mm)"
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
la var contig50bases "Close to US troops dummy"
foreach dist in `distlist' {
	la var contig50bases`dist' "Close to US troops, `dist'KM threshold"
}
la var armstrade1950 "Traded arms with US"
la var affinity0_65 "UNGA voting affinity"
la var affinity0_65_3 "UNGA voting affinity (3 votes)"
la var distus "Distance from the US (Km)"
la var milex "Military expediture"
la var milexpc "Military expediture pc"
la var distus1000 "Distance from the US" 
la var oil0 "No oil" 
la var sedvol0 "No sedimentary basins" 
la var net_exp_dummy "Net exporter of oil in the year" 
la var net_exp_usa_dummy "Net exporter of oil to USA in the year" 

* label values of third party variables
la define contig50bases 0 "No US troops in 1950s" 1 "US troops in 1950s"
la val contig50bases contig50bases
la define armstrade1950 0 "No arms' trade with the US in 1950s" 1 "Arms' trade with the US in 1950s"
la val armstrade1950 armstrade1950

* Sample from 1950 to 1999
keep if year < 2000

global outcome_list "conflict conflict2"
local controls "lnarea  abslat elevavg elevstd temp precip lnpop14"

* Make sample the same regardless of controls
foreach var in `controls' {
	drop if `var' == .
}

keep year region lnarea abslat elevavg elevstd temp precip lnpop14 ///
	conflict conflict2 sedvol sedvol2 coal coal2 gas gas2 oil oil oil2  ///
	armstrade90 armstrade ccode conf_years ///
	armstrade0 gdpdef oil_price oil_price2 gdpdef ///
	legor_uk legor_fr legor_so legor_ge legor_sc pmuslim pcatholic pprotest ///
	contig50bases* armstrade1950 armstrade_ussr1950 affinity* distus* ///
	milex milexpc* oil0 sedvol0 net_exp*

save ${main}2_processed/data_regressions_panel.dta, replace

preserve


* Merge with interventions
sort ccode year
merge 1:m ccode year using ${main}2_processed/US_interventions.dta

rename _merge _mergeUSINT

* Merge with interventions
sort ccode year
merge 1:m ccode year using ${main}2_processed/USUSSR_interventions.dta

rename _merge _mergeUSUSSRINT

*keep if _merge == 3

drop if _mergeUSINT == 2
gen confkoga = 0
replace confkoga = 1 if _mergeUSINT == 3

replace mili_intervention = 0 if missing(mili_intervention)
replace govmil = 0 if missing(govmil)

la var mili_intervention "Military intervention (US)"
la var govmil "Military intervention in favor of government (US)"

replace mili_intervention_all = 0 if missing(mili_intervention_all)
replace govmil_all = 0 if missing(govmil_all)

la var mili_intervention_all "Military intervention"
la var govmil_all "Military intervention in favor of government"

save ${main}2_processed/data_interventions_panel.dta, replace

* prova con fraction conflict
collapse region lnarea abslat elevavg elevstd temp precip lnpop14 ///
	conflict conflict2 sedvol sedvol2 coal coal2 gas gas2 oil oil2  ///
	armstrade90 armstrade conf_years ///
	armstrade0 gdpdef oil_price oil_price2 ///
	legor_uk legor_fr legor_so legor_ge legor_sc pmuslim pcatholic pprotest ///
	contig50bases* armstrade1950 armstrade_ussr1950 affinity* distus*  ///
	milex milexpc* mili_intervention* govmil* oil0 sedvol0 net_exp* (min) year, by(ccode)

replace mili_intervention = mili_intervention > 0 if mili_intervention != .
replace govmil = govmil > 0 if govmil != .

replace mili_intervention_all = mili_intervention_all > 0 if mili_intervention_all != .
replace govmil_all = govmil_all > 0 if govmil_all != .

replace net_exp_dummy = net_exp_dummy > 0 if net_exp_dummy != .
replace net_exp_usa_dummy = net_exp_usa_dummy > 0 if net_exp_usa_dummy != .

*label controls used in 
la var lnarea "Area, (log Km\(^2\))"
la var abslat "Absolute latitude"
la var elevavg "Average altitude (Km)"
la var elevstd "Dispersion in altitude"
la var temp "Average temperature (C)"
la var precip "Average precipitation (mm)"
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
la var contig50bases "Close to US troops dummy"
foreach dist in `distlist' {
	la var contig50bases`dist' "Close to US base, `dist'KM threshold"
}
la var armstrade1950 "Traded arms with US"
la var affinity0_65 "UNGA voting affinity"
la var affinity0_65_3 "UNGA voting affinity (3 votes)"
la var distus "Distance from the US (Km)"
la var milex "Military expediture (2021\$)"
la var milexpc "Military expediture pc (2021\$)"
la var milexpc "Military expediture pc (2021\$), squared"
la var distus1000 "Distance from the US (1000 Kms)" 
la var oil0 "No oil" 
la var sedvol0 "No sedimentary basins" 
la var net_exp_dummy "Net exporter of oil once 62-99" 
la var net_exp_usa_dummy "Net exporter of oil to USA once 62-99" 

save ${main}2_processed/data_interventions_crossc.dta, replace


restore

preserve


keep if year > 1961

* prova con fraction conflict
collapse region lnarea abslat elevavg elevstd temp precip lnpop14 ///
	conflict conflict2 sedvol sedvol2 coal coal2 gas gas2 oil oil2  ///
	armstrade90 armstrade conf_years ///
	armstrade0 gdpdef oil_price oil_price2 ///
	legor_uk legor_fr legor_so legor_ge legor_sc pmuslim pcatholic pprotest ///
	contig50bases* armstrade1950 armstrade_ussr1950 affinity* distus*  ///
	milex milexpc milexpc2 oil0 sedvol0 net_exp* (min) year, by(ccode)

sum net_exp_dummy, de
replace net_exp_dummy = net_exp_dummy > 0  if net_exp_dummy != .
sum net_exp_usa_dummy, de
replace net_exp_usa_dummy = net_exp_usa_dummy > 0 if net_exp_usa_dummy != .

*label controls used in 
la var lnarea "Area, (log Km\(^2\))"
la var abslat "Absolute latitude"
la var elevavg "Average altitude (Km)"
la var elevstd "Dispersion in altitude"
la var temp "Average temperature (C)"
la var precip "Average precipitation (mm)"
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
la var contig50bases "Close to US troops dummy"
foreach dist in `distlist' {
	la var contig50bases`dist' "Close to US base, `dist'KM threshold"
}
la var armstrade1950 "Traded arms with US"
la var affinity0_65 "UNGA voting affinity"
la var affinity0_65_3 "UNGA voting affinity (3 votes)"
la var distus "Distance from the US (Km)"
la var milex "Military expediture (2021\$)"
la var milexpc "Military expediture pc (2021\$)"
la var milexpc "Military expediture pc, squared (2021\$)"
la var distus1000 "Distance from the US (1000 Kms)" 
la var oil0 "No oil" 
la var sedvol0 "No sedimentary basins" 
la var net_exp_dummy "Net exporter of oil once 62-99" 
la var net_exp_usa_dummy "Net exporter of oil to USA once 62-99" 

save ${main}2_processed/data_regressions_crossc62_99.dta, replace

restore

* prova con fraction conflict
collapse region lnarea abslat elevavg elevstd temp precip lnpop14 ///
	conflict conflict2 sedvol sedvol2 coal coal2 gas gas2 oil oil2  ///
	armstrade90 armstrade conf_years ///
	armstrade0 gdpdef oil_price oil_price2 ///
	legor_uk legor_fr legor_so legor_ge legor_sc pmuslim pcatholic pprotest ///
	contig50bases* armstrade1950 armstrade_ussr1950 affinity* distus*  ///
	milex milexpc milexpc2 oil0 sedvol0 net_exp* (min) year, by(ccode)

sum net_exp_dummy, de
replace net_exp_dummy = net_exp_dummy > 0  if net_exp_dummy != .
sum net_exp_usa_dummy, de
replace net_exp_usa_dummy = net_exp_usa_dummy > 0 if net_exp_usa_dummy != .

*label controls used in 
la var lnarea "Area, (log Km\(^2\))"
la var abslat "Absolute latitude"
la var elevavg "Average altitude (Km)"
la var elevstd "Dispersion in altitude"
la var temp "Average temperature (C)"
la var precip "Average precipitation (mm)"
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
la var contig50bases "Close to US troops dummy"
foreach dist in `distlist' {
	la var contig50bases`dist' "Close to US base, `dist'KM threshold"
}
la var armstrade1950 "Traded arms with US"
la var affinity0_65 "UNGA voting affinity"
la var affinity0_65_3 "UNGA voting affinity (3 votes)"
la var distus "Distance from the US (Km)"
la var milex "Military expediture (2021\$)"
la var milexpc "Military expediture pc (2021\$)"
la var milexpc "Military expediture pc, squared (2021\$)"
la var distus1000 "Distance from the US (1000 Kms)" 
la var oil0 "No oil" 
la var sedvol0 "No sedimentary basins" 
la var net_exp_dummy "Net exporter of oil once 62-99" 
la var net_exp_usa_dummy "Net exporter of oil to USA once 62-99" 

save ${main}2_processed/data_regressions_crossc.dta, replace

**********************************ANALYSIS**************************************

gen thirdparty = .



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
				ivreg2 `outcome' `independent' i.region, cluster(ccode) partial(i.region)
				* Save geographic controls indicator
				estadd local geocontrols = "No"
			}
			else {
				ivreg2 `outcome' `independent' `controls' i.region, cluster(ccode) partial(i.region)
				* Save geographic controls indicator
				estadd local geocontrols = "Yes"
			}
			
			* Save time controls indicators
			
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
 	stats(space space putest space gas coal continentfe geocontrols   peak N, fmt(s s s s s s s a2 a2) ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value}"' `" "' `"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' `"Continent FEs"'  `"Geo Controls"' `"Peak"' `"\(N\)"')) ///
		mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US troops dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US troops dummy" 1.thirdparty#c.x "Res. Value \(\times\) US troops dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US troops dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US troops dummy" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US troops}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US troops dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US troops dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US troops}"' `"\qquad \emph{p-value: countries w/ US troops}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US arms' trade dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US arms' trade dummy" 1.thirdparty#c.x "Res. Value \(\times\) US arms' trade dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US arms' trade dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US arms' trade dummy" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US arms' trade}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US arms' trade dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US arms' trade dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US arms' trade}"' `"\qquad \emph{p-value: countries w/ US  arms' trade}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
	postfoot("\hline\hline \end{tabular}}")


	
* Table 4: Interventions, bases, and arms

preserve
clear

use ${main}2_processed/data_interventions_panel.dta, replace
keep if confkoga == 1

local controls "lnarea  abslat elevavg elevstd temp precip lnpop14"

gen thirdparty = .
la var thirdparty "US influence"

global thirdparty_list "contig50bases armstrade1950"
global outcome_list "mili_intervention govmil"

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
							
				if (`i_con' == 1) {
					ivreg2 `outcome' thirdparty  ///
					i.year i.region `controls' ///
					, robust partial(`controls' i.region i.year)
					* Save geographic controls indicator
				}
				else {
					ivreg2 `outcome' thirdparty milexpc ///
					i.year i.region `controls' ///
					, robust partial(`controls' i.region i.year)
					* Save geographic controls indicator
					
				}
				
				* Save time controls indicators
				estadd local geocontrols = "Yes"
				
				estadd local continentfe = "Yes"
				* Save resource controls indicators
				estadd local yearfe = "Yes"
				
				est sto reg`counter'
			}

}
}


esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 using ///
${main}5_output/tables/interv_panel_rob.tex, replace ///
starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) label nonumbers ///
prehead("\begin{tabular}{l*{9}{c}} \hline\hline  &\multicolumn{8}{c}{y = Military intevention} \\             &\multicolumn{4}{c}{   US influence: troops   }&\multicolumn{4}{c}{  US influence: arms' trade }  \\ \cmidrule(lr){2-5} \cmidrule(lr){6-9} & \multicolumn{2}{c}{   \Shortstack{1em}{All \\ interventions}   }&\multicolumn{2}{c}{\Shortstack{1em}{Gov't-supporting \\ interventions}}& \multicolumn{2}{c}{   \Shortstack{1em}{All \\ interventions}   }&\multicolumn{2}{c}{\Shortstack{1em}{Gov't-supporting \\ interventions}}  \\  ") postfoot("\hline\hline \end{tabular}") nomtitles ///
stats(space  continentfe geocontrols yearfe  N, fmt(s s s s a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "'   `"Continent FEs"' `"Geo Controls"' `"Year FEs"'  `"\(N\)"')) 
restore


	
	
		
*TABLE A1: summary

	estpost tabstat sedvol oil gas coal lnarea  abslat elevavg elevstd temp ///
	precip lnpop14 conflict conflict2 contig50bases armstrade1950 affinity0_65 distus, stat(mean sd min p50  max n) col(stat) 
	*esttab, cells("mean sd p25 p50  p75 count") label
	matrix summary = e(mean)',  e(sd)' , e(min)', e(p50)',  e(max)', e(count)'

	esttab using ${main}5_output/tables/summary.tex, cells("mean(fmt(%9.3g) label(Mean)) sd(fmt(%9.3g) label(sd)) min(fmt(%9.3g) label(Min)) p50(fmt(%9.3g) label(Median))  max(fmt(%9.3g) label(Max)) count(fmt(%9.0g) label(N))") label noobs nonumber replace 

	estpost tabstat sedvol oil gas coal , stat(mean sd min p50  max n) col(stat) 
	*esttab, cells("mean sd p25 p50  p75 count") label
	matrix summary = e(mean)',  e(sd)' , e(min)', e(p50)',  e(max)', e(count)'

	esttab using ${main}5_output/tables/summarya.tex, cells("mean(fmt(%9.4f) label(\quad)) sd(fmt(%9.3g) label(\quad)) min(fmt(%9.3f) label(\quad)) p50(fmt(%9.3f) label(\quad))  max(fmt(%9.3f) label(\quad)) count(fmt(%9.0g) label(\quad))") label noobs nomtitles nonumber replace prehead("") posthead(" ") postfoot("")

	
		estpost tabstat lnarea  abslat elevavg elevstd temp precip lnpop14, stat(mean sd min p50  max n) col(stat) 
	*esttab, cells("mean sd p25 p50  p75 count") label
	matrix summary = e(mean)',  e(sd)' , e(min)', e(p50)',  e(max)', e(count)'

	esttab using ${main}5_output/tables/summaryb.tex, cells("mean(fmt(%9.3f) label(\quad)) sd(fmt(%9.3f) label(\quad)) min(fmt(%9.3f) label(\quad)) p50(fmt(%9.3f) label(\quad))  max(fmt(%9.3f) label(\quad)) count(fmt(%9.0g) label(\quad))") label noobs nomtitles nonumber replace prehead("") posthead(" ") postfoot("")

	
		estpost tabstat conflict conflict2 , stat(mean sd min p50  max n) col(stat) 
	*esttab, cells("mean sd p25 p50  p75 count") label
	matrix summary = e(mean)',  e(sd)' , e(min)', e(p50)',  e(max)', e(count)'

	esttab using ${main}5_output/tables/summaryc.tex, cells("mean(fmt(%9.3f) label(\quad)) sd(fmt(%9.3f) label(\quad)) min(fmt(%9.3g) label(\quad)) p50(fmt(%9.3f) label(\quad))  max(fmt(%9.3f) label(\quad)) count(fmt(%9.0g) label(\quad))") label noobs nomtitles nonumber replace prehead("") posthead(" ") postfoot("")


		estpost tabstat contig50bases armstrade1950 affinity0_65 distus, stat(mean sd min p50  max n) col(stat) 
	*esttab, cells("mean sd p25 p50  p75 count") label
	matrix summary = e(mean)',  e(sd)' , e(min)', e(p50)',  e(max)', e(count)'

	esttab using ${main}5_output/tables/summaryd.tex, cells("mean(fmt(%9.3f) label(\quad)) sd(fmt(%9.3f) label(\quad)) min(fmt(%9.3g) label(\quad)) p50(fmt(%9.3g) label(\quad))  max(fmt(a1) label(\quad)) count(fmt(%9.0g) label(\quad))") label noobs nomtitles nonumber replace prehead("") posthead(" ") postfoot("")

	

			
* Table A2: Determinants of third party presence
ivreg2 contig50bases    `controls'
est sto reg1
ivreg2 contig50bases  oil sedvol  `controls'
est sto reg2
ivreg2 armstrade1950     `controls'
est sto reg3
ivreg2 armstrade1950   oil sedvol  `controls'
est sto reg4

esttab reg1 reg2 reg3 reg4 using ///
${main}5_output/tables/balance.tex, replace ///
label se ///
starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
 nobaselevels nonumbers nomtitles ///
 	postfoot("\hline\hline \end{tabular}") 	 prehead("\begin{tabular}{l*{5}{c}} \hline\hline  &\multicolumn{4}{c}{y = US Involvement} \\ \cmidrule(lr){2-3} \cmidrule(lr){4-5} &\multicolumn{2}{c}{Involvment: Bases}&\multicolumn{2}{c}{Involvement: Arms' Trade} \\") nonumbers
	


est clear

global outcome_list "conflict conflict2"
			
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
				ivreg2 `outcome' `independent' i.region, cluster(ccode) partial(i.region)
				* Save geographic controls indicator
				estadd local geocontrols = "No"
			}
			else {
				ivreg2 `outcome' `independent' `controls' i.region, cluster(ccode) partial(i.region)
				* Save geographic controls indicator
				estadd local geocontrols = "Yes"
			}
			
			* Save time controls indicators
			
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
coeflabels(sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)" oil "Oil" oil2 "Oil\(^2\)" gas "Gas" gas2 "Gas\(^2\)" coal "Coal" coal2 "Coal\(^2\)" lnarea "Area, (log Km\(^2\))" abslat "Absolute latitude" elevavg "Average altitude (Km)" elevstd "Dispersion in altitude" temp "Average temperature (C)" precip "Average precipitation (mm)" lnpop14 "Population, logs") se ///
starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
 nobaselevels ///
 order(oil oil2 gas gas2 coal coal2 sedvol sedvol2 `control') ///
 	stats(space space putest space continentfe geocontrols  peak N, fmt(s s s s s s a2 a2) ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value}"' `" "' `"Continent FEs"' `"Geo Controls"' `"Peak"' `"\(N\)"')) ///
		mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
			postfoot("\hline\hline \end{tabular}}")	


			


local controls "lnarea  abslat elevavg elevstd temp precip lnpop14"
	
* Table A4: Resources and military expenditure

global thirdparty_list "contig50bases"
local counter 0

gen x = sedvol
* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
			forval i_con = 1/2 {
				local counter = `counter' + 1
				

				if (`i_con' == 1) {
					ivreg2 milexpc c.x c.x#i.thirdparty ///
					i.thirdparty ///
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 milexpc c.x c.x#i.thirdparty ///
					i.thirdparty  i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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

				* Save resource controls indicators
				estadd local gascoal = "No"
				estadd local gascoalsq = "No"
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				est sto reg`counter'
			}
}

drop x



gen x = oil
* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
			forval i_con = 1/2 {
				local counter = `counter' + 1
				
				if (`i_con' == 1) {
					ivreg2 milexpc c.x c.x#i.thirdparty i.thirdparty ///
					c.gas c.coal  ///
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 milexpc c.x c.x#i.thirdpar i.thirdparty ///
					c.gas c.coal  ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				est sto reg`counter'
			}
}

drop x

esttab reg1 reg2 reg3 reg4 using ///
${main}5_output/tables/arms_int_bases_milexpc.tex, replace ///
 drop(`controls'  ///
	gas coal) /// 
	coeflabels(x "Res. Value" 1.thirdparty "US troops dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US troops dummy" 1.thirdparty#c.x "Res. Value \(\times\) US troops dummy" ///
	oil "Oil") se noobs ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers nomtitles ///
		prehead("") posthead("  \\ \textbf{\textit{Panel (a)}}  & & &  &   \\ \emph{US troops}  & & &  &   \\ [1em]")    postfoot("\hline") 


global thirdparty_list "armstrade1950"
local counter 0

gen x = sedvol
* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
			forval i_con = 1/2 {
				local counter = `counter' + 1
			
				
				if (`i_con' == 1) {
					ivreg2 milexpc c.x c.x#i.thirdparty ///
					i.thirdparty ///
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 milexpc c.x c.x#i.thirdparty ///
					i.thirdparty i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
				
				* Save resource controls indicators
				estadd local gascoal = "No"
				estadd local gascoalsq = "No"
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				est sto reg`counter'
			}
}


drop x 



gen x = oil
* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
			forval i_con = 1/2 {
				local counter = `counter' + 1
				
				if (`i_con' == 1) {
					ivreg2 milexpc c.x c.x#i.thirdparty  i.thirdparty ///
					c.gas c.coal  ///
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 milexpc c.x c.x#i.thirdparty i.thirdparty ///
					c.gas c.coal  ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				est sto reg`counter'
			}

}

drop x

esttab reg1 reg2 reg3 reg4 using ///
${main}5_output/tables/arms_int_armstrade_milexpc.tex, replace ///
 drop(`controls'  ///
	gas coal) /// 
	coeflabels(x "Res. Value" 1.thirdparty "US arms' trade dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US arms' trade dummy" 1.thirdparty#c.x "Res. Value \(\times\) US arms' trade dummy" ///
	 oil "Oil" ) se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers nomtitles noobs ///
		prehead("") posthead("  \\ \textbf{\textit{Panel (b)}}  & & &  &   \\ \emph{Arms' trade}  & & &  &   \\ [1em]")    postfoot("\hline") ///
	nonumbers nomtitles

	
* Table A5: Sedimentary basins presence and conflict, with third party presence
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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "USSR arms' trade dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) USSR arms' trade dummy" 1.thirdparty#c.x "Res. Value \(\times\) USSR arms' trade dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) USSR arms' trade dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) USSR arms' trade dummy" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols N, ///
	fmt(s s s %6.3f s %6.3f s s s s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries w/ USSR arms' trade}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) USSR arms' trade dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) USSR arms' trade dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o USSR arms' trade}"' `"\qquad \emph{p-value: countries w/ USSR  arms' trade}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
	postfoot("\hline\hline \end{tabular}}")

	
	

* Table A6: WB resources and sedimentary basins, by contiguity to US bases, controlling for military expenditure

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
					c.milexpc  i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.milexpc  i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					c.milexpc  i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty c.milexpc  i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
					c.gas c.gas2 c.coal c.coal2 c.milexpc  ///
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 c.milexpc ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					c.gas c.gas2 c.coal c.coal2 c.milexpc  ///
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 c.milexpc  ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
${main}5_output/tables/prio_int_bases_milexpc.tex, replace ///
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US troops dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US troops dummy" 1.thirdparty#c.x "Res. Value \(\times\) US troops dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US troops dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US troops dummy" oil "Oil" oil2 "Oil\(^2\)" milexpc  "Military expenditure") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US troops}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US troops dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US troops dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US troops}"' `"\qquad \emph{p-value: countries w/ US troops}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
	postfoot("\hline\hline \end{tabular}}")



	
			
* Table A7: WB resources and sedimentary basins, by US armstrade, controlling for military expenditure

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
					c.milexpc  i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.milexpc  i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					c.milexpc  i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty c.milexpc  i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
					c.gas c.gas2 c.coal c.coal2 c.milexpc  ///
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 c.milexpc  ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					c.gas c.gas2 c.coal c.coal2 c.milexpc  ///
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 c.milexpc  ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
${main}5_output/tables/prio_int_armstrade_milexpc.tex, replace ///
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US arms' trade dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US arms' trade dummy" 1.thirdparty#c.x "Res. Value \(\times\) US arms' trade dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US arms' trade dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US arms' trade dummy" oil "Oil" oil2 "Oil\(^2\)" milexpc "Military expenditure") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US arms' trade}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US arms' trade dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US arms' trade dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US arms' trade}"' `"\qquad \emph{p-value: countries w/ US  arms' trade}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
	postfoot("\hline\hline \end{tabular}}")


	
	
* Table A8: WB resources and sedimentary basins, by contiguity to US bases

global thirdparty_list "contig50bases750 contig50bases1250 contig50bases1500 contig50bases1750"
local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		forval i_indep = 1/2 {
				local counter = `counter' + 1
				
				* Test for inverse-U shaped relation with interaction
				if (`i_indep' == 1) {
					gen x = oil
					gen x2 = oil2
					
					ivreg2 conflict c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					
				}
				else {
					gen x = sedvol
					gen x2 = sedvol2
					
					ivreg2 conflict c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)

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
				
				
				if (`i_indep' == 1) {
					ivreg2 conflict c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					
					estadd local gascoal = "Yes"
					estadd local gascoalsq = "Yes"
					
				}
				else {	
					ivreg2 conflict c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					
					estadd local gascoal = "No"
					estadd local gascoalsq = "No"

				}
				
				estadd local geocontrols = "Yes"
				* Save time controls indicators
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
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				sum thirdparty
				local avgbases : di %6.3f scalar(`r(mean)')
				estadd local avgbases "`avgbases'"
				
				est sto reg`counter'
				drop x x2
			
		}
}


esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8  using ///
${main}5_output/tables/prio_int_bases_dist.tex, replace ///
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US troops dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US troops dummy" 1.thirdparty#c.x "Res. Value \(\times\) US troops dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US troops dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US troops dummy" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Thr. 750KM" "Thr. 1250KM" "Thr. 1500KM" "Thr. 1750KM" , ///
	pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols avgbases N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s s s  a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US troops}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US troops dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US troops dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US troops}"' `"\qquad \emph{p-value: countries w/ US troops}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\% w/ bases"'  `"\(N\)"')) ///
	mtitles("Oil" "Sed. Bas." "Oil" "Sed. Bas." "Oil" "Sed. Bas." "Oil" "Sed. Bas." "Oil" "Sed. Bas.") ///
	postfoot("\hline\hline \end{tabular}}")


	


* Table A9: WB resources and sedimentary basins, by contiguity to US bases, Excluding countries without Resources

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
					i.region if sedvol0 == 0, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.region `controls' if sedvol0 == 0, ///
					cluster(ccode) partial(i.region)
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
					i.region if sedvol0 == 0, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.region `controls' if sedvol0 == 0, ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
					i.region if oil0 == 0, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls' if oil0 == 0, ///
					cluster(ccode) partial(i.region)
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
					i.region if oil0 == 0, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls' if oil0 == 0, ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
${main}5_output/tables/prio_int_bases_no0.tex, replace ///
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US troops dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US troops dummy" 1.thirdparty#c.x "Res. Value \(\times\) US troops dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US troops dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US troops dummy" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US troops}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US troops dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US troops dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US troops}"' `"\qquad \emph{p-value: countries w/ US troops}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
	postfoot("\hline\hline \end{tabular}}")
	
			
* Table A10: WB resources and sedimentary basins, by US armstrade, Excluding countries without Resources

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
					i.region if sedvol0 == 0, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.region `controls' if sedvol0 == 0, ///
					cluster(ccode) partial(i.region)
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
					i.region if sedvol0 == 0, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.region `controls' if sedvol0 == 0, ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
					i.region if oil0 == 0, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls' if oil0 == 0, ///
					cluster(ccode) partial(i.region)
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
					i.region if oil0 == 0, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls' if oil0 == 0, ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
${main}5_output/tables/prio_int_armstrade_no0.tex, replace ///
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US arms' trade dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US arms' trade dummy" 1.thirdparty#c.x "Res. Value \(\times\) US arms' trade dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US arms' trade dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US arms' trade dummy" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US arms' trade}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US arms' trade dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US arms' trade dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US arms' trade}"' `"\qquad \emph{p-value: countries w/ US  arms' trade}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
	postfoot("\hline\hline \end{tabular}}")

	

	
* Table A11: impact of resources on conflict, no Australia

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
				ivreg2 `outcome' `independent' i.region if ccode != 900, cluster(ccode) partial(i.region)
				* Save geographic controls indicator
				estadd local geocontrols = "No"
			}
			else {
				ivreg2 `outcome' `independent' `controls' i.region if ccode != 900, cluster(ccode) partial(i.region)
				* Save geographic controls indicator
				estadd local geocontrols = "Yes"
			}
			
			* Save time controls indicators
			
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
 	stats(space space putest space gas coal continentfe geocontrols peak N, fmt(s s s s s s a2 a2) ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value}"' `" "' `"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' `"Continent FEs"' `"Geo Controls"' `"Peak"' `"\(N\)"')) ///
		mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
			postfoot("\hline\hline \end{tabular}}")	



		
* Table A12: WB resources and sedimentary basins, by contig bases (no australia)

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
					i.region if ccode != 900, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.region `controls' if ccode != 900, ///
					cluster(ccode) partial(i.region)
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
					i.region if ccode != 900, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.region `controls' if ccode != 900, ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
					i.region if ccode != 900, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls' if ccode != 900, ///
					cluster(ccode) partial(i.region)
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
					i.region if ccode != 900, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls' if ccode != 900, ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US troops dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US troops dummy" 1.thirdparty#c.x "Res. Value \(\times\) US troops dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US troops dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US troops dummy" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US troops}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US troops dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US troops dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US troops}"' `"\qquad \emph{p-value: countries w/ US troops}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
	postfoot("\hline\hline \end{tabular}}")

	
			
* Table A13: WB resources and sedimentary basins, by armstrade (no australia)

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
					i.region if ccode != 900, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.region `controls' if ccode != 900, ///
					cluster(ccode) partial(i.region)
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
					i.region if ccode != 900, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.region `controls' if ccode != 900, ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
					i.region if ccode != 900, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls' if ccode != 900, ///
					cluster(ccode) partial(i.region)
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
					i.region if ccode != 900, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls' if ccode != 900, ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US arms' trade dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US arms' trade dummy" 1.thirdparty#c.x "Res. Value \(\times\) US arms' trade dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US arms' trade dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US arms' trade dummy" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US arms' trade}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US arms' trade dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US arms' trade dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US arms' trade}"' `"\qquad \emph{p-value: countries w/ US  arms' trade}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
	postfoot("\hline\hline \end{tabular}}")

	

	
* Table A14: Conflict and all resources
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
				logit `outcome' `independent' i.region, cluster(ccode)
				* Save geographic controls indicator
				estadd local geocontrols = "No"
			}
			else {
				logit `outcome' `independent' `controls' i.region, cluster(ccode)
				* Save geographic controls indicator
				estadd local geocontrols = "Yes"
			}
			
			* Save time controls indicators
			
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
 	stats(continentfe geocontrols  peak N, fmt(s s a2 a2) ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"Continent FEs"' `"Geo Controls"' `"Peak"' `"\(N\)"')) ///
		mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
			postfoot("\hline\hline \end{tabular}}")	
		
	
			
* Table A15: WB resources and sedimentary basins, by UN affinity '65 (0 thresholds)

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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US UNGA affinity dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US UNGA affinity dummy" 1.thirdparty#c.x "Res. Value \(\times\) US UNGA affinity dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US UNGA affinity dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US UNGA affinity dummy" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols N, ///
	fmt(s s s %6.3f s %6.3f s s s s  s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US UNGA affinity}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US UNGA affinity dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US UNGA affinity dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US UNGA affinity}"' `"\qquad \emph{p-value: countries w/ US UNGA affinity}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
	postfoot("\hline\hline \end{tabular}}")


* Table A16: Resources and conflict, with third party presence
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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "Close to US" c.x#1.thirdparty ///
	"Res. Value \(\times\) Close to US" 1.thirdparty#c.x "Res. Value \(\times\) Close to US" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) Close to US" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) Close to US" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries close to US}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) Close to US}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) Close to US}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries close to US}"' `"\qquad \emph{p-value: countries close to US}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
	postfoot("\hline\hline \end{tabular}}")

	
	

	
est clear

preserve

use ${main}2_processed/data_regressions_panel.dta, replace
	
global outcome_list "conflict conflict2"
local controls "lnarea abslat elevavg elevstd temp precip lnpop14"
			
* Table A17: Conflict and resources, exposure design with prices	

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
			ivreg2 `outcome' c.sedvol#c.oil_price c.sedvol2#c.oil_price2  i.year i.ccode c.year#i.region, cluster(ccode) partial(i.year i.ccode)
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
keep(c.sedvol#c.oil_price c.sedvol2#c.oil_price2) ///
coeflabels(c.sedvol#c.oil_price  "Sed. Vol. \(\times\) Oil Price" c.sedvol2#c.oil_price2  "Sed. Vol.\(^2\) \(\times\) Oil Price\(^2\)") se ///
starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
 nobaselevels ///
 	stats(yearfe countryfe geocontrols  peak N, fmt(s s s a2 a2) ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"Year FEs"' `"Country FEs"' `"Regional trends"' `"Peak"' `"\(N\)"')) ///
		mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
			postfoot("\hline\hline \end{tabular}}")	

restore


	
preserve



use ${main}/2_processed/data_regressions_crossc62_99.dta, clear

gen thirdparty = .

* Table A18: WB resources and sedimentary basins, by contiguity to US bases

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
					net_exp_dummy i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.region net_exp_dummy `controls', ///
					cluster(ccode) partial(i.region)
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
					net_exp_dummy i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty  ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.region net_exp_dummy `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
					net_exp_dummy i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					net_exp_dummy i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					net_exp_dummy i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					net_exp_dummy i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
${main}5_output/tables/prio_int_bases_oilnet.tex, replace ///
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US troops dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US troops dummy" 1.thirdparty#c.x "Res. Value \(\times\) US troops dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US troops dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US troops dummy" oil "Oil" oil2 "Oil\(^2\)" net_exp_dummy "Net exporter") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US troops}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US troops dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US troops dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US troops}"' `"\qquad \emph{p-value: countries w/ US troops}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
	postfoot("\hline\hline \end{tabular}}")
	
			
* Table A19: WB resources and sedimentary basins, by US armstrade

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
					net_exp_dummy i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					net_exp_dummy i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					net_exp_dummy i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty  ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.region net_exp_dummy `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
					c.gas c.gas2 c.coal c.coal2 net_exp_dummy ///
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls' net_exp_dummy, ///
					cluster(ccode) partial(i.region)
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
					ivreg2 `outcome' c.x c.x#i.thirdparty  c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region net_exp_dummy, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region net_exp_dummy `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
${main}5_output/tables/prio_int_armstrade_oilnet.tex, replace ///
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US arms' trade dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US arms' trade dummy" 1.thirdparty#c.x "Res. Value \(\times\) US arms' trade dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US arms' trade dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US arms' trade dummy" oil "Oil" oil2 "Oil\(^2\)" net_exp_dummy "Net exporter") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US arms' trade}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US arms' trade dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US arms' trade dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US arms' trade}"' `"\qquad \emph{p-value: countries w/ US  arms' trade}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
	postfoot("\hline\hline \end{tabular}}")


restore




	
	
	



	
* Table: Conflict and resources, disaggregated resources, IV

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach outcome of varlist $outcome_list {
	forval i_con = 1/3 {
		local counter = `counter' + 1
		if (`i_con' == 1) {
			ivreg2 `outcome' (c.oil c.oil2 = c.sedvol c.sedvol2), first partial()
			* Save geographic controls indicator
			estadd local geocontrols = "No"
			estadd local continentfe = "No"
			
			cdsy, type(limlsize10) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
			estadd local limlsize10 =  scalar(`r(cv)')
			
			cdsy, type(limlsize15) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
			estadd local limlsize15 =  scalar(`r(cv)')
			
			cdsy, type(limlsize20) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
			estadd local limlsize20 =  scalar(`r(cv)')
			
			cdsy, type(limlsize25) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
			estadd local limlsize25 =  scalar(`r(cv)')
		}
		if (`i_con' == 2) {
			ivreg2 `outcome' (c.oil c.oil2 = c.sedvol c.sedvol2) i.region, first partial(i.region)
			* Save geographic controls indicator
			estadd local geocontrols = "No"
			estadd local continentfe = "Yes"
			
			cdsy, type(limlsize10) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
			estadd local limlsize10 =  scalar(`r(cv)')
			
			cdsy, type(limlsize15) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
			estadd local limlsize15 =  scalar(`r(cv)')
			
			cdsy, type(limlsize20) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
			estadd local limlsize20 =  scalar(`r(cv)')
			
			cdsy, type(limlsize25) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
			estadd local limlsize25 =  scalar(`r(cv)')
		}
		if (`i_con' == 3) {
			ivreg2 `outcome' (c.oil c.oil2 = c.sedvol c.sedvol2) `controls' i.region, first partial(i.region)
			* Save geographic controls indicator
			estadd local geocontrols = "Yes"
			estadd local continentfe = "Yes"
		
			cdsy, type(limlsize10) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
			estadd local limlsize10 =  scalar(`r(cv)')
			
			cdsy, type(limlsize15) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
			estadd local limlsize15 =  scalar(`r(cv)')
			
			cdsy, type(limlsize20) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
			estadd local limlsize20 =  scalar(`r(cv)')
			
			cdsy, type(limlsize25) k2(`e(exexog_ct)') nendog(`e(endog_ct)')
			estadd local limlsize25 =  scalar(`r(cv)')
		}
		
		* Save time controls indicators
		
		local Fstat: di %6.3f e(widstat)
		estadd local Fstat =  scalar(`Fstat') 
		
		* Save auxiliary indicator for esttab
		estadd local space = " "
		estadd scalar peak = -_b[c.oil]/(2*_b[c.oil2])
		
		* Test for inverse-U shaped relation
		utest oil oil2, quadratic

		if `r(p)' != . & _b[c.oil2] < 0 {
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
			local putest ="."
		}
				
		estadd local putest = "`putest'"
		
		est sto reg`counter'
	}

}

esttab reg1 reg2 reg3 reg4 reg5 reg6 using ///
${main}5_output/tables/prioallred_iv.tex, replace ///
coeflabels(oil "Oil Value" oil2 "Oil Value\(^2\)") se ///
starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
 nobaselevels noconstant ///
 mgroups("Resource Value: Oil pc" , ///
	pattern(1 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 drop(`controls' _cons) ///
 	stats(Fstat space limlsize10 limlsize15 limlsize20 limlsize25 space space putest space continentfe geocontrols    N, fmt(s s s s s s s s s s s  a2) ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}"  "\multicolumn{1}{c}{@}" )  ///
	labels(`"CD F-stat"' `" "'  `"Stock-Yogo crit. value (10\% max. IV size)"' `"Stock-Yogo crit. value (15\% max. IV size)"' `"Stock-Yogo crit. value (20\% max. IV size)"' `"Stock-Yogo crit. value (25\% max. IV size)"' `" "' `"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value}"' `" "' `"Continent FEs"'  `"Geo Controls"'  `"\(N\)"')) ///
		mtitles("Conf." "Conf." "Conf.""War" "War" "War") ///
			postfoot("\hline\hline \end{tabular}}")	
	
est sto clear


* Table: WB resources and sedimentary basins, by contiguity to US bases, controlling for military expenditure

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
					c.milexpc c.milexpc2  i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.milexpc c.milexpc2  i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					c.milexpc c.milexpc2  i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty c.milexpc c.milexpc2  i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
					c.gas c.gas2 c.coal c.coal2 c.milexpc c.milexpc2  ///
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 c.milexpc c.milexpc2 ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					c.gas c.gas2 c.coal c.coal2 c.milexpc c.milexpc2  ///
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 c.milexpc c.milexpc2  ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
${main}5_output/tables/prio_int_bases_milexpc2.tex, replace ///
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US troops dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US troops dummy" 1.thirdparty#c.x "Res. Value \(\times\) US troops dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US troops dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US troops dummy" oil "Oil" oil2 "Oil\(^2\)" milexpc  "Military expenditure" milexpc2  "Military expenditure\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US troops}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US troops dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US troops dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US troops}"' `"\qquad \emph{p-value: countries w/ US troops}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
	postfoot("\hline\hline \end{tabular}}")



	
			
* Table: WB resources and sedimentary basins, by US armstrade, controlling for military expenditure

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
					c.milexpc c.milexpc2  i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.milexpc c.milexpc2  i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					c.milexpc c.milexpc2  i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty c.milexpc c.milexpc2  i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
					c.gas c.gas2 c.coal c.coal2 c.milexpc c.milexpc2  ///
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 c.milexpc c.milexpc2 ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					c.gas c.gas2 c.coal c.coal2 c.milexpc c.milexpc2  ///
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 c.milexpc c.milexpc2  ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
${main}5_output/tables/prio_int_armstrade_milexpc2.tex, replace ///
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US arms' trade dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US arms' trade dummy" 1.thirdparty#c.x "Res. Value \(\times\) US arms' trade dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US arms' trade dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US arms' trade dummy" oil "Oil" oil2 "Oil\(^2\)" milexpc "Military expenditure" milexpc2 "Military expenditure\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US arms' trade}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US arms' trade dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US arms' trade dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US arms' trade}"' `"\qquad \emph{p-value: countries w/ US  arms' trade}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
	postfoot("\hline\hline \end{tabular}}")

	
* Table: WB resources and sedimentary basins, by contiguity to US bases, controlling for military expenditure

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
					c.milexpc c.milexpc#i.thirdparty  i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.milexpc c.milexpc#i.thirdparty  i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					c.milexpc c.milexpc#i.thirdparty  i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty c.milexpc c.milexpc#i.thirdparty  i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
					c.gas c.gas2 c.coal c.coal2 c.milexpc c.milexpc#i.thirdparty  ///
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 c.milexpc c.milexpc#i.thirdparty ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					c.gas c.gas2 c.coal c.coal2 c.milexpc c.milexpc#i.thirdparty  ///
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 c.milexpc c.milexpc#i.thirdparty  ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
${main}5_output/tables/prio_int_bases_milexpc_int.tex, replace ///
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US troops dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US troops dummy" 1.thirdparty#c.x "Res. Value \(\times\) US troops dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US troops dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US troops dummy" oil "Oil" oil2 "Oil\(^2\)" milexpc  "Military expenditure" c.milexpc#1.thirdparty  "Military expenditure\(*\) US troops dummy") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US troops}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US troops dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US troops dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US troops}"' `"\qquad \emph{p-value: countries w/ US troops}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
	postfoot("\hline\hline \end{tabular}}")

	

	
			
* Table: WB resources and sedimentary basins, by US armstrade, controlling for military expenditure

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
					c.milexpc c.milexpc#i.thirdparty  i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.milexpc c.milexpc#i.thirdparty  i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					c.milexpc c.milexpc#i.thirdparty  i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty c.milexpc c.milexpc#i.thirdparty  i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
					c.gas c.gas2 c.coal c.coal2 c.milexpc c.milexpc#i.thirdparty  ///
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 c.milexpc c.milexpc#i.thirdparty ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
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
					c.gas c.gas2 c.coal c.coal2 c.milexpc c.milexpc#i.thirdparty  ///
					i.region, cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 c.milexpc c.milexpc#i.thirdparty  ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
${main}5_output/tables/prio_int_armstrade_milexpc_int.tex, replace ///
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US arms' trade dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US arms' trade dummy" 1.thirdparty#c.x "Res. Value \(\times\) US arms' trade dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US arms' trade dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US arms' trade dummy" oil "Oil" oil2 "Oil\(^2\)" milexpc "Military expenditure" c.milexpc#1.thirdparty "Military expenditure \(*\) US arms' trade dummy") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US arms' trade}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US arms' trade dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US arms' trade dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US arms' trade}"' `"\qquad \emph{p-value: countries w/ US  arms' trade}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
	postfoot("\hline\hline \end{tabular}}")


	


* Table: WB resources and sedimentary basins, by contiguity to US bases

global thirdparty_list "contig50bases750 contig50bases1250 contig50bases1500 contig50bases1750"
local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		forval i_indep = 1/2 {
				local counter = `counter' + 1
				
				* Test for inverse-U shaped relation with interaction
				if (`i_indep' == 1) {
					gen x = oil
					gen x2 = oil2
					
					ivreg2 conflict2 c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					
				}
				else {
					gen x = sedvol
					gen x2 = sedvol2
					
					ivreg2 conflict2 c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)

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
				
				
				if (`i_indep' == 1) {
					ivreg2 conflict2 c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					
					estadd local gascoal = "Yes"
					estadd local gascoalsq = "Yes"
					
				}
				else {	
					ivreg2 conflict2 c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					
					estadd local gascoal = "No"
					estadd local gascoalsq = "No"

				}
				
				estadd local geocontrols = "Yes"
				* Save time controls indicators
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
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				sum thirdparty
				local avgbases : di %6.3f scalar(`r(mean)')
				estadd local avgbases "`avgbases'"
				
				est sto reg`counter'
				drop x x2
			
		}
}


esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8  using ///
${main}5_output/tables/prio_int_bases_dist_c2.tex, replace ///
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US troops dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US troops dummy" 1.thirdparty#c.x "Res. Value \(\times\) US troops dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US troops dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US troops dummy" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Thr. 750KM" "Thr. 1250KM" "Thr. 1500KM" "Thr. 1750KM" , ///
	pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols avgbases N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s s s  a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US troops}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US troops dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US troops dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US troops}"' `"\qquad \emph{p-value: countries w/ US troops}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\% w/ bases"'  `"\(N\)"')) ///
	mtitles("Oil" "Sed. Bas." "Oil" "Sed. Bas." "Oil" "Sed. Bas." "Oil" "Sed. Bas." "Oil" "Sed. Bas.") ///
	postfoot("\hline\hline \end{tabular}}")


	
* Table: WB resources and sedimentary basins, by contiguity to US bases

global thirdparty_list "contig50bases500"
local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		forval i_indep = 1/2 {
				local counter = `counter' + 1
				
				* Test for inverse-U shaped relation with interaction
				if (`i_indep' == 1) {
					gen x = oil
					gen x2 = oil2
					
					ivreg2 conflict c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					
				}
				else {
					gen x = sedvol
					gen x2 = sedvol2
					
					ivreg2 conflict c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)

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
				
				
				if (`i_indep' == 1) {
					ivreg2 conflict c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					
					estadd local gascoal = "Yes"
					estadd local gascoalsq = "Yes"
					
				}
				else {	
					ivreg2 conflict c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					i.region `controls', ///
					cluster(ccode) partial(i.region)
					
					estadd local gascoal = "No"
					estadd local gascoalsq = "No"

				}
				
				estadd local geocontrols = "Yes"
				* Save time controls indicators
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
				
				estadd local space = " "
				estadd local thirdpartyfe = "Yes"
				
				sum thirdparty
				local avgbases : di %6.3f scalar(`r(mean)')
				estadd local avgbases "`avgbases'"
				
				est sto reg`counter'
				drop x x2
			
		}
}


esttab reg1 reg2 using ///
${main}5_output/tables/prio_int_bases_dist500.tex, replace ///
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US troops dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US troops dummy" 1.thirdparty#c.x "Res. Value \(\times\) US troops dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US troops dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US troops dummy" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Thr. 500KM" , ///
	pattern(1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols avgbases N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s s s  a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US troops}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US troops dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US troops dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US troops}"' `"\qquad \emph{p-value: countries w/ US troops}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\% w/ bases"'  `"\(N\)"')) ///
	mtitles("Oil" "Sed. Bas." "Oil" "Sed. Bas." "Oil" "Sed. Bas." "Oil" "Sed. Bas." "Oil" "Sed. Bas.") ///
	postfoot("\hline\hline \end{tabular}}")


clear

use ${main}2_processed/data_interventions_crossc.dta, replace

local controls "lnarea  abslat elevavg elevstd temp precip lnpop14"

gen thirdparty = .
la var thirdparty "US influence"

global thirdparty_list "contig50bases"
global outcome_list "conflict conflict2"




clear

use ${main}2_processed/data_interventions_crossc.dta, replace
local controls "lnarea  abslat elevavg elevstd temp precip lnpop14"

gen thirdparty = .

	
global thirdparty_list "contig50bases"
global outcome_list "conflict conflict2"


* Table : WB resources and sedimentary basins, by contiguity to US bases, Controlling for Military Expenditure

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
					i.region i.mili_intervention_all `controls', cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.region `controls' i.mili_intervention_all c.x#i.mili_intervention_all  c.x2#i.mili_intervention_all, ///
					cluster(ccode) partial(i.region)
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
					i.region i.mili_intervention_all `controls', cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.mili_intervention_all i.region `controls' c.x#i.mili_intervention_all  c.x2#i.mili_intervention_all, ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
					c.gas c.gas2 c.coal c.coal2 i.mili_intervention_all ///
					i.region `controls', cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 i.mili_intervention_all ///
					i.region `controls' c.x#i.mili_intervention_all  c.x2#i.mili_intervention_all, ///
					cluster(ccode) partial(i.region)
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
					c.gas c.gas2 c.coal c.coal2 i.mili_intervention_all ///
					i.region `controls', cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 i.mili_intervention_all ///
					i.region `controls' c.x#i.mili_intervention_all  c.x2#i.mili_intervention_all, ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
${main}5_output/tables/prio_int_bases_interv_all.tex, replace ///
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US troops dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US troops dummy" 1.thirdparty#c.x "Res. Value \(\times\) US troops dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US troops dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US troops dummy" oil "Oil" oil2 "Oil\(^2\)" 1.mili_intervention_all "US or USSR intervention" 1.mili_intervention_all#c.x "Res. Value \(\times\) US or USSR Intervention" 1.mili_intervention_all#c.x2 "Res. Value\(^2\) \(\times\) US or USSR Intervention") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US troops}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US troops dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US troops dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US troops}"' `"\qquad \emph{p-value: countries w/ US troops}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
	postfoot("\hline\hline \end{tabular}}")
	
			
* Table: WB resources and sedimentary basins, by US armstrade

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
					i.region i.mili_intervention_all `controls', cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					i.region `controls' i.mili_intervention_all c.x#i.mili_intervention_all  c.x2#i.mili_intervention_all, ///
					cluster(ccode) partial(i.region)
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
					i.region i.mili_intervention_all `controls', cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty ///
					c.x2 c.x2#i.thirdparty i.thirdparty i.region i.mili_intervention_all `controls' c.x#i.mili_intervention_all  c.x2#i.mili_intervention_all, ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
					i.region i.mili_intervention_all `controls', cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				else {
					ivreg2 `outcome' c.x c.x#0.thirdparty c.x2 c.x2#0.thirdparty 0.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region `controls' i.mili_intervention_all c.x#i.mili_intervention_all  c.x2#i.mili_intervention_all, ///
					cluster(ccode) partial(i.region)
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
					i.region i.mili_intervention_all `controls', cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				else {
					ivreg2 `outcome' c.x c.x#i.thirdparty c.x2 c.x2#i.thirdparty i.thirdparty ///
					c.gas c.gas2 c.coal c.coal2 ///
					i.region i.mili_intervention_all `controls' c.x#i.mili_intervention_all  c.x2#i.mili_intervention_all, ///
					cluster(ccode) partial(i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "Yes"
				}
				
				* Save time controls indicators
				
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
${main}5_output/tables/prio_int_armstrade_interv_all.tex, replace ///
 drop(`controls'  ///
	gas gas2 coal coal2) /// 
	coeflabels(x "Res. Value" x2 "Res. Value\(^2\)" 1.thirdparty "US arms' trade dummy" c.x#1.thirdparty ///
	"Res. Value \(\times\) US arms' trade dummy" 1.thirdparty#c.x "Res. Value \(\times\) US arms' trade dummy" ///
	1.thirdparty#c.x2 "Res. Value\(^2\) \(\times\) US arms' trade dummy" c.x2#1.thirdparty ///
	"Res. Value\(^2\) \(\times\) US arms' trade dummy" oil "Oil" oil2 "Oil\(^2\)" 1.mili_intervention_all "US or USSR intervention" 1.mili_intervention_all#c.x "Res. Value \(\times\) US or USSR Intervention" 1.mili_intervention_all#c.x2 "Res. Value\(^2\) \(\times\) US or USSR Intervention") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Resource Value: Oil pc" "Resource Value: Sedimentary basins" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space space putest putestint space gascoal gascoalsq continentfe geocontrols N, ///
	fmt(s s s %6.3f s %6.3f s s s s s  s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`" "' `"\emph{Countries with US arms' trade}"' ///
	`"\qquad \emph{Res. Value \(+\) Res. Value \(\times\) US arms' trade dummy}"' 	`"\qquad \emph{p-value}"' `"\qquad \emph{Res. Value\(^2\) \(+\) Res. Value\(^2\) \(\times\) US arms' trade dummy}"'`"\qquad \emph{p-value}"' `" "' ///
	`"\emph{H0: No inv.-U shape \cite{lind2010or}}"' `"\qquad \emph{p-value: countries w/o US arms' trade}"' `"\qquad \emph{p-value: countries w/ US  arms' trade}"' `" "' ///
	`"Gas, Gas\(^2\)"' `"Coal, Coal\(^2\)"' ///
	`"Continent FEs"' `"Geo Controls"' `"\(N\)"')) ///
	mtitles("Conf." "Conf." "War" "War" "Conf." "Conf." "War" "War") ///
	postfoot("\hline\hline \end{tabular}}")


********* Distributions

use ${main}2_processed/data_regressions_crossc.dta, clear

histogram oil, percent ytitle(Percentage of countries) by(, note(, color(none) nobox))  by(armstrade1950, ) graphregion(color(white))  bin(10)
graph export ${main}5_output/figures/oilarms.png, replace

histogram oil, percent ytitle(Percentage of countries) by(, note(, color(none) nobox))  by(contig50bases, ) graphregion(color(white))  bin(10)
graph export ${main}5_output/figures/oilbases.png, replace

histogram sedvol, percent ytitle(Percentage of countries) by(, note(, color(none) nobox))  by(armstrade1950, ) graphregion(color(white))  bin(10)
graph export ${main}5_output/figures/sedvolarms.png, replace

histogram sedvol, percent ytitle(Percentage of countries) by(, note(, color(none) nobox))  by(contig50bases, ) graphregion(color(white)) bin(10)
graph export ${main}5_output/figures/sedvolbases.png, replace


********* Maps

* Figure 1a
use ${main}2_processed/data_regressions_crossc.dta, clear
kountry ccode, from(cown) to(iso3c)
rename _ISO3C_ ISO_A3
merge m:m ISO_A3 using  ${main}1_data/maps_utilities/worlddata_cleaned.dta
duplicates drop ISO_A3, force
spmap oil using ${main}1_data/maps_utilities/worldcoor.dta, id(id) fcolor(Greens2)
graph export ${main}5_output/figures/oil.png, replace

* Figure 1b
use ${main}2_processed/data_regressions_crossc.dta, clear
kountry ccode, from(cown) to(iso3c)
rename _ISO3C_ ISO_A3
merge m:m ISO_A3 using  ${main}1_data/maps_utilities/worlddata_cleaned.dta
duplicates drop ISO_A3, force
spmap sedvol using ${main}1_data/maps_utilities/worldcoor.dta, id(id) fcolor(Greens2)
graph export ${main}5_output/figures/sedvol.png, replace

* Figure 1c
use ${main}2_processed/data_regressions_crossc.dta, clear
kountry ccode, from(cown) to(iso3c)
rename _ISO3C_ ISO_A3
merge m:m ISO_A3 using  ${main}1_data/maps_utilities/worlddata_cleaned.dta
duplicates drop ISO_A3, force
spmap contig50bases using ${main}1_data/maps_utilities/worldcoor.dta, id(id) fcolor(Greens2)
graph export ${main}5_output/figures/bases50.png, replace

* Figure 1d
use ${main}2_processed/data_regressions_crossc.dta, clear
kountry ccode, from(cown) to(iso3c)
rename _ISO3C_ ISO_A3
merge m:m ISO_A3 using  ${main}1_data/maps_utilities/worlddata_cleaned.dta
duplicates drop ISO_A3, force
spmap armstrade1950 using ${main}1_data/maps_utilities/worldcoor.dta, id(id) fcolor(Greens2)
graph export ${main}5_output/figures/armstrade1950.png, replace

* Figure 2
use ${main}2_processed/data_regressions_crossc.dta, clear
kountry ccode, from(cown) to(iso3c)
rename _ISO3C_ ISO_A3
merge m:m ISO_A3 using  ${main}1_data/maps_utilities/worlddata_cleaned.dta
duplicates drop ISO_A3, force
spmap conf_years using ${main}1_data/maps_utilities/worldcoor.dta, id(id) fcolor(Greens2)
graph export ${main}5_output/figures/conflict_years.png, replace


	

