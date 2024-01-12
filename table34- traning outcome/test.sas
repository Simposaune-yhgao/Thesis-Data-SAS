data single_sort (keep=ret3 rank2 date permno); set out2;
by rank2; run;
proc means mean data=single_sort noprint;

var ret3;
class rank2;
output out=singlemean(drop=_freq_ _type_) mean=ret3;
run;
 
proc sort data=allinone;
by permno year month; run;/*2009*/

data allndelist; set allinone;
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
data delistret3; merge allinone allndelist;
by permno year month; run;

proc rank data=delistret3 out=single group=5 DESCENDING;
var pi_merton;
ranks rank1;
run;

proc means mean data =single  noprint;

var ret3  pi_merton ;
class rank1;
output out=singlemean (drop=_type_ _freq_) MEAN = RET3   Pi_Merton ;
run;

proc rank data=delistret3 out=singlesize group=5 DESCENDING;
var size;
ranks rank2;
run;

proc means mean data =singlesize  noprint;

var ret3  pi_merton size ;
class rank2;
output out=singlemeansize (drop=_type_ _freq_) MEAN = RET3   Pi_Merton size ;
run;
proc sort data=delistret3 ;
by permno;
run;

proc means mean data =delistret3  noprint;

var ret3  pi_merton size ;
class permno;
output out=singlemeanfirm (drop=_type_ _freq_) MEAN = RET3   Pi_Merton size ;
run;
proc rank data=singlemeanfirm out=singlemeanfirm group=2 ;
var size; ranks srank;
run;

proc means data= singlemeanfirm noprint;
var ret3  pi_merton size ;
class  srank;

output out=sbmean MEAN = RET3 BM  Pi_Merton Size;run;
/********************lagsize和ret(t+1)單排**********************/
data allinone3(drop=ret1 ret2 ret3 lagret);set allinone2;
lagsize=lag(log(size));
run;
proc rank data=allinone3 out=singlesize group=5 DESCENDING;
var lagsize;
ranks rank2;
run;

proc means mean data =singlesize  noprint;

var retroll  pi_merton lagsize ;
class rank2;
output out=singlemeansize (drop=_type_ _freq_) MEAN = RETroll   Pi_Merton lagsize ;
run;
/********************lagbm和R(T+1) 單排**********************/
data allinone3(drop=ret1 ret2 ret3 lagret);set allinone2;
lagbm=lag(bm);
run;
proc rank data=allinone3 out=singlebm group=5 DESCENDING;
var lagbm;
ranks rank2;
run;

proc means mean data =singlebm  noprint;

var ret  pi_merton lagbm ;
class rank2;
output out=singlemeanbm (drop=_type_ _freq_) MEAN = RET   Pi_Merton lagbm ;
run;

proc sort data=all2ntime1;
by permno time;
run;

data added; set all2ntime1;
if last.permno & year ^= 2008 then retroll =-1;
	else delete;
by permno time;
if last.permno;
	do time=0 to (time1+1);	
			output;
	end;
	run;

data delistingret; merge added all2ntime1;
by permno time;
run;

proc sort data=allinone1;
by  date permno;
run;
