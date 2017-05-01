/* 
Aaron Gullickson
organizedata.do

This code should create the the data used in McClintock's analysis for
both the regression models and the log linear models. McClintock has
also provided me with do files and log files that allow me to
make some comparisons and check my coding vs hers.

This script will load both the Wave III respondent data and the
romantic partner data and will code and keep the variables needed. It
will then merge the two datasets and rename things based on female vs
male characteristics to produce the matched partner data.

In compiling these data, I have noted some oddities in the romantic
pair data. However, after some experimentation I was able to produce a
sample size and a distribution of characteristics for each partner's
education and attractiveness that exactly match McClintock's. Since my
goal is replication I have not pursued the reason for these oddities,
but I document them here for others who might use this data. First,
the romantic pairs data was supposed to be only of heterosexual
couples but based on the reported sex of both partners, I am finding a
few same sex couples. This occurs regardless of whether one takes wave
1 or wave 3 reported sex. I found that my partner characteristics
matched McClintock's if I assumed that the ego respondent's sex was
correct and switched the partner's sex to produce a heterosexual
couple.

Second, the labeling of the id to match partners and respondents seems
backwards to me in the partner3.dta file. The AID actually matches the
IDs from the partner data set and the P_AID matches the IDs in the ego
respondent sample. I assume this is just a labeling issue, but it was
initially very puzzling.
*/

/*
WAVE III Home Data
*/

clear
import sasxport Data/allwave1.xpt
keep aid bio_sex
save gender_w1.dta, replace

//get relationship stuff
clear
import sasxport Data/sect19.xpt
keep aid rrelno h3rd6m h3rd6y
save relatd.dta, replace


clear
import sasxport Data/sect17.xpt
merge 1:1 aid rrelno using relatd.dta
drop if _merge!=3
drop _merge

keep if cp==1

duplicates report aid
table h3tr1

//need to code relationship status
//not sure how to handle missings, surprised they are included - will treat as zeros
generate RELTYPE = 1
replace RELTYPE = 2 if h3tr11==1 & h3tr12!=1
replace RELTYPE = 3 if h3tr12==1
replace h3rd6y=. if h3rd6y>2002
replace h3rd6m=. if h3rd6m>12

keep aid RELTYPE h3rd6m h3rd6y
save relationship.dta, replace

//get pregnancy stuff
clear
import sasxport Data/sect18.xpt
keep if h3tp1==5
duplicates drop aid, force
generate PREGNANT = 1
keep aid PREGNANT
save pregnancy.dta, replace

clear
import sasxport Data/wave3.xpt

merge 1:1 aid using gender_w1.dta
drop if _merge==2
drop _merge

merge 1:1 aid using relationship.dta
drop if _merge==2
drop _merge

merge 1:1 aid using pregnancy.dta
drop if _merge==2
drop _merge
replace PREGNANT=0 if PREGNANT==.

/*relationship duration*/
generate currentdate = iyear3+((imonth3-1)/12)
generate relatedate = h3rd6y+((h3rd6m-1)/12)
generate DURATION = (currentdate-relatedate)*12
replace DURATION=. if DURATION<0

/*
YEARS OF EDUCATION
McClintock directly coded four categories off of years of
education, here is her code:
recode m3_yrsedu 0/11=1 12=2 13/15=3 16/25=4, gen(m3_edu4)
recode f3_yrsedu 0/11=1 12=2 13/15=3 16/25=4, gen(f3_edu4)

Highest grade is given by H3ED1, so lets code from that
*/
recode h3ed1 0/11=1 12=2 13/15=3 16/25=4, gen(EDU)
replace EDU=. if EDU>4


/**now recode h3ed1 into yrsed**/
generate YRED=h3ed1
replace YRED=. if h3ed1>=96

/*
Here is some old code I put together for education based on combining information about
years of ed and degree receipt before I realized McClintock actually sent me her code.
This variable might be better than McClintock's because it does not simply figure out
degree receipt from years of education. I will keep it for comparison sake. One issue
is how to treat GEDs. I will exclude them here from HS diploma 
*/
generate EDU2 = .
replace EDU2 = 1 if h3ed1>1 & h3ed1<=12
//assuming GED's don't count here
replace EDU2 = 2 if h3ed1==12 & h3ed3==1 //high school diplma
replace EDU2 = 3 if h3ed1>12
replace EDU2 = 4 if h3ed5==1 | h3ed6==1 | h3ed7==1 | h3ed8==1 
//how to deal with missing values - for now just add in the three
//that are missing across all degree cateogories
replace EDU2 = . if h3ed3>=6 | h3ed5>=6

/*
EXPECTED COLLEGE GRAD
McClintock didn't provide code for her expected college grad but per
the article this should be straightforward to calculate as individuals
who have completed or are currently enrolled in four year degree
program. One question however is whether McClintock actually coded
this off of the questions about degree receipt or just simply off of
years of education. Given the way she coded EDU, I am going to assume
she did it simply. 
*/

generate GRAD = EDU==4
replace GRAD = 1 if h3ed26==3
// | h3ed26==4 - This is the grad schol group that are excluded
replace GRAD = . if EDU==. | h3ed26==6 | h3ed26>7

generate GRAD2 = EDU2==4
replace GRAD2 = 1 if h3ed26==3 | h3ed26==4
replace GRAD2 = . if EDU2==. | h3ed26==6 | h3ed26>7


/*
ATTRACTIVENESS
This one should be easy to code. I just need to collapse the two
bottom categories as McClintock did.
*/

generate ATT = h3ir1
    
generate ATTCAT = ATT
replace ATTCAT = 2 if ATTCAT==1

rename bio_sex SEX1
rename bio_sex3 SEX3
rename aid AID

/*
*Race - which best describes you? 
* McClintock coded as white NH, Black NH, everybody else
* I will ignore missing values here
*/

generate hispanic = h3od2==1
generate multi = h3od6!=7

generate RACE = 3
replace RACE = 1 if !hispanic & ((!multi & h3od4a==1) | h3od6==1)
replace RACE = 2 if !hispanic & ((!multi & h3od4b==1) | h3od6==2)

generate AGE = calcage3

keep AID SEX1 SEX3 EDU YRED EDU2 GRAD GRAD2 ATT ATTCAT RACE AGE RELTYPE PREGNANT DURATION

save ego, replace

/*
ROMANTIC PARTNER DATA
*/

clear
import sasxport Data/wave3p.xpt


recode h3ed1 0/11=1 12=2 13/15=3 16/25=4, gen(PEDU)
replace PEDU=. if PEDU>4


generate PYRED=h3ed1
replace PYRED=. if h3ed1>=96


generate PEDU2 = .
replace PEDU2 = 1 if h3ed1>1 & h3ed1<=12
replace PEDU2 = 2 if h3ed1==12 & h3ed3==1
replace PEDU2 = 3 if h3ed1>12
replace PEDU2 = 4 if h3ed5==1 | h3ed6==1 | h3ed7==1 | h3ed8==1
replace PEDU2 = . if h3ed3>=6 | h3ed5>=6

generate PGRAD = PEDU==4
replace PGRAD = 1 if h3ed26==3
// | h3ed26==4
replace PGRAD = . if PEDU==. | h3ed26==6 | h3ed26>7

generate PGRAD2 = PEDU2==4
replace PGRAD2 = 1 if h3ed26==3 | h3ed26==4
replace PGRAD2 = . if PEDU2==. | h3ed26==6 | h3ed26>7

generate PATT = h3ir1
generate PATTCAT = PATT
replace PATTCAT = 2 if PATTCAT==1

rename bio_sex3 PSEX
rename aid AID

/*
*Race - which best describes you? 
* McClintock coded as white NH, Black NH, everybody else
* I will ignore missing values here
*/
generate hispanic = h3od2==1
generate multi = h3od6!=7

generate PRACE = 3
replace PRACE = 1 if !hispanic & ((!multi & h3od4a==1) | h3od6==1)
replace PRACE = 2 if !hispanic & ((!multi & h3od4b==1) | h3od6==2)

generate PAGE = calcage3

keep AID PSEX PEDU PEDU2 PYRED PGRAD PGRAD2 PATT PATTCAT PRACE PAGE
save partner, replace

clear
import sasxport Data/partner3.xpt
rename aid AID
merge 1:1 AID using partner
drop _merge
drop AID
rename p_aid AID
save partner, replace


/*
MERGE DATA SETS
*/

clear
use ego, replace
merge 1:1 AID using partner

keep if _merge==3
drop _merge

table SEX1 PSEX
table SEX3 PSEX
table SEX1 SEX3

//I am finding some same sex couples. Its better if I use wave 3, but still problematic.
//I have found that if I 'correct' the partner's sex based on ego's sex then I get results for 
//the tabulations of educ and attractiveness that exactly match McClintock.
rename SEX3 SEX
replace PSEX=2 if SEX==PSEX & SEX==1
replace PSEX=1 if SEX==PSEX & SEX==2

//now code female and male
generate FYRED=.
generate MYRED=.
generate FEDU=.
generate MEDU=.
generate FEDU2=.
generate MEDU2=.
generate FGRAD=.
generate MGRAD=.
generate FGRAD2=.
generate MGRAD2=.
generate FATT=.
generate MATT=.
generate FATTCAT=.
generate MATTCAT=.
generate FRACE=.
generate MRACE=.
generate FAGE=.
generate MAGE=.

replace MYRED = YRED if SEX==1
replace FYRED = YRED if SEX==2
replace MYRED = PYRED if PSEX==1
replace FYRED = PYRED if PSEX==2

replace MEDU = EDU if SEX==1
replace FEDU = EDU if SEX==2
replace MEDU = PEDU if PSEX==1
replace FEDU = PEDU if PSEX==2

replace MGRAD = GRAD if SEX==1
replace FGRAD = GRAD if SEX==2
replace MGRAD = PGRAD if PSEX==1
replace FGRAD = PGRAD if PSEX==2

replace MEDU2 = EDU2 if SEX==1
replace FEDU2 = EDU2 if SEX==2
replace MEDU2 = PEDU2 if PSEX==1
replace FEDU2 = PEDU2 if PSEX==2

replace MGRAD2 = GRAD2 if SEX==1
replace FGRAD2 = GRAD2 if SEX==2
replace MGRAD2 = PGRAD2 if PSEX==1
replace FGRAD2 = PGRAD2 if PSEX==2

replace MATT = ATT if SEX==1
replace FATT = ATT if SEX==2
replace MATT = PATT if PSEX==1
replace FATT = PATT if PSEX==2

replace MATTCAT = ATTCAT if SEX==1
replace FATTCAT = ATTCAT if SEX==2
replace MATTCAT = PATTCAT if PSEX==1
replace FATTCAT = PATTCAT if PSEX==2

replace MAGE = AGE if SEX==1
replace FAGE = AGE if SEX==2
replace MAGE = PAGE if PSEX==1
replace FAGE = PAGE if PSEX==2

replace MRACE = RACE if SEX==1
replace FRACE = RACE if SEX==2
replace MRACE = PRACE if PSEX==1
replace FRACE = PRACE if PSEX==2

/*
COMPARE TO McClintock's results
*/

tabulate FEDU

/*
-> tabulation of f3_edu4
RECODE of |
  f3_yrsedu |
(W3 - Years |
     of Edu) |      Freq.     Percent        Cum.
------------+-----------------------------------
1|                   242        16.06
2|                   537        35.63
3|                   531        35.24
4|                   197        13.07
------------+-----------------------------------
Total |            1,507
*/

tabulate MEDU

/*
-> tabulation of m3_edu4
RECODE of |
  m3_yrsedu |
(W3 - Years |
     of Edu) |      Freq.     Percent
------------+-----------------------------------
1|                    287       19.06
2|                    586       38.91
3|                    466       30.94
4|                    167       11.09
------------+-----------------------------------
Total |             1,506 
*/

tabulate FGRAD

/*
-> tabulation of f3_ee_cgrdp
Clg Grad or |
       More |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      1,096       72.78       72.78
          1 |        410       27.22      100.00
------------+-----------------------------------
      Total |      1,506      100.00
*/

tabulate MGRAD

/*
-> tabulation of m3_ee_cgrdp
Clg Grad or |
       More |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      1,172       77.93       77.93
          1 |        332       22.07      100.00
------------+-----------------------------------
          Total |      1,504      100.00
*/

tabulate FATTCAT

/*
-> tabulation of f3_physatt4
RECODE of |
 f3_physatt |      Freq.     Percent        Cum.
           2|         87        5.77
           3|        596       39.55
           4|        586       38.89
           5|        238       15.79
------------+-----------------------------------
      Total |      1,507      100.00
*/

tabulate MATTCAT

/*
-> tabulation of m3_physatt4
  RECODE of |
 m3_physatt |
      (W3 - |
Interviewer |
     -rated |
   physical |
attractiven |
       ess) |
                   Freq.     Percent        Cum.
------------+-----------------------------------
           2|     85         5.64
           3|    777        51.56
           4|    521        34.57
           5|    124         8.23
------------+-----------------------------------
      Total |   1,507      100.00
*/

tabulate FRACE
tabulate MRACE
summarize FATT FGRAD FYRED FAGE PREGNANT DURATION
summarize MATT MGRAD MYRED MAGE 
tabulate RELTYPE

//HOPEFULLY THIS LINE UP PRETTY CLOSELY
  
drop EDU PEDU EDU2 PEDU2 GRAD PGRAD GRAD2 PGRAD2 ATT PATT SEX PSEX RACE PRACE AGE PAGE YRED PYRED ATTCAT PATTCAT

/*
NOW MAKE THE TABLES
*/

save fulldata, replace

drop if MEDU==. | FEDU==.
drop MATT FATT
rename MATTCAT MATT
rename FATTCAT FATT
contract MEDU FEDU MATT FATT, zero
rename _freq Freq
saveold table_yrsed.dta, replace version(12)

use fulldata, clear
drop if MEDU2==. | FEDU2==.
drop MATT FATT
rename MATTCAT MATT
rename FATTCAT FATT
contract MEDU2 FEDU2 MATT FATT, zero
rename _freq Freq
saveold table_yrsed_better.dta, replace version(12)


use fulldata, clear
drop if MGRAD==. | FGRAD==.
drop MATT FATT
rename MATTCAT MATT
rename FATTCAT FATT
contract MGRAD FGRAD MATT FATT, zero
rename _freq Freq
saveold table_grad.dta, replace version(12)

use fulldata, clear
drop if MGRAD2==. | FGRAD2==.
drop MATT FATT
rename MATTCAT MATT
rename FATTCAT FATT
contract MGRAD2 FGRAD2 MATT FATT, zero
rename _freq Freq
saveold table_grad_better.dta, replace version(12)

use fulldata, clear
saveold fulldata_old.dta, replace version(12)


