
*ssc install spmap
*ssc install shp2dta
*ssc install mif2dta


if "`c(username)'" == "giacomobattiston" { 
        cd "/Users/giacomobattiston/"
        global main "Dropbox/ricerca_dropbox/bbf/technology_conflict/"
		global git "Documents/GitHub/technology_conflict/"
}
else {
	cd "C:\Users\Franceschin\Documents\GitHub\technology_conflict"
	global main "C:\Users\Franceschin\Dropbox\bbf\technology_conflict\"
}
