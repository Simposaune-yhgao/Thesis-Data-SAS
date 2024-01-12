libname  VX  'D:\ResearchData\V&X';
data t1; set VX.table1sic2;
year=year(datadate);
 run;
data t2; set t1;
if sic >=6000 & sic<=6799 then delete;
run;


proc sort  data=t2; by year sic gvkey; run;

data t3; set t2;
by year sic gvkey;
 if first.gvkey;/*delete repication*/
 run;

 data t4; set t3;
 by year;
if first.year then c=0;
retain c;
c+1;

if last.year;
run;
data t5; set t3;
proc sort data = t5; by year DLRSN; run;
data t6; set t5;
by year dlrsn;
if first.dlrsn then b=0;
retain b;
b+1;
if last.dlrsn;
if dlrsn =02 then output;
run;










/*retain sample; by year;
if first.year then sample=0;
        sample=sample+1;

run;*/
