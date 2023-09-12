# Summer Olympic Medals
This dataset is a list of all the medal winners in the Summer Olympics from 1976 Montreal to 2008 Beijing. 
It includes each and every medal awarded within the period.

Project includes work with **window functions** to show:
 - rank of each athlete by the number of medals they've earned using **RANK() and DENSE_RANK()** functions;
 - the previous champions country of each year's event by gender in 100m event using the **LAG()** function;
 - the current and future women's high jump gold medalists using the **LEAD()** function;
 - the average number of medals per third using the **NTILE()** function;
 - the cumulative sum of gold medals Poland earned using the **SUM() aggregate window function**;
 - the maximum medals number Poland, USA and Russia earned since 1996 using the **MAX() aggregate window function**;
 - the last 'Olympic' city using the **LAST_VALUE()** function with **ROWS frame**;
 - the maximum number of gold medals won by Eastern EU countries between the current and next year using the **MAX() aggregate window function with ROWS frame**;
 - the group-level totals of Chinese and Russian medals in the 2008 Summer Olympics per medal class using the **ROLLUP() function**.
