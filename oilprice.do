* Import price deflator data and save as dta
clear all

import delimited ${main}1_data\fred\GDPDEF.csv,clear

* Clean date variable
gen date_aux=date(date,"YMD")
gen year=year(date_aux)

* Turn into yearly dataset
collapse (mean) gdpdef, by (year)

save ${main}2_processed\deflator.dta, replace


clear all

import delimited ${main}1_data\fred\WTISPLC.csv,clear

* Clean date variable
gen date_aux=date(date,"YMD")
gen year=year(date_aux)

* Turn into yearly dataset
collapse (mean) wtisplc, by (year)

* Merge deflator data
merge 1:1 year using ${main}2_processed\deflator.dta

rename wtisplc oil_price
replace oil_price = oil_price/gdpdef
gen oil_price2 = oil_price^2

keep year gdpdef oil_price oil_price2

save ${main}2_processed\oilprice.dta,replace


