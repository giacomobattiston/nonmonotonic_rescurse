
*******Exporters*********
replace ccode= 0 if exporter == "World"
replace ccode=  2 if exporter=="USA";
replace ccode= 20 if exporter=="Canada";
replace ccode= 31 if exporter=="Bahamas";
replace ccode= 40 if exporter=="Cuba";
replace ccode= 41 if exporter=="Haiti";
replace ccode= 42 if exporter=="Dominica";
replace ccode= 51 if exporter=="Jamaica";
replace ccode= 52 if exporter=="Trinidad Tbg";
replace ccode= 53 if exporter=="Barbados";
*replace ccode= 54 if exporter=="DMA";
*replace ccode= 55 if exporter=="GRD";
*replace ccode= 56 if exporter=="LCA";
*replace ccode= 57 if exporter=="VCT";
*replace ccode= 58 if exporter=="ATG";
replace ccode= 60 if exporter=="St.Kt-Nev-An";
replace ccode= 70 if exporter=="Mexico";
replace ccode= 80 if exporter=="Belize";
replace ccode= 90 if exporter=="Guatemala";
replace ccode= 91 if exporter=="Honduras";
replace ccode= 92 if exporter=="El Salvador";
replace ccode= 93 if exporter=="Nicaragua";
*replace ccode= 94 if exporter=="CRI";
replace ccode= 95 if exporter=="Panama";
replace ccode=100 if exporter=="Colombia";
replace ccode=101 if exporter=="Venezuela";
replace ccode=110 if exporter=="Guyana";
replace ccode=115 if exporter=="Suriname";
replace ccode=130 if exporter=="Ecuador";
replace ccode=135 if exporter=="Peru";
replace ccode=140 if exporter=="Brazil";
replace ccode=145 if exporter=="Bolivia";
replace ccode=150 if exporter=="Paraguay";
replace ccode=155 if exporter=="Chile";
replace ccode=160 if exporter=="Argentina";
replace ccode=165 if exporter=="Uruguay";
replace ccode=200 if exporter=="UK";
replace ccode=205 if exporter=="Ireland";
replace ccode=210 if exporter=="Netherlands";
replace ccode=211 if exporter=="Belgium-Lux";
*replace ccode=212 if exporter=="LUX";
replace ccode=220 if exporter=="France";
replace ccode=220 if exporter=="France,Monac";
*replace ccode=221 if exporter=="MCO";
*replace ccode=223 if exporter=="LIE";
replace ccode=225 if exporter=="CHE";
replace ccode=230 if exporter=="Spain";
*replace ccode=232 if exporter=="AND";
replace ccode=235 if exporter=="Portugal";
replace ccode=255 if exporter=="Germany";
replace ccode=255 if exporter=="Fm German FR";
replace ccode=290 if exporter=="Poland";
replace ccode=305 if exporter=="Austria";
replace ccode=310 if exporter=="Hungary";
replace ccode=316 if exporter=="Czechoslav";
replace ccode=316 if exporter=="Czech Republic";
replace ccode=317 if exporter=="Slovak Republic";
replace ccode=325 if exporter=="Italy";
*replace ccode=331 if exporter=="SMR";
replace ccode=338 if exporter=="Malta";
replace ccode=339 if exporter=="Albania";
replace ccode=343 if exporter=="Macedonia";
replace ccode=344 if exporter=="Croatia";
replace ccode=345 if exporter=="Fm Yugoslav";
replace ccode=346 if exporter=="Bosnia";
replace ccode=349 if exporter=="Slovenia";
replace ccode=350 if exporter=="Greece";
replace ccode=352 if exporter=="Cyprus";
replace ccode=355 if exporter=="Bulgaria";
replace ccode=359 if exporter=="Moldavia";
replace ccode=360 if exporter=="Romania";
replace ccode=365 if exporter=="Russia";
replace ccode=365 if exporter=="Fm USSR";
replace ccode=366 if exporter=="Estonia";
replace ccode=367 if exporter=="Latvia";
replace ccode=368 if exporter=="Lituania";
replace ccode=369 if exporter=="Ukraine";
replace ccode=370 if exporter=="Belarus";
replace ccode=371 if exporter=="Armenia";
replace ccode=372 if exporter=="Georgia";
replace ccode=373 if exporter=="Azerbajan";
replace ccode=375 if exporter=="Finland";
replace ccode=380 if exporter=="Sweden";
replace ccode=385 if exporter=="Norway";
replace ccode=390 if exporter=="Denmark";
replace ccode=395 if exporter=="Iceland";
replace ccode = 396 if exporter == "Abkhazia"
replace ccode = 700 if exporter == "Afghanistan"
replace ccode = 700 if exporter == "Afganistan"
replace ccode = 700 if exporter == "Afghanistan, Islamic Republic of"
replace ccode = 700 if exporter == "Afghanistan, Islamic Rep. of (Afghanistan)"
replace ccode = 700 if exporter == "Afghanistan(1992-)"
replace ccode = 339 if exporter == "Albania"
replace ccode = 615 if exporter == "Algeria"
replace ccode = 232 if exporter == "Andorra"
replace ccode = 540 if exporter == "Angola"
replace ccode = .   if exporter == "Anguilla"
replace ccode = 58  if exporter == "Antigua and Barbuda"
replace ccode = 58  if exporter == "Antigua"
replace ccode = 58  if exporter == "Antigua & Barbuda"
replace ccode = 58  if exporter == "Antigua & B"
replace ccode = 160 if exporter == "Argentina"
replace ccode = 160 if exporter == "Argentin"
replace ccode = 371 if exporter == "Armenia"
replace ccode = 371 if exporter == "Armenia, Republic of"
replace ccode = .   if exporter == "Aruba"
replace ccode = 900 if exporter == "Australia"
replace ccode = 900 if exporter == "Australia*"
replace ccode = 305 if exporter == "Austria"
replace ccode = 305 if exporter == "Austria*"
replace ccode = 300 if exporter == "Austria-Hungary"
replace ccode = 373 if exporter == "Azerbaijan"
replace ccode = 373 if exporter == "Azerbaijan, Republic of"

/***************************
ccode numbers for B-countries 
****************************/

replace ccode = 267 if exporter == "Baden"
replace ccode = 31  if exporter == "Bahamas"
replace ccode = 31  if exporter == "Bahamas, The"
replace ccode = 692 if exporter == "Bahrain"
replace ccode = 692 if exporter == "Bahrain, Kingdom of"
replace ccode = 692 if exporter == "Bahrein"
replace ccode = 771 if exporter == "Bangladesh"
replace ccode = 53  if exporter == "Barbados"
replace ccode = 245 if exporter == "Bavaria"
replace ccode = 370 if exporter == "Belarus"
replace ccode = 370 if exporter == "Byelorussia"
replace ccode = 211 if exporter == "Belgium"
replace ccode = 211 if exporter == "Belgo-Luxembourg Economic Union"
replace ccode = 80  if exporter == "Belize"
replace ccode = 434 if exporter == "Benin"
replace ccode = 434 if exporter == "Benin (Dahomey)"
replace ccode = 760 if exporter == "Bhutan"
replace ccode = 145 if exporter == "Bolivia"
replace ccode = 346 if exporter == "Bosnia"
replace ccode = 346 if exporter == "Bosnia-Hercegovina"
replace ccode = 346 if exporter == "Bosnia-Hercegovenia"
replace ccode = 346 if exporter == "Bosnia-Herz"
replace ccode = 346 if exporter == "Bosnia-Herzegovina"
replace ccode = 346 if exporter == "Bosnia-Herz."
replace ccode = 346 if exporter == "Bosnia and Herzegovina"
replace ccode = 346 if exporter == "Bosnia & Herzegovina"
replace ccode = 346 if exporter == "Bosnia Herzegovenia"
replace ccode = 346 if exporter == "Bosnia Herzg"
replace ccode = 571 if exporter == "Botswana"
replace ccode = 140 if exporter == "Brazil"
replace ccode = 835 if exporter == "Brunei"
replace ccode = 835 if exporter == "Brunei Darussalam"
replace ccode = 355 if exporter == "Bulgaria"
replace ccode = 439 if exporter == "Burkina Faso"
replace ccode = 439 if exporter == "Burkina Faso (Upper Volta)"
replace ccode = 516 if exporter == "Burundi"

/***************************
ccode numbers for C-countries 
****************************/

replace ccode = 811 if exporter == "Cambodia"
replace ccode = 811 if exporter == "Kampuchea"
replace ccode = 811 if exporter == "Kampuchea, Democratic"
replace ccode = 811 if exporter == "Cambodia (Kampuchea)"
replace ccode = 471 if exporter == "Cameroon"
replace ccode = 471 if exporter == "Cameroun"
replace ccode = 20  if exporter == "Canada"
replace ccode = 402 if exporter == "Cape Verde Is"
replace ccode = 402 if exporter == "Cape Verde Is."
replace ccode = 402 if exporter == "Cape Verde"
replace ccode = 402 if exporter == "C. Verde Is."
replace ccode = 482 if exporter == "Central African Republic"
replace ccode = 482 if exporter == "Central African Rep"
replace ccode = 482 if exporter == "Central African Rep."
replace ccode = 482 if exporter == "Cent. Af. Rep."
replace ccode = 482 if exporter == "Cen African Rep"
replace ccode = 482 if exporter == "C.A.R."
replace ccode = 483 if exporter == "Chad"
replace ccode = 155 if exporter == "Chile"
replace ccode = 710 if exporter == "China"
replace ccode = 710 if exporter == "China P Rep"
replace ccode = 710 if exporter == "China, PR"
replace ccode = 710 if exporter == "China, P.R.: Mainland"
replace ccode = 710 if exporter == "PRC"
replace ccode = 100 if exporter == "Colombia"
replace ccode = 100 if exporter == "Columbia"
replace ccode = 581 if exporter == "Comoros"
replace ccode = 581 if exporter == "Comoro Is."
replace ccode = 581 if exporter == "Comoro Is"
replace ccode = 484 if exporter == "Congo"
replace ccode = 484 if exporter == "Congo, Rep."
replace ccode = 484 if exporter == "Congo, Rep. of"
replace ccode = 484 if exporter == "Congo, Republic of"
replace ccode = 484 if exporter == "Congo Republic"
replace ccode = 484 if exporter == "Congo (Republic)"
replace ccode = 484 if exporter == "Rep. Congo"
replace ccode = 484 if exporter == "Congo, Rep. of the"
replace ccode = 484 if exporter == "CongoRep"
replace ccode = 484 if exporter == "Congo (Brazzaville)"
replace ccode = 484 if exporter == "Congo, Brazzaville"
replace ccode = 484 if exporter == "Congo Brazzaville"
replace ccode = 484 if exporter == "Congo (Brazzaville,Rep. of Congo)"
replace ccode = 484 if exporter == "Congo (Brazzaville, Republic of Congo)"
replace ccode = 484 if exporter == "Congo, Republic of (Brazzaville)"
replace ccode = 490 if exporter == "Congo (Kinshasa)"
replace ccode = 490 if exporter == "Congo Kinshasa"
replace ccode = 490 if exporter == "Congo, Kinshasa"
replace ccode = 490 if exporter == "Dem.Rp.Congo"
replace ccode = 490 if exporter == "Congo, Democratic Republic of"
replace ccode = 490 if exporter == "Congo, Democratic Republic"
replace ccode = 490 if exporter == "Congo, the Democratic Republic of the"
replace ccode = 490 if exporter == "Congo, Dem. Rep."
replace ccode = 490 if exporter == "Congo (Democratic Republic)"
replace ccode = 490 if exporter == "Congo/Zaire"
replace ccode = 490 if exporter == "Congo, Democratic Republic of (Zaire)" 
replace ccode = 490 if exporter == "Congo, Democratic Republic of the Za?re)" 
replace ccode = 490 if exporter == "CongoDemRep"
replace ccode = 490 if exporter == "Democratic Republic of the Congo"
replace ccode = 490 if exporter == "Zaire"
replace ccode = 490 if exporter == "Zaire/Congo Dem Rep"
replace ccode = 490 if exporter == "Zaire (Democ Republic Congo)"
replace ccode = 490 if exporter == "Zaire (Congo after 1997)"
replace ccode = 94  if exporter == "Costa Rica"
replace ccode = 437 if exporter == "Cote Divoire"
replace ccode = 437 if exporter == "Cote d'Ivoire"
replace ccode = 437 if exporter == "Côte d'Ivoire"
replace ccode = 437 if exporter == "Cote d`Ivoire"
replace ccode = 437 if exporter == "Cote D'Ivoire"
replace ccode = 437 if exporter == "C?e d'Ivoire"
replace ccode = 437 if exporter == "C?te d'Ivoire (Ivory Coast)"
replace ccode = 437 if exporter == "C??te d'Ivoire"
replace ccode = 437 if exporter == "Cote dIvoire"
replace ccode = 437 if exporter == "Ivory Coast"
replace ccode = 344 if exporter == "Croatia"
replace ccode = 40  if exporter == "Cuba"
replace ccode = 352 if exporter == "Cyprus"
replace ccode = 352 if exporter == "Cyprus (Greek)"
replace ccode = 352 if exporter == "Cyprus (G)"
replace ccode = .   if exporter == "Cyprus (Turkey)"
replace ccode = .   if exporter == "Turk Cyprus"
replace ccode = 315 if exporter == "Czechoslovak"
replace ccode = 315 if exporter == "Czechoslovakia"
replace ccode = 315 if exporter == "Czechoslavakia"
replace ccode = 315 if exporter == "Former Czechoslovakia"
replace ccode = 316 if exporter == "Czech Rep"
replace ccode = 316 if exporter == "Czech Rep."
replace ccode = 316 if exporter == "Czech Republic"
replace ccode = 316 if exporter == "CzechRepublic"
replace ccode = 316 if exporter == "Czech Rep (C-Slv.)"

/***************************
ccode numbers for D-countries 
****************************/

replace ccode = 390 if exporter == "Denmark"
replace ccode = 390 if exporter == "Denmark*"
replace ccode = 522 if exporter == "Djibouti"
replace ccode = 54  if exporter == "Dominica"
replace ccode = 42  if exporter == "Dom. Rep."
replace ccode = 42  if exporter == "Dom Rep"
replace ccode = 42  if exporter == "Dominican Rep"
replace ccode = 42  if exporter == "Dominican Republic"
replace ccode = 42  if exporter == "Dominican Rep."
replace ccode = 42  if exporter == "Dominican Rp"

/***************************
ccode numbers for E-countries 
****************************/

replace ccode = 860 if exporter == "East Timor"
replace ccode = 860 if exporter == "East Timor (Timor-Leste)"
replace ccode = 860 if exporter == "Timor-Leste"
replace ccode = 860 if exporter == "Timor-Leste, Dem. Rep. of"
replace ccode = 860 if exporter == "TimorLeste"
replace ccode = 860 if exporter == "Timor-Leste (East Timor)"
replace ccode = 130 if exporter == "Ecuador"
replace ccode = 651 if exporter == "Egypt"
replace ccode = 651 if exporter == "Egypt, Arab Rep."
replace ccode = 651 if exporter == "EgyptArabRep"
replace ccode = 92  if exporter == "El Salvador"
replace ccode = 92  if exporter == "ElSalvador"
replace ccode = 92  if exporter == "Salvador"
replace ccode = 411 if exporter == "Equatorial Guinea"
replace ccode = 411 if exporter == "Eq.Guinea"
replace ccode = 411 if exporter == "Eq. Guinea"
replace ccode = 531 if exporter == "Eritrea"
replace ccode = 366 if exporter == "Estonia"
replace ccode = 530 if exporter == "Ethiopia (former)"
replace ccode = 530 if exporter == "Ethiopia"

/***************************
ccode numbers for F-countries 
****************************/

replace ccode = 987 if exporter == "Federated States of Micronesia"
replace ccode = 950 if exporter == "Fiji"
replace ccode = 375 if exporter == "Finland"
replace ccode = 220 if exporter == "France"

/***************************
ccode numbers for G-countries 
****************************/

replace ccode = 481 if exporter == "Gabon"
replace ccode = 420 if exporter == "Gambia"
replace ccode = 420 if exporter == "Gambia The"
replace ccode = 420 if exporter == "Gambia, The"
replace ccode = 372 if exporter == "Georgia"
replace ccode = 260 if exporter == "Germany" 
replace ccode = 260 if exporter == "Germany Fed Rep"
replace ccode = 260 if exporter == "German Federal Republic"
replace ccode = 260 if exporter == "FRG/Germany"
replace ccode = 260 if exporter == "Germany, W."
replace ccode = 260 if exporter == "Germany West"
replace ccode = 260 if exporter == "Germany, FR"
replace ccode = 260 if exporter == "FR Germany"
replace ccode = 265 if exporter == "Germany Dem Rep"
replace ccode = 265 if exporter == "Germany DR"
replace ccode = 265 if exporter == "Fm German DR"
replace ccode = 265 if exporter == "GDR"
replace ccode = 265 if exporter == "Germany, E."
replace ccode = 265 if exporter == "East Germany"
replace ccode = 265 if exporter == "Germany East"
replace ccode = 265 if exporter == "German Democratic Republic"
replace ccode = 260 if ccode == 255 & year < 1946 /*pre-WWII, Germany/Prussia has a different number*/
replace ccode = 452 if exporter == "Ghana"
replace ccode = 99  if exporter == "Great Colombia"
replace ccode = 99  if exporter == "Gran Colombia"
replace ccode = 350 if exporter == "Greece"
replace ccode = 55  if exporter == "Grenada"
replace ccode = 90  if exporter == "Guatemala"
replace ccode = 438 if exporter == "Guinea"
replace ccode = 438 if exporter == "Guineau"
replace ccode = 404 if exporter == "GuineaBissau"
replace ccode = 404 if exporter == "Guinea Bissau"
replace ccode = 404 if exporter == "Guinea-Bissau"
replace ccode = 404 if exporter == "Guinea-Bisau"
replace ccode = 110 if exporter == "Guyana"

/***************************
ccode numbers for H-countries 
****************************/

replace ccode = 41   if exporter == "Haiti"
replace ccode = 240  if exporter == "Hanover"
replace ccode = 273  if exporter == "Hesse Electoral"
replace ccode = 273  if exporter == "Hesse-Kassel"
replace ccode = 275  if exporter == "Hesse Grand Ducal"
replace ccode = 275  if exporter == "Hesse-Darmstadt"
replace ccode = 91   if exporter == "Honduras"
replace ccode = 708 if exporter == "Hong Kong"
replace ccode = 708 if exporter == "Hong-Kong"
replace ccode = 708 if exporter == "Hong Kong (SAR China)"
replace ccode = 708 if exporter == "HongKong"
replace ccode = 708 if exporter == "Hong Kong (China)"
replace ccode = 708 if exporter == "Hong Kong, China"
replace ccode = 708 if exporter == "China, P.R.: Hong Kong"
replace ccode = 708 if exporter == "China,P.R.:Hong Kong"
replace ccode = 708 if exporter == "Hong Kong, China"
replace ccode = 708 if exporter == "HongKongSARChina"
replace ccode = 708 if exporter == "Hong Kong SAR, China"
replace ccode = 708 if exporter == "China, Hong Kong Special Administrative Region"
replace ccode = 310  if exporter == "Hungary"

/***************************
ccode numbers for I-countries 
****************************/

replace ccode = 395 if exporter == "Iceland"
replace ccode = 750 if exporter == "India"
replace ccode = 850 if exporter == "Indonesia"
replace ccode = 850 if exporter == "Indonesia including East Timor"
replace ccode = 630 if exporter == "Iran"
replace ccode = 630 if exporter == "Iran (Persia)"
replace ccode = 630 if exporter == "Iran Islam Rep"
replace ccode = 630 if exporter == "Iran, Islamic Rep."
replace ccode = 630 if exporter == "Iran, Islamic Republic of"
replace ccode = 630 if exporter == "Iran, Islamic Republic of (Iran)"
replace ccode = 630 if exporter == "Iran, I.R. of"
replace ccode = 630 if exporter == "Islamic Rep. of Iran"
replace ccode = 630 if exporter == "IranIslamicRep"
replace ccode = 630 if exporter == "Iran (Islamic Republic of)"
replace ccode = 645 if exporter == "Iraq"
replace ccode = 205 if exporter == "Ireland"
replace ccode = 666 if exporter == "Israel"
replace ccode = 325 if exporter == "Italy"
replace ccode = 325 if exporter == "Italy*"
replace ccode = 325 if exporter == "Italy/Sardinia"

/***************************
ccode numbers for J-countries 
****************************/

replace ccode = 51  if exporter == "Jamaica"
replace ccode = 740 if exporter == "Japan"
replace ccode = 663 if exporter == "Jordan"

/***************************
ccode numbers for K-countries 
****************************/

replace ccode = 705 if exporter == "Kazakhstan"
replace ccode = 705 if exporter == "Khazakhstan"
replace ccode = 501 if exporter == "Kenya"
replace ccode = 970 if exporter == "Kiribati"
replace ccode = 730 if exporter == "Korea"
replace ccode = 731 if exporter == "Korea, North"
replace ccode = 731 if exporter == "Korea, N"
replace ccode = 731 if exporter == "Korea (North)"
replace ccode = 731 if exporter == "Korea North"
replace ccode = 731 if exporter == "Korea D P Rp"
replace ccode = 731 if exporter == "Korea Dem P Rep"
replace ccode = 731 if exporter == "Korea, Dem. Rep."
replace ccode = 731 if exporter == "Korea, Dem. People's Rep. of"
replace ccode = 731 if exporter == "Dem. People's Rep. Korea"
replace ccode = 731 if exporter == "Korea, Democratic People's Republic of"
replace ccode = 731 if exporter == "Korea, DPR"
replace ccode = 731 if exporter == "North Korea"
replace ccode = 731 if exporter == "Democratic People's Republic of Korea"
replace ccode = 731 if exporter == "PRK"
replace ccode = 732 if exporter == "Korea (South)"
replace ccode = 730 if exporter == "Korea"
replace ccode = 730 if exporter == "Korea Rep."
replace ccode = 732 if exporter == "Korea, South"
replace ccode = 732 if exporter == "Korea, S"
replace ccode = 732 if exporter == "Korea South"
replace ccode = 732 if exporter == "Korea Rep"
replace ccode = 732 if exporter == "Korea, Republic of"
replace ccode = 732 if exporter == "Korea, Rep."
replace ccode = 732 if exporter == "South Korea"
replace ccode = 732 if exporter == "ROK"
replace ccode = 732 if exporter == "Republic of Korea"
replace ccode = 732 if exporter == "Korea, Republic Of"
replace ccode = 347 if exporter == "Kosovo"
replace ccode = 690 if exporter == "Kuwait"
replace ccode = 703 if exporter == "Kyrgyzstan"
replace ccode = 703 if exporter == "Kyrgyz Republic"
replace ccode = 703 if exporter == "Kyrgyz Republic (Kyrgyzstan)"

/***************************
ccode numbers for L-countries 
****************************/

replace ccode = 812 if exporter == "Laos"
replace ccode = 812 if exporter == "Lao PDR"
replace ccode = 812 if exporter == "Lao P Dem Rep"
replace ccode = 812 if exporter == "Lao P.Dem.Rep"
replace ccode = 812 if exporter == "Lao P.Dem.R"
replace ccode = 812 if exporter == "Lao People's Democratic Republic"
replace ccode = 812 if exporter == "Lao People's Democratic Republic (Laos)"
replace ccode = 367 if exporter == "Latvia"
replace ccode = 660 if exporter == "Lebanon"
replace ccode = 570 if exporter == "Lesotho"
replace ccode = 450 if exporter == "Liberia"
replace ccode = 620 if exporter == "Libya"
replace ccode = 620 if exporter == "Libyan Arab Jamah"
replace ccode = 620 if exporter == "Libya Arab Jamahiriy"
replace ccode = 620 if exporter == "Libyan Arab Jamahiriya"
replace ccode = 223 if exporter == "Liechtenstein"
replace ccode = 368 if exporter == "Lithuania"
replace ccode = 212 if exporter == "Luxembourg"

/***************************
ccode numbers for M-countries 
****************************/

replace ccode = 709 if exporter == "Macao SAR, China"
replace ccode = 709 if exporter == "Macao"
replace ccode = 709 if exporter == "Macao (SAR China)"
replace ccode = 709 if exporter == "China, P.R.: Macao"
replace ccode = 709 if exporter == "China, Macao Special Administrative Region"
replace ccode = 343 if exporter == "Macedonia"
replace ccode = 343 if exporter == "TFYR of Macedonia"
replace ccode = 343 if exporter == "TFYR Macedna"
replace ccode = 343 if exporter == "Macedonia FRY"
replace ccode = 343 if exporter == "Macedonia, FYR"
replace ccode = 343 if exporter == "FYR Macedonia"
replace ccode = 343 if exporter == "Macedonia, the Former Yugoslav Republic of"
replace ccode = 343 if exporter == "Macedonia, former Yugoslav Republic of"
replace ccode = 580 if exporter == "Madagascar"
replace ccode = 580 if exporter == "Madagascar (Malagasy Republic)"
replace ccode = 580 if exporter == "Madagascar (Malagasy)"
replace ccode = 553 if exporter == "Malawi"
replace ccode = 820 if exporter == "Malaysia"
replace ccode = 820 if exporter == "Malaysia (Malaya)"
replace ccode = 781 if exporter == "Maldives"
replace ccode = 432 if exporter == "Mali"
replace ccode = 432 if exporter == "Marli"
replace ccode = 338 if exporter == "Malta"
replace ccode = 983 if exporter == "Marshall Is"
replace ccode = 983 if exporter == "Marshall Islands"
replace ccode = 983 if exporter == "Marshall Islan"
replace ccode = 983 if exporter == "Marshall Islands, Republic of"
replace ccode = 435 if exporter == "Mauritania"
replace ccode = 590 if exporter == "Mauritius"
replace ccode = 280 if exporter == "Mecklenburg Schwerin"
replace ccode = 70  if exporter == "Mexico"
replace ccode = 987 if exporter == "Micronesia"
replace ccode = 987 if exporter == "Micronesia Fed States"
replace ccode = 987 if exporter == "Micronesia, Fed. States"
replace ccode = 987 if exporter == "Micronesia, Fed. Sts."
replace ccode = 987 if exporter == "Micronesia, Fed Stat"
replace ccode = 987 if exporter == "Micronesia, Federated States of"
replace ccode = 987 if exporter == "Federated States of Micronesia"
replace ccode = 332 if exporter == "Modena"
replace ccode = 359 if exporter == "Moldova"
replace ccode = 359 if exporter == "Republic of Moldova"
replace ccode = 359 if exporter == "Moldova Rep"
replace ccode = 359 if exporter == "Moldova, Republic Of"
replace ccode = 359 if exporter == "Republic Of Moldova"
replace ccode = 221 if exporter == "Monaco"
replace ccode = 712 if exporter == "Mongolia"
replace ccode = 341 if exporter == "Montenegro"
replace ccode = .   if exporter == "Montserrat"
replace ccode = 600 if exporter == "Morocco"
replace ccode = 541 if exporter == "Mozambique"
replace ccode = 775 if exporter == "Myanmar"
replace ccode = 775 if exporter == "Myanmar (Burma)"
replace ccode = 775 if exporter == "Myanmar(Burma)"
replace ccode = 775 if exporter == "Burma (Myanmar)"
replace ccode = 775 if exporter == "Burma"

/***************************
ccode numbers for N-countries 
****************************/

replace ccode = 565 if exporter == "Namibia"
replace ccode = 971 if exporter == "Nauru"
replace ccode = 790 if exporter == "Nepal"
replace ccode = 210 if exporter == "Netherlands"
replace ccode = . if exporter == "Netherlands Antilles"
replace ccode = 920 if exporter == "New Zealand"	
replace ccode = 93  if exporter == "Nicaragua"
replace ccode = 436 if exporter == "Niger"
replace ccode = 475 if exporter == "Nigeria"
replace ccode = 385 if exporter == "Norway"

/***************************
ccode numbers for O and P counttries 
****************************/

replace ccode = 698 if exporter == "Oman"
replace ccode = 564 if exporter == "Orange Free State"

replace ccode = 770 if exporter == "Pakistan"
replace ccode = 770 if exporter == "Pakistan, (1972-)"
replace ccode = 986 if exporter == "Palau"
replace ccode = 95  if exporter == "Panama"
replace ccode = 95  if exporter == "Panama Canal Zone"
replace ccode = 327 if exporter == "Papal States"
replace ccode = 910 if exporter == "Papua New Guinea"
replace ccode = 910 if exporter == "Papua New Guinea"
replace ccode = 910 if exporter == "Papua N.Guin"
replace ccode = 910 if exporter == "P. N. Guinea"
replace ccode = 150 if exporter == "Paraguay"
replace ccode = 335 if exporter == "Parma"
replace ccode = 135 if exporter == "Peru"
replace ccode = 840 if exporter == "Philipines"
replace ccode = 840 if exporter == "Philippines" 
replace ccode = 840 if exporter == "Phillippines"
replace ccode = 840 if exporter == "Philippi"
replace ccode = 290 if exporter == "Poland"
replace ccode = 235 if exporter == "Portugal"
replace ccode = 255 if exporter == "Prussia"

/***************************
ccode numbers for Q and R-countries 
****************************/

replace ccode = 694 if exporter == "Qatar"

replace ccode = 360 if exporter == "Romania"
replace ccode = 360 if exporter == "Rumania"
replace ccode = 365 if exporter == "Russia"
replace ccode = 365 if exporter == "Russian Fed"
replace ccode = 365 if exporter == "Russian Federation"
replace ccode = 365 if exporter == "USSR"
replace ccode = 365 if exporter == "U.S.S.R."
replace ccode = 365 if exporter == "Soviet Union"
replace ccode = 365 if exporter == "Russia (Soviet Union)"
replace ccode = 365 if exporter == "Russia (USSR)"
replace ccode = 517 if exporter == "Rwanda"

/***************************
ccode numbers for S-countries 
****************************/

replace ccode = 403 if exporter == "Sao Tome et Principe"
replace ccode = 403 if exporter == "Sao Tome and principe"
replace ccode = 403 if exporter == "Sao Tome"
replace ccode = 403 if exporter == "S? Tom�and Principe"
replace ccode = 403 if exporter == "Sao Tome & Principe"
replace ccode = 403 if exporter == "Sao Tome & P"
replace ccode = 403 if exporter == "Sao Tome and Principe"
replace ccode = 403 if exporter == "S?o Tom? and Principe"
replace ccode = 403 if exporter == "Sao Tom?E and Principe"
replace ccode = 403 if exporter == "S?o Tom? and Pr?ncipe"
replace ccode = 60  if exporter == "Saint Kitts and Nevis"
replace ccode = 60  if exporter == "St. Kitts and Nevis"
replace ccode = 60  if exporter == "St Kitts and Nevis"
replace ccode = 60  if exporter == "St. Kitts & Nevis"
replace ccode = 60  if exporter == "St. Kitts & N"
replace ccode = 56  if exporter == "Saint Lucia"
replace ccode = 56  if exporter == "St. Lucia"
replace ccode = 56  if exporter == "St Lucia"
replace ccode = 56  if exporter == "StLucia"
replace ccode = 57  if exporter == "Saint Vincent and the Grenadines"
replace ccode = 57  if exporter == "St.Vincent & Grenadines"
replace ccode = 57  if exporter == "St. Vin. & G"
replace ccode = 57  if exporter == "St. Vincent and the Grenadines"
replace ccode = 57  if exporter == "St. Vincent & Grenadine"
replace ccode = 57  if exporter == "St. Vincent & Grenadines"
replace ccode = 57  if exporter == "St Vincent and The Grenadines"
replace ccode = 57  if exporter == "St Vincent and the Grenadines"
replace ccode = 57  if exporter == "StVincentandtheGrenadines"
replace ccode = 57  if exporter == "StVincentand"
replace ccode = 57  if exporter == "St Vincent"
replace ccode = 990 if exporter == "Samoa"
replace ccode = 990 if exporter == "W. Samoa"
replace ccode = 990 if exporter == "W Samoa"
replace ccode = 990 if exporter == "Western Samoa"
replace ccode = 990 if exporter == "Samoa (Western Samoa)"
replace ccode = 331 if exporter == "San Marino"
replace ccode = 670 if exporter == "Saudi Arabia"
replace ccode = 269 if exporter == "Saxony"
replace ccode = 433 if exporter == "Senegal"
replace ccode = 340 if exporter == "Serbia" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode = 340 if exporter == "Serbia, Republic of" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode = 340 if exporter == "Serbia Montenegro" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode = 340 if exporter == "Serbia & Montenegro" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode = 340 if exporter == "SerbiaandMontenegro" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode = 340 if exporter == "Serbia and Montenegro" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode = 340 if exporter == "Serbia-Montenegro" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode = 340 if exporter == "Serbia" & ((year < 1918 & year > 1877) | (year > 2006 & year != .)) 
replace ccode = 340 if exporter == "SERBIA, REPUBLIC OF" & ((year < 1918 & year > 1877) | (year > 2006 & year != .)) 
replace ccode = 340 if exporter == "Yugoslavia" & ((year < 1918 & year > 1877) | (year > 2006 & year != .)) 


// For observations that should be Yugoslavia 
replace ccode = 345 if exporter == "Serbia" & year > 1917 & year < 2007
replace ccode = 345 if exporter == "Serbia, Republic of" & year > 1917 & year < 2007
replace ccode = 345 if exporter == "Serbia Montenegro" & year > 1917 & year < 2007
replace ccode = 345 if exporter == "Serbia & Montenegro" & year > 1917 & year < 2007
replace ccode = 345 if exporter == "SerbiaandMontenegro" & year > 1917 & year < 2007
replace ccode = 345 if exporter == "Serbia and Montenegro" & year > 1917 & year < 2007
replace ccode = 345 if exporter == "Yugoslavia" & year > 1917 & year < 2007
replace ccode = 345 if exporter == "Serbia" & year > 1917 & year < 2007
replace ccode = 345 if exporter == "SERBIA, REPUBLIC OF" & year > 1917 & year < 2007
replace ccode = 345 if exporter == "Serbia and Montenegro" & year > 1917 & year < 2007

replace ccode = 591 if exporter == "Seychelles"
replace ccode = 591 if exporter == "Seychelle"
replace ccode = 451 if exporter == "Sierra Leone"
replace ccode = 830 if exporter == "Singapore"
replace ccode = 317 if exporter == "Slovak Republic"
replace ccode = 317 if exporter == "Slovakia"
replace ccode = 349 if exporter == "Slovenia"
replace ccode = 940 if exporter == "Solomon Is"
replace ccode = 940 if exporter == "Solomon Is."
replace ccode = 940 if exporter == "Solomon Islands"
replace ccode = 520 if exporter == "Somalia"
replace ccode = 560 if exporter == "South Africa"
replace ccode = 560 if exporter == "SouthAfrica"
replace ccode = 560 if exporter == "S. Africa"
replace ccode = 397 if exporter == "South Ossetia"
replace ccode = 626 if exporter == "South Sudan"
replace ccode = 626 if exporter == "S. Sudan"
replace ccode = 626 if exporter == "Sudan (South)"
replace ccode = 365 if exporter == "Soviet Union"
replace ccode = 230 if exporter == "Spain"
replace ccode = 780 if exporter == "Sri Lanka"
replace ccode = 780 if exporter == "Sri Lanka (Ceylon)"
replace ccode = 780 if exporter == "SriLanka"
replace ccode = 625 if exporter == "Sudan"
replace ccode = 115 if exporter == "Suriname"
replace ccode = 115 if exporter == "Surinam"
replace ccode = 572 if exporter == "Swaziland"
replace ccode = 380 if exporter == "Sweden"
replace ccode = 225 if exporter == "Switzerland"
replace ccode = 225 if exporter == "Switz.Liecht"
replace ccode = 652 if exporter == "Syria"
replace ccode = 652 if exporter == "Syrian Arab Rep"
replace ccode = 652 if exporter == "Syrian Arab Republic"
replace ccode = 652 if exporter == "SyrianArabRep"
replace ccode = 652 if exporter == "Syrian Arab Republic (Syria)"

/***************************
ccode numbers for T-countries 
****************************/

replace ccode = 713 if exporter == "Taiwan"
replace ccode = 713 if exporter == "Taiwan (China)"
replace ccode = 713 if exporter == "Taiwan, China"
replace ccode = 713 if exporter == "Taiwan Province of China"
replace ccode = 713 if exporter == "Taiwan, Republic of China on"   
replace ccode = 713 if exporter == "TaiwanChina"
replace ccode = 713 if exporter == "China, Taiwan Province of"
replace ccode = 713 if exporter == "Chinese Taipei"
replace ccode = 702 if exporter == "Tajikistan"
replace ccode = 510 if exporter == "Tanzania"
replace ccode = 510 if exporter == "Tanzania (Tanganyika)"
replace ccode = 510 if exporter == "Tanzania Uni Rep"
replace ccode = 510 if exporter == "Tanzania, United Rep. of"
replace ccode = 510 if exporter == "Tanzania, United Rep.of"
replace ccode = 510 if exporter == "Tanzania, United Rep. of "
replace ccode = 510 if exporter == "Tanzania, United Rep. of "
replace ccode = 510 if exporter == "Tanzania, United Republic of"
replace ccode = 510 if exporter == "United Rep. of Tanzania"
replace ccode = 510 if exporter == "United Republic of Tanzania"
replace ccode = 800 if exporter == "Thailand"
replace ccode = 800 if exporter == "Thailand (Siam)"
replace ccode = 711 if exporter == "Tibet"
replace ccode = 461 if exporter == "Togo"
replace ccode = 972 if exporter == "Tonga"
replace ccode = 563 if exporter == "Transvaal"
replace ccode = 52  if exporter == "Trinidad-Tobago"
replace ccode = 52  if exporter == "Trinidad and Tobago"
replace ccode = 52  if exporter == "Trinidad & Tobago"
replace ccode = 52  if exporter == "Trinidad & T"
replace ccode = 52  if exporter == "Trinidad"
replace ccode = 616 if exporter == "Tunisia"
replace ccode = 640 if exporter == "Turkey"
replace ccode = 640 if exporter == "Turkey/Ottoman Empire"
replace ccode = 640 if exporter == "Turkey (Ottoman Empire)"
replace ccode = 701 if exporter == "Turkmenistan"
replace ccode = 337 if exporter == "Tuscany"
replace ccode = 973 if exporter == "Tuvalu"
replace ccode = 329 if exporter == "Two Sicilies"


/***************************
ccode numbers for U-countries 
****************************/

replace ccode = 500 if exporter == "Uganda"
replace ccode = 500 if exporter == "Ugandan"
replace ccode = 500 if exporter == "Nogeria"
replace ccode = 369 if exporter == "Ukraine"
replace ccode = 696 if exporter == "United Arab Emirates"
replace ccode = 696 if exporter == "Un. Arab Em."
replace ccode = 696 if exporter == "Untd Arab Em"
replace ccode = 696 if exporter == "UnitedArabEmirates"
replace ccode = 696 if exporter == "UAE"
replace ccode = 696 if exporter == "U.A.E."
replace ccode = 200 if exporter == "United Kingdom"
replace ccode = 200 if exporter == "UnitedKingdom"
replace ccode = 200 if exporter == "UK"
replace ccode = 200 if exporter == "U.K."
replace ccode = 89 if exporter == "United Provinces of Central America"
replace ccode = 89 if exporter == "United Province CA"
replace ccode = 2 	 if exporter == "United States"
replace ccode = 2   if exporter == "UnitedStates"
replace ccode = 2 	 if exporter == "United States of America"
replace ccode = 2 	 if exporter == "United States, America"
replace ccode = 2   if exporter == "USA"
replace ccode = 165 if exporter == "Uruguay"
replace ccode = 704 if exporter == "Uzbekistan"


/***************************
ccode numbers for V and W-countries 
****************************/

replace ccode = 935 if exporter == "Vanuatu"
replace ccode = . if exporter == "Vatican City"
replace ccode = 101 if exporter == "Venezuela"
replace ccode = 101 if exporter == "Venezuela, RB"
replace ccode = 101 if exporter == "Venezuela, R.B."
replace ccode = 101 if exporter == "VenezuelaRB"
replace ccode = 101 if exporter == "Venezuela (Bolivarian Republic of)"
replace ccode = 101 if exporter == "Venezuela, Republica Bolivariana de"
replace ccode = 101 if exporter == "Venezuela, Rep?blica Bolivariana de"
replace ccode = 816 if exporter == "Vietnam, Democratic Republic of"
replace ccode = 816 if exporter == "Vietnam, N."
replace ccode = 816 if exporter == "Vietnam, North"
replace ccode = 816 if exporter == "Vietnam, N"
replace ccode = 816 if exporter == "N. Vietnam"
replace ccode = 816 if exporter == "Vietnam North"
replace ccode = 816 if exporter == "Vietnam, Socialist Republic of"  
replace ccode = 816 if exporter == "Viet Nam"  
replace ccode = 816 if exporter == "Vietnam"  
replace ccode = 817 if exporter == "Vietnam, Republic of"
replace ccode = 817 if exporter == "Vietnam, Republic of (South Vietnam)"
replace ccode = 817 if exporter == "Vietnam, S."
replace ccode = 817 if exporter == "Vietnam, S"
replace ccode = 817 if exporter == "Vietnam South"
replace ccode = 817 if exporter == "Vietnam, South"
replace ccode = 817 if exporter == "S. Vietnam"
replace ccode = 817 if exporter == "Republic of Vietnam"
// This is for Vietnam before French occupation
replace exporter = "Vietnam" if ccode==816
replace ccode = 815 if exporter == "Vietnam (Annam/Cochin China/Tonkin)"
replace ccode = 815 if exporter == "Vietnam/Annam/Cochin China/Tonkin"
replace ccode = 815 if exporter =="Vietnam" & year<1893 
replace ccode = 816 if ccode == 815 & year < 1893 /*because vietnam has a different ccode during this period*/

replace ccode = 271 if exporter == "Wuerttemburg"

/***************************
ccode numbers for Y-countries 
****************************/

replace ccode = 678 if exporter == "Yemen"
replace ccode = 678 if exporter == "Fm Yemen Dm"
replace ccode = 678 if exporter == "Yemen Arab Rep"
replace ccode = 678 if exporter == "Yemen Arab Rep."
replace ccode = 678 if exporter == "Yemen Arab Republic"
replace ccode = 678 if exporter == "Yemen (AR)"
replace ccode = 678 if exporter == "Yemen, N."
replace ccode = 678 if exporter == "Yemen, N"
replace ccode = 678 if exporter == "Yemen North"
replace ccode = 678 if exporter == "Yemen, Rep."
replace ccode = 678 if exporter == "Yemen, Republic of"
replace ccode = 678 if exporter == "Republic of (Southern Yemen))"
replace ccode = 680 if exporter == "Yemen, S."
replace ccode = 680 if exporter == "Yemen, S"
replace ccode = 680 if exporter == "Yemen South"
replace ccode = 680 if exporter == "Yemen, South"
replace ccode = 680 if exporter == "S. Yemen"
replace ccode = 680 if exporter == "Yemen P Dem Rep"
replace ccode = 680 if exporter == "Yemen People's Republic"
replace ccode = 680 if exporter == "Yemen, People's Democratic"
replace ccode = 680 if exporter == "Yemen (PDR)"
replace ccode = 680 if exporter == "Yemen, P.D.R."
replace ccode = 680 if exporter == "Fm Yemen AR"
replace ccode = 345 if exporter == "Yugoslavia" & year > 1917 & year < 2007
replace ccode = 345 if exporter == "Yugoslav" & year > 1917 & year < 2007
replace ccode = 345 if exporter == "Yugoslavia (FRY)" & year > 1917 & year < 2007
replace ccode = 345 if exporter == "Yugoslavia, FR" & year > 1917 & year < 2007
replace ccode = 345 if exporter == "Yugoslavia, SFR" & year > 1917 & year < 2007
replace ccode = 345 if exporter == "Yugoslavia, Federal Republic of" & year > 1917 & year < 2007
replace ccode = 345 if exporter == "Former Yugoslavia, Socialist Fed. Rep." & year > 1917 & year < 2007
replace ccode = 345 if exporter == "Serbia/Yugoslavia" & year > 1917 & year < 2007
replace ccode = 345 if exporter == "Yugoslavia (Serbia)" & year > 1917 & year < 2007
replace ccode = 345 if exporter == "SFR of Yugoslavia (former)" & year > 1917 & year < 2007
replace ccode = 345 if exporter == "Yugoslavia -91" & year > 1917 & year < 2007

// For observations that should be Serbia
replace ccode = 340 if exporter == "Yugoslavia" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode = 340 if exporter == "Yugoslav" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode = 340 if exporter == "Yugoslavia (FRY)" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode = 340 if exporter == "Yugoslavia, FR" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode = 340 if exporter == "Yugoslavia, SFR" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode = 340 if exporter == "Yugoslavia, Federal Republic of" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode = 340 if exporter == "Former Yugoslavia, Socialist Fed. Rep." & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode = 340 if exporter == "Serbia/Yugoslavia" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode = 340 if exporter == "Yugoslavia (Serbia)" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode = 340 if exporter == "SFR of Yugoslavia (former)" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode = 340 if exporter == "Yugoslavia -91" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))

/***************************
ccode numbers for Z-countries 
****************************/

replace ccode = 551 if exporter == "Zambia"
replace ccode = 511 if exporter == "Zanzibar"
replace ccode = 552 if exporter == "Zimbabwe"
replace ccode = 552 if exporter == "Zimbabwe (Rhodesia)"

************importers******************
replace ccode2= 0 if importer == "World"
replace ccode2=  2 if importer=="USA";
replace ccode2= 20 if importer=="Canada";
replace ccode2= 31 if importer=="Bahamas";
replace ccode2= 40 if importer=="Cuba";
replace ccode2= 41 if importer=="Haiti";
replace ccode2= 42 if importer=="Dominica";
replace ccode2= 51 if importer=="Jamaica";
replace ccode2= 52 if importer=="Trinidad Tbg";
replace ccode2= 53 if importer=="Barbados";
*replace ccode2= 54 if importer=="DMA";
*replace ccode2= 55 if importer=="GRD";
*replace ccode2= 56 if importer=="LCA";
*replace ccode2= 57 if importer=="VCT";
*replace ccode2= 58 if importer=="ATG";
*replace ccode2= 60 if importer=="KNA";
replace ccode2= 70 if importer=="Mexico";
replace ccode2= 80 if importer=="Belize";
replace ccode2= 90 if importer=="Guatemala";
replace ccode2= 91 if importer=="Honduras";
replace ccode2= 92 if importer=="El Salvador";
replace ccode2= 93 if importer=="Nicaragua";
*replace ccode2= 94 if importer=="CRI";
replace ccode2= 95 if importer=="Panama";
replace ccode2=100 if importer=="Colombia";
replace ccode2=101 if importer=="Venezuela";
replace ccode2=110 if importer=="Guyana";
replace ccode2=115 if importer=="Suriname";
replace ccode2=130 if importer=="Ecuador";
replace ccode2=135 if importer=="Peru";
replace ccode2=140 if importer=="Brazil";
replace ccode2=145 if importer=="Bolivia";
replace ccode2=150 if importer=="Paraguay";
replace ccode2=155 if importer=="Chile";
replace ccode2=160 if importer=="Argentina";
replace ccode2=165 if importer=="Uruguay";
replace ccode2=200 if importer=="UK";
replace ccode2=205 if importer=="Ireland";
replace ccode2=210 if importer=="Netherlands";
replace ccode2=211 if importer=="Belgium-Lux";
*replace ccode2=212 if importer=="LUX";
replace ccode2=220 if importer=="France";
replace ccode2=220 if importer=="France,Monac";
*replace ccode2=221 if importer=="MCO";
*replace ccode2=223 if importer=="LIE";
replace ccode2=225 if importer=="CHE";
replace ccode2=230 if importer=="Spain";
*replace ccode2=232 if importer=="AND";
replace ccode2=235 if importer=="Portugal";
replace ccode2=255 if importer=="Germany";
replace ccode2=255 if importer=="Fm German FR";
replace ccode2=290 if importer=="Poland";
replace ccode2=305 if importer=="Austria";
replace ccode2=310 if importer=="Hungary";
replace ccode2=316 if importer=="Czechoslav";
replace ccode2=316 if importer=="Czech Republic";
replace ccode2=317 if importer=="Slovak Republic";
replace ccode2=325 if importer=="Italy";
*replace ccode2=331 if importer=="SMR";
replace ccode2=338 if importer=="Malta";
replace ccode2=339 if importer=="Albania";
replace ccode2=343 if importer=="Macedonia";
replace ccode2=344 if importer=="Croatia";
replace ccode2=345 if importer=="Fm Yugoslav";
replace ccode2=346 if importer=="Bosnia";
replace ccode2=349 if importer=="Slovenia";
replace ccode2=350 if importer=="Greece";
replace ccode2=352 if importer=="Cyprus";
replace ccode2=355 if importer=="Bulgaria";
replace ccode2=359 if importer=="Moldavia";
replace ccode2=360 if importer=="Romania";
replace ccode2=365 if importer=="Russia";
replace ccode2=365 if importer=="Fm USSR";
replace ccode2=366 if importer=="Estonia";
replace ccode2=367 if importer=="Latvia";
replace ccode2=368 if importer=="Lituania";
replace ccode2=369 if importer=="Ukraine";
replace ccode2=370 if importer=="Belarus";
replace ccode2=371 if importer=="Armenia";
replace ccode2=372 if importer=="Georgia";
replace ccode2=373 if importer=="Azerbajan";
replace ccode2=375 if importer=="Finland";
replace ccode2=380 if importer=="Sweden";
replace ccode2=385 if importer=="Norway";
replace ccode2=390 if importer=="Denmark";
replace ccode2=395 if importer=="Iceland";
replace ccode2 = 396 if importer == "Abkhazia"
replace ccode2 = 700 if importer == "Afghanistan"
replace ccode2 = 700 if importer == "Afganistan"
replace ccode2 = 700 if importer == "Afghanistan, Islamic Republic of"
replace ccode2 = 700 if importer == "Afghanistan, Islamic Rep. of (Afghanistan)"
replace ccode2 = 700 if importer == "Afghanistan(1992-)"
replace ccode2 = 339 if importer == "Albania"
replace ccode2 = 615 if importer == "Algeria"
replace ccode2 = 232 if importer == "Andorra"
replace ccode2 = 540 if importer == "Angola"
replace ccode2 = .   if importer == "Anguilla"
replace ccode2 = 58  if importer == "Antigua and Barbuda"
replace ccode2 = 58  if importer == "Antigua"
replace ccode2 = 58  if importer == "Antigua & Barbuda"
replace ccode2 = 58  if importer == "Antigua & B"
replace ccode2 = 160 if importer == "Argentina"
replace ccode2 = 160 if importer == "Argentin"
replace ccode2 = 371 if importer == "Armenia"
replace ccode2 = 371 if importer == "Armenia, Republic of"
replace ccode2 = .   if importer == "Aruba"
replace ccode2 = 900 if importer == "Australia"
replace ccode2 = 900 if importer == "Australia*"
replace ccode2 = 305 if importer == "Austria"
replace ccode2 = 305 if importer == "Austria*"
replace ccode2 = 300 if importer == "Austria-Hungary"
replace ccode2 = 373 if importer == "Azerbaijan"
replace ccode2 = 373 if importer == "Azerbaijan, Republic of"

/***************************
ccode2 numbers for B-countries 
****************************/

replace ccode2 = 267 if importer == "Baden"
replace ccode2 = 31  if importer == "Bahamas"
replace ccode2 = 31  if importer == "Bahamas, The"
replace ccode2 = 692 if importer == "Bahrain"
replace ccode2 = 692 if importer == "Bahrain, Kingdom of"
replace ccode2 = 692 if importer == "Bahrein"
replace ccode2 = 771 if importer == "Bangladesh"
replace ccode2 = 53  if importer == "Barbados"
replace ccode2 = 245 if importer == "Bavaria"
replace ccode2 = 370 if importer == "Belarus"
replace ccode2 = 370 if importer == "Byelorussia"
replace ccode2 = 211 if importer == "Belgium"
replace ccode2 = 211 if importer == "Belgo-Luxembourg Economic Union"
replace ccode2 = 80  if importer == "Belize"
replace ccode2 = 434 if importer == "Benin"
replace ccode2 = 434 if importer == "Benin (Dahomey)"
replace ccode2 = 760 if importer == "Bhutan"
replace ccode2 = 145 if importer == "Bolivia"
replace ccode2 = 346 if importer == "Bosnia"
replace ccode2 = 346 if importer == "Bosnia-Hercegovina"
replace ccode2 = 346 if importer == "Bosnia-Hercegovenia"
replace ccode2 = 346 if importer == "Bosnia-Herz"
replace ccode2 = 346 if importer == "Bosnia-Herzegovina"
replace ccode2 = 346 if importer == "Bosnia-Herz."
replace ccode2 = 346 if importer == "Bosnia and Herzegovina"
replace ccode2 = 346 if importer == "Bosnia & Herzegovina"
replace ccode2 = 346 if importer == "Bosnia Herzegovenia"
replace ccode2 = 346 if importer == "Bosnia Herzg"
replace ccode2 = 571 if importer == "Botswana"
replace ccode2 = 140 if importer == "Brazil"
replace ccode2 = 835 if importer == "Brunei"
replace ccode2 = 835 if importer == "Brunei Darussalam"
replace ccode2 = 355 if importer == "Bulgaria"
replace ccode2 = 439 if importer == "Burkina Faso"
replace ccode2 = 439 if importer == "Burkina Faso (Upper Volta)"
replace ccode2 = 516 if importer == "Burundi"

/***************************
ccode2 numbers for C-countries 
****************************/

replace ccode2 = 811 if importer == "Cambodia"
replace ccode2 = 811 if importer == "Kampuchea"
replace ccode2 = 811 if importer == "Kampuchea, Democratic"
replace ccode2 = 811 if importer == "Cambodia (Kampuchea)"
replace ccode2 = 471 if importer == "Cameroon"
replace ccode2 = 471 if importer == "Cameroun"
replace ccode2 = 20  if importer == "Canada"
replace ccode2 = 402 if importer == "Cape Verde Is"
replace ccode2 = 402 if importer == "Cape Verde Is."
replace ccode2 = 402 if importer == "Cape Verde"
replace ccode2 = 402 if importer == "C. Verde Is."
replace ccode2 = 482 if importer == "Central African Republic"
replace ccode2 = 482 if importer == "Central African Rep"
replace ccode2 = 482 if importer == "Central African Rep."
replace ccode2 = 482 if importer == "Cent. Af. Rep."
replace ccode2 = 482 if importer == "Cen African Rep"
replace ccode2 = 482 if importer == "C.A.R."
replace ccode2 = 483 if importer == "Chad"
replace ccode2 = 155 if importer == "Chile"
replace ccode2 = 710 if importer == "China"
replace ccode2 = 710 if importer == "China P Rep"
replace ccode2 = 710 if importer == "China, PR"
replace ccode2 = 710 if importer == "China, P.R.: Mainland"
replace ccode2 = 710 if importer == "PRC"
replace ccode2 = 100 if importer == "Colombia"
replace ccode2 = 100 if importer == "Columbia"
replace ccode2 = 581 if importer == "Comoros"
replace ccode2 = 581 if importer == "Comoro Is."
replace ccode2 = 581 if importer == "Comoro Is"
replace ccode2 = 484 if importer == "Congo"
replace ccode2 = 484 if importer == "Congo, Rep."
replace ccode2 = 484 if importer == "Congo, Rep. of"
replace ccode2 = 484 if importer == "Congo, Republic of"
replace ccode2 = 484 if importer == "Congo Republic"
replace ccode2 = 484 if importer == "Congo (Republic)"
replace ccode2 = 484 if importer == "Rep. Congo"
replace ccode2 = 484 if importer == "Congo, Rep. of the"
replace ccode2 = 484 if importer == "CongoRep"
replace ccode2 = 484 if importer == "Congo (Brazzaville)"
replace ccode2 = 484 if importer == "Congo, Brazzaville"
replace ccode2 = 484 if importer == "Congo Brazzaville"
replace ccode2 = 484 if importer == "Congo (Brazzaville,Rep. of Congo)"
replace ccode2 = 484 if importer == "Congo (Brazzaville, Republic of Congo)"
replace ccode2 = 484 if importer == "Congo, Republic of (Brazzaville)"
replace ccode2 = 490 if importer == "Congo (Kinshasa)"
replace ccode2 = 490 if importer == "Congo Kinshasa"
replace ccode2 = 490 if importer == "Congo, Kinshasa"
replace ccode2 = 490 if importer == "Dem.Rp.Congo"
replace ccode2 = 490 if importer == "Congo, Democratic Republic of"
replace ccode2 = 490 if importer == "Congo, Democratic Republic"
replace ccode2 = 490 if importer == "Congo, the Democratic Republic of the"
replace ccode2 = 490 if importer == "Congo, Dem. Rep."
replace ccode2 = 490 if importer == "Congo (Democratic Republic)"
replace ccode2 = 490 if importer == "Congo/Zaire"
replace ccode2 = 490 if importer == "Congo, Democratic Republic of (Zaire)" 
replace ccode2 = 490 if importer == "Congo, Democratic Republic of the Za?re)" 
replace ccode2 = 490 if importer == "CongoDemRep"
replace ccode2 = 490 if importer == "Democratic Republic of the Congo"
replace ccode2 = 490 if importer == "Zaire"
replace ccode2 = 490 if importer == "Zaire/Congo Dem Rep"
replace ccode2 = 490 if importer == "Zaire (Democ Republic Congo)"
replace ccode2 = 490 if importer == "Zaire (Congo after 1997)"
replace ccode2 = 94  if importer == "Costa Rica"
replace ccode2 = 437 if importer == "Cote Divoire"
replace ccode2 = 437 if importer == "Cote d'Ivoire"
replace ccode2 = 437 if importer == "Côte d'Ivoire"
replace ccode2 = 437 if importer == "Cote d`Ivoire"
replace ccode2 = 437 if importer == "Cote D'Ivoire"
replace ccode2 = 437 if importer == "C?e d'Ivoire"
replace ccode2 = 437 if importer == "C?te d'Ivoire (Ivory Coast)"
replace ccode2 = 437 if importer == "C??te d'Ivoire"
replace ccode2 = 437 if importer == "Cote dIvoire"
replace ccode2 = 437 if importer == "Ivory Coast"
replace ccode2 = 344 if importer == "Croatia"
replace ccode2 = 40  if importer == "Cuba"
replace ccode2 = 352 if importer == "Cyprus"
replace ccode2 = 352 if importer == "Cyprus (Greek)"
replace ccode2 = 352 if importer == "Cyprus (G)"
replace ccode2 = .   if importer == "Cyprus (Turkey)"
replace ccode2 = .   if importer == "Turk Cyprus"
replace ccode2 = 315 if importer == "Czechoslovak"
replace ccode2 = 315 if importer == "Czechoslovakia"
replace ccode2 = 315 if importer == "Czechoslavakia"
replace ccode2 = 315 if importer == "Former Czechoslovakia"
replace ccode2 = 316 if importer == "Czech Rep"
replace ccode2 = 316 if importer == "Czech Rep."
replace ccode2 = 316 if importer == "Czech Republic"
replace ccode2 = 316 if importer == "CzechRepublic"
replace ccode2 = 316 if importer == "Czech Rep (C-Slv.)"

/***************************
ccode2 numbers for D-countries 
****************************/

replace ccode2 = 390 if importer == "Denmark"
replace ccode2 = 390 if importer == "Denmark*"
replace ccode2 = 522 if importer == "Djibouti"
replace ccode2 = 54  if importer == "Dominica"
replace ccode2 = 42  if importer == "Dom. Rep."
replace ccode2 = 42  if importer == "Dom Rep"
replace ccode2 = 42  if importer == "Dominican Rep"
replace ccode2 = 42  if importer == "Dominican Republic"
replace ccode2 = 42  if importer == "Dominican Rep."
replace ccode2 = 42  if importer == "Dominican Rp"


/***************************
ccode2 numbers for E-countries 
****************************/

replace ccode2 = 860 if importer == "East Timor"
replace ccode2 = 860 if importer == "East Timor (Timor-Leste)"
replace ccode2 = 860 if importer == "Timor-Leste"
replace ccode2 = 860 if importer == "Timor-Leste, Dem. Rep. of"
replace ccode2 = 860 if importer == "TimorLeste"
replace ccode2 = 860 if importer == "Timor-Leste (East Timor)"
replace ccode2 = 130 if importer == "Ecuador"
replace ccode2 = 651 if importer == "Egypt"
replace ccode2 = 651 if importer == "Egypt, Arab Rep."
replace ccode2 = 651 if importer == "EgyptArabRep"
replace ccode2 = 92  if importer == "El Salvador"
replace ccode2 = 92  if importer == "ElSalvador"
replace ccode2 = 92  if importer == "Salvador"
replace ccode2 = 411 if importer == "Equatorial Guinea"
replace ccode2 = 411 if importer == "Eq. Guinea"
replace ccode2 = 411 if importer == "Eq.Guinea"
replace ccode2 = 531 if importer == "Eritrea"
replace ccode2 = 366 if importer == "Estonia"
replace ccode2 = 530 if importer == "Ethiopia (former)"
replace ccode2 = 530 if importer == "Ethiopia"

/***************************
ccode2 numbers for F-countries 
****************************/

replace ccode2 = 987 if importer == "Federated States of Micronesia"
replace ccode2 = 950 if importer == "Fiji"
replace ccode2 = 375 if importer == "Finland"
replace ccode2 = 220 if importer == "France"

/***************************
ccode2 numbers for G-countries 
****************************/

replace ccode2 = 481 if importer == "Gabon"
replace ccode2 = 420 if importer == "Gambia"
replace ccode2 = 420 if importer == "Gambia The"
replace ccode2 = 420 if importer == "Gambia, The"
replace ccode2 = 372 if importer == "Georgia"
replace ccode2 = 260 if importer == "Germany" 
replace ccode2 = 260 if importer == "Germany Fed Rep"
replace ccode2 = 260 if importer == "German Federal Republic"
replace ccode2 = 260 if importer == "FRG/Germany"
replace ccode2 = 260 if importer == "Germany, W."
replace ccode2 = 260 if importer == "Germany West"
replace ccode2 = 260 if importer == "Germany, FR"
replace ccode2 = 260 if importer == "FR Germany"
replace ccode2 = 265 if importer == "Germany Dem Rep"
replace ccode2 = 265 if importer == "Germany DR"
replace ccode2 = 265 if importer == "Fm German DR"
replace ccode2 = 265 if importer == "GDR"
replace ccode2 = 265 if importer == "Germany, E."
replace ccode2 = 265 if importer == "East Germany"
replace ccode2 = 265 if importer == "Germany East"
replace ccode2 = 265 if importer == "German Democratic Republic"
replace ccode2 = 260 if ccode2 == 255 & year < 1946 /*pre-WWII, Germany/Prussia has a different number*/
replace ccode2 = 452 if importer == "Ghana"
replace ccode2 = 99  if importer == "Great Colombia"
replace ccode2 = 99  if importer == "Gran Colombia"
replace ccode2 = 350 if importer == "Greece"
replace ccode2 = 55  if importer == "Grenada"
replace ccode2 = 90  if importer == "Guatemala"
replace ccode2 = 438 if importer == "Guinea"
replace ccode2 = 438 if importer == "Guineau"
replace ccode2 = 404 if importer == "GuineaBissau"
replace ccode2 = 404 if importer == "Guinea Bissau"
replace ccode2 = 404 if importer == "Guinea-Bissau"
replace ccode2 = 404 if importer == "Guinea-Bisau"
replace ccode2 = 110 if importer == "Guyana"

/***************************
ccode2 numbers for H-countries 
****************************/

replace ccode2 = 41   if importer == "Haiti"
replace ccode2 = 240  if importer == "Hanover"
replace ccode2 = 273  if importer == "Hesse Electoral"
replace ccode2 = 273  if importer == "Hesse-Kassel"
replace ccode2 = 275  if importer == "Hesse Grand Ducal"
replace ccode2 = 275  if importer == "Hesse-Darmstadt"
replace ccode2 = 91   if importer == "Honduras"
replace ccode2 = 708 if importer == "Hong Kong"
replace ccode2 = 708 if importer == "Hong-Kong"
replace ccode2 = 708 if importer == "Hong Kong (SAR China)"
replace ccode2 = 708 if importer == "HongKong"
replace ccode2 = 708 if importer == "Hong Kong (China)"
replace ccode2 = 708 if importer == "Hong Kong, China"
replace ccode2 = 708 if importer == "China, P.R.: Hong Kong"
replace ccode2 = 708 if importer == "China,P.R.:Hong Kong"
replace ccode2 = 708 if importer == "Hong Kong, China"
replace ccode2 = 708 if importer == "HongKongSARChina"
replace ccode2 = 708 if importer == "Hong Kong SAR, China"
replace ccode2 = 708 if importer == "China, Hong Kong Special Administrative Region"
replace ccode2 = 310  if importer == "Hungary"

/***************************
ccode2 numbers for I-countries 
****************************/

replace ccode2 = 395 if importer == "Iceland"
replace ccode2 = 750 if importer == "India"
replace ccode2 = 850 if importer == "Indonesia"
replace ccode2 = 850 if importer == "Indonesia including East Timor"
replace ccode2 = 630 if importer == "Iran"
replace ccode2 = 630 if importer == "Iran (Persia)"
replace ccode2 = 630 if importer == "Iran Islam Rep"
replace ccode2 = 630 if importer == "Iran, Islamic Rep."
replace ccode2 = 630 if importer == "Iran, Islamic Republic of"
replace ccode2 = 630 if importer == "Iran, Islamic Republic of (Iran)"
replace ccode2 = 630 if importer == "Iran, I.R. of"
replace ccode2 = 630 if importer == "Islamic Rep. of Iran"
replace ccode2 = 630 if importer == "IranIslamicRep"
replace ccode2 = 630 if importer == "Iran (Islamic Republic of)"
replace ccode2 = 645 if importer == "Iraq"
replace ccode2 = 205 if importer == "Ireland"
replace ccode2 = 666 if importer == "Israel"
replace ccode2 = 325 if importer == "Italy"
replace ccode2 = 325 if importer == "Italy*"
replace ccode2 = 325 if importer == "Italy/Sardinia"

/***************************
ccode2 numbers for J-countries 
****************************/

replace ccode2 = 51  if importer == "Jamaica"
replace ccode2 = 740 if importer == "Japan"
replace ccode2 = 663 if importer == "Jordan"

/***************************
ccode2 numbers for K-countries 
****************************/

replace ccode2 = 705 if importer == "Kazakhstan"
replace ccode2 = 705 if importer == "Khazakhstan"
replace ccode2 = 501 if importer == "Kenya"
replace ccode2 = 970 if importer == "Kiribati"
replace ccode2 = 730 if importer == "Korea"
replace ccode2 = 731 if importer == "Korea, North"
replace ccode2 = 731 if importer == "Korea, N"
replace ccode2 = 731 if importer == "Korea (North)"
replace ccode2 = 731 if importer == "Korea North"
replace ccode2 = 731 if importer == "Korea D P Rp"
replace ccode2 = 731 if importer == "Korea Dem P Rep"
replace ccode2 = 731 if importer == "Korea, Dem. Rep."
replace ccode2 = 731 if importer == "Korea, Dem. People's Rep. of"
replace ccode2 = 731 if importer == "Dem. People's Rep. Korea"
replace ccode2 = 731 if importer == "Korea, Democratic People's Republic of"
replace ccode2 = 731 if importer == "Korea, DPR"
replace ccode2 = 731 if importer == "North Korea"
replace ccode2 = 731 if importer == "Democratic People's Republic of Korea"
replace ccode2 = 731 if importer == "PRK"
replace ccode2 = 732 if importer == "Korea (South)"
replace ccode2 = 732 if importer == "Korea Rep."
replace ccode2 = 730 if importer == "Korea"
replace ccode2 = 732 if importer == "Korea, South"
replace ccode2 = 732 if importer == "Korea, S"
replace ccode2 = 732 if importer == "Korea South"
replace ccode2 = 732 if importer == "Korea Rep"
replace ccode2 = 732 if importer == "Korea, Republic of"
replace ccode2 = 732 if importer == "Korea, Rep."
replace ccode2 = 732 if importer == "South Korea"
replace ccode2 = 732 if importer == "ROK"
replace ccode2 = 732 if importer == "Republic of Korea"
replace ccode2 = 732 if importer == "Korea, Republic Of"
replace ccode2 = 347 if importer == "Kosovo"
replace ccode2 = 690 if importer == "Kuwait"
replace ccode2 = 703 if importer == "Kyrgyzstan"
replace ccode2 = 703 if importer == "Kyrgyz Republic"
replace ccode2 = 703 if importer == "Kyrgyz Republic (Kyrgyzstan)"

/***************************
ccode2 numbers for L-countries 
****************************/

replace ccode2 = 812 if importer == "Laos"
replace ccode2 = 812 if importer == "Lao PDR"
replace ccode2 = 812 if importer == "Lao P Dem Rep"
replace ccode2 = 812 if importer == "Lao P.Dem.Rep"
replace ccode2 = 812 if importer == "Lao P.Dem.R"
replace ccode2 = 812 if importer == "Lao People's Democratic Republic"
replace ccode2 = 812 if importer == "Lao People's Democratic Republic (Laos)"
replace ccode2 = 367 if importer == "Latvia"
replace ccode2 = 660 if importer == "Lebanon"
replace ccode2 = 570 if importer == "Lesotho"
replace ccode2 = 450 if importer == "Liberia"
replace ccode2 = 620 if importer == "Libya"
replace ccode2 = 620 if importer == "Libyan Arab Jamah"
replace ccode2 = 620 if importer == "Libya Arab Jamahiriy"
replace ccode2 = 620 if importer == "Libyan Arab Jamahiriya"
replace ccode2 = 223 if importer == "Liechtenstein"
replace ccode2 = 368 if importer == "Lithuania"
replace ccode2 = 212 if importer == "Luxembourg"

/***************************
ccode2 numbers for M-countries 
****************************/

replace ccode2 = 709 if importer == "Macao SAR, China"
replace ccode2 = 709 if importer == "Macao"
replace ccode2 = 709 if importer == "Macao (SAR China)"
replace ccode2 = 709 if importer == "China, P.R.: Macao"
replace ccode2 = 709 if importer == "China, Macao Special Administrative Region"
replace ccode2 = 343 if importer == "Macedonia"
replace ccode2 = 343 if importer == "TFYR Macedna"
replace ccode2 = 343 if importer == "TFYR of Macedonia"
replace ccode2 = 343 if importer == "Macedonia FRY"
replace ccode2 = 343 if importer == "Macedonia, FYR"
replace ccode2 = 343 if importer == "FYR Macedonia"
replace ccode2 = 343 if importer == "Macedonia, the Former Yugoslav Republic of"
replace ccode2 = 343 if importer == "Macedonia, former Yugoslav Republic of"
replace ccode2 = 580 if importer == "Madagascar"
replace ccode2 = 580 if importer == "Madagascar (Malagasy Republic)"
replace ccode2 = 580 if importer == "Madagascar (Malagasy)"
replace ccode2 = 553 if importer == "Malawi"
replace ccode2 = 820 if importer == "Malaysia"
replace ccode2 = 820 if importer == "Malaysia (Malaya)"
replace ccode2 = 781 if importer == "Maldives"
replace ccode2 = 432 if importer == "Mali"
replace ccode2 = 432 if importer == "Marli"
replace ccode2 = 338 if importer == "Malta"
replace ccode2 = 983 if importer == "Marshall Is"
replace ccode2 = 983 if importer == "Marshall Islands"
replace ccode2 = 983 if importer == "Marshall Islan"
replace ccode2 = 983 if importer == "Marshall Islands, Republic of"
replace ccode2 = 435 if importer == "Mauritania"
replace ccode2 = 590 if importer == "Mauritius"
replace ccode2 = 280 if importer == "Mecklenburg Schwerin"
replace ccode2 = 70  if importer == "Mexico"
replace ccode2 = 987 if importer == "Micronesia"
replace ccode2 = 987 if importer == "Micronesia Fed States"
replace ccode2 = 987 if importer == "Micronesia, Fed. States"
replace ccode2 = 987 if importer == "Micronesia, Fed. Sts."
replace ccode2 = 987 if importer == "Micronesia, Fed Stat"
replace ccode2 = 987 if importer == "Micronesia, Federated States of"
replace ccode2 = 987 if importer == "Federated States of Micronesia"
replace ccode2 = 332 if importer == "Modena"
replace ccode2 = 359 if importer == "Moldova"
replace ccode2 = 359 if importer == "Republic of Moldova"
replace ccode2 = 359 if importer == "Moldova Rep"
replace ccode2 = 359 if importer == "Moldova, Republic Of"
replace ccode2 = 359 if importer == "Republic Of Moldova"
replace ccode2 = 221 if importer == "Monaco"
replace ccode2 = 712 if importer == "Mongolia"
replace ccode2 = 341 if importer == "Montenegro"
replace ccode2 = .   if importer == "Montserrat"
replace ccode2 = 600 if importer == "Morocco"
replace ccode2 = 541 if importer == "Mozambique"
replace ccode2 = 775 if importer == "Myanmar"
replace ccode2 = 775 if importer == "Myanmar (Burma)"
replace ccode2 = 775 if importer == "Myanmar(Burma)"
replace ccode2 = 775 if importer == "Burma (Myanmar)"
replace ccode2 = 775 if importer == "Burma"

/***************************
ccode2 numbers for N-countries 
****************************/

replace ccode2 = 565 if importer == "Namibia"
replace ccode2 = 971 if importer == "Nauru"
replace ccode2 = 790 if importer == "Nepal"
replace ccode2 = 210 if importer == "Netherlands"
replace ccode2 = . if importer == "Netherlands Antilles"
replace ccode2 = 920 if importer == "New Zealand"	
replace ccode2 = 93  if importer == "Nicaragua"
replace ccode2 = 436 if importer == "Niger"
replace ccode2 = 475 if importer == "Nigeria"
replace ccode2 = 385 if importer == "Norway"

/***************************
ccode2 numbers for O and P counttries 
****************************/

replace ccode2 = 698 if importer == "Oman"
replace ccode2 = 564 if importer == "Orange Free State"

replace ccode2 = 770 if importer == "Pakistan"
replace ccode2 = 770 if importer == "Pakistan, (1972-)"
replace ccode2 = 986 if importer == "Palau"
replace ccode2 = 95  if importer == "Panama"
replace ccode2 = 95  if importer == "Panama Canal Zone"
replace ccode2 = 327 if importer == "Papal States"
replace ccode2 = 910 if importer == "Papua New Guinea"
replace ccode2 = 910 if importer == "Papua New Guinea"
replace ccode2 = 910 if importer == "Papua N.Guin"
replace ccode2 = 910 if importer == "P. N. Guinea"
replace ccode2 = 150 if importer == "Paraguay"
replace ccode2 = 335 if importer == "Parma"
replace ccode2 = 135 if importer == "Peru"
replace ccode2 = 840 if importer == "Philipines"
replace ccode2 = 840 if importer == "Philippines" 
replace ccode2 = 840 if importer == "Phillippines"
replace ccode2 = 840 if importer == "Philippi"
replace ccode2 = 290 if importer == "Poland"
replace ccode2 = 235 if importer == "Portugal"
replace ccode2 = 255 if importer == "Prussia"

/***************************
ccode2 numbers for Q and R-countries 
****************************/

replace ccode2 = 694 if importer == "Qatar"

replace ccode2 = 360 if importer == "Romania"
replace ccode2 = 360 if importer == "Rumania"
replace ccode2 = 365 if importer == "Russia"
replace ccode2 = 365 if importer == "Russian Fed"
replace ccode2 = 365 if importer == "Russian Federation"
replace ccode2 = 365 if importer == "USSR"
replace ccode2 = 365 if importer == "U.S.S.R."
replace ccode2 = 365 if importer == "Soviet Union"
replace ccode2 = 365 if importer == "Russia (Soviet Union)"
replace ccode2 = 365 if importer == "Russia (USSR)"
replace ccode2 = 517 if importer == "Rwanda"

/***************************
ccode2 numbers for S-countries 
****************************/

replace ccode2 = 403 if importer == "Sao Tome et Principe"
replace ccode2 = 403 if importer == "Sao Tome and principe"
replace ccode2 = 403 if importer == "Sao Tome"
replace ccode2 = 403 if importer == "S? Tom�and Principe"
replace ccode2 = 403 if importer == "Sao Tome & Principe"
replace ccode2 = 403 if importer == "Sao Tome & P"
replace ccode2 = 403 if importer == "Sao Tome and Principe"
replace ccode2 = 403 if importer == "S?o Tom? and Principe"
replace ccode2 = 403 if importer == "Sao Tom?E and Principe"
replace ccode2 = 403 if importer == "S?o Tom? and Pr?ncipe"
replace ccode2 = 60  if importer == "Saint Kitts and Nevis"
replace ccode2 = 60  if importer == "St. Kitts and Nevis"
replace ccode2 = 60  if importer == "St Kitts and Nevis"
replace ccode2 = 60  if importer == "St. Kitts & Nevis"
replace ccode2 = 60  if importer == "St. Kitts & N"
replace ccode2 = 60  if importer == "St.Kt-Nev-An";
replace ccode2 = 56  if importer == "Saint Lucia"
replace ccode2 = 56  if importer == "St. Lucia"
replace ccode2 = 56  if importer == "St Lucia"
replace ccode2 = 56  if importer == "StLucia"
replace ccode2 = 57  if importer == "Saint Vincent and the Grenadines"
replace ccode2 = 57  if importer == "St.Vincent & Grenadines"
replace ccode2 = 57  if importer == "St. Vin. & G"
replace ccode2 = 57  if importer == "St. Vincent and the Grenadines"
replace ccode2 = 57  if importer == "St. Vincent & Grenadine"
replace ccode2 = 57  if importer == "St. Vincent & Grenadines"
replace ccode2 = 57  if importer == "St Vincent and The Grenadines"
replace ccode2 = 57  if importer == "St Vincent and the Grenadines"
replace ccode2 = 57  if importer == "StVincentandtheGrenadines"
replace ccode2 = 57  if importer == "StVincentand"
replace ccode2 = 57  if importer == "St Vincent"
replace ccode2 = 990 if importer == "Samoa"
replace ccode2 = 990 if importer == "W. Samoa"
replace ccode2 = 990 if importer == "W Samoa"
replace ccode2 = 990 if importer == "Western Samoa"
replace ccode2 = 990 if importer == "Samoa (Western Samoa)"
replace ccode2 = 331 if importer == "San Marino"
replace ccode2 = 670 if importer == "Saudi Arabia"
replace ccode2 = 269 if importer == "Saxony"
replace ccode2 = 433 if importer == "Senegal"
replace ccode2 = 340 if importer == "Serbia" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode2 = 340 if importer == "Serbia, Republic of" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode2 = 340 if importer == "Serbia Montenegro" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode2 = 340 if importer == "Serbia & Montenegro" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode2 = 340 if importer == "SerbiaandMontenegro" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode2 = 340 if importer == "Serbia and Montenegro" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode2 = 340 if importer == "Serbia-Montenegro" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode2 = 340 if importer == "Serbia" & ((year < 1918 & year > 1877) | (year > 2006 & year != .)) 
replace ccode2 = 340 if importer == "SERBIA, REPUBLIC OF" & ((year < 1918 & year > 1877) | (year > 2006 & year != .)) 
replace ccode2 = 340 if importer == "Yugoslavia" & ((year < 1918 & year > 1877) | (year > 2006 & year != .)) 


// For observations that should be Yugoslavia 
replace ccode2 = 345 if importer == "Serbia" & year > 1917 & year < 2007
replace ccode2 = 345 if importer == "Serbia, Republic of" & year > 1917 & year < 2007
replace ccode2 = 345 if importer == "Serbia Montenegro" & year > 1917 & year < 2007
replace ccode2 = 345 if importer == "Serbia & Montenegro" & year > 1917 & year < 2007
replace ccode2 = 345 if importer == "SerbiaandMontenegro" & year > 1917 & year < 2007
replace ccode2 = 345 if importer == "Serbia and Montenegro" & year > 1917 & year < 2007
replace ccode2 = 345 if importer == "Yugoslavia" & year > 1917 & year < 2007
replace ccode2 = 345 if importer == "Serbia" & year > 1917 & year < 2007
replace ccode2 = 345 if importer == "SERBIA, REPUBLIC OF" & year > 1917 & year < 2007
replace ccode2 = 345 if importer == "Serbia and Montenegro" & year > 1917 & year < 2007

replace ccode2 = 591 if importer == "Seychelles"
replace ccode2 = 591 if importer == "Seychelle"
replace ccode2 = 451 if importer == "Sierra Leone"
replace ccode2 = 830 if importer == "Singapore"
replace ccode2 = 317 if importer == "Slovak Republic"
replace ccode2 = 317 if importer == "Slovakia"
replace ccode2 = 349 if importer == "Slovenia"
replace ccode2 = 940 if importer == "Solomon Is"
replace ccode2 = 940 if importer == "Solomon Is."
replace ccode2 = 940 if importer == "Solomon Islands"
replace ccode2 = 520 if importer == "Somalia"
replace ccode2 = 560 if importer == "South Africa"
replace ccode2 = 560 if importer == "SouthAfrica"
replace ccode2 = 560 if importer == "S. Africa"
replace ccode2 = 397 if importer == "South Ossetia"
replace ccode2 = 626 if importer == "South Sudan"
replace ccode2 = 626 if importer == "S. Sudan"
replace ccode2 = 626 if importer == "Sudan (South)"
replace ccode2 = 365 if importer == "Soviet Union"
replace ccode2 = 230 if importer == "Spain"
replace ccode2 = 780 if importer == "Sri Lanka"
replace ccode2 = 780 if importer == "Sri Lanka (Ceylon)"
replace ccode2 = 780 if importer == "SriLanka"
replace ccode2 = 625 if importer == "Sudan"
replace ccode2 = 115 if importer == "Suriname"
replace ccode2 = 115 if importer == "Surinam"
replace ccode2 = 572 if importer == "Swaziland"
replace ccode2 = 380 if importer == "Sweden"
replace ccode2 = 225 if importer == "Switzerland"
replace ccode2 = 225 if importer == "Switz.Liecht"
replace ccode2 = 652 if importer == "Syria"
replace ccode2 = 652 if importer == "Syrian Arab Rep"
replace ccode2 = 652 if importer == "Syrian Arab Republic"
replace ccode2 = 652 if importer == "SyrianArabRep"
replace ccode2 = 652 if importer == "Syrian Arab Republic (Syria)"

/***************************
ccode2 numbers for T-countries 
****************************/

replace ccode2 = 713 if importer == "Taiwan"
replace ccode2 = 713 if importer == "Taiwan (China)"
replace ccode2 = 713 if importer == "Taiwan, China"
replace ccode2 = 713 if importer == "Taiwan Province of China"
replace ccode2 = 713 if importer == "Taiwan, Republic of China on"   
replace ccode2 = 713 if importer == "TaiwanChina"
replace ccode2 = 713 if importer == "China, Taiwan Province of"
replace ccode2 = 713 if importer == "Chinese Taipei"
replace ccode2 = 702 if importer == "Tajikistan"
replace ccode2 = 510 if importer == "Tanzania"
replace ccode2 = 510 if importer == "Tanzania (Tanganyika)"
replace ccode2 = 510 if importer == "Tanzania Uni Rep"
replace ccode2 = 510 if importer == "Tanzania, United Rep. of"
replace ccode2 = 510 if importer == "Tanzania, United Rep.of"
replace ccode2 = 510 if importer == "Tanzania, United Rep. of "
replace ccode2 = 510 if importer == "Tanzania, United Rep. of "
replace ccode2 = 510 if importer == "Tanzania, United Republic of"
replace ccode2 = 510 if importer == "United Rep. of Tanzania"
replace ccode2 = 510 if importer == "United Republic of Tanzania"
replace ccode2 = 800 if importer == "Thailand"
replace ccode2 = 800 if importer == "Thailand (Siam)"
replace ccode2 = 711 if importer == "Tibet"
replace ccode2 = 461 if importer == "Togo"
replace ccode2 = 972 if importer == "Tonga"
replace ccode2 = 563 if importer == "Transvaal"
replace ccode2 = 52  if importer == "Trinidad-Tobago"
replace ccode2 = 52  if importer == "Trinidad and Tobago"
replace ccode2 = 52  if importer == "Trinidad & Tobago"
replace ccode2 = 52  if importer == "Trinidad & T"
replace ccode2 = 52  if importer == "Trinidad"
replace ccode2 = 616 if importer == "Tunisia"
replace ccode2 = 640 if importer == "Turkey"
replace ccode2 = 640 if importer == "Turkey/Ottoman Empire"
replace ccode2 = 640 if importer == "Turkey (Ottoman Empire)"
replace ccode2 = 701 if importer == "Turkmenistan"
replace ccode2 = 337 if importer == "Tuscany"
replace ccode2 = 973 if importer == "Tuvalu"
replace ccode2 = 329 if importer == "Two Sicilies"


/***************************
ccode2 numbers for U-countries 
****************************/

replace ccode2 = 500 if importer == "Uganda"
replace ccode2 = 500 if importer == "Ugandan"
replace ccode2 = 500 if importer == "Nogeria"
replace ccode2 = 369 if importer == "Ukraine"
replace ccode2 = 696 if importer == "Untd Arab Em"
replace ccode2 = 696 if importer == "United Arab Emirates"
replace ccode2 = 696 if importer == "Un. Arab Em."
replace ccode2 = 696 if importer == "UnitedArabEmirates"
replace ccode2 = 696 if importer == "UAE"
replace ccode2 = 696 if importer == "U.A.E."
replace ccode2 = 200 if importer == "United Kingdom"
replace ccode2 = 200 if importer == "UnitedKingdom"
replace ccode2 = 200 if importer == "UK"
replace ccode2 = 200 if importer == "U.K."
replace ccode2 = 89 if importer == "United Provinces of Central America"
replace ccode2 = 89 if importer == "United Province CA"
replace ccode2 = 2 	 if importer == "United States"
replace ccode2 = 2   if importer == "UnitedStates"
replace ccode2 = 2 	 if importer == "United States of America"
replace ccode2 = 2 	 if importer == "United States, America"
replace ccode2 = 2   if importer == "USA"
replace ccode2 = 165 if importer == "Uruguay"
replace ccode2 = 704 if importer == "Uzbekistan"


/***************************
ccode2 numbers for V and W-countries 
****************************/

replace ccode2 = 935 if importer == "Vanuatu"
replace ccode2 = . if importer == "Vatican City"
replace ccode2 = 101 if importer == "Venezuela"
replace ccode2 = 101 if importer == "Venezuela, RB"
replace ccode2 = 101 if importer == "Venezuela, R.B."
replace ccode2 = 101 if importer == "VenezuelaRB"
replace ccode2 = 101 if importer == "Venezuela (Bolivarian Republic of)"
replace ccode2 = 101 if importer == "Venezuela, Republica Bolivariana de"
replace ccode2 = 101 if importer == "Venezuela, Rep?blica Bolivariana de"
replace ccode2 = 816 if importer == "Vietnam, Democratic Republic of"
replace ccode2 = 816 if importer == "Vietnam, N."
replace ccode2 = 816 if importer == "Vietnam, North"
replace ccode2 = 816 if importer == "Vietnam, N"
replace ccode2 = 816 if importer == "N. Vietnam"
replace ccode2 = 816 if importer == "Vietnam North"
replace ccode2 = 816 if importer == "Vietnam, Socialist Republic of"  
replace ccode2 = 816 if importer == "Viet Nam"  
replace ccode2 = 816 if importer == "Vietnam"  
replace ccode2 = 817 if importer == "Vietnam, Republic of"
replace ccode2 = 817 if importer == "Vietnam, Republic of (South Vietnam)"
replace ccode2 = 817 if importer == "Vietnam, S."
replace ccode2 = 817 if importer == "Vietnam, S"
replace ccode2 = 817 if importer == "Vietnam South"
replace ccode2 = 817 if importer == "Vietnam, South"
replace ccode2 = 817 if importer == "S. Vietnam"
replace ccode2 = 817 if importer == "Republic of Vietnam"
// This is for Vietnam before French occupation
replace importer = "Vietnam" if ccode2==816
replace ccode2 = 815 if importer == "Vietnam (Annam/Cochin China/Tonkin)"
replace ccode2 = 815 if importer == "Vietnam/Annam/Cochin China/Tonkin"
replace ccode2 = 815 if importer =="Vietnam" & year<1893 
replace ccode2 = 816 if ccode2 == 815 & year < 1893 /*because vietnam has a different ccode2 during this period*/

replace ccode2 = 271 if importer == "Wuerttemburg"

/***************************
ccode2 numbers for Y-countries 
****************************/

replace ccode2 = 678 if importer == "Yemen"
replace ccode2 = 678 if importer == "Fm Yemen Dm"
replace ccode2 = 678 if importer == "Yemen Arab Rep"
replace ccode2 = 678 if importer == "Yemen Arab Rep."
replace ccode2 = 678 if importer == "Yemen Arab Republic"
replace ccode2 = 678 if importer == "Yemen (AR)"
replace ccode2 = 678 if importer == "Yemen, N."
replace ccode2 = 678 if importer == "Yemen, N"
replace ccode2 = 678 if importer == "Yemen North"
replace ccode2 = 678 if importer == "Yemen, Rep."
replace ccode2 = 678 if importer == "Yemen, Republic of"
replace ccode2 = 678 if importer == "Republic of (Southern Yemen))"
replace ccode2 = 680 if importer == "Yemen, S."
replace ccode2 = 680 if importer == "Yemen, S"
replace ccode2 = 680 if importer == "Yemen South"
replace ccode2 = 680 if importer == "Yemen, South"
replace ccode2 = 680 if importer == "S. Yemen"
replace ccode2 = 680 if importer == "Yemen P Dem Rep"
replace ccode2 = 680 if importer == "Yemen People's Republic"
replace ccode2 = 680 if importer == "Yemen, People's Democratic"
replace ccode2 = 680 if importer == "Yemen (PDR)"
replace ccode2 = 680 if importer == "Yemen, P.D.R."
replace ccode2 = 680 if importer == "Fm Yemen AR"
replace ccode2 = 345 if importer == "Yugoslavia" & year > 1917 & year < 2007
replace ccode2 = 345 if importer == "Yugoslav" & year > 1917 & year < 2007
replace ccode2 = 345 if importer == "Yugoslavia (FRY)" & year > 1917 & year < 2007
replace ccode2 = 345 if importer == "Yugoslavia, FR" & year > 1917 & year < 2007
replace ccode2 = 345 if importer == "Yugoslavia, SFR" & year > 1917 & year < 2007
replace ccode2 = 345 if importer == "Yugoslavia, Federal Republic of" & year > 1917 & year < 2007
replace ccode2 = 345 if importer == "Former Yugoslavia, Socialist Fed. Rep." & year > 1917 & year < 2007
replace ccode2 = 345 if importer == "Serbia/Yugoslavia" & year > 1917 & year < 2007
replace ccode2 = 345 if importer == "Yugoslavia (Serbia)" & year > 1917 & year < 2007
replace ccode2 = 345 if importer == "SFR of Yugoslavia (former)" & year > 1917 & year < 2007
replace ccode2 = 345 if importer == "Yugoslavia -91" & year > 1917 & year < 2007

// For observations that should be Serbia
replace ccode2 = 340 if importer == "Yugoslavia" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode2 = 340 if importer == "Yugoslav" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode2 = 340 if importer == "Yugoslavia (FRY)" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode2 = 340 if importer == "Yugoslavia, FR" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode2 = 340 if importer == "Yugoslavia, SFR" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode2 = 340 if importer == "Yugoslavia, Federal Republic of" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode2 = 340 if importer == "Former Yugoslavia, Socialist Fed. Rep." & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode2 = 340 if importer == "Serbia/Yugoslavia" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode2 = 340 if importer == "Yugoslavia (Serbia)" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode2 = 340 if importer == "SFR of Yugoslavia (former)" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
replace ccode2 = 340 if importer == "Yugoslavia -91" & ((year < 1918 & year > 1877) | (year > 2006 & year != .))
