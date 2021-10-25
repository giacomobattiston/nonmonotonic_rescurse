* Import UN voting data and save cleaning version
clear all


global main "C:\Users\ricfr\Dropbox\bbf\technology_conflict\"

use ${main}2_processed\data_regressions.dta,clear

merge m:1 ccode using ${main}2_processed\US_affinity.dta

* many countries not existent in that period, so no data with respect to US affinity
*create dummies for proximity to US in terms of UN votes
qui sum avg_affinity55, detail
gen affinity90 = avg_affinity55 >  `r(p90)' if !missing(avg_affinity55)
gen affinity50 = avg_affinity55 >  `r(p50)' if !missing(avg_affinity55)
gen affinity_avg = avg_affinity55 >  `r(mean)' if !missing(avg_affinity55)
la var affinity50 "voting affinity with US above median"
la var affinity90 "voting affinity with US above the 90th percentile"
la var affinity_avg "voting affinity with US above the average"

qui sum avg_affinity59, detail
gen affinity90_60 = avg_affinity59 >  `r(p90)' if !missing(avg_affinity59)
gen affinity50_60 = avg_affinity59 >  `r(p50)' if !missing(avg_affinity59)
gen affinity_avg_60 = avg_affinity59 >  `r(mean)' if !missing(avg_affinity59)
la var affinity50_60 "voting affinity with US above median"
la var affinity90_60 "voting affinity with US above the 90th percentile"
la var affinity_avg_60 "voting affinity with US above the average"

qui sum avg_affinity65, detail

*same using votes until 1965
gen affinity90_65 = avg_affinity65 >  `r(p90)' if !missing(avg_affinity65)
gen affinity50_65 = avg_affinity65 >  `r(p50)' if !missing(avg_affinity65)
gen affinity_avg_65 = avg_affinity65 >  `r(mean)' if !missing(avg_affinity65)
la var affinity50_65 "voting affinity with US above median, until 1965"
la var affinity90_65 "voting affinity with US above the 90th percentile, until 1965"
la var affinity_avg_65 "voting affinity with US above the average, until 1965"

qui sum avg_affinity99, detail

*same using votes until 1999
gen affinity90_99 = avg_affinity99 >  `r(p90)' if !missing(avg_affinity99)
gen affinity50_99 = avg_affinity99 >  `r(p50)' if !missing(avg_affinity99)
gen affinity_avg_99 = avg_affinity99 >  `r(mean)' if !missing(avg_affinity99)
la var affinity50_99 "voting affinity with US above median, until 1999"
la var affinity90_99 "voting affinity with US above the 90th percentile, until 1999"
la var affinity_avg_99 "voting affinity with US above the average, until 1999"


gen thirdparty=.
*replace 0 if missing
replace affinity50=0 if affinity50==.
replace affinity90=0 if affinity90==.
replace affinity_avg=0 if affinity_avg==.

replace affinity50_65=0 if affinity50_65==.
replace affinity90_65=0 if affinity90_65==.
replace affinity_avg_65=0 if affinity_avg_65==.

replace affinity50_99=0 if affinity50_99==.
replace affinity90_99=0 if affinity90_99==.
replace affinity_avg_99=0 if affinity_avg_99==.

replace affinity50_60=0 if affinity50_60==.
replace affinity90_60=0 if affinity90_60==.
replace affinity_avg_60=0 if affinity_avg_60==.


* Sedimentary bases presence and conflict, with third party presence
* affinity50

global thirdparty_list "affinity50 affinity90 affinity50_65 affinity90_65 affinity50_99"

global thirdparty_list "affinity_avg affinity_avg_65 affinity_avg_99"


global thirdparty_list " affinity50_60 affinity90_60 affinity_avg_60"

global outcome_list "conflict conflict2"
local controls "lnarea  abslat elevavg elevstd temp precip lnpop14  "
			

local counter 0

* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.sedvol c.sedvol#i.thirdparty c.sedvol2 ///
					c.sedvol2#i.thirdparty i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.sedvol c.sedvol#i.thirdparty ///
					c.sedvol2 c.sedvol2#i.thirdparty i.thirdparty i.year i.region `controls', ///
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
				local  b1 = _b[c.sedvol] + _b[c.sedvol#1.thirdparty]
				qui lincom c.sedvol + c.sedvol#1.thirdparty
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
				local  b2 = _b[c.sedvol2] + _b[c.sedvol2#1.thirdparty]
				qui lincom c.sedvol2 + c.sedvol2#1.thirdparty
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
				
				est sto reg`counter'
			}

}
}

esttab reg1 reg2 reg3 reg4 using ///
	${main}5_output/tables/prio_sedint_affinity_50_60.tex, replace ///
	drop(`controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	
		esttab reg5 reg6 reg7 reg8 using ///
	${main}5_output/tables/prio_sedint_affinity_90_60.tex, replace ///
	drop(`controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	
		esttab reg9 reg10 reg11 reg12 using ///
	${main}5_output/tables/prio_sedint_affinity_avg_60.tex, replace ///
	drop(`controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	



esttab reg1 reg2 reg3 reg4 using ///
	${main}5_output/tables/prio_sedint_affinity50.tex, replace ///
	drop(`controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	esttab reg5 reg6 reg7 reg8 using ///
	${main}5_output/tables/prio_sedint_affinity90.tex, replace ///
	drop(`controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	*votes until 1965
	esttab reg9 reg10 reg11 reg12 using ///
	${main}5_output/tables/prio_sedint_affinity50_65.tex, replace ///
	drop(`controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	esttab reg13 reg14 reg15 reg16 using ///
	${main}5_output/tables/prio_sedint_affinity90_65.tex, replace ///
	drop(`controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	
	*votes until 1999
	esttab reg17 reg18 reg19 reg20 using ///
	${main}5_output/tables/prio_sedint_affinity50_99.tex, replace ///
	drop(`controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	esttab reg21 reg22 reg23 reg24 using ///
	${main}5_output/tables/prio_sedint_affinity90_99.tex, replace ///
	drop(`controls') coeflabels(1.thirdparty "Third Party Presence" ///
	c.sedvol#1.thirdparty "Sed. Vol. X Third Party" 1.thirdparty#c.sedvol ///
	"Sed. Vol. X Third Party" 1.thirdparty#c.sedvol2 ///
	"Sed. Vol.\(^2\) X Third Party" c.sedvol2#1.thirdparty ///
	"Sed. Vol.\(^2\) X Third Party" sedvol "Sed. Vol." sedvol2 "Sed. Vol.\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"'  `"\qquad Sed. Vol."' 	`"\qquad p-value"' `"\qquad Sed. Vol.\(^2\)"'`"\qquad p-value"'  `" "' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
* WB resources presence and conflict, with third party presence
* affinity50

local counter 0
global thirdparty_list "affinity50 affinity50_65 affinity50_99"

global thirdparty_list "affinity_avg_60 affinity50_60 affinity90_60"


* For loop for regressions: iterates over third party measure, outcome, controls
foreach thirdparty of varlist $thirdparty_list {
	replace thirdparty = `thirdparty'
		foreach outcome of varlist $outcome_list {
			forval i_con = 1/2 {
				local counter = `counter' + 1
				if (`i_con' == 1) {
					ivreg2 `outcome' c.oil c.oil#i.thirdparty   c.oil2 c.oil2#i.thirdparty i.thirdparty ///
					c.gas c.gas#i.thirdparty c.gas2 c.gas2#i.thirdparty   ///
					c.coal c.coal#i.thirdparty c.coal2 c.coal2#i.thirdparty ///
					i.year i.region, cluster(ccode) partial(i.year i.region)
					* Save geographic controls indicator
					estadd local geocontrols = "No"
				}
				else {
					ivreg2 `outcome' c.oil c.oil#i.thirdparty c.oil2 c.oil2#i.thirdparty i.thirdparty ///
					c.gas c.gas#i.thirdparty c.gas2 c.gas2#i.thirdparty ///
					c.coal c.coal#i.thirdparty c.coal2 c.coal2#i.thirdparty ///
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
				local  b1 = _b[c.oil] + _b[c.oil#1.thirdparty]
				qui lincom c.oil + c.oil#1.thirdparty
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
				local  b2 = _b[c.oil2] + _b[c.oil2#1.thirdparty]
				qui lincom c.oil2 + c.oil2#1.thirdparty
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
				
				est sto reg`counter'
			}

}
}

esttab reg1 reg2 reg3 reg4 using ///
 ${main}5_output/tables/prio_oilint_affinity_avg_60.tex, replace ///
  drop(`controls' 1.thirdparty#c.gas 1.thirdparty#c.gas2 ///
	gas gas2 1.thirdparty#c.coal ///
	1.thirdparty#c.coal2 coal coal2) /// 
	coeflabels(1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil X Third Party" 1.thirdparty#c.oil "Oil X Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) X Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) X Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space gascoal gascoalsq yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"Gas, Coal X Third Party"' `"Gas\(^2\), Coal\(^2\) X Third Party"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	
	
	esttab reg5 reg6 reg7 reg8 using ///
 ${main}5_output/tables/prio_oilint_affinity50_60.tex, replace ///
  drop(`controls' 1.thirdparty#c.gas 1.thirdparty#c.gas2 ///
	gas gas2 1.thirdparty#c.coal ///
	1.thirdparty#c.coal2 coal coal2) /// 
	coeflabels(1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil X Third Party" 1.thirdparty#c.oil "Oil X Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) X Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) X Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space gascoal gascoalsq yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"Gas, Coal X Third Party"' `"Gas\(^2\), Coal\(^2\) X Third Party"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	
	esttab reg9 reg10 reg11 reg12 using ///
 ${main}5_output/tables/prio_oilint_affinity90_60.tex, replace ///
  drop(`controls' 1.thirdparty#c.gas 1.thirdparty#c.gas2 ///
	gas gas2 1.thirdparty#c.coal ///
	1.thirdparty#c.coal2 coal coal2) /// 
	coeflabels(1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil X Third Party" 1.thirdparty#c.oil "Oil X Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) X Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) X Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space gascoal gascoalsq yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"Gas, Coal X Third Party"' `"Gas\(^2\), Coal\(^2\) X Third Party"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	

esttab reg1 reg2 reg3 reg4 using ///
 ${main}5_output/tables/prio_oilint_affinity50.tex, replace ///
  drop(`controls' 1.thirdparty#c.gas 1.thirdparty#c.gas2 ///
	gas gas2 1.thirdparty#c.coal ///
	1.thirdparty#c.coal2 coal coal2) /// 
	coeflabels(1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil X Third Party" 1.thirdparty#c.oil "Oil X Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) X Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) X Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space gascoal gascoalsq yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"Gas, Coal X Third Party"' `"Gas\(^2\), Coal\(^2\) X Third Party"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	
	
	esttab reg5 reg6 reg7 reg8 using ///
 ${main}5_output/tables/prio_oilint_affinity50_65.tex, replace ///
  drop(`controls' 1.thirdparty#c.gas 1.thirdparty#c.gas2 ///
	gas gas2 1.thirdparty#c.coal ///
	1.thirdparty#c.coal2 coal coal2) /// 
	coeflabels(1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil X Third Party" 1.thirdparty#c.oil "Oil X Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) X Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) X Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space gascoal gascoalsq yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"Gas, Coal X Third Party"' `"Gas\(^2\), Coal\(^2\) X Third Party"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	
	
	esttab reg9 reg10 reg11 reg12 using ///
 ${main}5_output/tables/prio_oilint_affinity50_99.tex, replace ///
  drop(`controls' 1.thirdparty#c.gas 1.thirdparty#c.gas2 ///
	gas gas2 1.thirdparty#c.coal ///
	1.thirdparty#c.coal2 coal coal2) /// 
	coeflabels(1.thirdparty "Third Party Presence" c.oil#1.thirdparty ///
	"Oil X Third Party" 1.thirdparty#c.oil "Oil X Third Party" ///
	1.thirdparty#c.oil2 "Oil\(^2\) X Third Party" c.oil2#1.thirdparty ///
	"Oil\(^2\) X Third Party" oil "Oil" oil2 "Oil\(^2\)") se ///
	starlevels(\sym{*} 0.1 \sym{**} 0.05 \sym{***} 0.01) ///
	nobaselevels nonumbers ///
	mgroups("Third Party: US Bases" "Third Party: US Arms' Trade" , ///
	pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
 	stats(space space b1s p1 b2s p2 space gascoal gascoalsq yearfe continentfe geocontrols N, ///
	fmt(s s s  %6.3f s %6.3f s s s s s s   a2)  ///
	layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" )  ///
	labels(`"\emph{Linear Combination:}"' `"\qquad \emph{Base + Inter. Coeff.}"' ///
	`"\qquad Oil"' 	`"\qquad p-value"' `"\qquad Oil\(^2\)"'`"\qquad p-value"' `" "' ///
	`"Gas, Coal X Third Party"' `"Gas\(^2\), Coal\(^2\) X Third Party"' `"Year FEs"' ///
	`"Continent FEs"' `"Geo Controls"'  `"\(N\)"')) ///
	mtitles("Conf." "Conf." "H. Conf." "H. Conf." "Conf." "Conf." "H. Conf." "H. Conf.") ///
	postfoot("\hline\hline \end{tabular}}")
	