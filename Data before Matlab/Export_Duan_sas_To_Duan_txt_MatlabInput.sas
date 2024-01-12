/* Export sas dataset to txt files for forward intensity approach of J.C. Duan matlab program */
libname BEAVAR 'C:\ResearchData\BEA\Variables';

%let firm_txt_PathName = 'c:\tmp\firm.txt';
%let firmList_txt_PathName = 'c:\tmp\firmlist.txt';
*%let Variables =  relative_size exret_y  Idio_Risk;
%let Variables =  relative_size exret_y  Idio_Risk  DTD ;
*%let Variables = relative_size exret_y  Idio_Risk DTD_Ind  DTD_Diff  Cus_DTD  Sup_DTD;
*%let Variables = CASH_TA NI_TA relative_size exret_y  Idio_Risk  DTD DTD_Ind  DTD_Diff  Cus_DTD  Sup_DTD;
%let Data_sas_IN = BEAVAR.Firm_DuanData_Expand_Fill9;
%let year_Start = 1997;  * reference month of Duan's matlab code , now tempararily 1997 based on BEA IO Tables;


data tmp_output; set &Data_sas_IN.;   ***匯出資料以txt檔的形式 output 個;
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

/*********     firmlist end    *********/
