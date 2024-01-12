
libname BEAVAR 'C:\ResearchData\BEA\Variables';
libname BEACD 'C:\ResearchData\BEA\BEACD';
libname CRSPA 'C:\GoogleDrive\DataAlice\Alice_SAS\CRSP';
libname CCM 'C:\ResearchData\CCM';
libname CRSP 'C:\ResearchData\CRSP_Data';


/* HANK:  CCM key merge with 4 firm-specific variables */ 
libname Shum 'C:\ResearchData\Shumway';
data Shumway_2001all; set Shum.Shumway_2001all;
where ^missing(exret_y);
run;

libname RMI "C:\ResearchData\RMI" ;
data RMI_CCM; set RMI.RMI_CCM;
keep permno year month DTD sigma;
run;

*Add RMI DTD (Hank: Inclusing financial firms??? );
proc sql;
    create table BEAVAR.firmdata_ShumDTD as
	select a.permno,  a.year, a.month,  relative_size, exret_y, Idio_Risk,  DTD, sigma 
	from Shumway_2001all as a left join RMI_CCM as b
    on a.permno=b.permno and a.month=b.month and a.year=b.year;
	proc sort nodupkey; by permno year month;run;
quit;

data BEAVAR.firmdata_ShumDTD; set BEAVAR.firmdata_ShumDTD;
if ^missing(relative_size) and ^missing(DTD);
run;


/*  Hank : Here add CASH_TA, NI_TA from CCM quarterly later, merge by permno */
data DP_CASH_NI_TA;  set CCM.DP_1983_2015_CASH_NI_TA(rename=( LPERMNO=permno));
year=year(DATADATE);
month=month(DATADATE);
if year>=1990; * match RMI DTD period;
keep gvkey permno year month Cash_TA NI_TA;
run;

%include "C:\GoogleDrive\Program\SAS_Macro\lag3Months.sas";
%Lag3Months(DP_CASH_NI_TA);


proc sql;
    create table BEAVAR.firmdata_ShumDTD_CASH_NI as
	select a.* , b.Cash_TA, b.NI_TA 
	from BEAVAR.firmdata_ShumDTD as a left join DP_CASH_NI_TA_lag3M as b
    on a.permno=b.permno and a.month=b.month and a.year=b.year;
	proc sort nodupkey; by permno year month;run;
quit;

%include "C:\GoogleDrive\Program\SAS_Macro\mac_Forward_Var_Fill.sas"; 
%mac_Forward_Var_Fill(dsetin= BEAVAR.firmdata_ShumDTD_CASH_NI, dsetout=update_CASH_NI, Firm_ID=permno, variables=Cash_TA NI_TA);

proc sort data=BEAVAR.firmdata_ShumDTD_CASH_NI;
by permno year month;
proc sort data=update_CASH_NI;
run;
data BEAVAR.firmdata_ShumDTD_CASH_NI;
update BEAVAR.firmdata_ShumDTD_CASH_NI update_CASH_NI;
by permno year month;
run;



*Add BEA industry classification ;
/*HANK only find > year 2004 : change here */
Data CCM_CRSP_monthly_BEA_key (keep = PERMNO NAICS BEA71 year month);
set BEACD.BEA_permno;
if missing (NAICS) then delete;
if missing (BEA71) then delete;
proc sort; by PERMNO year month;
run;

data BEAVAR.firmdata_BEA; merge   BEAVAR.firmdata_ShumDTD_CASH_NI (in=a) CCM_CRSP_monthly_BEA_key;
if a=1;
if bea71='' then delete;  /* Hank why ??? */
by PERMNO year month; 
run;

data BEAVAR.firmdata_BEA; set BEAVAR.firmdata_BEA; ***此資料包含所有的公司+保留產業(因一間公司會在不同產業);
if missing(CASH_TA) or  missing(DTD) or missing(NAICS) then delete;
proc sort; 
by permno year month;
run; 


**before compute Mean_DTD, need to winsor DTD first;
%include "C:\GoogleDrive\Program\SAS_Macro\Winsorize_Macro.sas";
%winsor(dsetin=BEAVAR.Firmdata_BEA, dsetout=BEAVAR.firmdata_BEA_win, byvar=none, vars=CASH_TA NI_TA relative_size exret_y  Idio_Risk  DTD , type=winsor, pctl=1 99);


*決ean DTD by BEA classification;
Proc means noprint data=BEAVAR.firmdata_BEA_win;
Var DTD;
Class BEA71 year month;
Output out=Firm_bea71_MDTD (drop=_type_ _freq_) mean=DTD_Ind;
Run;


data BEAVAR.bea71_DTD_Ind; set Firm_bea71_MDTD;
if ^missing(BEA71) and ^missing(year) and ^missing(month);
run;

data Firm_bea71_MDTD; set Firm_bea71_MDTD;
If ^missing(year) and ^missing(month) and ^missing(bea71) then output;
run;
proc sort; by BEA71 year month;
run;

proc sort data=BEAVAR.firmdata_BEA_win; 
by BEA71 year month; 
run;
data Firm_BEA71_MDTD; merge BEAVAR.firmdata_BEA_win Firm_bea71_MDTD;
by BEA71 year month; 
DTD_Diff = (DTD-DTD_Ind);
if missing(DTD_Diff) then delete;
run;

/***  6/1 stop here ***/

/***  RUN customer-supplier DTD ***/

data Cus_sup_DTD; set BEAVAR.Cus_sup_DTD;
run;

proc sql;
create table Firm_BEA71_DTDAll as
select a.*, b.Cus_DTD, Sup_DTD
from  Firm_BEA71_MDTD as a left join Cus_sup_DTD as b
on a.BEA71=b.BEA71 and a.month=b.month and a.year=b.year
order by permno, year, month
;
quit;


/*  Start export first 6/9 */


/** Start here 6/9  **/



proc sort data= Firm_BEA71_DTDAll;  
by permno year month;
run;

*汽otal number of Firms ;
data FirmNum; set Firm_BEA71_DTDAll (keep= permno bea71); **firms:16715;  ** 11329;
proc sort nodupkey;by permno;
run;



data ExpandCalendar; set FirmNum;
do year =1997 to 2014;  * Hank : start to end year;
do month = 1 to 12;
output;
end;
end;
run;

proc sql;
    create table Firm_DuanData_Expand as
	select *
    from ExpandCalendar as a left join Firm_BEA71_DTDAll as b 
    on a.permno=b.permno and a.bea71=b.bea71 and a.month=b.month and a.year=b.year;
	proc sort nodupkey; by permno year month;run;
quit;


/************  Follow Duan's format  *********************/

%include "C:\GoogleDrive\Program\SAS_Macro\FillMissing.sas";  /*Call FillMissing*/
%FillMissing(datain=Firm_DuanData_Expand, dataout= BEAVAR.Firm_DuanData_Expand_Fill9);

/* Then run
C:\ResearchData\BEA\Variables
Export_Duan_sas_To_Duan_txt_MatlabInput.sas
*/

/************   END of Duan_Data_Firm_List *********************/



