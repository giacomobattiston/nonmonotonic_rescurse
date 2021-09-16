
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
drop v*

* Luxemburg and Belgium are put together in distances dataset: sum arms trade
qui sum armstrade if country == "Luxembourg"
replace armstrade = armstrade + `r(mean)' if country == "Belgium and Luxembourg"
drop if country == "Luxembourg"

* So are Serbia and Montenengro: sum arms trade
qui sum armstrade if country == "Montenegro"
replace armstrade = armstrade + `r(mean)' if country == "Serbia and Montenegro"
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

keep ccode dist_arms armstrade
keep if !missing(ccode) &  !missing(dist)
replace armstrade = 0 if missing(armstrade)
save ${main}2_processed/dist_arms.dta, replace

clear

****************************ARMS' IMPORTS FROM UKRAINE***************************

* Construct the dataset on arms' imports from Ukraine
import delimited ${main}1_data/sipri_tiv/TIV-Export-UKR-1950-2019_noheader.csv, /// 
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
replace country = "Russian Federation" if country == "Russia"
replace country = "Macedonia (the former Yugoslav Rep. of)" if country == "North Macedonia"
replace country = "United States of America" if country == "United States"

* armstrade will store overall quantity of armstrade from the US 1950-99
gen armstrade_ukr = 0

* Sum over arms trade from 1950 to 99 (each v is a year)
foreach var of varlist v* {
	destring `var', replace
	replace `var' = 0 if `var' == .
	replace armstrade_ukr = armstrade_ukr + `var'
}
drop v*

* Merge Sudan
qui sum armstrade if country == "South Sudan"
replace armstrade = armstrade + `r(mean)' if country == "Sudan"
drop if country == "South Sudan"

* armstrade dummy
gen armstrade_dummy_ukr = 1 if armstrade_ukr > 0
keep if armstrade_dummy_ukr == 1

save ${main}2_processed/arms_trade_UKR.dta, replace

clear
* Now start constructing the final data. Import distances
import excel ${main}1_data/geodist/dist_cepii.xls, sheet("dist_cepii") firstrow

* Merge with country names
rename iso_d id_country
merge m:1 id_country using ${main}2_processed/country_names.dta
rename _merge _merge1

* Use country names to merge with arms_trade
merge m:1 country using ${main}2_processed/arms_trade_UKR.dta
rename id_country iso_d 

* In this long data, keep only couples where destination has arms trade
keep if armstrade_dummy == 1
keep dist iso_o iso_d 
rename dist dist_arms_ukr
drop if missing(iso_o)

* Take minimum distance from base for each origin
collapse (min) dist_arms_ukr, by(iso_o)

* Use the same procedure above to merge with arms trade in millions
rename iso_o id_country
merge m:1 id_country using ${main}2_processed/country_names.dta
rename _merge _merge3
merge m:1 country using ${main}2_processed/arms_trade_UKR.dta
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

keep ccode dist_arms_ukr armstrade_ukr
keep if !missing(ccode) &  !missing(dist)
replace armstrade_ukr = 0 if missing(armstrade_ukr)
save ${main}2_processed/dist_arms_UKR.dta, replace

**********************Department of Defence Personnel***************************
* all personell
clear
* Import data on DoD personnel by country
import excel ${main}1_data/dmdc/dmdc_2014.xlsx,  firstrow

* Drop Unkownn or US territories
drop if country == "Unknown"
drop if country == "Virgin Islands, U.S."
drop if country == "American Samoa"
drop if country == "British Indian Ocean Territory"
drop if country == "Guam"

* Rename countries to adjust inconsistencies with geodist
replace country = "Korea" if country == "Korea, South"
replace country = "Belgium and Luxemburg" if country == "Belgium"
replace country = "Serbia and Montenegro" if country == "Kosovo"

* Generate a dummy for there being personnel at all
drop if personnel == .
gen base_dummy = 1

save ${main}2_processed/dmdc_2014.dta, replace

drop if personnel < 1000
save ${main}2_processed/dmdc_2014_1000.dta, replace


****CONTIGUITY BASES

clear
* Now start constructing the final data. Import distances
import excel ${main}1_data/geodist/dist_cepii.xls, sheet("dist_cepii") firstrow

* Countries are contiguous to themselves
replace contig = 1 if iso_o == iso_d

* Merge with country names
rename iso_d id_country
merge m:1 id_country using ${main}2_processed/country_names.dta
rename _merge _merge1

* Use country names to merge with arms_trade
merge m:1 country using ${main}2_processed/dmdc_2014_1000.dta
rename id_country iso_d 

* In this long data, keep only couples where destination has arms trade
keep if base_dummy == 1
keep contig iso_o iso_d 
rename contig contig_bases1000
drop if missing(iso_o)

* Take minimum distance from base for each origin
collapse (max) contig_bases1000, by(iso_o)

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

keep ccode contig_bases1000
keep if !missing(ccode) &  !missing(contig_bases1000)
save ${main}2_processed/contig_bases1000.dta, replace


****CONTIGUITY BASES 1950

clear
* Now start constructing the final data. Import distances
import excel ${main}1_data/geodist/dist_cepii.xls, sheet("dist_cepii") firstrow

* Countries are contiguous to themselves
replace contig = 1 if iso_o == iso_d

*max km distance traveled in a day by US troops
*321.869


*try with distances
replace contig = dist < 321.869
*replace contig = dist < 5000

* Merge with country names
rename iso_d id_country
merge m:1 id_country using ${main}2_processed/country_names.dta
rename _merge _merge1

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

stop
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




