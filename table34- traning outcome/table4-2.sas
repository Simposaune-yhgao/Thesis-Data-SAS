/*PROC EXPORT DATA = dlibmret DBMS = XLS OUTFILE = 'D:\ResearchData\sv\dlibmret';
RUN;*/
libname ff 'D:\ResearchData\FF';
data allinone(drop=  price next_ret1); set ff.testdata;
bm=1/mb;
size=log(size);
run;
proc sort data=allinone;
by permno date; run;
/*data allinone1; set allinone;
by permno year;
if first.year then delete ;run;*/
data allinone1; set allinone;/*算算數平均年報酬*/
by permno year;
if first.year then do 
	ret1=ret+1; end;
else do;
	retain ret1;ret1=ret1*(1+ret);
	 end;
if last.year then
                ret2 =100*(ret1**(1/12)-1);
run;

data ret3(keep=permno year date ret2); set allinone1;run;/*去掉一些colume*/
proc sort data=ret3;
by  permno year descending ret2;
run;

data ret4; set ret3;/*ret3:把算術平均年報酬貼到每一row*/
by permno year descending ret2;
if ^missing(ret2) then ret3=ret2;
retain ret3; run;

proc sort data=allinone1;
by year permno descending ret2 date ; run;
proc sort data=ret4;
by year permno descending ret2 date ; run;



data allinone2; merge allinone1 ret4;/*allinone2裡面有dli和年報酬(ret3)*/
by year permno descending ret2 date ; 
run;

proc sort data=allinone1;
by permno year month; run;/*2009*/

data allndelist; set allinone1;/*到09年沒生存就在最後加入-100%*/
by permno year month ;
if last.permno & year ^=2009 then do
	ret3 =-100;
	if month^=12 then do
		year=year; 
		month=month+1;
		end;
	else do  		
		year=year+1; 		
		month=1;
		end;
	output;
	end; run;
data delistret3; merge allinone1 allndelist;
by permno year month; run;



proc rank data=delistret3 out=out1 group=5 DESCENDING;
var pi_merton;
ranks rank1;
run;
proc sort data=out1;
by rank1 ;
run;
proc rank data=out1 out=out2 group=5;
var size; ranks rank2; by rank1; run;
/*proc sort data=out2;
by rank1 rank2;
run;
data out3; set out2;
by rank1 rank2;
retain a;

if first.rank2 then a=1;
else a=a+1;
if last.rank2 then do
b=a;
output; end;

run;*/



/*proc sort data=out2;
by permno date;run;*/
/*data table3;set out2;
bm=1/mb;
predli=lag(pi_merton);
run;*/
/*proc sort data=table3;
by rank1 rank2;run;*/
proc means mean data =out2  noprint;/*做portfolio的平均*/

var ma bm pi_merton size;
class rank1 rank2;
output out=portmean(drop=_type_ _freq_) MEAN = ma BM  Pi_Merton Size;
run;

DATA portmean1;
	SET portmean;
	IF rank1 = . THEN DELETE;
	IF rank2 = . THEN DELETE;
	rank1 = rank1 + 1;
	rank2 = rank2 + 1;
RUN;


proc transpose data=portmean1 OUT = TableIV(DROP = _LABEL_ );
var  ma size  pi_merton bm;
by rank1;ID rank2;
run;
PROC SORT;
		BY _NAME_;
RUN;

DATA TableIV;
	SET TableIV;
	SminusL=_1-_5;
	LABEL _NAME_ = 'Variable'
					_1 = 'Small 1'
					_2 = '2'
					_3 = '3'
					_4 = '4'
					_5 = 'Big 5'
					Group1 = 'DLI (1: High, 5: Low)';
RUN;
Libname out 'D:\ResearchData\table34';
data ttest; set out2;
if rank1=0 & rank2=0 then group1=1;
if rank1=0 & rank2=4 then group1=2;
if rank1=1 & rank2=0 then group2=1;
if rank1=1 & rank2=4 then group2=2;
if rank1=2 & rank2=0 then group3=1;
if rank1=2 & rank2=4 then group3=2;
if rank1=3 & rank2=0 then group4=1;
if rank1=3 & rank2=4 then group4=2;
if rank1=4 & rank2=0 then group5=1;
if rank1=4 & rank2=4 then group5=2;run;
/*proc ttest data= ttest;
class group1 ;
var ret3;
run;
proc ttest data= ttest;
class group2 ;
var ret3;
run;proc ttest data= ttest;
class group3 ;
var ret3;
run;proc ttest data= ttest;
class group4 ;
var ret3;
run;proc ttest data= ttest;
class group5 ;
var ret3;
run;
*/


data out.table4_2;
    Set tableiv;
 Run;
