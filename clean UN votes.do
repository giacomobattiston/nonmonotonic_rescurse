* Import UN voting data and save cleaning version
clear all

global main "C:\Users\ricfr\Dropbox\bbf\technology_conflict\"


use ${main}1_data\UN_votes\affinity_01242010.dta,clear

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

*affinity based on 3 possible votes
by ccodeb: egen avg_affinity99_3=mean(s3un4608i)
bysort ccodeb less1956: egen avg_affinity55_3=mean(s3un4608i)
bysort ccodeb less1960: egen avg_affinity59_3=mean(s3un4608i)
bysort ccodeb less1966: egen avg_affinity65_3=mean(s3un4608i)

*affinity based on 2 possible votes

by ccodeb: egen avg_affinity99=mean(s2un4608i)
bysort ccodeb less1956: egen avg_affinity55=mean(s2un4608i)
bysort ccodeb less1960: egen avg_affinity59=mean(s2un4608i)
bysort ccodeb less1966: egen avg_affinity65=mean(s2un4608i)

*keeping one record per country
sort ccodeb year
bysort ccodeb: gen rank=_n
drop if rank>1
replace avg_affinity59=. if year>1959
replace avg_affinity55=. if year>1955
replace avg_affinity65=. if year>1965

replace avg_affinity59_3=. if year>1959
replace avg_affinity55_3=. if year>1955
replace avg_affinity65_3=. if year>1965

*keeping only the useful variables
keep ccodeb avg_affinity*
rename ccodeb ccode

save ${main}2_processed\US_affinity.dta,replace


