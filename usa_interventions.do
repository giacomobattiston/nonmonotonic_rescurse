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
*replace vietnam with same number we use in other dataset
replace ccode=816 if ccode==817
sort ccode year
save ${main}2_processed/US_interventions.dta,replace


**merging this database with our main one

use ${main}2_processed\data_regressions_panel.dta,clear
sort ccode year
merge 1:1 ccode year using ${main}2_processed/US_interventions.dta

*there are 248 "interventions" (year and country) that we do not classify as conflicts in our database
/*
they are: 
1)Cuba 58-59  (no resources wB)
2)UK 69-99(???, powerful country)
3)Yugoslavia 91 (non c'è più la yugoslavia)
4)Bosnia 92-95 (no resources WB)
5)Greece 45 (abbiamo il 1945?)
6)Cyprus 74 (no resources)
7)Russia 94-99 (powerful)
8)Guinea-Bissau 98-99 (no resources)
9)Somalia 81-99 (no resources)
10)Angola 75-99 (no resources)
11)Algeria (no resources)
12)Sudan 63-99 (no resources)
13)Iran 78-93 (no resources)
14)Yemen 62-69 (no resources)
15)679(?which country?yemen?) 94 (no resources)
16)Yemen 86-87  (no resources)
17)Afghanistan 78-99 (no resources)
18)China (powerful)
19)Myanmar (no resources)
*/
drop if _merge==2
g us_interv=0
replace us_interv=1 if _merge==3
drop _merge
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



