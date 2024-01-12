LIBNAME DATA 'C:\Users\user\Desktop\Default Prediction\Default';

DATA FirmData;
	SET DATA.model_fd_final;
RUN;

PROC SORT DATA = FirmData;
	BY PERMNO;
RUN;

DATA FirmDTD;
	RETAIN CURDAT PERMNO year month DTD DLSTCD relative_size exret_y Idio_Risk dtddiff yearstart monthstart yearend monthend;
	SET FirmData;
RUN;

DATA FirmYearMonthOnly;
	SET FirmDTD;
	KEEP PERMNO Year Month;
Run;

DATA FirmNotConsecutive;
	SET FirmYearMonthOnly;
	Lag_Year = LAG(Year);
	Lag_Month = LAG(Month);
	Lag_Month = Lag_Month + 1;
	IF Lag_Month = 13 THEN DO;
		Lag_Year = Lag_Year + 1;
		Lag_Month = 1;
	END;
	IF PERMNO ^= LAG(PERMNO) THEN DO;
		Lag_Year = .;
		Lag_Month = .;
	END;
RUN;

DATA FirmNotConsecutive;
	SET FirmNotConsecutive;
	IF Year ^= Lag_Year OR Month ^= Lag_Month THEN OUTPUT;
RUN;

DATA FirmNotConsecutive;
	SET FirmNotConsecutive;
	IF Lag_Year = . THEN DELETE;
	IF Lag_Month = . THEN DELETE;
	DROP Lag_Year Lag_Month;
	PROC SORT NODUPKEY;
		BY PERMNO Year Month;
RUN;

DATA DATA.FirmNotConsecutive;
	SET WORK.FirmNotConsecutive;
RUN;
