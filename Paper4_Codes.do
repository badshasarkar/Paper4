*Sarkar, B. (2025). An assessment of the impact of temporary migration on household adaptive capacity to climate
///variability (e.g., drought) in rural India. Rural and Regional Development, 3(3), 10010.
///https://doi.org/10.70322/rrd.2025.10010

*psm
clear 

*merge hhh data 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012in"
keep STATEID DISTID PSUID HHID HHSPLITID RO4 RO3 RO5 RO6 HHEDUC 
keep if RO4 == 1 
duplicates drop STATEID DISTID PSUID HHID HHSPLITID, force 
sort STATEID DISTID PSUID HHID HHSPLITID
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012in.hhh", replace
clear

use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012hh"
sort STATEID DISTID PSUID HHID HHSPLITID
merge 1:1 STATEID DISTID PSUID HHID HHSPLITID using "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012in.hhh", gen (_merge1)
keep if _merge1 == 3
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

*merge 1 year migration variable 
clear
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012in"
keep if MGYEAR1 == 1
duplicates report STATEID DISTID PSUID HHID HHSPLITID
duplicates list STATEID DISTID PSUID HHID HHSPLITID
duplicates drop STATEID DISTID PSUID HHID HHSPLITID, force 
keep STATEID DISTID PSUID HHID HHSPLITID MGYEAR1
sort STATEID DISTID PSUID HHID HHSPLITID
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012in.migra", replace 
clear 

use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
sort STATEID DISTID PSUID HHID HHSPLITID
merge 1:1 STATEID DISTID PSUID HHID HHSPLITID using "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012in.migra", gen (_merge2)
drop if _merge2 == 2
recode MGYEAR1 (1=1) (.=0), gen (MIGRA)
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

* remove urban households 
tab URBAN2011, missing 
keep if URBAN2011 == 0
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

* merge drought data
clear
import excel "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\drought1.xlsx", sheet("Sheet3") firstrow
keep ST_NM STATEID DISTID dy40
sort STATEID DISTID
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\drought1", replace
clear 

use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
sort STATEID DISTID 
merge m:m STATEID DISTID using "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\drought1", gen (_merge3)
drop if _merge3 == 2
recode dy40 (0=0) (1=1) (3=1) (.=0), gen (DROUGHT)
tab DROUGHT
recode DROUGHT (0=1) (1=2)
tab DROUGHT
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

* covariates 
sum NPERSONS NNR ID11 ID13 ID14 COPC RO3 RO5 RO6 HHEDUC STATEID

drop if NPERSONS == .
drop if NNR == .
drop if ID11 == .
drop if ID13 == .
drop if ID14 == .
drop if COPC == .
drop if RO3 == .
drop if RO5 == .
drop if RO6 == .
drop if HHEDUC == .
drop if STATEID == .

/*
NPERSONS = HQ4 2.0 N in household 
NNR = HQ5 3.0 N Household non-residents
ID11 = HQ3 1.11 Religion / RELIG
ID13 = HQ3 1.13 Caste category / SOCIAL
ID14 = HQ3 1.14 Main income source / OCCU
COPC = HQ23 14. Household expenditure /capita / MPCE 
RO3 = HQ4 2.3 Sex / SEX
RO5 = HQ4 2.5 Age / AGE
RO6 = HQ4 2.6 Marital Status / MARITAL
HHEDUC = HQ19 11.6 Highest adult Education / EDU
STATEID = State code
FM4A = HQ7 5.4a Owned kharif
FM4B = HQ7 5.4b Owned rabi
FM4C = HQ7 5.4c Owned summer
FM3 = HQ7 5.3 Local units/acre
*/
tab NPERSONS
tab NNR
recode NNR (1/9=1) (0=2)
tab NNR 
tab ID11
recode ID11 (1=1) (2=2) (3/9=3), gen (RELIG)
tab RELIG
tab ID13
recode ID13 (1=1) (2=1) (3=2) (4=3) (5=4) (6=1), gen (SOCIAL)
tab SOCIAL
tab ID14
recode ID14 (1/2=1) (5/10=2) (3=3) (4=4) (11=5), gen (OCCU)
tab OCCU
sum COPC
gen MPCE = (COPC/12)
sum MPCE
tab RO3
gen SEX = RO3
tab SEX
tab RO5
gen AGE = RO5
tab AGE
tab RO6
recode RO6 (0=1) (1=1) (2=2) (3=3) (4=4) (5=1), gen (MARITAL) 
tab MARITAL
tab HHEDUC
recode HHEDUC (0=1) (1/5=2) (6/10=3) (11/16=4), gen (EDU)
tab EDU
sum NPERSONS NNR RELIG SOCIAL OCCU MPCE SEX AGE MARITAL EDU STATEID
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

*variable land owned 
sum FM4A FM4B FM4C FM1
keep STATEID DISTID PSUID HHID HHSPLITID FM4A FM4B FM4C FM1
tab FM1, missing 
drop if FM1 == 0
gen delete = (FM4A+FM4B+FM4C+FM1)
tab delete, missing 
recode delete (.=10000), gen (delete2)
tab delete2, missing 
drop FM4A FM4B FM4C FM1 delete
sort STATEID DISTID PSUID HHID HHSPLITID
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\delete", replace
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
sort STATEID DISTID PSUID HHID HHSPLITID
merge 1:1 STATEID DISTID PSUID HHID HHSPLITID using "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\delete", gen (_merge4)
drop if delete2 == 10000
drop delete2
gen land = (((FM4A+FM4B+FM4C)/3)/FM3)
recode land (.=0), gen (LAND1)
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

/*
*variable mpce Deaton equilibrium scale 
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\dataset15"
gen ADULT = (NADULTM+NADULTF+NTEENM+NTEENF)
gen CHILD = (NCHILDM+NCHILDF)
gen NPERSONS1 = (ADULT+CHILD)
gen NPERSONSD = (NPERSONS-NPERSONS1)
gen ADULT1 = 1
gen ADULT2 = (ADULT-1)
gen ADULTD = (ADULT-ADULT1-ADULT2)
gen T = (ADULT1*1)+(ADULT2*0.7)+(CHILD*0.5)
gen MPCED = (COTOTAL/T)
xtile MPCED5 = MPCED, nq(5)
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\dataset15", replace
*/
/*
*outcome IRRI
sum FM11A FM11B FM11C FM12A FM12B FM12C
gen IRRI = ((FM12A+FM12B+FM12C)/(FM11A+FM11B+FM11C))*100 
sum IRRI
recode IRRI (.=0), gen (IRRI1)
sum IRRI1
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace
*/
/*
FM11A = HQ7 5.11a Cultivated kharif
FM11B = HQ7 5.11b Cultivated rabi
FM11C = HQ7 5.11c Cultivated summer
FM12A = HQ7 5.12a Irrigated kharif
FM12B = HQ7 5.12b Irrigated rabi
FM12C = HQ7 5.12c Irrigated summer
*/
/*
*outcome IRRICOST
sum FM31
gen IRRIC = FM31
sum IRRIC
recode IRRIC (.=0), gen (IRRIC1)
sum IRRIC1
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace
*/
/*
FM4A = HQ7 5.4a Owned kharif
FM4B = HQ7 5.4b Owned rabi
FM4C = HQ7 5.4c Owned summer
FM5A = HQ7 5.5a Rented in kharif
FM5B = HQ7 5.5b Rented in rabi
FM5C = HQ7 5.5c Rented in summer
FM6A = HQ7 5.6a Rented out kharif
FM6B = HQ7 5.6b Rented out rabi
FM6C = HQ7 5.6c Rented out summer
FM31 = HQ9 5.31 Irrigation water Rs
*/

*INCOME per capita and income components  
clear
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012in"
keep STATEID DISTID PSUID HHID HHSPLITID RO4 INCAG INCBUS INCOTHER INCEARN INCBENEFITS INCREMIT INCOME
keep if RO4 == 1 
duplicates drop STATEID DISTID PSUID HHID HHSPLITID, force 
sort STATEID DISTID PSUID HHID HHSPLITID
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012in.hhh", replace
clear
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
sort STATEID DISTID PSUID HHID HHSPLITID
merge 1:1 STATEID DISTID PSUID HHID HHSPLITID using "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012in.hhh", gen (_merge5)
keep if _merge5 == 3
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

sum INCOME 
recode INCOME (-867025/0=0), gen (INCOME0)
sum INCOME0
drop if INCOME0==0

recode INCAG (-123500/-10=-10), gen (INCAG0)
sum INCAG0
drop if INCAG0==-10

recode INCBUS (-65993/-1000=-1000), gen (INCBUS0)
sum INCBUS0
drop if INCBUS0==-1000

sum INCOMEPC
sum INCAG INCBUS INCOTHER INCEARN INCBENEFITS INCREMIT INCOME
recode INCAG (.=0), gen (INCAG1)
recode INCBUS (.=0), gen (INCBUS1)
recode INCOTHER (.=0), gen (INCOTHER1)
recode INCEARN (.=0), gen (INCEARN1)
recode INCBENEFITS (.=0), gen (INCBENEFITS1)
recode INCREMIT (.=0), gen (INCREMIT1)
sum INCAG1 INCBUS1 INCOTHER1 INCEARN1 INCBENEFITS1 INCREMIT1 
generate INCOME1 = (INCAG1+INCBUS1+INCOTHER1+INCEARN1+INCBENEFITS1+INCREMIT1)
generate INCOMED = (INCOME-INCOME1)
sum INCOMED
/*
generate INCAG1PC = (INCAG1/NPERSONS)
generate INCBUS1PC = (INCBUS1/NPERSONS)
generate INCOTHER1PC = (INCOTHER1/NPERSONS)
generate INCEARN1PC = (INCEARN1/NPERSONS)
generate INCBENEFITS1PC = (INCBENEFITS1/NPERSONS)
generate INCREMIT1PC = (INCREMIT1/NPERSONS)
generate INCOME1PC = (INCAG1PC+INCBUS1PC+INCOTHER1PC+INCEARN1PC+INCBENEFITS1PC+INCREMIT1PC)
generate INCOME1PCD = (INCOMEPC-INCOME1PC)
sum INCAG1PC INCBUS1PC INCOTHER1PC INCEARN1PC INCBENEFITS1PC INCREMIT1PC INCOME1PC
sum INCOME1PCD
*/
/*
INCOME = HQ Total income
INCAG = HQ7-10 Income from agriculture minus expenses
INCBUS = HQ14-16 8.5,25,45 All businesses: Net income
INCOTHER = HQ17 9.1-3 Income from property, pensions (rupees)
INCEARN = HQ13 7.10-12 annual household wage and salary earnings with bonuses
INCBENEFITS = HQ17 9.5+13,1-8 all Government benefits Rs
INCREMIT = HQ5 3.13a Rs received by household from non-resident last year
*/
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace 


*outcome livelihood diversification 
generate INCAG1P = (INCAG1/INCOME)
generate INCBUS1P = (INCBUS1/INCOME)
generate INCOTHER1P = (INCOTHER1/INCOME)
generate INCEARN1P = (INCEARN1/INCOME)
generate INCBENEFITS1P = (INCBENEFITS1/INCOME)
generate INCREMIT1P = (INCREMIT1/INCOME)
sum INCAG1P INCBUS1P INCOTHER1P INCEARN1P INCBENEFITS1P INCREMIT1P

generate LD = (1/(INCAG1P^2+INCBUS1P^2+INCOTHER1P^2+INCEARN1P^2+INCBENEFITS1P^2+INCREMIT1P^2))
sum LD
recode LD (.=0), gen (LD1)
sum LD1

generate INCNAG1P = (INCBUS1P+INCOTHER1P+INCEARN1P+INCBENEFITS1P+INCREMIT1P)*100
generate INC1P = INCAG1P*100+INCNAG1P
sum INCAG1P INCNAG1P INC1P
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace
/*
*household asset
sum ASSETS
drop if ASSETS == .
sum ASSETS
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace
*ASSETS = Total household assets (0-33)
*/
/*
*water source distance normally
tab WA2A, missing
drop if WA2A == .
recode WA2A (2=0)
tab WA4A, missing
recode WA4A (.=0)
gen WADISTN = WA2A*WA4A
tab WADISTN, missing 

*water source distance summer
tab WA2B, missing
drop if WA2B == .
recode WA2B (2=0)
tab WA4B, missing
recode WA4B (.=0)
gen WADISTS = WA2B*WA4B
tab WADISTS, missing 

*WA2A = EQ9 5.2a Water inside or outside house/compound: normally
*WA2B = EQ9 5.2b Water inside or outside house/compound: summer
*WA4A = EQ9 5.4a Walking time to external water source (minutes one way): normally
*WA4B = EQ9 5.4b Walking time to external water source (minutes one way): summer
*keep key treatment ylist xlist subsamples 
*/
keep STATEID DISTID PSUID HHID HHSPLITID MIGRA INCOMEPC LD1 INCNAG1P DROUGHT NPERSONS NNR RELIG SOCIAL LAND1 OCCU MPCE SEX AGE MARITAL EDU STATEID 
sort STATEID DISTID PSUID HHID HHSPLITID
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

* MPCE xtiles 
xtile MPCE3 = MPCE, nq(3)
tab MPCE3
xtile MPCE5 = MPCE, nq(5)
tab MPCE5

* INCOMEPC xtiles 
xtile INCOMEPC5 = INCOMEPC, nq(5)
/*
* LAND groups 
gen LANDH = LAND1*0.404686
recode LANDH (0=1) (.0016187/.9961502=2) (1.000707/3.931236=3) (4.04686/161.8744=4), gen (LANDH1)
*/
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

*PSM extimation 
global treatment MIGRA
global ylist MPCE LD1 INCNAG1P 
global xlist i.DROUGHT NPERSONS i.NNR i.RELIG i.SOCIAL LAND1 i.OCCU INCOMEPC i.SEX AGE i.MARITAL i.EDU i.STATEID 

*****full sample*****
psmatch2 $treatment $xlist, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlist, both
psmatch2 $treatment $xlist, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlist, both
psmatch2 $treatment $xlist, outcome($ylist) common radius caliper(0.01)
pstest $xlist, both graph  
psmatch2 $treatment $xlist, outcome($ylist) common kernel 
pstest $xlist, both 
psmatch2 $treatment $xlist, outcome($ylist) common kernel bw(0.01)
pstest $xlist, both 
psgraph 


*****economic group MPCE5 == 1*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
global xlisteg i.DROUGHT NPERSONS i.NNR i.RELIG i.SOCIAL LAND1 i.OCCU i.SEX AGE i.MARITAL i.EDU i.STATEID 
keep if MPCE5 == 1
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common radius caliper(0.01)
pstest $xlisteg, both  
psmatch2 $treatment $xlisteg, outcome($ylist) common kernel 
pstest $xlisteg, both 
psgraph 


*****economic group MPCE5 == 2*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCE5 == 2
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common radius caliper(0.01)
pstest $xlisteg, both  
psmatch2 $treatment $xlisteg, outcome($ylist) common kernel 
pstest $xlisteg, both 
psgraph 

*****economic group MPCE5 == 3*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCE5 == 3
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common radius caliper(0.01)
pstest $xlisteg, both  
psmatch2 $treatment $xlisteg, outcome($ylist) common kernel 
pstest $xlisteg, both 
psgraph 

*****economic group MPCE5 == 4*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCE5 == 4
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common radius caliper(0.01)
pstest $xlisteg, both  
psmatch2 $treatment $xlisteg, outcome($ylist) common kernel 
pstest $xlisteg, both 
psgraph 

*****economic group MPCE5 == 5*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCE5 == 5
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common radius caliper(0.01)
pstest $xlisteg, both  
psmatch2 $treatment $xlisteg, outcome($ylist) common kernel 
pstest $xlisteg, both 
psgraph 


*****social group SOCIAL == 1*****
global xlistsg i.DROUGHT NPERSONS i.NNR i.RELIG LAND1 i.OCCU INCOMEPC i.SEX AGE i.MARITAL i.EDU i.STATEID 
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if SOCIAL == 1
psmatch2 $treatment $xlistsg, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlistsg, both
psmatch2 $treatment $xlistsg, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlistsg, both
psmatch2 $treatment $xlistsg, outcome($ylist) common radius caliper(0.01)
pstest $xlistsg, both  
psmatch2 $treatment $xlistsg, outcome($ylist) common kernel 
pstest $xlistsg, both 
psgraph 

*****social group SOCIAL == 2*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if SOCIAL == 2
psmatch2 $treatment $xlistsg, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlistsg, both
psmatch2 $treatment $xlistsg, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlistsg, both
psmatch2 $treatment $xlistsg, outcome($ylist) common radius caliper(0.01)
pstest $xlistsg, both  
psmatch2 $treatment $xlistsg, outcome($ylist) common kernel 
pstest $xlistsg, both 
psgraph 

*****social group SOCIAL == 3*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if SOCIAL == 3
psmatch2 $treatment $xlistsg, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlistsg, both
psmatch2 $treatment $xlistsg, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlistsg, both
psmatch2 $treatment $xlistsg, outcome($ylist) common radius caliper(0.01)
pstest $xlistsg, both  
psmatch2 $treatment $xlistsg, outcome($ylist) common kernel 
pstest $xlistsg, both 
psgraph 

*****social group SOCIAL == 4*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if SOCIAL == 4
psmatch2 $treatment $xlistsg, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlistsg, both
psmatch2 $treatment $xlistsg, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlistsg, both
psmatch2 $treatment $xlistsg, outcome($ylist) common radius caliper(0.01)
pstest $xlistsg, both  
psmatch2 $treatment $xlistsg, outcome($ylist) common kernel 
pstest $xlistsg, both 
psgraph 

*****drought group DROUGHT == 1*****
global xlistdr NPERSONS i.NNR i.RELIG i.SOCIAL LAND1 i.OCCU INCOMEPC i.SEX AGE i.MARITAL i.EDU i.STATEID 
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if DROUGHT == 1
psmatch2 $treatment $xlistdr, outcome($ylist) common neighbor(1) caliper(0.05)
pstest $xlistdr, both
psmatch2 $treatment $xlistdr, outcome($ylist) common neighbor(5) caliper(0.05)
pstest $xlistdr, both
psmatch2 $treatment $xlistdr, outcome($ylist) common radius caliper(0.01)
pstest $xlistdr, both  
psmatch2 $treatment $xlistdr, outcome($ylist) common kernel 
pstest $xlistdr, both 
psgraph 


*****drought group DROUGHT == 2*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if DROUGHT == 2
psmatch2 $treatment $xlistdr, outcome($ylist) common neighbor(1) caliper(0.05)
pstest $xlistdr, both
psmatch2 $treatment $xlistdr, outcome($ylist) common neighbor(5) caliper(0.05)
pstest $xlistdr, both
psmatch2 $treatment $xlistdr, outcome($ylist) common radius caliper(0.01)
pstest $xlistdr, both  
psmatch2 $treatment $xlistdr, outcome($ylist) common kernel 
pstest $xlistdr, both 
psgraph 

/*
*****land group LANDH1 == 1*****
global xlistla i.DROUGHT NPERSONS i.NNR i.RELIG i.SOCIAL i.OCCU INCOMEPC i.SEX AGE i.MARITAL i.EDU i.STATEID 
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if LANDH1 == 1
psmatch2 $treatment $xlistla, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlistla, both
psmatch2 $treatment $xlistla, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlistla, both
psmatch2 $treatment $xlistla, outcome($ylist) common radius caliper(0.01)
pstest $xlistla, both  
psmatch2 $treatment $xlistla, outcome($ylist) common kernel bw(0.01)
pstest $xlistla, both 
psgraph 

*****land group LANDH1 == 2*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if LANDH1 == 2
psmatch2 $treatment $xlistla, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlistla, both
psmatch2 $treatment $xlistla, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlistla, both
psmatch2 $treatment $xlistla, outcome($ylist) common radius caliper(0.01)
pstest $xlistla, both  
psmatch2 $treatment $xlistla, outcome($ylist) common kernel bw(0.01)
pstest $xlistla, both 
psgraph 

*****land group LANDH1 == 3*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if LANDH1 == 3
psmatch2 $treatment $xlistla, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlistla, both
psmatch2 $treatment $xlistla, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlistla, both
psmatch2 $treatment $xlistla, outcome($ylist) common radius caliper(0.01)
pstest $xlistla, both  
psmatch2 $treatment $xlistla, outcome($ylist) common kernel bw(0.01)
pstest $xlistla, both 
psgraph 

*****land group LANDH1 == 4*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if LANDH1 == 4
psmatch2 $treatment $xlistla, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlistla, both
psmatch2 $treatment $xlistla, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlistla, both
psmatch2 $treatment $xlistla, outcome($ylist) common radius caliper(0.01)
pstest $xlistla, both  
psmatch2 $treatment $xlistla, outcome($ylist) common kernel bw(0.01)
pstest $xlistla, both 
psgraph 

*****occupation group OCCU == 1*****
global xlistoc i.DROUGHT NPERSONS i.NNR i.RELIG i.SOCIAL LAND1 INCOMEPC i.SEX AGE i.MARITAL i.EDU i.STATEID 
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if OCCU == 1
psmatch2 $treatment $xlistoc, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlistoc, both
psmatch2 $treatment $xlistoc, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlistoc, both
psmatch2 $treatment $xlistoc, outcome($ylist) common radius caliper(0.01)
pstest $xlistoc, both  
psmatch2 $treatment $xlistoc, outcome($ylist) common kernel bw(0.01)
pstest $xlistoc, both 
psgraph 

*****occupation group OCCU == 2*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if OCCU == 2
psmatch2 $treatment $xlistoc, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlistoc, both
psmatch2 $treatment $xlistoc, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlistoc, both
psmatch2 $treatment $xlistoc, outcome($ylist) common radius caliper(0.01)
pstest $xlistoc, both  
psmatch2 $treatment $xlistoc, outcome($ylist) common kernel bw(0.01)
pstest $xlistoc, both 
psgraph 

*****occupation group OCCU == 3*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if OCCU == 3
psmatch2 $treatment $xlistoc, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlistoc, both
psmatch2 $treatment $xlistoc, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlistoc, both
psmatch2 $treatment $xlistoc, outcome($ylist) common radius caliper(0.01)
pstest $xlistoc, both  
psmatch2 $treatment $xlistoc, outcome($ylist) common kernel bw(0.01)
pstest $xlistoc, both 
psgraph 

*****occupation group OCCU == 4*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if OCCU == 4
psmatch2 $treatment $xlistoc, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlistoc, both
psmatch2 $treatment $xlistoc, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlistoc, both
psmatch2 $treatment $xlistoc, outcome($ylist) common radius caliper(0.01)
pstest $xlistoc, both  
psmatch2 $treatment $xlistoc, outcome($ylist) common kernel bw(0.01)
pstest $xlistoc, both 
psgraph 

*****occupation group OCCU == 5*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if OCCU == 5
psmatch2 $treatment $xlistoc, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlistoc, both
psmatch2 $treatment $xlistoc, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlistoc, both
psmatch2 $treatment $xlistoc, outcome($ylist) common radius caliper(0.01)
pstest $xlistoc, both  
psmatch2 $treatment $xlistoc, outcome($ylist) common kernel bw(0.01)
pstest $xlistoc, both 
psgraph 
*/
*robustness checks permanent migration excluded 
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
tab NNR 
keep if NNR == 2 
xtile MPCENNR3 = MPCE, nq(3)
tab MPCENNR3

xtile MPCENNR5 = MPCE, nq(5)
tab MPCENNR5
* INCOMEPC xtiles 
xtile INCOMEPCN3 = INCOMEPC, nq(3)
tab INCOMEPCN3

xtile INCOMEPCN5 = INCOMEPC, nq(5)
tab INCOMEPCN5
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

*PSM extimation 
global treatment MIGRA
global ylist MPCE LD1 INCNAG1P 
global xlist i.DROUGHT NPERSONS i.RELIG i.SOCIAL LAND1 i.OCCU INCOMEPC i.SEX AGE i.MARITAL i.EDU i.STATEID 

*****full sample*****
psmatch2 $treatment $xlist, outcome($ylist) common neighbor(1) caliper(0.05)
pstest $xlist, both
psmatch2 $treatment $xlist, outcome($ylist) common neighbor(5) caliper(0.05)
pstest $xlist, both
psmatch2 $treatment $xlist, outcome($ylist) common radius caliper(0.01)
pstest $xlist, both  
psmatch2 $treatment $xlist, outcome($ylist) common kernel  
pstest $xlist, both 
psgraph 
/*
*****economic group MPCENNR3 == 1*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
global xlisteg i.DROUGHT NPERSONS i.RELIG i.SOCIAL LAND1 i.OCCU i.SEX AGE i.MARITAL i.EDU i.STATEID 
keep if MPCENNR3 == 1
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(1) caliper(0.05) 
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(5) caliper(0.05)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common radius caliper(0.01)
pstest $xlisteg, both  
psmatch2 $treatment $xlisteg, outcome($ylist) common kernel  
pstest $xlisteg, both 
psgraph 


*****economic group MPCENNR3 == 2*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCENNR3 == 2
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(1) caliper(0.05) 
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(5) caliper(0.05)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common radius caliper(0.01)
pstest $xlisteg, both  
psmatch2 $treatment $xlisteg, outcome($ylist) common kernel  
pstest $xlisteg, both 
psgraph 

*****economic group MPCENNR3 == 3*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCENNR3 == 3
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(1) caliper(0.05) 
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(5) caliper(0.05)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common radius caliper(0.01)
pstest $xlisteg, both  
psmatch2 $treatment $xlisteg, outcome($ylist) common kernel  
pstest $xlisteg, both 
psgraph 
*/

*****economic group MPCENNR5 == 1*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
global xlisteg i.DROUGHT NPERSONS i.RELIG i.SOCIAL LAND1 i.OCCU i.SEX AGE i.MARITAL i.EDU i.STATEID 
keep if MPCENNR5 == 1
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(1) caliper(0.05)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(5) caliper(0.05)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common radius caliper(0.01)
pstest $xlisteg, both  
psmatch2 $treatment $xlisteg, outcome($ylist) common kernel 
pstest $xlisteg, both 
psgraph 


*****economic group MPCENNR5 == 2*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCENNR5 == 2
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(1) caliper(0.05)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(5) caliper(0.05)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common radius caliper(0.01)
pstest $xlisteg, both  
psmatch2 $treatment $xlisteg, outcome($ylist) common kernel 
pstest $xlisteg, both 
psgraph 

*****economic group MPCENNR5 == 3*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCENNR5 == 3
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(1) caliper(0.05)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(5) caliper(0.05)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common radius caliper(0.01)
pstest $xlisteg, both  
psmatch2 $treatment $xlisteg, outcome($ylist) common kernel 
pstest $xlisteg, both 
psgraph 

*****economic group MPCENNR5 == 4*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCENNR5 == 4
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(1) caliper(0.05)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(5) caliper(0.05)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common radius caliper(0.01)
pstest $xlisteg, both  
psmatch2 $treatment $xlisteg, outcome($ylist) common kernel 
pstest $xlisteg, both 
psgraph 

*****economic group MPCENNR5 == 5*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCENNR5 == 5
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(1) caliper(0.05)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common neighbor(5) caliper(0.05)
pstest $xlisteg, both
psmatch2 $treatment $xlisteg, outcome($ylist) common radius caliper(0.01)
pstest $xlisteg, both  
psmatch2 $treatment $xlisteg, outcome($ylist) common kernel 
pstest $xlisteg, both 
psgraph 


*****social group SOCIAL == 1*****
global xlistsg i.DROUGHT NPERSONS i.RELIG LAND1 i.OCCU INCOMEPC i.SEX AGE i.MARITAL i.EDU i.STATEID 
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if SOCIAL == 1
psmatch2 $treatment $xlistsg, outcome($ylist) common neighbor(1) caliper(0.05) 
pstest $xlistsg, both
psmatch2 $treatment $xlistsg, outcome($ylist) common neighbor(5) caliper(0.05)
pstest $xlistsg, both
psmatch2 $treatment $xlistsg, outcome($ylist) common radius caliper(0.01)
pstest $xlistsg, both  
psmatch2 $treatment $xlistsg, outcome($ylist) common kernel  
pstest $xlistsg, both 
psgraph 

*****social group SOCIAL == 2*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if SOCIAL == 2
psmatch2 $treatment $xlistsg, outcome($ylist) common neighbor(1) caliper(0.05) 
pstest $xlistsg, both
psmatch2 $treatment $xlistsg, outcome($ylist) common neighbor(5) caliper(0.05)
pstest $xlistsg, both
psmatch2 $treatment $xlistsg, outcome($ylist) common radius caliper(0.01)
pstest $xlistsg, both  
psmatch2 $treatment $xlistsg, outcome($ylist) common kernel  
pstest $xlistsg, both 
psgraph 

*****social group SOCIAL == 3*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if SOCIAL == 3
psmatch2 $treatment $xlistsg, outcome($ylist) common neighbor(1) caliper(0.05) 
pstest $xlistsg, both
psmatch2 $treatment $xlistsg, outcome($ylist) common neighbor(5) caliper(0.05)
pstest $xlistsg, both
psmatch2 $treatment $xlistsg, outcome($ylist) common radius caliper(0.01)
pstest $xlistsg, both  
psmatch2 $treatment $xlistsg, outcome($ylist) common kernel  
pstest $xlistsg, both 
psgraph 

*****social group SOCIAL == 4*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if SOCIAL == 4
psmatch2 $treatment $xlistsg, outcome($ylist) common neighbor(1) caliper(0.05) 
pstest $xlistsg, both
psmatch2 $treatment $xlistsg, outcome($ylist) common neighbor(5) caliper(0.05)
pstest $xlistsg, both
psmatch2 $treatment $xlistsg, outcome($ylist) common radius caliper(0.01)
pstest $xlistsg, both  
psmatch2 $treatment $xlistsg, outcome($ylist) common kernel  
pstest $xlistsg, both 
psgraph 
/*
*****drought group DROUGHT == 1*****
global xlistdr NPERSONS i.RELIG i.SOCIAL LAND1 i.OCCU INCOMEPC i.SEX AGE i.MARITAL i.EDU i.STATEID 
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if DROUGHT == 1
psmatch2 $treatment $xlistdr, outcome($ylist) common neighbor(1) caliper(0.01)
pstest $xlistdr, both
psmatch2 $treatment $xlistdr, outcome($ylist) common neighbor(5) caliper(0.01)
pstest $xlistdr, both
psmatch2 $treatment $xlistdr, outcome($ylist) common radius caliper(0.01)
pstest $xlistdr, both  
psmatch2 $treatment $xlistdr, outcome($ylist) common kernel bw(0.05)
pstest $xlistdr, both 
psgraph 


*****drought group DROUGHT == 2*****
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if DROUGHT == 2
psmatch2 $treatment $xlistdr, outcome($ylist) common neighbor(1) caliper(0.05)
pstest $xlistdr, both
psmatch2 $treatment $xlistdr, outcome($ylist) common neighbor(5) caliper(0.05)
pstest $xlistdr, both
psmatch2 $treatment $xlistdr, outcome($ylist) common radius caliper(0.05)
pstest $xlistdr, both  
psmatch2 $treatment $xlistdr, outcome($ylist) common kernel bw(0.05)
pstest $xlistdr, both 
psgraph 
*/

*did
*migra1
clear 

*merge hhh data 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012in"
keep STATEID DISTID PSUID HHID HHSPLITID RO4 RO3 RO5 RO6 HHEDUC 
keep if RO4 == 1 
duplicates drop STATEID DISTID PSUID HHID HHSPLITID, force 
sort STATEID DISTID PSUID HHID HHSPLITID
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012in.hhh", replace
clear

use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012hh"
sort STATEID DISTID PSUID HHID HHSPLITID
merge 1:1 STATEID DISTID PSUID HHID HHSPLITID using "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012in.hhh", gen (_merge1)
keep if _merge1 == 3
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

*merge 1 year migration variable 
clear
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012in"
keep if MGYEAR1 == 1
duplicates report STATEID DISTID PSUID HHID HHSPLITID
duplicates list STATEID DISTID PSUID HHID HHSPLITID
duplicates drop STATEID DISTID PSUID HHID HHSPLITID, force 
keep STATEID DISTID PSUID HHID HHSPLITID MGYEAR1
sort STATEID DISTID PSUID HHID HHSPLITID
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012in.migra", replace 
clear 

use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
sort STATEID DISTID PSUID HHID HHSPLITID
merge 1:1 STATEID DISTID PSUID HHID HHSPLITID using "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012in.migra", gen (_merge2)
drop if _merge2 == 2
recode MGYEAR1 (1=1) (.=0), gen (MIGRA)
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

* remove urban households 
tab URBAN2011, missing 
keep if URBAN2011 == 0
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

* merge drought data
clear
import excel "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\drought1.xlsx", sheet("Sheet3") firstrow
keep ST_NM STATEID DISTID dy40
sort STATEID DISTID
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\drought1", replace
clear 

use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
sort STATEID DISTID 
merge m:m STATEID DISTID using "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\drought1", gen (_merge3)
drop if _merge3 == 2
recode dy40 (0=0) (1=1) (3=1) (.=0), gen (DROUGHT)
tab DROUGHT
recode DROUGHT (0=1) (1=2)
tab DROUGHT
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

* covariates 
sum NPERSONS NNR ID11 ID13 ID14 COPC RO3 RO5 RO6 HHEDUC STATEID

drop if NPERSONS == .
drop if NNR == .
drop if ID11 == .
drop if ID13 == .
drop if ID14 == .
drop if COPC == .
drop if RO3 == .
drop if RO5 == .
drop if RO6 == .
drop if HHEDUC == .
drop if STATEID == .

/*
NPERSONS = HQ4 2.0 N in household 
NNR = HQ5 3.0 N Household non-residents
ID11 = HQ3 1.11 Religion / RELIG
ID13 = HQ3 1.13 Caste category / SOCIAL
ID14 = HQ3 1.14 Main income source / OCCU
COPC = HQ23 14. Household expenditure /capita / MPCE 
RO3 = HQ4 2.3 Sex / SEX
RO5 = HQ4 2.5 Age / AGE
RO6 = HQ4 2.6 Marital Status / MARITAL
HHEDUC = HQ19 11.6 Highest adult Education / EDU
STATEID = State code
FM4A = HQ7 5.4a Owned kharif
FM4B = HQ7 5.4b Owned rabi
FM4C = HQ7 5.4c Owned summer
FM3 = HQ7 5.3 Local units/acre
*/
tab NPERSONS
tab NNR
recode NNR (1/9=1) (0=2)
tab NNR 
tab ID11
recode ID11 (1=1) (2=2) (3/9=3), gen (RELIG)
tab RELIG
tab ID13
recode ID13 (1=1) (2=1) (3=2) (4=3) (5=4) (6=1), gen (SOCIAL)
tab SOCIAL
tab ID14
recode ID14 (1/2=1) (5/10=2) (3=3) (4=4) (11=5), gen (OCCU)
tab OCCU
sum COPC
gen MPCE = (COPC/12)
sum MPCE
tab RO3
gen SEX = RO3
tab SEX
tab RO5
gen AGE = RO5
tab AGE
tab RO6
recode RO6 (0=1) (1=1) (2=2) (3=3) (4=4) (5=1), gen (MARITAL) 
tab MARITAL
tab HHEDUC
recode HHEDUC (0=1) (1/5=2) (6/10=3) (11/16=4), gen (EDU)
tab EDU
sum DROUGHT NPERSONS NNR RELIG SOCIAL OCCU MPCE SEX AGE MARITAL EDU STATEID
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

*variable land owned 
sum FM4A FM4B FM4C FM1
keep STATEID DISTID PSUID HHID HHSPLITID FM4A FM4B FM4C FM1
tab FM1, missing 
drop if FM1 == 0
gen delete = (FM4A+FM4B+FM4C+FM1)
tab delete, missing 
recode delete (.=10000), gen (delete2)
tab delete2, missing 
drop FM4A FM4B FM4C FM1 delete
sort STATEID DISTID PSUID HHID HHSPLITID
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\delete", replace
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
sort STATEID DISTID PSUID HHID HHSPLITID
merge 1:1 STATEID DISTID PSUID HHID HHSPLITID using "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\delete", gen (_merge4)
drop if delete2 == 10000
drop delete2
gen land = (((FM4A+FM4B+FM4C)/3)/FM3)
recode land (.=0), gen (LAND1)
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

/*
*variable mpce Deaton equilibrium scale 
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\dataset15"
gen ADULT = (NADULTM+NADULTF+NTEENM+NTEENF)
gen CHILD = (NCHILDM+NCHILDF)
gen NPERSONS1 = (ADULT+CHILD)
gen NPERSONSD = (NPERSONS-NPERSONS1)
gen ADULT1 = 1
gen ADULT2 = (ADULT-1)
gen ADULTD = (ADULT-ADULT1-ADULT2)
gen T = (ADULT1*1)+(ADULT2*0.7)+(CHILD*0.5)
gen MPCED = (COTOTAL/T)
xtile MPCED5 = MPCED, nq(5)
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\dataset15", replace
*/
/*
*outcome IRRI
sum FM11A FM11B FM11C FM12A FM12B FM12C
gen IRRI = ((FM12A+FM12B+FM12C)/(FM11A+FM11B+FM11C))*100 
sum IRRI
recode IRRI (.=0), gen (IRRI1)
sum IRRI1
*/
/*
FM11A = HQ7 5.11a Cultivated kharif
FM11B = HQ7 5.11b Cultivated rabi
FM11C = HQ7 5.11c Cultivated summer
FM12A = HQ7 5.12a Irrigated kharif
FM12B = HQ7 5.12b Irrigated rabi
FM12C = HQ7 5.12c Irrigated summer
*/

*INCOME per capita and income components  
clear
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012in"
keep STATEID DISTID PSUID HHID HHSPLITID RO4 INCAG INCBUS INCOTHER INCEARN INCBENEFITS INCREMIT INCOME
keep if RO4 == 1 
duplicates drop STATEID DISTID PSUID HHID HHSPLITID, force 
sort STATEID DISTID PSUID HHID HHSPLITID
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012in.hhh", replace
clear
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
sort STATEID DISTID PSUID HHID HHSPLITID
merge 1:1 STATEID DISTID PSUID HHID HHSPLITID using "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2012in.hhh", gen (_merge5)
keep if _merge5 == 3
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

sum INCOME 
recode INCOME (-867025/0=0), gen (INCOME0)
sum INCOME0
drop if INCOME0==0

recode INCAG (-123500/-10=-10), gen (INCAG0)
sum INCAG0
drop if INCAG0==-10

recode INCBUS (-65993/-1000=-1000), gen (INCBUS0)
sum INCBUS0
drop if INCBUS0==-1000

sum INCOMEPC
sum INCAG INCBUS INCOTHER INCEARN INCBENEFITS INCREMIT INCOME
recode INCAG (.=0), gen (INCAG1)
recode INCBUS (.=0), gen (INCBUS1)
recode INCOTHER (.=0), gen (INCOTHER1)
recode INCEARN (.=0), gen (INCEARN1)
recode INCBENEFITS (.=0), gen (INCBENEFITS1)
recode INCREMIT (.=0), gen (INCREMIT1)
sum INCAG1 INCBUS1 INCOTHER1 INCEARN1 INCBENEFITS1 INCREMIT1 
generate INCOME1 = (INCAG1+INCBUS1+INCOTHER1+INCEARN1+INCBENEFITS1+INCREMIT1)
generate INCOMED = (INCOME-INCOME1)
sum INCOMED
/*
generate INCAG1PC = (INCAG1/NPERSONS)
generate INCBUS1PC = (INCBUS1/NPERSONS)
generate INCOTHER1PC = (INCOTHER1/NPERSONS)
generate INCEARN1PC = (INCEARN1/NPERSONS)
generate INCBENEFITS1PC = (INCBENEFITS1/NPERSONS)
generate INCREMIT1PC = (INCREMIT1/NPERSONS)
generate INCOME1PC = (INCAG1PC+INCBUS1PC+INCOTHER1PC+INCEARN1PC+INCBENEFITS1PC+INCREMIT1PC)
generate INCOME1PCD = (INCOMEPC-INCOME1PC)
sum INCAG1PC INCBUS1PC INCOTHER1PC INCEARN1PC INCBENEFITS1PC INCREMIT1PC INCOME1PC
sum INCOME1PCD
*/
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace 


*outcome livelihood diversification 
generate INCAG1P = (INCAG1/INCOME)
generate INCBUS1P = (INCBUS1/INCOME)
generate INCOTHER1P = (INCOTHER1/INCOME)
generate INCEARN1P = (INCEARN1/INCOME)
generate INCBENEFITS1P = (INCBENEFITS1/INCOME)
generate INCREMIT1P = (INCREMIT1/INCOME)
sum INCAG1P INCBUS1P INCOTHER1P INCEARN1P INCBENEFITS1P INCREMIT1P

generate LD = (1/(INCAG1P^2+INCBUS1P^2+INCOTHER1P^2+INCEARN1P^2+INCBENEFITS1P^2+INCREMIT1P^2))
sum LD
recode LD (.=0), gen (LD1)
sum LD1

generate INCNAG1P = (INCBUS1P+INCOTHER1P+INCEARN1P+INCBENEFITS1P+INCREMIT1P)*100
generate INC1P = INCAG1P*100+INCNAG1P
sum INCAG1P INCNAG1P INC1P
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

*keep key treatment ylist xlist subsamples 
keep STATEID DISTID PSUID HHID HHSPLITID MIGRA INCOMEPC LD1 INCNAG1P DROUGHT NPERSONS NNR RELIG SOCIAL LAND1 OCCU MPCE SEX AGE MARITAL EDU  
sort STATEID DISTID PSUID HHID HHSPLITID
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace


*IHDS 2005 calculate outcomes 
clear
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2005hh.dta"

sum INCOME INCWAGE INCSALARY INCAGWAGE INCNONAGWAGE INCBUS INCFARM INCANIMALS INCAGPROP INCREMIT INCPROP INCBENEFITS INCOTHER INCOME5
gen INCAG = (INCFARM+INCANIMALS+INCAGPROP)
gen INCEARN = (INCSALARY+INCAGWAGE+INCNONAGWAGE)
sum INCOME INCAG INCBUS INCPROP INCEARN INCBENEFITS INCREMIT
recode INCAG (.=0), gen (INCAG1)
recode INCBUS (.=0), gen (INCBUS1)
recode INCPROP (.=0), gen (INCOTHER1)
recode INCEARN (.=0), gen (INCEARN1)
recode INCBENEFITS (.=0), gen (INCBENEFITS1)
recode INCREMIT (.=0), gen (INCREMIT1)
generate INCOME1 = (INCAG1+INCBUS1+INCOTHER1+INCEARN1+INCBENEFITS1+INCREMIT1)
sum INCOME1 INCAG1 INCBUS1 INCOTHER1 INCEARN1 INCBENEFITS1 INCREMIT1 
generate INCOMED = (INCOME-INCOME1)
sum INCOMED
generate INCOTHERD = (INCOTHER-INCPROP)
sum INCOTHERD

gen LINKFACTOR = 1.80
gen INCOMEPC = (INCOME/NPERSONS)*LINKFACTOR

/*
gen INCOMEF = INCOME*LINKFACTOR
gen INCAGF = INCAG*LINKFACTOR
gen INCBUSF = INCBUS*LINKFACTOR
gen INCPROPF = INCPROP*LINKFACTOR
gen INCEARNF = INCEARN*LINKFACTOR
gen INCBENEFITSF = INCBENEFITS*LINKFACTOR
gen INCREMITF = INCREMIT*LINKFACTOR
sum INCOMEF INCAGF INCBUSF INCPROPF INCEARNF INCBENEFITSF INCREMITF

gen INCOMEFPC = INCOMEF/NPERSONS
gen INCAGFPC = INCAGF/NPERSONS
gen INCBUSFPC = INCBUSF/NPERSONS
gen INCPROPFPC = INCPROPF/NPERSONS
gen INCEARNFPC = INCEARNF/NPERSONS
gen INCBENEFITSFPC = INCBENEFITSF/NPERSONS
gen INCREMITFPC = INCREMITF/NPERSONS
sum INCOMEFPC INCAGFPC INCBUSFPC INCPROPFPC INCEARNFPC INCBENEFITSFPC INCREMITFPC

gen INCAG1PC = (INCAG1/NPERSONS)*LINKFACTOR
gen INCBUS1PC = (INCBUS1/NPERSONS)*LINKFACTOR
gen INCOTHER1PC = (INCOTHER1/NPERSONS)*LINKFACTOR
gen INCEARN1PC = (INCEARN1/NPERSONS)*LINKFACTOR
gen INCBENEFITS1PC = (INCBENEFITS1/NPERSONS)*LINKFACTOR
gen INCREMIT1PC = (INCREMIT1/NPERSONS)*LINKFACTOR
generate INCOME1PC = (INCAG1PC+INCBUS1PC+INCOTHER1PC+INCEARN1PC+INCBENEFITS1PC+INCREMIT1PC)
generate INCOME1PCD = (INCOMEPC-INCOME1PC)
sum INCOMEPC INCAG1PC INCBUS1PC INCOTHER1PC INCEARN1PC INCBENEFITS1PC INCREMIT1PC 
sum INCOME1PCD
*/

recode INCAG (-228327.8/-.53=-1), gen (INCAG0)
sum INCAG0
drop if INCAG0==-1

drop if INCOME==0
drop if INCOME1==0

generate INCAG1P = (INCAG1/INCOME1)
generate INCBUS1P = (INCBUS1/INCOME1)
generate INCOTHER1P = (INCOTHER1/INCOME1)
generate INCEARN1P = (INCEARN1/INCOME1)
generate INCBENEFITS1P = (INCBENEFITS1/INCOME1)
generate INCREMIT1P = (INCREMIT1/INCOME1)
sum INCAG1P INCBUS1P INCOTHER1P INCEARN1P INCBENEFITS1P INCREMIT1P

generate LD = (1/(INCAG1P^2+INCBUS1P^2+INCOTHER1P^2+INCEARN1P^2+INCBENEFITS1P^2+INCREMIT1P^2))
sum LD
recode LD (.=0), gen (LD1)
sum LD1

generate INCNAG1P = (INCBUS1P+INCOTHER1P+INCEARN1P+INCBENEFITS1P+INCREMIT1P)*100
generate INC1P = INCAG1P*100+INCNAG1P
sum INCAG1P INCNAG1P INC1P
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2005hh.ld", replace

*IHDS 2005 merge drought data
clear
import excel "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\dist2001df32.xlsx", sheet("Sheet3") firstrow
keep STATEID DISTID dy401
sort STATEID DISTID
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\drought2", replace
clear 

use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2005hh.ld"
sort STATEID DISTID 
merge m:m STATEID DISTID using "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\drought2", gen (_merge6)
drop if _merge6 == 2
recode dy401 (0=0) (1=1) (2=1) (3=1) (.=0), gen (DROUGHT)
recode DROUGHT (0=1) (1=2)
tab DROUGHT
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2005hh.ld", replace

*merge hhh data IHDS 2005
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2005in"
keep STATEID DISTID PSUID HHID HHSPLITID RO4 RO3 RO5 RO6 ED2 ED5 
keep if RO4 == 1 
sort STATEID DISTID PSUID HHID HHSPLITID
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2005in.hhh", replace
clear

use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2005hh.ld"
sort STATEID DISTID PSUID HHID HHSPLITID
merge 1:1 STATEID DISTID PSUID HHID HHSPLITID using "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2005in.hhh", gen (_merge7)
keep if _merge7 == 3
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2005hh.ld", replace

*IHDS 2005 covariates 
tab NPERSONS
tab ID14, missing
recode ID14 (1=1) (2=2) (3/9=3), gen (RELIG)
tab RELIG
tab ID13
recode ID13 (1=1) (2=2) (3=3) (4=4) (5=1), gen (SOCIAL)
tab SOCIAL
tab ID15, missing
recode ID15 (1/2=1) (5/10=2) (3=3) (4=4) (11=5), gen (OCCU)
tab OCCU
sum COPC
drop if COPC == -6
drop if COPC == -4
gen MPCE = COPC*LINKFACTOR
sum MPCE
tab STATEID, missing 
sum FM2 FM3 FM4
recode FM2 (-1=.), gen (FM2new)
gen LAND = (FM4/FM2new)
sum LAND 
recode LAND (.=0), gen(LAND1)
sum LAND1


sum RO4 RO3 RO5 RO6 ED2 ED5
tab RO3, nol
gen SEX = RO3
tab SEX
tab RO5
gen AGE = RO5
tab AGE
tab RO6, nol
recode RO6 (0=1) (1=1) (2=2) (3=3) (4=4) (5=1), gen (MARITAL) 
tab MARITAL
tab ED5, nol
drop if ED5 == -1
recode ED5 (0=1) (1/5=2) (6/10=3) (11/15=4), gen (EDU)
tab EDU
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2005hh.ld", replace

*merge nnr data IHDS 2005
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2005nnr"
keep STATEID DISTID PSUID HHID HHSPLITID PERSONID 
tab PERSONID, missing 
keep if PERSONID == 50 
sort STATEID DISTID PSUID HHID HHSPLITID
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2005nnr.2", replace
clear

use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2005hh.ld"
sort STATEID DISTID PSUID HHID HHSPLITID
merge 1:1 STATEID DISTID PSUID HHID HHSPLITID using "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2005nnr.2", gen (_merge8)
drop if _merge8 == 2
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2005hh.ld", replace

tab PERSONID, missing 
recode PERSONID (50=1) (.=2), gen (NNR)
tab NNR, missing 

sum DROUGHT NPERSONS NNR RELIG SOCIAL LAND1 OCCU MPCE SEX AGE MARITAL EDU STATEID

save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2005hh.ld", replace

/*
DROUGHT NPERSONS NNR RELIG SOCIAL LAND1 OCCU MPCE SEX AGE MARITAL EDU STATEID 

NPERSONS = HH4 2.0 N in HH/ NPERSONS
ID14 = HH3 1.14 Religion/ RELIG
ID13 = HH3 1.13 Caste category/ SOCIAL
ID15 = HH3 1.15 Main income source/ OCCU
COPC = HH19 12. Monthly consumption per capita/ MPCE
STATEID = State code/ STATEID
FM2 = HH6 4.2 Local units/acre
FM3 = HH6 4.3 Any owned or cultivated
FM4 = HH6 4.4 Area owned
FM5 = HH6 4.5 Area owned & cultivated 
*/

keep STATEID DISTID PSUID HHID HHSPLITID INCOMEPC LD1 INCNAG1P DROUGHT NPERSONS NNR RELIG SOCIAL LAND1 OCCU MPCE SEX AGE MARITAL EDU  
sort STATEID DISTID PSUID HHID HHSPLITID
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2005hh.ld", replace

*merge IHDSI and IHDSII
rename * X*
rename XSTATEID STATEID
rename XDISTID DISTID
rename XPSUID PSUID
rename XHHID HHID2005
rename XHHSPLITID HHSPLITID2005
sort STATEID DISTID PSUID HHID2005 HHSPLITID2005
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2005hh.ld", replace
clear 

import excel "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\ihds_201112\merge_practice\linkhh.xlsx", sheet("Sheet1") firstrow
sort STATEID DISTID PSUID HHID HHSPLITID
merge 1:1 STATEID DISTID PSUID HHID HHSPLITID using "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", gen (_merge9)
keep if _merge9==3
sort STATEID DISTID PSUID HHID2005 HHSPLITID2005
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace
clear

use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\ihds2005hh.ld"
merge m:m STATEID DISTID PSUID HHID2005 HHSPLITID2005 using "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", gen (_merge10)
keep if _merge10==3
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

/*
*robustness checks permanent migration excluded 
tab NNR 
keep if NNR == 2 
*/
* MPCE xtiles 
xtile MPCEII3 = MPCE, nq(3)
tab MPCEII3
xtile MPCEII5 = MPCE, nq(5)
tab MPCEII5
xtile MPCEI3 = XMPCE, nq(3)
tab MPCEI3
xtile MPCEI5 = XMPCE, nq(5)
tab MPCEI5

xtile INCOMEPCI3 = XINCOMEPC, nq(3)
tab INCOMEPCI3

xtile INCOMEPCI5 = XINCOMEPC, nq(5)
tab INCOMEPCI5

xtile INCOMEPCII5 = INCOMEPC, nq(5)
tab INCOMEPCII5

tab XSOCIAL
gen SOCIALI = XSOCIAL
tab SOCIALI

tab SOCIAL
gen SOCIALII = SOCIAL
tab SOCIALII

gen ID = _n
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace


* wide to long panel
rename XINCOMEPC INCOMEPC0
rename XLD1 LD10
rename XINCNAG1P INCNAG1P0
rename XDROUGHT DROUGHT0
rename XNPERSONS NPERSONS0
rename XNNR NNR0
rename XRELIG RELIG0
rename XSOCIAL SOCIAL0
rename XLAND1 LAND10
rename XOCCU OCCU0
rename XMPCE MPCE0
rename XSEX SEX0
rename XAGE AGE0
rename XMARITAL MARITAL0
rename XEDU EDU0

rename INCOMEPC INCOMEPC1
rename LD1 LD11
rename INCNAG1P INCNAG1P1
rename DROUGHT DROUGHT1
rename NPERSONS NPERSONS1
rename NNR NNR1
rename RELIG RELIG1
rename SOCIAL SOCIAL1
rename LAND1 LAND11
rename OCCU OCCU1
rename MPCE MPCE1
rename SEX SEX1
rename AGE AGE1
rename MARITAL MARITAL1
rename EDU EDU1

reshape long INCOMEPC LD1 INCNAG1P DROUGHT NPERSONS NNR RELIG SOCIAL LAND1 OCCU MPCE SEX AGE MARITAL EDU, i(STATEID DISTID PSUID HHID HHSPLITID) j(year)

tab1 MIGRA year
gen DID = MIGRA*year
save "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1", replace

mean MPCE, over (MIGRA year)

*DID full sample 
global xlist i.DROUGHT NPERSONS i.NNR i.RELIG i.SOCIAL LAND1 i.OCCU INCOMEPC i.SEX AGE i.MARITAL i.EDU i.STATEID 

*pooled ols simple
reg MPCE DID MIGRA year  
reg LD1 DID MIGRA year  
reg INCNAG1P DID MIGRA year  

*pooled ols adjusted
reg MPCE DID MIGRA year $xlist 
reg LD1 DID MIGRA year $xlist 
reg INCNAG1P DID MIGRA year $xlist 

*set data as panel data 
/*
egen ID=group(STATEID DISTID PSUID HHID2005 HHSPLITID2005)
*/
xtset ID year

*fixed effects simple   
xtreg MPCE DID MIGRA year, fe 
xtreg LD1 DID MIGRA year, fe 
xtreg INCNAG1P DID MIGRA year, fe 

*fixed effects adjucted    
xtreg MPCE DID MIGRA year $xlist, fe 
xtreg LD1 DID MIGRA year $xlist, fe 
xtreg INCNAG1P DID MIGRA year $xlist, fe 

*first differences simple 
reg D.(MPCE DID MIGRA year), noconstant  
reg D.(LD1 DID MIGRA year), noconstant 
reg D.(INCNAG1P DID MIGRA year), noconstant 

*random effects simple   
xtreg MPCE DID MIGRA year, re 
xtreg LD1 DID MIGRA year, re 
xtreg INCNAG1P DID MIGRA year, re 

*Hausman test for fixed versus random effects mocel 
quietly xtreg MPCE DID MIGRA year, fe
estimates store fixed
quietly xtreg MPCE DID MIGRA year, re
estimates store random 
hausman fixed random 

*Breusch-Pegan LM test for random effects versus ols
quietly xtreg MPCE DID MIGRA year, re
xttest0 

*recovering individual-specific effects 
quietly xtreg MPCE DID MIGRA year, fe
predict alphafehat, u
sum alphafehat 

gen MIGRA0=0
rename MIGRA MIGRA1

*collapse (mean) MPCE, by(MIGRA year)

/*
*DID INCOMEPCI3 == 1
global xlisteg i.DROUGHT NPERSONS i.NNR i.RELIG i.SOCIAL LAND1 i.OCCU INCOMEPC i.SEX AGE i.MARITAL i.EDU i.STATEID 
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if INCOMEPCI3 == 1
regress MPCE DID MIGRA year $xlisteg 
regress INCOMEPC DID MIGRA year $xlisteg
regress LD1 DID MIGRA year $xlisteg

*DID INCOMEPCI3 == 2
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if INCOMEPCI3 == 2
regress MPCE DID MIGRA year $xlisteg 
regress INCOMEPC DID MIGRA year $xlisteg
regress LD1 DID MIGRA year $xlisteg

*DID INCOMEPCI3 == 3
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if INCOMEPCI3 == 3
regress MPCE DID MIGRA year $xlisteg 
regress INCOMEPC DID MIGRA year $xlisteg
regress LD1 DID MIGRA year $xlisteg
*/
*DID MPCEI5 == 1
global xlisteg i.DROUGHT NPERSONS i.NNR i.RELIG i.SOCIAL LAND1 i.OCCU INCOMEPC i.SEX AGE i.MARITAL i.EDU i.STATEID 
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCEI5 == 1
regress MPCE DID MIGRA year $xlisteg 
regress LD1 DID MIGRA year $xlisteg
regress INCNAG1P DID MIGRA year $xlisteg

*DID MPCEI5 == 2
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCEI5 == 2
regress MPCE DID MIGRA year $xlisteg 
regress LD1 DID MIGRA year $xlisteg
regress INCNAG1P DID MIGRA year $xlisteg

*DID MPCEI5 == 3
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCEI5 == 3
regress MPCE DID MIGRA year $xlisteg 
regress LD1 DID MIGRA year $xlisteg
regress INCNAG1P DID MIGRA year $xlisteg

*DID MPCEI5 == 4
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCEI5 == 4
regress MPCE DID MIGRA year $xlisteg 
regress LD1 DID MIGRA year $xlisteg
regress INCNAG1P DID MIGRA year $xlisteg

*DID MPCEI5 == 5
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCEI5 == 5
regress MPCE DID MIGRA year $xlisteg 
regress LD1 DID MIGRA year $xlisteg
regress INCNAG1P DID MIGRA year $xlisteg

*DID SOCIALI == 1
global xlistsg i.DROUGHT NPERSONS i.NNR i.RELIG i.SOCIAL LAND1 i.OCCU INCOMEPC i.SEX AGE i.MARITAL i.EDU i.STATEID 
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if SOCIALI == 1
regress MPCE DID MIGRA year $xlistsg 
regress LD1 DID MIGRA year $xlistsg
regress INCNAG1P DID MIGRA year $xlistsg

*DID SOCIALI == 2
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if SOCIALI == 2
regress MPCE DID MIGRA year $xlistsg 
regress LD1 DID MIGRA year $xlistsg
regress INCNAG1P DID MIGRA year $xlistsg

*DID SOCIALI == 3
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if SOCIALI == 3
regress MPCE DID MIGRA year $xlistsg 
regress LD1 DID MIGRA year $xlistsg
regress INCNAG1P DID MIGRA year $xlistsg

*DID SOCIALI == 4
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if SOCIALI == 4
regress MPCE DID MIGRA year $xlistsg 
regress LD1 DID MIGRA year $xlistsg
regress INCNAG1P DID MIGRA year $xlistsg

/*
*DID INCOMEPCII5 == 1
global xlisteg i.DROUGHT NPERSONS i.NNR i.RELIG i.SOCIAL LAND1 i.OCCU INCOMEPC i.SEX AGE i.MARITAL i.EDU i.STATEID 

clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if INCOMEPCII5 == 1
regress MPCE DID MIGRA year $xlisteg 
regress INCOMEPC DID MIGRA year $xlisteg
regress LD1 DID MIGRA year $xlisteg

*DID INCOMEPCII5 == 2
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if INCOMEPCII5 == 2
regress MPCE DID MIGRA year $xlisteg 
regress INCOMEPC DID MIGRA year $xlisteg
regress LD1 DID MIGRA year $xlisteg

*DID INCOMEPCII5 == 3
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if INCOMEPCII5 == 3
regress MPCE DID MIGRA year $xlisteg 
regress INCOMEPC DID MIGRA year $xlisteg
regress LD1 DID MIGRA year $xlisteg

*DID INCOMEPCII5 == 4
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if INCOMEPCII5 == 4
regress MPCE DID MIGRA year $xlisteg 
regress INCOMEPC DID MIGRA year $xlisteg
regress LD1 DID MIGRA year $xlisteg

*DID INCOMEPCII5 == 5
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if INCOMEPCII5 == 5
regress MPCE DID MIGRA year $xlisteg 
regress INCOMEPC DID MIGRA year $xlisteg
regress LD1 DID MIGRA year $xlisteg

*DID SOCIALII == 1
global xlistsg i.DROUGHT NPERSONS i.NNR i.RELIG i.SOCIAL LAND1 i.OCCU INCOMEPC i.SEX AGE i.MARITAL i.EDU i.STATEID 
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if SOCIALII == 1
regress MPCE DID MIGRA year $xlistsg 
regress INCOMEPC DID MIGRA year $xlistsg
regress LD1 DID MIGRA year $xlistsg

*DID SOCIALII == 2
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if SOCIALII == 2
regress MPCE DID MIGRA year $xlistsg 
regress INCOMEPC DID MIGRA year $xlistsg
regress LD1 DID MIGRA year $xlistsg

*DID SOCIALII == 3
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if SOCIALII == 3
regress MPCE DID MIGRA year $xlistsg 
regress INCOMEPC DID MIGRA year $xlistsg
regress LD1 DID MIGRA year $xlistsg

*DID SOCIALII == 4
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if SOCIALII == 4
regress MPCE DID MIGRA year $xlistsg 
regress INCOMEPC DID MIGRA year $xlistsg
regress LD1 DID MIGRA year $xlistsg



*DID MPCEII5 == 1
global xlisteg i.DROUGHT NPERSONS i.NNR i.RELIG i.SOCIAL LAND1 i.OCCU i.SEX AGE i.MARITAL i.EDU i.STATEID 
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCEII5 == 1
regress INCOMEPC DID MIGRA year $xlisteg
regress LD1 DID MIGRA year $xlisteg

*DID MPCEII5 == 2
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCEII5 == 2
regress INCOMEPC DID MIGRA year $xlisteg
regress LD1 DID MIGRA year $xlisteg

*DID MPCEII5 == 3
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCEII5 == 3
regress INCOMEPC DID MIGRA year $xlisteg
regress LD1 DID MIGRA year $xlisteg

*DID MPCEII5 == 4
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCEII5 == 4
regress INCOMEPC DID MIGRA year $xlisteg
regress LD1 DID MIGRA year $xlisteg

*DID MPCEII5 == 5
clear 
use "C:\Users\badsh\OneDrive\Desktop\SRC_Reviews2\results_4newrevision\data1"
keep if MPCEII5 == 5
regress INCOMEPC DID MIGRA year $xlisteg
regress LD1 DID MIGRA year $xlisteg
*/


