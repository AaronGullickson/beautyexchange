##############################
# Run log-linear (or negative binomial really) models 
# from McClintock paper
# 
# The models 1a, 1b, 2a, and 2b here correspond exactly 
# to the models in McClintock's paper. 1c and 2c are 
# my recoded versions where the two forms of exchange 
# (stereotypical and reverse-stereotypical) are fit as 
# two separate effects rather than a main effect and 
# interaction term. 
#
# The input files here are not included because they 
# contain some table cells that have two few cases to 
# release under the AddHealth contract agreements. 
#
###############################
library(foreign)
library(MASS)

edtable <- read.dta("table_yrsed.dta")

#matching parameters for attractiveness and education
edtable$attmatch <- edtable$FATT==edtable$MATT
edtable$edmatch <- edtable$FEDU==edtable$MEDU

#upward exchange parameters, opp=attractive men, educated women; stereo=attractive women, educated men, sym=force them to be the same
edtable$uexchangeopp <- edtable$MATT>edtable$FATT & edtable$MEDU<edtable$FEDU
edtable$uexchangestereo <- edtable$FATT>edtable$MATT & edtable$FEDU<edtable$MEDU
edtable$uexchangesym <- edtable$uexchangeopp | edtable$uexchangestereo

#now also do downward exchange terms, synonomous with these terms
edtable$dexchangeopp <- edtable$MATT<edtable$FATT & edtable$MEDU<edtable$FEDU
edtable$dexchangestereo <- edtable$FATT<edtable$MATT & edtable$FEDU<edtable$MEDU
edtable$dexchangesym <- edtable$dexchangeopp | edtable$dexchangestereo

edtable$FATT <- as.factor(edtable$FATT)
edtable$MATT <- as.factor(edtable$MATT)
edtable$MEDU <- as.factor(edtable$MEDU)
edtable$FEDU <- as.factor(edtable$FEDU)

#model 1a
model1a <- glm.nb(Freq~FATT+MATT+FEDU+MEDU+FATT*FEDU+MATT*MEDU+attmatch+edmatch+uexchangesym, data=edtable)
model1b <- update(model1a, .~.+uexchangestereo)
#fit stereotypical and opposite separately
model1c <- update(model1b, .~.-uexchangesym+uexchangeopp+uexchangestereo, data=edtable)

#now for college

coltable <- read.dta("table_grad_better.dta")
coltable$FEDU <- coltable$FGRAD
coltable$MEDU <- coltable$MGRAD

#matching parameters for attractiveness and education
coltable$attmatch <- coltable$FATT==coltable$MATT
coltable$edmatch <- coltable$FEDU==coltable$MEDU

#upward exchange parameters, opp=atrractive men, educated women; stereo=attractive women, educated men, sym=force them to be the same
coltable$uexchangeopp <- coltable$MATT>coltable$FATT & coltable$MEDU<coltable$FEDU
coltable$uexchangestereo <- coltable$FATT>coltable$MATT & coltable$FEDU<coltable$MEDU
coltable$uexchangesym <- coltable$uexchangeopp | coltable$uexchangestereo

#now also do downward exchange terms, synonomous with these terms
coltable$dexchangeopp <- coltable$MATT<coltable$FATT & coltable$MEDU<coltable$FEDU
coltable$dexchangestereo <- coltable$FATT<coltable$MATT & coltable$FEDU<coltable$MEDU
coltable$dexchangesym <- coltable$dexchangeopp | coltable$dexchangestereo

coltable$FATT <- as.factor(coltable$FATT)
coltable$MATT <- as.factor(coltable$MATT)
coltable$MEDU <- as.factor(coltable$MEDU)
coltable$FEDU <- as.factor(coltable$FEDU)

model2a <- update(model1a, data=coltable)
model2b <- update(model1b, data=coltable)
model2c <- update(model1c, data=coltable)


