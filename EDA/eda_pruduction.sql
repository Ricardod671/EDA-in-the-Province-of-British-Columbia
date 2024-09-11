-- Query to determine the total number of distinct wells in the production data.
SELECT COUNT(DISTINCT id_well) AS num_wells
FROM production;

/*
This query identifies the number of distinct wells 
that have contributed production data. 
It serves as a foundational metric to understand 
the scale of well activity within the dataset.
*/

-- Calculate the total production volumes for gas, oil, water, and condensate.
SELECT 
	SUM(gas_prod_vol) AS gas_total_production,
	SUM(oil_prod_vol) AS oil_total_production,
	SUM(water_prod_vol) AS water_total_production,
	SUM(cond_prod_vol) AS cond_total_production
FROM production;

/*
Calculate the total production volumes for 
gas, oil, water, and condensate.
*/

--  Determine the first and most recent production dates.
SELECT 
	MIN(production_date) AS first_day_production,
	MAX(production_date) AS current_day_production
FROM production;
/*
This query identifies the production timeline 
by providing the earliest and latest production dates,
offering insight into the period over which the data 
was collected.
*/

-- Calculate annual production and cumulative production volumes for gas, oil, water, and condensate.
SELECT 
	DATE_PART('year',production_date) AS years,
	SUM(gas_prod_vol) AS gas_total_production,
	SUM(oil_prod_vol) AS oil_total_production,
	SUM(water_prod_vol) AS water_total_production,
	SUM(cond_prod_vol) AS cond_total_production,
	SUM(SUM(gas_prod_vol)) OVER(ORDER BY DATE_PART('year', production_date)) AS acum_gas,
	SUM(SUM(oil_prod_vol)) OVER(ORDER BY DATE_PART('year', production_date)) AS acum_oil,
	SUM(SUM(water_prod_vol)) OVER(ORDER BY DATE_PART('year', production_date)) AS acum_water,
	SUM(SUM(cond_prod_vol)) OVER(ORDER BY DATE_PART('year', production_date)) AS acum_cond
FROM production
GROUP BY 1
ORDER BY 1 ASC;

/*
This query analyzes the yearly production and cumulative output
for each product type. It offers insights into 
the production trends over time and highlights 
how production levels have grown year-on-year.
*/

-- First and Last Production Date Per Well.
SELECT 
	id_well,
	MIN(production_date) AS first_day_production,
	MAX(production_date) AS last_day_production
FROM production
GROUP BY 1
ORDER BY 1 ASC;
/*
This query provides the initial and final production 
dates for each well, which is useful for 
understanding the operational lifespan of individual 
wells.
*/
-- Name of id_wells. 
WITH id_well_production AS (
    SELECT DISTINCT id_well 
    FROM production
)
SELECT 
	p.id_well,
	w.well_name
FROM id_well_production AS p
LEFT JOIN wells AS w ON p.id_well = w.id_well;

-- Checking that not exist null.
WITH id_well_production AS (
    SELECT DISTINCT id_well 
    FROM production
)
SELECT 
    COUNT(*) AS null_count
FROM id_well_production AS p
LEFT JOIN wells AS w ON p.id_well = w.id_well
WHERE w.well_name IS NULL;

-- Checking that when the well doesn't produce, we don't have data.
SELECT *
FROM production
WHERE id_well = 29;

-- Oil production for one well without information whe the well doesn't produce.
SELECT 
	p.id_well,
	w.well_name,
	p.production_date,
	p.oil_prod_vol,
	SUM(p.oil_prod_vol) OVER(ORDER BY p.production_date)
FROM production AS p
INNER JOIN wells AS w ON p.id_well=w.id_well
WHERE p.id_well = 29;

-- Gas,oil,water,cond produccion with all data including the dates when the well doesn't produce.
-- This is for the well_id=29, but is posible convert this query to a view to make all easy.
SELECT 
	c.dates,
	t.well AS well,
	ROUND(COALESCE(t.gas_prod,0),2) AS gas_production,
	SUM(t.gas_prod) OVER (ORDER BY c.dates) AS gas_acumulation,
	ROUND(COALESCE(t.oil_prod,0),2) AS oil_production,
	SUM(t.oil_prod) OVER (ORDER BY c.dates) AS oil_acumulation,
	ROUND(COALESCE(t.water_prod,0),2) AS water_production,
	SUM(t.water_prod) OVER (ORDER BY c.dates) AS water_acumulation,
	ROUND(COALESCE(t.cond_prod,0),2) AS cond_production,
	SUM(t.cond_prod) OVER (ORDER BY c.dates) AS cond_acumulation
FROM datetable AS C
LEFT JOIN (
	SELECT
		A.production_date AS dates,
		B.well_name AS well,
		A.gas_prod_vol AS gas_prod,
		A.oil_prod_vol AS oil_prod,
		A.water_prod_vol AS water_prod,
		A.cond_prod_vol AS cond_prod
	FROM production AS A
	INNER JOIN wells AS B ON B.id_well=A.id_well
	WHERE A.id_well = 29
	AND A.production_date >= (SELECT MIN(production_date) FROM production WHERE id_well=29)
	AND A.production_date <= (SELECT MAX(production_date) FROM production WHERE id_well=29)
) AS t ON c.dates=t.dates
WHERE c.dates > (SELECT MIN(production_date) FROM production WHERE id_well=29)
AND c.dates < (SELECT MAX(production_date) FROM production WHERE id_well=29)
ORDER BY c.dates ASC;


-- Acumulation of oil per well.
SELECT 
	w.well_name AS well,
	SUM(p.oil_prod_vol) AS total_oil_production
FROM production AS p
INNER JOIN wells AS w ON p.id_well=w.id_well
GROUP BY 1
ORDER BY 2 DESC;

-- Acumulation of gas per well.
SELECT 
	w.well_name AS well,
	SUM(p.gas_prod_vol) AS total_gas_production
FROM production AS p
INNER JOIN wells AS w ON p.id_well=w.id_well
GROUP BY 1
ORDER BY 2 DESC;

-- Acumulation of water per well.
SELECT 
	w.well_name AS well,
	SUM(p.water_prod_vol) AS total_water_production
FROM production AS p
INNER JOIN wells AS w ON p.id_well=w.id_well
GROUP BY 1
ORDER BY 2 DESC;


-- Acumulation of condensate per well.
SELECT 
	w.well_name AS well,
	SUM(p.cond_prod_vol) AS total_cond_production
FROM production AS p
INNER JOIN wells AS w ON p.id_well=w.id_well
GROUP BY 1
ORDER BY 2 DESC;

-- Peak oil production per well.
SELECT 
	w.well_name AS well,
	MAX(p.oil_prod_vol) AS max_oil_production
FROM production AS p
INNER JOIN wells AS w ON p.id_well=w.id_well
GROUP BY 1
ORDER BY 2 DESC;

-- Peak gas production per well.
SELECT 
	w.well_name AS well,
	MAX(p.gas_prod_vol) AS max_gas_production
FROM production AS p
INNER JOIN wells AS w ON p.id_well=w.id_well
GROUP BY 1
ORDER BY 2 DESC;

-- Peak water production per well.
SELECT 
	w.well_name AS well,
	MAX(p.water_prod_vol) AS max_water_production
FROM production AS p
INNER JOIN wells AS w ON p.id_well=w.id_well
GROUP BY 1
ORDER BY 2 DESC;

-- Peak cond production per well.
SELECT 
	w.well_name AS well,
	MAX(p.cond_prod_vol) AS max_cond_production
FROM production AS p
INNER JOIN wells AS w ON p.id_well=w.id_well
GROUP BY 1
ORDER BY 2 DESC;

-- Average oil production per well.
SELECT 
	w.well_name AS well,
	ROUND(AVG(p.oil_prod_vol),2) AS avg_oil_production
FROM production AS p
INNER JOIN wells AS w ON p.id_well=w.id_well
GROUP BY 1
ORDER BY 2 DESC;

-- Average gas production per well.
SELECT 
	w.well_name AS well,
	ROUND(AVG(p.gas_prod_vol),2) AS avg_gas_production
FROM production AS p
INNER JOIN wells AS w ON p.id_well=w.id_well
GROUP BY 1
ORDER BY 2 DESC;

-- Average water production per well.
SELECT 
	w.well_name AS well,
	ROUND(AVG(p.water_prod_vol),2) AS avg_water_production
FROM production AS p
INNER JOIN wells AS w ON p.id_well=w.id_well
GROUP BY 1
ORDER BY 2 DESC;

-- Average cond production per well.
SELECT 
	w.well_name AS well,
	ROUND(AVG(p.cond_prod_vol),2) AS avg_cond_production
FROM production AS p
INNER JOIN wells AS w ON p.id_well=w.id_well
GROUP BY 1
ORDER BY 2 DESC;

-- Average oil production of all wells of briths columbia.
SELECT ROUND(AVG(oil_prod_vol),2) AS avg_oil_production
FROM production;

-- Average gas production of all wells of briths columbia.
SELECT ROUND(AVG(gas_prod_vol),2) AS avg_gas_production
FROM production;

-- Average water production of all wells of briths columbia.
SELECT ROUND(AVG(water_prod_vol),2) AS avg_water_production
FROM production;

-- Average cond production of all wells of briths columbia.
SELECT ROUND(AVG(cond_prod_vol),2) AS avg_cond_production
FROM production;

-- Construction of retencion analysis.
-- Table of wells with begin and last date. 
SELECT 
	w.well_name AS well,
	MIN(p.production_date) AS begin_dates,
	MAX(p.production_date) AS current_dates
FROM production AS p
LEFT JOIN wells AS w ON p.id_well=w.id_well
GROUP BY 1;


-- Creating a log for every month that the well was on production.
SELECT
	A.well,
	A.star_prod_date,
	A.end_prod_date,
	D.dates,
	DATE_PART('year',D.dates) - DATE_PART('year',A.star_prod_date) AS periodo
FROM(
	SELECT 
		w.well_name AS well,
		MIN(p.production_date) AS star_prod_date,
		MAX(p.production_date) AS end_prod_date
	FROM production AS p
	LEFT JOIN wells AS w ON p.id_well=w.id_well
	GROUP BY 1) AS A
LEFT JOIN datetable AS D ON D.dates BETWEEN A.star_prod_date AND A.end_prod_date

/*
Cohort by year of wells on production in British Columbia
the first row represent the number of wells that were drill and put on 
production at any time, the second row mean the number of wells that 
keep produccion for one year.
*/ 

SELECT
	DATE_PART('year',D.dates) - DATE_PART('year',A.star_prod_date) AS periodo,
	COUNT(DISTINCT A.well)
FROM(
	SELECT 
		w.well_name AS well,
		MIN(p.production_date) AS star_prod_date,
		MAX(p.production_date) AS end_prod_date
	FROM production AS p
	LEFT JOIN wells AS w ON p.id_well=w.id_well
	GROUP BY 1) AS A
LEFT JOIN datetable AS D ON D.dates BETWEEN A.star_prod_date AND A.end_prod_date
GROUP BY 1


-- Calculation the percentage.
SELECT
	periodo,
	survive_cohort,
	FIRST_VALUE(survive_cohort) OVER(ORDER BY periodo) AS cohort_size,
	ROUND(CAST(survive_cohort AS NUMERIC) / CAST(FIRST_VALUE(survive_cohort) OVER (ORDER BY periodo) AS NUMERIC), 4) AS pcretein	
FROM(
	SELECT
		DATE_PART('year',D.dates) - DATE_PART('year',A.star_prod_date) AS periodo,
		COUNT(DISTINCT A.well) AS survive_cohort
	FROM(
		SELECT 
			w.well_name AS well,
			MIN(p.production_date) AS star_prod_date,
			MAX(p.production_date) AS end_prod_date
		FROM production AS p
		LEFT JOIN wells AS w ON p.id_well=w.id_well
		GROUP BY 1) AS A
	LEFT JOIN datetable AS D ON D.dates BETWEEN A.star_prod_date AND A.end_prod_date
	GROUP BY 1) AS aa;
	

-- Checking the name of the old well on production.
-- name: WHITECAPET AL BOUNDARY LAKE 06-06-086-13
SELECT *	
FROM(	
	SELECT
		A.well,
		A.star_prod_date,
		A.end_prod_date,
		D.dates,
		DATE_PART('year',D.dates) - DATE_PART('year',A.star_prod_date) AS periodo
	FROM(
		SELECT 
			w.well_name AS well,
			MIN(p.production_date) AS star_prod_date,
			MAX(p.production_date) AS end_prod_date
		FROM production AS p
		LEFT JOIN wells AS w ON p.id_well=w.id_well
		GROUP BY 1) AS A
	LEFT JOIN datetable AS D ON D.dates BETWEEN A.star_prod_date AND A.end_prod_date)AS C
WHERE C.periodo = 69;


-- Number of wells put in production per year.
SELECT
	DATE_PART('year',A.begin_dates)	AS years,
	COUNT(DISTINCT A.well) AS N_well
FROM(
	SELECT 
		w.well_name AS well,
		MIN(p.production_date) AS begin_dates,
		MAX(p.production_date) AS current_dates
	FROM production AS p
	LEFT JOIN wells AS w ON p.id_well=w.id_well
	GROUP BY 1) AS A
GROUP BY 1
ORDER BY 1

-- Cheking the total number of wells on production 
SELECT 
	SUM(K.N_well) AS total_number_well_production
FROM(
	SELECT
		DATE_PART('year',A.begin_dates)	AS years,
		COUNT(DISTINCT A.well) AS N_well
	FROM(
		SELECT 
			w.well_name AS well,
			MIN(p.production_date) AS begin_dates,
			MAX(p.production_date) AS current_dates
		FROM production AS p
		LEFT JOIN wells AS w ON p.id_well=w.id_well
		GROUP BY 1) AS A
	GROUP BY 1
	ORDER BY 1) AS K


-- Core table
SELECT 
	id_well AS well,
	MIN(production_date) AS begin_dates
FROM production 
GROUP BY 1;

-- Cohort by year analisys with out percentage
SELECT 
	EXTRACT(YEAR FROM begin_dates) AS first_year,
	DATE_PART('year',b.production_date) - DATE_PART('year',a.begin_dates) AS periodo,
	COUNT(DISTINCT a.id_well) AS pozos_producciendo
FROM(
	SELECT 
		id_well,
		MIN(production_date) AS begin_dates
	FROM production 
	GROUP BY 1) AS a
JOIN production AS b ON a.id_well=b.id_well
GROUP BY 1,2;

-- Cohort by year analisys with out percentage.
SELECT 
	first_year,
	periodo,
	production_wells,
	FIRST_VALUE(production_wells) OVER(PARTITION BY first_year ORDER BY periodo) AS size_cohort,
	ROUND(CAST(production_wells AS NUMERIC) /CAST(FIRST_VALUE(production_wells) OVER (PARTITION BY first_year ORDER BY periodo) AS NUMERIC),2) AS retein_pct
FROM(
	SELECT 
		EXTRACT(YEAR FROM begin_dates) AS first_year,
		DATE_PART('year',b.production_date) - DATE_PART('year',a.begin_dates) AS periodo,
		COUNT(DISTINCT a.id_well) AS production_wells
	FROM(
		SELECT 
			id_well,
			MIN(production_date) AS begin_dates
		FROM production 
		GROUP BY 1) AS a
	JOIN production AS b ON a.id_well=b.id_well
	GROUP BY 1,2) AS aa;

-- Cohort analisys by decade.
SELECT 
	id_well AS well,
	MIN(production_date) AS begin_dates,
	(EXTRACT(YEAR FROM MIN(production_date)) - EXTRACT(YEAR FROM MIN(production_date)) % 10)::int AS decade
FROM production 
GROUP BY 1

-- Cohort analisys per decade without percentage.
SELECT 
	a.decade,
	DATE_PART('year',b.production_date) - DATE_PART('year',a.begin_dates) AS periodo,
	COUNT(DISTINCT a.id_well) AS pozos_producciendo
FROM(
	SELECT 
		id_well,
		MIN(production_date) AS begin_dates,
		(EXTRACT(YEAR FROM MIN(production_date)) - EXTRACT(YEAR FROM MIN(production_date)) % 10)::int AS decade
	FROM production 
	GROUP BY 1) AS a
JOIN production AS b ON a.id_well=b.id_well
GROUP BY 1,2;

SELECT 
	decade,
	periodo,
	production_wells,
	FIRST_VALUE(production_wells) OVER(PARTITION BY decade ORDER BY periodo) AS size_cohort,
	ROUND(CAST(production_wells AS NUMERIC) /CAST(FIRST_VALUE(production_wells) OVER (PARTITION BY decade ORDER BY periodo) AS NUMERIC),2) AS retein_pct
FROM(
	SELECT 
		a.decade,
		DATE_PART('year',b.production_date) - DATE_PART('year',a.begin_dates) AS periodo,
		COUNT(DISTINCT a.id_well) AS production_wells 
	FROM(
		SELECT 
			id_well,
			MIN(production_date) AS begin_dates,
			(EXTRACT(YEAR FROM MIN(production_date)) - EXTRACT(YEAR FROM MIN(production_date)) % 10)::int AS decade
		FROM production 
		GROUP BY 1) AS a
	JOIN production AS b ON a.id_well=b.id_well
	GROUP BY 1,2) AS aa;



-- Total production per decade.
WITH id_well_decade AS (
	SELECT 
		id_well, 
		MIN(production_date) AS begin_dates,
		(EXTRACT(YEAR FROM MIN(production_date)) - EXTRACT(YEAR FROM MIN(production_date)) % 10)::int AS decade
	FROM production 
	GROUP BY 1
)
SELECT
	t.decade,
	SUM(t.gas_prod_vol) AS gas_total_production_decade,
	SUM(t.oil_prod_vol)AS oil_total_production_decade,
	SUM(t.water_prod_vol) AS water_total_production_decade,
	SUM(t.cond_prod_vol) AS cond_total_production_decade
FROM(
	SELECT *
	FROM production AS A
	INNER JOIN id_well_decade AS B ON A.id_well=B.id_well) AS t
GROUP BY 1
ORDER BY 1;

-- Adding periods to a production table.
SELECT 
	*,
	ROW_NUMBER() OVER(PARTITION BY id_well ORDER BY production_date) AS periods
FROM production

-- Comparation per decade of production for first 12 months.
WITH id_well_decade AS (
	SELECT 
		id_well, 
		MIN(production_date) AS begin_dates,
		(EXTRACT(YEAR FROM MIN(production_date)) - EXTRACT(YEAR FROM MIN(production_date)) % 10)::int AS decade
	FROM production 
	GROUP BY 1
),
production_with_period AS(
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY id_well ORDER BY production_date) AS periods
	FROM production
),
	production_with_all AS(
	SELECT *
	FROM production_with_period AS A
	INNER JOIN id_well_decade AS B ON A.id_well=B.id_well
)
SELECT 
	decade,
	periods,
	SUM(gas_prod_vol) AS gas,
	SUM(oil_prod_vol) AS oil,
	SUM(water_prod_vol) AS water,
	SUM(cond_prod_vol) AS cond	
FROM production_with_all
WHERE periods < 13
GROUP BY 1,2
ORDER BY 1,2








