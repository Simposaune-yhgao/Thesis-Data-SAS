/*PROC EXPORT DATA = dlibmret DBMS = XLS OUTFILE = 'D:\ResearchData\sv\dlibmret';
RUN;*/
libname ff 'D:\ResearchData\FF';
data allinone(drop= month price next_ret1); set ff.testdata;
bm=1/mb;
run;
proc sort data=allinone;
by permno date; run;
data allinone1; set allinone;
by permno year;
if first.year then do 
	ret1=ret+1; end;
else do;
	ret1=ret1*(1+ret);
	retain ret1; end;
if last.year then
                ret2 =ret1**(1/12);
run;






proc rank data=allinone out=out1 group=5 DESCENDING;
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


/*proc sort data=out2;
by permno date;run;*/
/*data table3;set out2;
bm=1/mb;
predli=lag(pi_merton);
run;*/
proc sort data=table3;
by rank1 rank2;run;
proc means mean data = table3  noprint;

var ret bm pi_merton size;
class rank1 rank2;
output out=portmean(drop=_type_ _freq_) MEAN = RET Size Pi_Merton BM;
run;
DATA portmean1;
	SET portmean;
	IF rank1 = . THEN DELETE;
	IF rank2 = . THEN DELETE;
	rank1 = rank1 + 1;
	rank2 = rank2 + 1;
RUN;


proc transpose data=portmean1 OUT = TableIV(DROP = _LABEL_ );
var  ret size  pi_merton bm;
by rank1;ID rank2;
run;
PROC SORT;
		BY _NAME_;
RUN;

DATA TableIV;
	SET TableIV;
	LABEL _NAME_ = 'Variable'
					_1 = 'Small 1'
					_2 = '2'
					_3 = '3'
					_4 = '4'
					_5 = 'Big 5'
					Group1 = 'DLI (1: High, 5: Low)';
RUN;
