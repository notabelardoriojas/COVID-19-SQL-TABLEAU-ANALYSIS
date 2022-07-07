SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY','')); #sql workbench thing
USE PortfolioProject;

#Death likeilhood 
DROP VIEW if exists deathlikelihood;
CREATE VIEW deathlikelihood as #creaitng views for tableau
SELECT 
	location, 
    date, 
    total_cases, 
    total_deaths, 
    (total_deaths/total_cases)*100 as death_percentage 
FROM 
	covid_data 
 
ORDER BY 
	1,2;

#Total cases vs Population for countries
DROP VIEW if exists popvscases;
CREATE VIEW popvscases as
SELECT 
    location,
    date,
    continent,
    total_cases,
    population,
    (total_cases / population) * 100 AS case_percentage
FROM
    covid_data
WHERE
	length(continent) > 1
ORDER BY 1 , 2;

#Countries with highest infection rate compared to other countries
DROP VIEW if exists infectionrate_country;
CREATE VIEW infectionrate_country as
SELECT 
    location,
    MAX(total_cases) as highest_cases,
    population,
    (MAX(total_cases) / population) AS HighestInfectionRate
FROM
    covid_data
GROUP BY
	Location, population
ORDER BY HighestInfectionRate desc;
#for continents (used for drilling down in tableau)
DROP VIEW if exists infectionrate_continents;
CREATE VIEW infectiionrate_continents as
SELECT 
    continent,
    MAX(total_cases) as highest_cases,
    MAX(total_cases / population) * 100 AS HighestInfectionRate
FROM
    covid_data
WHERE
	length(continent) > 1 
GROUP BY
	continent
ORDER BY HighestInfectionRate desc;

#Countries with highest death count per population
DROP VIEW if exists deathcount_countries;
CREATE VIEW deathcount_countries as
SELECT 
    location,
    iso_code,
    MAX(CAST(total_deaths AS UNSIGNED)) as HighestDeathCount #have to cast here, data imported weird
FROM
    covid_data
WHERE
	length(iso_code) = 3 #gets rid of non countries
GROUP BY
	Location, iso_code
ORDER BY HighestDeathCount desc;

#DROP VIEW if exists deathcount_vs_vaccines;
SELECT
	location,
    date,
    iso_code,
    cast(people_fully_vaccinated as unsigned) as vac_count,
    cast(total_deaths as unsigned) as death_count
from 
	covid_data
where 
	length(continent) > 1;

#Contients with highest death count per population
DROP VIEW if exists deathcount_continents;
CREATE VIEW deathcount_continents as
SELECT 
    continent,
    MAX(CAST(total_deaths AS UNSIGNED)) as HighestDeathCount #have to cast here, data imported weird
FROM
    covid_data
WHERE length(continent) > 1 #empty continent rows have empty string, not null
GROUP BY
	continent
ORDER BY HighestDeathCount desc;

#Global Numbers
DROP VIEW if exists globalcases;
CREATE VIEW globalcases as
SELECT
	date,
    SUM(new_cases) as GlobalTotalCases, #will give us the total cases
    SUM(cast(new_deaths as UNSIGNED)) as GlobalTotalDeaths
FROM
	covid_data
WHERE
	length(continent) > 1
GROUP BY
	date
ORDER BY 1,2;

DROP VIEW if exists maxglobalcases;
CREATE VIEW maxglobalcases as
SELECT
    SUM(new_cases) as GlobalTotalCases, #will give us the total cases
    SUM(cast(new_deaths as UNSIGNED)) as GlobalTotalDeaths
FROM
	covid_data
WHERE
	length(continent) > 1
ORDER BY 1,2;


#Total population vs fully_vaccinated

DROP view if exists popvsvac;
Create View popvsvac as 
SELECT 
	location, 
    date, 
    cast(population as UNSIGNED) as populationp, 
    cast(people_fully_vaccinated as UNSIGNED) as fully_vaxxed,
    MAX((cast(people_fully_vaccinated as UNSIGNED)/population)) as fully_vaccinated_percentage
FROM
	covid_data
WHERE
	length(continent) > 1 and cast(people_fully_vaccinated as UNSIGNED) > 0
GROUP BY
	location, date, populationp;
