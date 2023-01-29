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
sort ccode1 year
save ${main}2_processed/US_interventions.dta,replace


**merging this database with our main one

