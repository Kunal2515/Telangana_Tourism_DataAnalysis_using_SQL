
/*--------------------------------------------------------*****************---------------------------------------------------------------*/
/*                                                Telangana tourism data analysis using SQL                                               */

use tourism_dept;
## Show all content of the table.
SELECT * FROM tourism_dept.`domestic visitors_csv`;
SELECT * FROM tourism_dept.`foreign visitors_csv`;
SELECT * FROM tourism_dept.population_year_wise;


/*--------------------------------------------------------*****************---------------------------------------------------------------*/

## Q1. List down the top 10 districts that have the highest number of domestic visitors overall (2016-2019)?
## (Insight: Get an overview of districts that are doing well)
SELECT DISTINCT district, SUM(visitors) AS total_visitors
FROM tourism_dept.`domestic visitors_csv`
GROUP BY district
ORDER BY total_visitors DESC
LIMIT 10;

## Q2. List down the top 10 districts that have the highest number of foreign visitors overall (2016-2019)?
## (Insight: Get an overview of districts that are doing well)
SELECT DISTINCT district, SUM(visitors) AS total_visitors
FROM tourism_dept.`foreign visitors_csv`
GROUP BY district
ORDER BY total_visitors DESC
LIMIT 10;

/*--------------------------------------------------------*****************---------------------------------------------------------------*/

## Q3. What are the peak and low season months for Hyderabad based on domestic visitor data from 2016 to 2019 for Hyderabad district?
/*(Insight: Government can plan well for the peak seasons and boost low seasons
			  by introducing new events)*/
## For peak value
SELECT DISTINCT month, SUM(visitors) AS total_visitors 
FROM tourism_dept.`domestic visitors_csv` 
WHERE district='Hyderabad'
GROUP BY month
ORDER BY total_visitors DESC;

## For low season
SELECT DISTINCT month, SUM(visitors) AS total_visitors 
FROM tourism_dept.`domestic visitors_csv` 
WHERE district='Hyderabad'
GROUP BY month
ORDER BY total_visitors ASC;

/*--------------------------------------------------------*****************---------------------------------------------------------------*/

## Q4. What are the peak and low season months for Hyderabad based on foreign visitor data from 2016 to 2019 for Hyderabad district?
/*(Insight: Government can plan well for the peak seasons and boost low seasons
			  by introducing new events)*/
## For peak value
SELECT DISTINCT month, SUM(visitors) AS total_visitors 
FROM tourism_dept.`foreign visitors_csv` 
WHERE district='Hyderabad'
GROUP BY month
ORDER BY total_visitors DESC;

## For low season
SELECT DISTINCT month, SUM(visitors) AS total_visitors 
FROM tourism_dept.`foreign visitors_csv` 
WHERE district='Hyderabad'
GROUP BY month
ORDER BY total_visitors ASC;

/*--------------------------------------------------------*****************---------------------------------------------------------------*/

/*Q5. List down the top 3 districts based on compound annual growth rate (CAGR) of visitors between (2016-2019)?
	   (Insight: Districts that are growing)	
       (CAGR stands for Compound Annual Growth Rate. It is a measure used to calculate
	   the annualized growth rate of an investment over a specific period of time.
	   CAGR = [(Ending Value / Beginning Value) ^ (1 / Number of Years) - 1]
	   Here, CAGR from 2016-2019 (Number of Years = 3 years)) For both domestic and forign*/
       
## For Domestics
WITH cte AS (
SELECT  district,
	sum(case WHEN year=2016 THEN visitors ELSE 0 END) AS Initial_Value,
        sum(case WHEN year=2019 THEN visitors ELSE 0 END) AS Final_Value
FROM tourism_dept.`domestic visitors_csv`
GROUP BY district
)
SELECT *, round((power(Final_Value/Initial_Value,1/3)-1)*100,2) AS CAGR
FROM cte 
ORDER BY CAGR DESC 
LIMIT 5;

-- [Query-2]: For Foreign
WITH cte AS (
SELECT district,
	sum(case WHEN year=2016 THEN visitors ELSE 0 END) AS Initial_Value,
        sum(case WHEN year=2019 THEN visitors ELSE 0 END) AS Final_Value
FROM tourism_dept.`foreign visitors_csv`
GROUP BY district
)
SELECT *, round((power(Final_Value/Initial_Value,1/3)-1)*100,2) AS CAGR
FROM cte 
ORDER BY CAGR DESC 
LIMIT 5;

/*--------------------------------------------------------*****************---------------------------------------------------------------*/

/* 
Q6. List down the bottom 3 districts based on compounded annual growth rate(CAGR) of visitors between (2016-2019)?
(Insights: Districts that are declining)
*/
-- [Query-1] For Domestic
WITH cte AS (
SELECT district,
	sum(case WHEN year=2016 THEN visitors ELSE 0 END) AS Initial_Value,
        sum(case WHEN year=2019 THEN visitors ELSE 0 END) AS Final_Value
FROM tourism_dept.`domestic visitors_csv`
GROUP BY district
)
SELECT *, round((power(Final_Value/Initial_Value,1/3)-1)*100,2) as CAGR
FROM cte 
-- order by CAGR asc limit 3;                                 # output vary here because of Initial_Value has some zero values
WHERE Initial_Value != 0                                      # or you can say that 'where CAGR is not null' by creating new cte
ORDER BY CAGR ASC 
LIMIT 3;

 -- [QUERY-2] FOR FOREIGN
WITH cte AS (
SELECT district,
	sum(case WHEN year=2016 then visitors ELSE 0 END) AS Initial_Value,
        sum(case WHEN year=2019 then visitors ELSE 0 END) AS Final_Value
FROM tourism_dept.`foreign visitors_csv`
GROUP BY district
)
SELECT *, round((power(Final_Value/Initial_Value,1/3)-1)*100,2) as CAGR
FROM cte 
-- order by CAGR asc limit 3;                                 # output vary here because of Initial_Value has some zero values
WHERE Initial_Value != 0                                      # or you can say that 'where CAGR is not null' by creating new cte
ORDER BY CAGR ASC 
LIMIT 3;

/*--------------------------------------------------------*****************---------------------------------------------------------------*/

/* Q7. Show the top & bottom 3 districts with high domestic to foreign tourist ratio?
   (Insight: Government can learn from top districts and replicate the same to 
    bottom districts which can improve the foreign visitors will bring more revenue)                */
-- [Query]

WITH cte AS (
SELECT d.district, 
	sum(d.visitors) AS d_visitors, 
	sum(f.visitors) AS f_visitors
FROM tourism_dept.`domestic visitors_csv` d
JOIN tourism_dept.`foreign visitors_csv` f 
-- on d.district=f.district                                                    #this gives 71568 rows which is inaccurate 
-- on d.district=f.district and d.year=f.year                                  #this gives 18000 rows which is inaccurate
on d.district=f.district and d.year=f.year and d.month=f.month                 #this gives 1500 rows which is accurate
GROUP BY district
),
cte2 AS (
SELECT *, round(d_visitors/f_visitors,0) as ratio
FROM cte 
WHERE f_visitors != 0                                                        # with zero, result is infinity and ratio is null
ORDER BY ratio 
),
cte3 AS (
SELECT *, rank() over(order by ratio) as top,                                
          rank() over(order by ratio desc) as bottom
FROM cte2
)
SELECT district, d_visitors, f_visitors, ratio, top
FROM cte3
WHERE top<4 or bottom<4; 


/*--------------------------------------------------------*****************---------------------------------------------------------------*/
/*
+--------------------------------------------------------------------------------------------------------------------------+
		     # 𝐒𝐞𝐜𝐨𝐧𝐝𝐚𝐫𝐲 𝐑𝐞𝐬𝐞𝐚𝐫𝐜𝐡 𝐐𝐮𝐞𝐬𝐭𝐢𝐨𝐧𝐬: (𝐍𝐞𝐞𝐝 𝐭𝐨 𝐝𝐨 𝐫𝐞𝐬𝐞𝐚𝐫𝐜𝐡 𝐚𝐧𝐝 𝐠𝐞𝐭 𝐚𝐝𝐝𝐢𝐭𝐢𝐨𝐧𝐚𝐥 𝐝𝐚𝐭𝐚)
+--------------------------------------------------------------------------------------------------------------------------+
*/

/*Q8. List the top and bottom 5 districts based on 'population to tourist footfall ratio'* 
		 ratio in 2019?(*ratio: Total Visitors/Total Residents Population in the given year)
 @ RESEARCH:-
 # Additional data is taken from wikipedia: https://en.wikipedia.org/wiki/List_of_districts_of_Telangana
 # Now, to obtain 2019 and 2025 residents data I simply found CAGR with the current year i.e, 2023
 # Population data 2023 which is '38090000' is taken from this link:https://www.findeasy.in/population-of-telangana/ 
 # Population_2011(IV) = 34998289, Population_2023(FV) = 38090000, Growth => FV-IV = 38090000-34998289 = 3091711
   Growth Rate=> (Growth/IV)*100 = (3091711/34998289)*100 = 9% 
   Yearly Growth Rate => (0.09/11)*100 = 0.8%  [ time interval between 2023 and 2011 = 11 years ]
   Yearly Growth => Population_2011 * Yearly Growth Rate  = 34998289*0.008 = 279986
   Let's assume it is growing by 0.8% 
   Population (given_year) => Population_2011 + (yearly growth)* (no. of years gap)
   So, Population_2019 => Population_2011 + (Population_2011 * 0.008) * 8 = 37238179
   Similarly, Population_2025 => Population_2011 + (Population_2011 * 0.008) * 14 = 38918093 
   Using these calculations, a table is prepared district wise, table_name: [population_year_wise.csv] */
   
-- [Query-1]: Output
WITH cte AS (
SELECT D.district, sum(D.visitors) AS d_visitors,
		   sum(F.visitors) AS f_visitors,
		   sum(D.visitors)+sum(F.visitors) AS t_visitors
FROM tourism_dept.`domestic visitors_csv` D
JOIN tourism_dept.`foreign visitors_csv` F
on F.district=D.district and F.month=D.month and F.year=D.year                                    #pay attention to this
WHERE D.year=2019
GROUP BY district
),
cte1 AS (
SELECT C.*, population_2019 as t_residents, 
	    round(t_visitors/population_2019,2) as footfall_ratio
FROM cte C
JOIN population_year_wise Y
on Y.district=C.district
WHERE t_visitors != 0
)
SELECT district, footfall_ratio, top
FROM ( SELECT *, row_number() over(ORDER BY footfall_ratio DESC) AS top,
		 row_number() over(ORDER BY footfall_ratio ASC) AS bottom
	FROM cte1) AS subquery
WHERE top<6 OR bottom<6
ORDER BY footfall_ratio DESC;

## Some Additional Queies for this question
-- [Query-2]: For Domestic
WITH cte AS (
SELECT 	P.district, 
	year, 
	sum(D.visitors) as t_visitors , 
	population_2019 as t_population
FROM population_year_wise P
JOIN tourism_dept.`domestic visitors_csv` D
on P.district=D.district
WHERE year=2019
GROUP BY P.district, population_2019, year  
),
cte2 AS (
SELECT *, t_visitors/t_population as footfall_ratio,
	  row_number() over(ORDER BY t_visitors/t_population DESC) AS top,
	  row_number() over(ORDER BY t_visitors/t_population ASC ) AS bottom
FROM cte
WHERE t_visitors !=0 )
SELECT district, footfall_ratio, top
FROM cte2
WHERE top<6 or bottom<6
ORDER BY footfall_ratio DESC;

-- [Query-3]: For Foreign
WITH cte AS (
SELECT  P.district, year, 
	sum(F.visitors) AS t_visitors ,
        population_2019 AS t_population
FROM population_year_wise P
JOIN tourism_dept.`foreign visitors_csv` F
ON P.district=F.district
WHERE year=2019
GROUP BY P.district, population_2019, year                       # pay attention to this, how many column you're going to group by 
),
cte2 AS (
SELECT *,  t_visitors/t_population as footfall_ratio,
	   row_number() over(order by t_visitors/t_population DESC) AS top,
	   row_number() over(order by t_visitors/t_population ASC ) AS bottom
FROM cte
WHERE t_visitors !=0 )
SELECT district, footfall_ratio, top
FROM cte2
WHERE top<6 or bottom<6
ORDER BY footfall_ratio DESC;

/*--------------------------------------------------------*****************---------------------------------------------------------------*/

/* Q9. What will be the projected number of domestic and foreign tourists in Hyderabad in 2025 based on the Growth rate from previous years?
   (Insights: Better estimate of incoming tourists count so that government can plan the infrastructure better)
   # Procedure for finding projected value:
	step:1- first find AGR = [(FV/IV)^(1/n)-1] {here FV=13802362, IV=23394705, n= 2019-2016}
	AGR => [(13802362/23394705)^(1/3)-1] = -0.1612
	step:2- projected value => [current population*(1+(AGR/100))^n] = [13802362*(1+(-0.1612))^6]=4848743			
    {n=> 2019 to 2025}*/

-- [Query:-1] Domestic Projected Value for 2025
WITH cte AS (
SELECT district, sum(case WHEN year=2016 THEN visitors ELSE 0 END) AS Initial_Value,
		 sum(case WHEN year=2019 THEN visitors ELSE 0 END) AS Final_Value
FROM tourism_dept.`domestic visitors_csv`
WHERE district="hyderabad" 
)
SELECT *, round(Final_Value*power((1+AGR),6),0) AS projected_dom_2025
FROM (
	SELECT *, round(power(Final_Value/Initial_Value, (1/3))-1,2) AS AGR                                  # AGR=-0.16
	FROM cte
    ) AS subquery;
    
-- [Query:-2] Foreign Projected value for 2025
WITH cte AS (
SELECT district, sum(case WHEN year=2016 THEN visitors ELSE 0 END) AS Initial_Value,
		 sum(case WHEN year=2019 THEN visitors ELSE 0 END) AS Final_Value
FROM tourism_dept.`foreign visitors_csv`
WHERE district="hyderabad" 
)
SELECT *, round(final_value*power((1+AGR),6),0) AS projected_foreign_2025
from (
	SELECT *, round(power(Final_Value/Initial_Value, (1/3))-1,2) AS AGR                                   # AGR= 0.25 
	FROM cte
    ) AS subquery;

/*--------------------------------------------------------*****************---------------------------------------------------------------*/    
    
/* Q10. Estimated the projected revenue for Hyderabad in 2025 based on average spend per tourist (approximate data)
		Tourist  |  Average Revenue 
		Foreign	 |  Rs. 5600.00
		Domestic |  Rs. 1200.00  */

-- [Query-1] For Domestic Estimation
WITH cte AS (
SELECT district, sum(case WHEN year=2016 THEN visitors ELSE 0 END) AS Initial_Value,
	         sum(case WHEN year=2019 THEN visitors ELSE 0 END) AS Final_Value
FROM tourism_dept.`domestic visitors_csv`
WHERE district="hyderabad" 
)
SELECT *, round(Final_Value*power((1+AGR),6),0)  AS  projected_dom_2025,
          round(Final_Value*power((1+AGR),6),0)*1200  AS  Projected_dom_revenue
FROM (
	SELECT *, round(power(Final_Value/Initial_Value, (1/3))-1,2) AS AGR                                # AGR=-0.16
	FROM cte
    ) AS subquery;
    
-- [Query-2] For Foreign Estimation
WITH cte AS (
SELECT district, sum(case WHEN year=2016 THEN visitors ELSE 0 END) AS Initial_Value,
		 sum(case WHEN year=2019 THEN visitors ELSE 0 END) AS Final_Value
FROM tourism_dept.`foreign visitors_csv`
WHERE district="hyderabad" 
)
SELECT *, round(Final_Value*power((1+AGR),6),0) AS projected_dom_2025,
	  round(Final_Value*power((1+AGR),6),0)*5600 AS Projected_foreign_revenue
FROM (
	SELECT *, round(power(Final_Value/Initial_Value, (1/3))-1,2) AS AGR                                    # AGR=0.25
	FROM cte
    ) AS subquery;