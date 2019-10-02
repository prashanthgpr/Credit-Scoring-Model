Libname Credit2 "Y:\";
run;

/* Import the file */

Proc import datafile="Z:\Assignments\Graded Assignment\Topic 10 -  Regression Models\Credit.csv"
Out=Credit2.lreg
dbms=csv replace;
run;

proc contents data=Credit2.lreg;
run;

data Credit2.test;
set Credit2.lreg;
new_monthly_income=input(Monthlyincome,best12.);
run;



/* Data Exploration*/

Proc means n nmiss data=Credit2.test;
run;

data Credit2.lreg1;
set Credit2.test;
if missing(NPA_STATUS) then delete;
run;

proc means n nmiss data=Credit2.lreg1;
run;

Proc contents data=Credit2.lreg1;
run;

Proc freq data=Credit2.lreg1;
table  Gender Region  Rented_OwnHouse Occupation Education;
run;

/* Data Preparation */

Data Credit2.lreg2;
set Credit2.lreg1;

/*AGE*/

if age=0 then delete;
if age le 30 then age30=1;
else age30=0;
if 31 le age le 45 then age45=1;
else age45=0;
if 46 le age le 65 then age65=1;
else age65=0;
if 66 le age le 109 then age66=1;
else age66=0;

/*Gende*/

if Gender='Male' then gender1=1;
else Gender1=0;


/* Region */

if Region='East' then east1=1;
else east1=0;
if Region='North' then north1=1;
else north1=0;
if Region='West' then west1=1;
else west1=0;
if region='South' then south1=1;
else south1=0;
if region='Centr' then centr1=1;
else centr1=0;

/* House ownership status */

if Rented_OwnHouse= 'Ownhouse' then house1=1;
else house1=0;

/* Education */

if Education='Matric' then matric_dummy=1;
else matric_dummy=0;
if Education= 'Graduate' then graduate_dummy=1;
else graduate_dummy=0;
if Education='Post-Grad' then pg_dummy=1;
else pg_dummy=0;
if Education='PhD' then phd_dummy=1;
else phd_dummy=0;
if Education='Professional' then prof_dummy=1;
else prof_dummy=0;

if Education='Matric' then new_education=1;
else if Education='Graduate' then new_education=2;
else if Education='Post-Grad' then new_education=3;
else if Education='PhD' then new_education=4;
else new_education=5;
/* Monthly Income */
if new_monthly_income=. then new_monthly_income=0;
if new_monthly_income le 10000 then low_inc=1;
else low_inc=0;
if 10001 le new_monthly_income le 50000 then med_inc=1;
else med_inc=0;
if 50001 le new_monthly_income le 100000 then high_inc=1;
else high_inc=0;
if new_monthly_income> 100001 then very_high_inc=1;
else very_high_inc=0;
/* Occupation */
if Occupation= 'Self_Emp' then self_dummy=1;
else self_dummy=0;
if Occupation='Officer1' then officer1_dummy=1;
else officer1_dummy=0;
if Occupation='Officer2' then officer2_dummy=1;
else officer2_dummy=0;
if Occupation='Officer3' then officer3_dummy=1;
else officer3_dummy=0;
if Occupation='Non-offi' then nonoffi_dummy=1;
else nonoffi_dummy=0;

run;

/* Logistic Regression Model*/

Proc surveyselect data=Credit2.lreg2
method= SRS out=Credit2.lreg3 samprate=0.5 outall;
run;

data train validate;
set Credit2.lreg3;
if selected=0 then output train;
else if selected=1 then output validate;
run; 



Proc Logistic data=train decending;
Model NPA_Status=age30 age45 age65 gender1 east1 north1 west1 south1 house1 graduate_dummy pg_dummy
phd_dummy prof_dummy low_inc med_inc high_inc self_dummy officer1_dummy officer2_dummy officer3_dummy/ctable lackfit;
run;

/* Droping insignificent variables all income dummies*/

Proc Logistic data=train decending;
Model NPA_Status=age30 age45 age65 gender1 east1 north1 west1 south1 house1 pg_dummy graduate_dummy phd_dummy 
prof_dummy self_dummy officer1_dummy officer2_dummy officer3_dummy/ctable lackfit;
run;

/* Putting monthly income as a whole */

Proc Logistic data=train decending outModel=lre4;
Model NPA_Status=age30 age45 age65 gender1 east1 north1 west1 south1 house1 graduate_dummy prof_dummy phd_dummy
pg_dummy new_monthly_income self_dummy officer1_dummy officer2_dummy officer3_dummy/ctable lackfit;
score out=lre5;
run;

Proc Logistic data=Validate decending outModel=lre4;
Model NPA_Status=age30 age45 age65 gender1 east1 north1 west1 south1 house1 graduate_dummy prof_dummy phd_dummy
pg_dummy new_monthly_income self_dummy officer1_dummy officer2_dummy officer3_dummy/ctable lackfit;
score out=lre5;
run;


proc rank data=lre5 out=decile groups=10 ties=mean;
var p_1;
ranks decile;
run;

proc sort data=decile;
by decending  p_1;
run;

proc export data=decile outfile="Y:\pred.csv"
dbms=csv replace;
run;









