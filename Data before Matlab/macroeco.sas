libname BEAVAR 'D:\ResearchData\Duan';
libname DATA 'C:\Users\User\Desktop\JCDuan_Matlab_Code';


DATA snp;
	SET BEAVAR.snp;
	year=year(date);
	month=month(date);
	day= day(date);
	monthnum=(year-1982)*12+month;	
	if year=1981 then delete;

RUN;
data snpmonth (keep=date yrtrail year month); set snp;
by year month;
retain prv 122.550003;
if last.month then do 
	yrtrail=(Adj_Close-prv)/prv;
	prv=Adj_Close;
end;
if last.month;
if year=1982 then delete;
run;

DATA tbill;
	SET BEAVAR.tbillrate;
year=year(date);	
month=month(date);
if year=1982 then delete;
rename adj_close=tbillrate;
run;
data macroeco(keep= yrtrail tbillrate ); merge snpmonth tbill;
by year month;
if year=2010 then delete;
file 'c:\tmp\macro.txt';
put yrtrail tbillrate ;
run;
	

	

















