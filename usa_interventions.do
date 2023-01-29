clear all
set more off

if "`c(username)'" == "giacomobattiston" { 
        cd "/Users/giacomobattiston/"
        global main "Dropbox/ricerca_dropbox/bbf/technology_conflict/"
		global git "Documents/GitHub/technology_conflict/"
}
else {
	cd "C:\Users\ricfr\Documents\GitHub\technology_conflict"
	global main "C:\Users\ricfr\Dropbox\bbf\technology_conflict\"
}



**creating database of USA interventions
use ${main}1_data\Koga\KOGA_ISQ2011.dta,clear
keep if ccode2==2
keep ccode1 year
rename ccode1 ccode
sort ccode year
save ${main}2_processed/US_interventions.dta,replace


**merging this database with our main one

use ${main}2_processed\data_regressions_panel.dta,clear
sort ccode year
merge 1:1 ccode year using ${main}2_processed/US_interventions.dta

*there are 264 "interventions" (year and country) that we do not classify as conflicts in our database (maybe we should look later) i drop them
drop if _merge==2
g us_interv=0
replace us_interv=1 if _merge==3

*us_interv is a dummy that takes 1 if US intervened in the country in that year, we should re-run the regressions with this dummy

*show the endogeneity
reg us_inter oil
*interestingly negative
reg us_inter oil i.year
reg us_inter oil i.year lnarea  abslat elevavg elevstd temp precip lnpop14

reg us_interv sedvol
*interestingly positive!
reg us_interv sedvol i.year
reg us_inter sedvol i.year lnarea abslat elevavg elevstd temp precip lnpop14
*becomes negative with the controls, in particular the area



