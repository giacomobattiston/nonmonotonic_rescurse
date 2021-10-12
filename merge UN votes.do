* Import UN voting data and save cleaning version
clear all

use ${main}1_data\UN_votes\affinity_01242010.dta,clear

* we are interested with affinity with USA, ccode 2
keep if ccodea==2

sort ccodeb year 

* we gen an average affinity based on votes between 1946-1955, as average of the S index presented in Gartzke
drop if year>1955
by ccodeb: egen avg_affinity=mean(s2un4608i)

*keeping one record per country
by ccodeb: gen rank=_n
drop if rank>1

*keeping only the useful variables
keep ccodeb avg_affinity
rename ccodeb ccode

save ${main}2_processed\US_affinity.dta,replace


