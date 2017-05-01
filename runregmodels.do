/*
Aaron Gullickson
runmodels.do

This program will run our version of the conventional regression and difference models from 
McClintock's paper. We will forego control variables and MIM just to get to the fundamenal issues

We will run her basic models and then show how the difference model is the same as the conventional model
by including the missing parameters for wives education and husband's attractiveness
*/

use fulldata, clear

/**CONVENTIONAL MODEL MEDU**/
regress MYRED FATT FYRED MATT
correlate MYRED MATT

/**CONVENTIONAL MODEL MGRAD**/
glm MGRAD FATT FGRAD MATT, family(binomial) link(logit)

/**CONVENTIONAL MODEL FEDU**/
regress FYRED MATT MYRED FATT
correlate FYRED FATT

/**CONVENTIONAL MODEL MGRAD**/
glm FGRAD MATT MGRAD FATT, family(binomial) link(logit)

/**DIFF MODEL EDU**/
generate DIFFEDU = MYRED-FYRED
generate DIFFATT = MATT-FATT

regress DIFFEDU DIFFATT

regress DIFFEDU DIFFATT FYRED MATT

//the terms are the same, but R-squared is different because y is different

//show that diff model is identical to a restricted conventional model
glm MYRED DIFFATT, offset(FYRED)

//run the conventional model in glm to get model comparison stats
glm MYRED DIFFATT FYRED MATT

//look at the correlations
correlate DIFFEDU DIFFATT MYRED FYRED MATT FATT

//Now try to do McClintock's actual models

//deal with missing values 
replace RELTYPE=4 if RELTYPE==.
generate MISSDUR = DURATION==.
replace DURATION=38 if MISSDUR

// she standardized all non-dichotomous variables
egen mMYRED = mean(MYRED)
egen sMYRED = sd(MYRED)
generate zMYRED = (MYRED-mMYRED)/sMYRED

egen mFYRED = mean(FYRED)
egen sFYRED = sd(FYRED)
generate zFYRED = (FYRED-mFYRED)/sFYRED

egen mMATT = mean(MATT)
egen sMATT = sd(MATT)
generate zMATT = (MATT-mMATT)/sMATT

egen mFATT = mean(FATT)
egen sFATT = sd(FATT)
generate zFATT = (FATT-mFATT)/sFATT

egen mDUR = mean(DURATION)
egen sDUR = sd(DURATION)
generate zDUR = (DURATION-mDUR)/sDUR

egen mMAGE = mean(MAGE)
egen sMAGE = sd(MAGE)
generate zMAGE = (MAGE-mMAGE)/sMAGE

egen mFAGE = mean(FAGE)
egen sFAGE = sd(FAGE)
generate zFAGE = (FAGE-mFAGE)/sFAGE

//conventional
regress zMYRED zFATT zFYRED zMATT
regress zMYRED zFATT zFYRED zMATT zFAGE zMAGE i.FRACE i.MRACE i.RELTYPE PREGNANT zDUR MISSDUR
regress zFYRED zFATT zMYRED zMATT
regress zFYRED zMATT zMYRED zFATT zFAGE zMAGE i.FRACE i.MRACE i.RELTYPE PREGNANT zDUR MISSDUR

//diff models
generate DIFFAGE = MAGE-FAGE
regress DIFFEDU DIFFATT i.FRACE i.MRACE  i.RELTYPE PREGNANT zDUR MISSDUR DIFFAGE


