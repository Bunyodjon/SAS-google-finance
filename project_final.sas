/*
Discription of Program: This program downloads a historical stock data based on 
stock ticker, stock market ticker, start data and end date. It prints out plots and 
financial indicator in a report form. The program consists of one large macro that 
computes everything, and it could be called as many times as possible  
Date: October 1, 2017
Last Updated: December 13, 2017 
Author: Bunyod Tusmatov 

Input Variables:   
Macros and input: %finance (symbol=, stock_market=, start_date=, end_date=) 
Output variable: 
Program file: "C:\Users\Admin\Documents\Fall 2017 Courses\Statistical Programming\Homeworks\h5_A.sas"
Data source: Data is optained from google finance
Output file: two plots with several indicators like Moving Average and Bollinger Bands

*/

%macro finance(symbol=, stock_market=, start_date=, end_date=);

filename History url "http://finance.google.ca/finance/historical?q=&stock_market:&symbol&output=csv"  DEBUG; 

/* created hist_stock data set */
data work.hist_stock;
	infile History dsd firstobs=2; 
	input date date11. open high low close volume;
	format date date7. volume 12.0;
run;
filename History clear;   /* clears obtained data */

/*adjusts data based on optional input days=*/ 
proc sql;
	create table adjusted_data as
	select date, close, volume, low, high
	from hist_stock
	where date between "&start_date"d and "&end_date"d; 
quit;

proc sort data=adjusted_data;
	by date;
run;


/* calculated Simple Moving Ave, Exponential Average and Standard Deviation */
proc expand data=adjusted_data out=mov_ave;
	id date;
	convert close=MA / transout=(movave 7);
	convert close=LMA/ transout=(movave 30);
	convert close=STD /transout=(movstd 7);
run;

/* creates upper and lower bands with 2 std. devi and 3 standard deviation*/
data mov_ave2;
	set mov_ave;
	upperband=MA+1.96*STD;
 	lowerband=MA-1.96*STD;
 	upperband1=MA+3*STD;
 	lowerband1=MA-3*STD;
run;

/* creating costum template for the graphs */ 
title "Project Output";
proc template;
define statgraph cool_project;
begingraph / designwidth=750px designheight=900px;
    entrytitle "Amazon's Stock Price between &start_date and &end_date";
	layout lattice / columns=1 columndatarange=union rowweights=(0.45 0.45 0.1);
		columnaxes;
       		columnaxis / offsetmin=0.02 griddisplay=on;
      		endcolumnaxes;
		/*Main stock price */ 
		layout overlay / cycleattrs=true yaxisopts=(griddisplay=on label="Closing Price (USD)"); 
			seriesplot x=date y=close / name="Close Price" legendlabel="Closing Price" lineattrs=(thickness=1.5 color=cx008080);
			seriesplot x=date y=MA / name='MovAve' legendlabel="MA(7)" lineattrs=(thickness=1 color=cxff1493);
			seriesplot x=date y=LMA / name='Long-MA' legendlabel="Long-MA(30)" lineattrs=(thickness=1 color=cxD2691E);
			discretelegend "Close Price" "MovAve" "Long-MA" / across=1 border=on valign=top halign=left location=inside opaque=true;
		endlayout;
		/*Bollinger bands plot*/ 
		layout overlay / cycleattrs=true yaxisopts=(griddisplay=on label="Closing Price (USD)");
			bandplot x=date limitupper=upperband1 limitlower=lowerband1 / fillattrs=(color=cx20b2aa) 
              	display=(fill outline) name="boll" outlineattrs=(pattern=solid) legendlabel='BollingerBand 3STD';
			bandplot x=date limitupper=upperband limitlower=lowerband / fillattrs=(color=cxFFC0CB)
			legendlabel='BollingerBand 2STD' name='bb2';
			seriesplot x=date y=close / legendlabel="Daily Price" name='Close';
			discretelegend "Close" "boll" "bb2" / across=1 border=on valign=top halign=left location=inside opaque=true;
		endlayout; 
		
		/* small volume plot */
		layout overlay / yaxisopts=(griddisplay=on display=(line) displaysecondary=all)
					xaxisopts=(linearopts=(viewmax='11DEC17'd));
			needleplot x=date y=volume /  name="volume" legendlabel="Volume" lineattrs=(pattern=solid thickness=1.5px);
			discretelegend "volume"/ across=1 location=inside border=on halign=left valign=top opaque=true;
		endlayout;
	endlayout;
endgraph;
end;
run;
/* create ods rtf file */
ods rtf file="C:\Users\Admin\Documents\Fall 2017 Courses\Statistical Programming\Project\output_A.rtf";

proc sgrender data=Mov_ave2 template=cool_project; 
run;
/* close ods rtf file */
ods rtf close; 

%mend finance;

%finance(symbol=AMZN, stock_market=NASDAQ, start_date=12MAY17, end_date=11DEC17);

%finance(symbol=AMZN, stock_market=NASDAQ, start_date=12JUN17, end_date=11DEC17);

%finance(symbol=AMZN, stock_market=NASDAQ, start_date=12JUN17, end_date=11DEC17);

%finance(symbol=CAT, stock_market=NYSE, start_date=12MAY17, end_date=10DEC17);

%finance(symbol=CAT, sm=NYSE, days=90);


/* Google's time series plot replicated in SAS  */ 

title "SAS version of Google Financa's Time Series Plot"; /*put following title */
proc sgplot data=mov_ave2;
	/* create a band between two extreme values from above */
	band x=date upper=close lower=800 
		/fillattrs=(color=cx87CEEB) legendlabel='Amazon' name='bb1';
	/*yaxis grid values=(0 to 1500 by 20) valueshint */
	series x=date y=close / lineattrs=(thickness=2 color=cxFF6347) legendlabel="Daily Price" name='Close';
	series x=date y=MA / name='MovAve' legendlabel="MA(7)" lineattrs=(thickness=2 color=cxFF69B4); 
	series x=date y=LMA / name='Long-MA' legendlabel="Long-MA(30)"lineattrs=(thickness=2 color=cx008B8B);
	xaxis min='12OCT17'd max='11DEC17'd;
	yaxis values=(0 to 800 by 10);
	yaxis max=600; 
	yaxis label='Daily Closing Price (USD)';  /*label y-axis */
	xaxis label='Days (unit in day)';           /* label x-axis */
	keylegend 'Close' 'MovAve' 'bb1' 'Long-MA'     /* order the legend accor. to this*/
		/ location=inside across=1;
run;
