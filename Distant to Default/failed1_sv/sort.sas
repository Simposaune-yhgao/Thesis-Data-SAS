libname sv 'D:\ResearchData\sv';

data bkmk; set sv.tickerwrds;
if tic=' ' then a+1;
retain a;
run;
proc sort data= bkmk; by tic datadate;run;
data nameus; set name;
rename company_number = company_id;
if country_domicile ^='US' then delete; run;
data tickerdli ; merge nameus dli;

length tic $ 5;

tic = left(ticker);
by company_id; run;
proc sort data=tickerdli; by tic; run;
data dlibkmk; merge bkmk tickerdli;
if missing(at) then delete;
if missing(dli) then delete;
by tic; run;

data return(keep=ret TSYMBOL date comnam); set q157d3f0cfb75d5ca;
run;
data return1; set return;

fyear=year(date);
length tic $ 5;
if tsymbol=' ' then delete;
tic = left(tsymbol);run;

data dli_mk_bm1; set dli_mk_bm;
rename datadate = date; run;
proc sort data = dli_mk_bm1;
by tic fyear ;run;
proc sort data = return1;
by tic fyear;run;

data dlibmret; merge return1 dli_mk_bm1;
if missing(dli) then delete;
if missing(ret) then delete;
by tic fyear ;
run;

/*PROC EXPORT DATA = dlibmret DBMS = XLS OUTFILE = 'D:\ResearchData\sv\dlibmret';
RUN;*/
libname ff 'D:\ResearchData\FF';
data allinone(drop=year month price next_ret1); set ff.testdata;
run;
proc rank data=allinone out=out1 group=5;
var pi_merton;
ranks rank1;
run;
proc sort data=out1;
by rank1 ;
run;
proc rank data=out1 out=out2 group=5;
var size; ranks rank2; by rank1; run;
proc sort data=out2;
by rank1 rank2;
run;


proc sort data=out2;
by permno date;run;
data table3;set out2;
bm=1/mb;
predli=lag(pi_merton);
run;
proc sort data=table3;
by rank1 rank2;run;
proc means mean data = table3  noprint;

var ret bm predli size;
by rank1 rank2;
output out=portmean(drop=_type_ _freq_);
run;



proc transpose data=table3;
var rank2 ret size bm;
by rank1;
run;








/*proc sort data= dli;by company_id;run;
data name;set name; rename Company_Number=company_id;run; 
proc sort data= name;by company_id;run;
data dliname; merge dli name; 
by company_id; 
if Country_Domicile ^= 'US' then delete;
run;

data bkmkname1; set bkmkname;
company_name = lowcase(company_name);
run; 
data dliname1; set dliname;
company_name = lowcase(company_name);
run;
proc sort data= dliname1; by company_name; run;
proc sort data= bkmkname1; by company_name; run;
data bkmkdli(drop=fyear bkvlps sic company_id ); merge bkmkname1 dliname1;
by  Company_Name;
run;

data bkmkname ;set sv.bkmk ;
rename conm= Company_Name;
run;
proc sort data=bkmkname;
by Company_name datadate;
run;
proc sort data=name;
by Company_name ;
run;





















/*proc sort data= dli;by company_id;run;
data name1;set name; rename Company_Number=company_id;run; 
proc sort data= name1;by company_id;run;
data dliname; merge dli name1; 
by company_id; 
if Country_Domicile ^= 'US' then delete;
run;

data bkmkname1; set bkmkname;
company_name = lowcase(company_name);
run; 
data dliname1; set dliname;
company_name = lowcase(company_name);
run;
proc sort data= dliname; by company_name; run;
proc sort data= bkmkname1; by company_name; run;
data bkmkdli; merge bkmkname1 dliname;
by  Company_Name;
run;
data bkmkname ;set sv.bkmk ;
rename conm= Company_Name;
run;
proc sort data=bkmkname;
by Company_name datadate;
run;
proc sort data=name;
by Company_name ;
run;*/






















