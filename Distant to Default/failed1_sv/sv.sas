libname sv 'D:\ResearchData\sv';
PROC IMPORT OUT= WORK.dd /*import by clicking*/
            DATAFILE= "D:\ResearchData\sv\US-nohead.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
data DLI ; set dd;
if dtd<0 then delete ;
Dli=CDF('Normal', -(dtd),0,1);
d_date= MDY( mod(int(date/100),100)   , mod(date,100) , int(date/10000) );/*to generate "yymmdd" into "sas date"*/
year=year(d_date);month=month(d_date);
run;
proc means mean data=dli ;
var dli;
class year month;/*to split class when calculatetin means*/
output out= pd ;
run;
data sv; set pd;
if missing(year) then delete;
if missing(month) then delete;
if  _stat_ ^= 'MEAN' then delete; /*get only means*/
date=year*100+month;
sv=1-dli;
del_sv=dif(sv)/lag(sv);/*delta_sv*/
run; 
proc means mean data= sv ;
var sv del_sv;
output out=sumstat_sv;
run;
data ff3factor; set ff3factor;
rename var1 = date;
run;

data svff3(keep=date sv del_sv emkt smb hml);
merge sv ff3factor;
by date ;
run;
proc corr data=svff3;/*corr metrix*/
var del_sv emkt smb hml;
run;

proc reg data=svff3;
model  emkt=del_sv; 
 model smb=del_sv; 
model hml=del_sv ;  run;

