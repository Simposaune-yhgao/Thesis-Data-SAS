PROC IMPORT OUT= WORK.dd 
            DATAFILE= "D:\ResearchData\sv\US-nohead.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
