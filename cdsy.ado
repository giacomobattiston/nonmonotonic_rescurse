
program define cdsy, rclass
	version 8.2
	syntax , type(string) k2(integer) nendog(integer)

* type() can be ivbias5   (k2<=100, nendog<=3)
*               ivbias10  (ditto)
*               ivbias20  (ditto)
*               ivbias30  (ditto)
*               ivsize10  (k2<=100, nendog<=2)
*               ivsize15  (ditto)
*               ivsize20  (ditto)
*               ivsize25  (ditto)
*               fullrel5  (ditto)
*               fullrel10 (ditto)
*               fullrel20 (ditto)
*               fullrel30 (ditto)
*               fullmax5  (ditto)
*               fullmax10 (ditto)
*               fullmax20 (ditto)
*               fullmax30 (ditto)
*               limlsize10 (ditto)
*               limlsize15 (ditto)
*               limlsize20 (ditto)
*               limlsize25 (ditto)

	tempname temp cv

* Initialize critical value as MV
	scalar `cv'=.

	if "`type'"=="ivbias5" {
		mata: s_cdsy("`temp'", 1)
		if `k2'<=100 & `nendog'<=3 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

 	if "`type'"=="ivbias10" {
 		mata: s_cdsy("`temp'", 2)
		if `k2'<=100 & `nendog'<=3 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="ivbias20" {
	 	mata: s_cdsy("`temp'", 3)
		if `k2'<=100 & `nendog'<=3 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="ivbias30" {
	 	mata: s_cdsy("`temp'", 4)
		if `k2'<=100 & `nendog'<=3 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}


	if "`type'"=="ivsize10" {
	 	mata: s_cdsy("`temp'", 5)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="ivsize15" {
	 	mata: s_cdsy("`temp'", 6)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="ivsize20" {
	 	mata: s_cdsy("`temp'", 7)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="ivsize25" {
	 	mata: s_cdsy("`temp'", 8)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}
	
	if "`type'"=="fullrel5" {
	 	mata: s_cdsy("`temp'", 9)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}
	
	if "`type'"=="fullrel10" {
	 	mata: s_cdsy("`temp'", 10)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}
	
	if "`type'"=="fullrel20" {
	 	mata: s_cdsy("`temp'", 11)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="fullrel30" {
	 	mata: s_cdsy("`temp'", 12)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="fullmax5" {
	 	mata: s_cdsy("`temp'", 13)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}
	
	if "`type'"=="fullmax10" {
	 	mata: s_cdsy("`temp'", 14)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}
	
	if "`type'"=="fullmax20" {
	 	mata: s_cdsy("`temp'", 15)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="fullmax30" {
	 	mata: s_cdsy("`temp'", 16)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="limlsize10" {
	 	mata: s_cdsy("`temp'", 17)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="limlsize15" {
	 	mata: s_cdsy("`temp'", 18)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="limlsize20" {
	 	mata: s_cdsy("`temp'", 19)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}

	if "`type'"=="limlsize25" {
	 	mata: s_cdsy("`temp'", 20)
		if `k2'<=100 & `nendog'<=2 {
			scalar `cv'=`temp'[`k2',`nendog']
		}
	}
	return scalar cv=`cv'
end
