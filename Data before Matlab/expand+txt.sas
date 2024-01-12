/*sampai's data fill from1983 to 2010*/
libname DATA 'C:\Users\User\Desktop\JCDuan_Matlab_Code';
libname BEAVAR 'D:\ResearchData\Duan';

DATA FirmData;
	SET DATA.model_fd_final;
	IF Year > 2009 THEN DELETE;
RUN;
PROC SORT DATA = FirmData;
	BY PERMNO;
RUN;
DATA FirmDTD;
	RETAIN CURDAT PERMNO year month DTD DLSTCD relative_size exret_y Idio_Risk yearstart monthstart yearend monthend;
	SET FirmData;
RUN;
DATA FirmNumber;
	SET FirmDTD;
	KEEP PERMNO;
	PROC SORT NODUPKEY; 
		BY PERMNO;
RUN;
DATA ExpandCalendar;
	SET FirmNumber;
	DO Year = 1983 to 2009;
		DO Month = 1 to 12;
			OUTPUT;
		END;
	END;
RUN;
PROC SQL;
	CREATE TABLE Firm_DuanData_Expand AS
	SELECT *
	FROM ExpandCalendar AS A LEFT JOIN FirmData AS B
	ON A.PERMNO = B.PERMNO AND A.Year = B.Year AND A.Month = B.Month;
	PROC SORT NODUPKEY;
		BY PERMNO Year Month;
	RUN;
QUIT;
%INCLUDE 'C:\Users\User\Desktop\sas2matlab\FillMissing.sas';
%FillMissing(datain = Firm_DuanData_Expand, dataout =BEAVAR.Firm_DuanData_Expand_FillMissing);

/* Export sas dataset to txt files for forward intensity approach of J.C. Duan matlab program */
libname BEAVAR 'D:\ResearchData\Duan';

%let fillmiss='c:\Users\User\Desktop\sas2matlab';
%let firm_txt_PathName = 'c:\tmp\firm.txt';
%let firmList_txt_PathName = 'c:\tmp\firmlist.txt';
*%let Variables =  relative_size exret_y  Idio_Risk;
%let Variables =  permno relative_size exret_y  Idio_Risk  DTD DTDDiff;/*改*/
*%let Variables = relative_size exret_y  Idio_Risk DTD_Ind    Cus_DTD  Sup_DTD;
*%let Variables = CASH_TA NI_TA relative_size exret_y  Idio_Risk  DTD DTD_Ind  DTD_Diff  Cus_DTD  Sup_DTD;
%let Data_sas_IN =BEAVAR.Firm_duandata_expand_fillmissing ;
%let year_Start = 1983;  * reference month of Duan's matlab code , now tempararily 1997 based on BEA IO Tables;

data tmp_output; set &Data_sas_IN.;   ***匯出資料以txt檔的形式 output 個;
if year=2010 then delete;/*edited*/
file &firm_txt_PathName.;
put &Variables.; 
run;
**start to get firmlist**;
data start; set &Data_sas_IN.;

where DTD^=99999;
*if CASH_TA=99999 then delete;
start=(year-%eval(&year_Start.))*12+month;
proc sort nodupkey; 
by permno;
run;

data ending_tmp; set &Data_sas_IN.;
where DTD^=99999;
*if CASH_TA=99999 then delete;
ending=(year-%eval(&year_Start.))*12+month;
proc sort ; 
by permno descending year descending month;
run;

data ending; set ending_tmp;
proc sort nodupkey;
by permno;
run;

data BEAVAR.firmlist; merge start ending; **沐umber of firms :15067;
by permno;
keep permno start ending;
run;

*** event and output firmlist.txt;
data BEAVAR.firmlist_delist; merge BEAVAR.firmlist(in=a) BEAVAR.delist;
by permno;
if a=1;
run;

data BEAVAR.firmlist_event;set BEAVAR.firmlist_delist; 
*if year=2010 then delete;/*edited*/
select;
         when (100=<DLSTCD<200)       event=0; ** 0:active, 1:Default, ,2: M&A, DLSTCD=delisting code;
         when (400=<DLSTCD<=499)     event=1; 
         when (550=<DLSTCD<=599)     event=1; 
         otherwise                                         event=2; 
end;
drop DLSTDT DLSTCD;
file &firmList_txt_PathName.;
put permno start ending event;
run;

data firm; merge firmnotconsecutive(in=a) BEAVAR.Firm_DuanData_Expand_FillMissing(in=b);
by permno;
if a then delete;
file &firm_txt_PathName.;
put &Variables.; 
run; 

data list; merge BEAVAR.firmlist_event(in=a) firmnotconsecutive(in=b);
by permno;
if b then delete;
file &firmList_txt_PathName.;
put permno start ending event;
run;






/*********     firmlist end    *********/


/*data cbind(keep=curdat  relative_size permno  start ending a b );  merge tmp_output(in=c) BEAVAR.firmlist_event(in=d);
by permno;
if c;
retain  a 0;
b=ending-start+1;
if first.permno  then a=0;
if first.permno and relative_size ^=99999 then a=1;
if  relative_size ^=99999 then do;
		a=a+1;
end;
if last.permno then do;
	if a=ending-start+1 then do;
	output;
	end;
end;
run;
data cbind2; set cbind;

data outputfirm; set cbind;
file &firm_txt_PathName.;
put &Variables.; 
run;*/

/*data cbind2(keep=curdat  relative_size permno  start ending a b );  merge tmp_output BEAVAR.firmlist_event ;

by permno;
retain  a 0;
b=ending-start+1;
if first.permno  then a=0;
if first.permno and relative_size ^=99999 then a=1;
if  relative_size ^=99999 then do;
		a=a+1;
end;
if permno=10021;
run;
data cbind3 ; set cbind;
by permno;
retain c 0;
c=c+1;
run;*/
data uncontfirm(keep=permno year month uncont); set cbind;
by permno;
retain uncont 1;
	do year=1983 to 2010;
		do month =1 to 12;
			output;
		end;
	end;	
	run;
data del_uncont; merge uncontfirm tmp_output ;
by permno year month;
if uncont=. then output;
*proc sort;
*by permno year month;
run;
/*data check(keep=year month uncont  relative_size permno  start ending a b );  merge del_uncont(in=c) BEAVAR.firmlist_event(in=d);
by permno;
if c;
retain  a 0;
b=ending-start+1;
if first.permno  then a=0;
if first.permno and relative_size ^=99999 then a=1;
if  relative_size ^=99999 then do;
		a=a+1;
end;
if last.permno then do;
	if a=ending-start+1 then do;
	output;
	end;
end;
run;*/

data tmp_output; set del_uncont;   ***匯出資料以txt檔的形式 output 個;

file &firm_txt_PathName.;
put &Variables.; 
run;

data unconfirmlist(keep=permno start ending event); merge BEAVAR.firmlist_event(in=c) cbind(in=d);
if c=d then delete;
by permno;
run;

