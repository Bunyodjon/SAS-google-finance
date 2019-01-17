# SAS-google-finance

This SAS program creates a SAS macro that takes stock ticker, stock market ticker, start date and end date. Based on input variables, 
the macro downloads a historical stock data and prints out plots and financial indicator in a report form. The program consists of one 
large macro that computes everything, and it could be called as many times as possible.
Warming: this macro might not work if the google finance changes its rules about retrieving historical stock prices.  
Date: October 1, 2017
Last Updated: December 13, 2017 
Author: Bunyod Tusmatov 

### Input Variables:   
Macros and input: %finance (symbol=, stock_market=, start_date=, end_date=) 
Output variable: 
Program file: "C:\Users\Admin\Documents\Fall 2017 Courses\Statistical Programming\Homeworks\h5_A.sas"
Data source: Data is optained from the google finance
Output file: two plots with several indicators like Moving Average and Bollinger Bands
