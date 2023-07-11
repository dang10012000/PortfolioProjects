
-- Data Exploration
Select *
From Portfolio_Project..Covid_Deaths
Order By 3,4

Select *
From Portfolio_Project..Covid_Vaccinations
Order By 3,4

--Select the data that we are going to be using
Select location, date, total_cases, total_deaths, population
From Portfolio_Project..Covid_Deaths
Order By 1,2

--changing data types
ALTER TABLE Portfolio_Project..Covid_Deaths
ALTER COLUMN total_cases float;

ALTER TABLE Portfolio_Project..Covid_Deaths
ALTER COLUMN total_deaths int;


--Looking at Total Cases vs Total Dealths
--shows likelihood of dying if you have covid in your country
SELECT location, date, total_cases, total_deaths, ROUND(total_deaths/total_cases*100,2) AS Death_Percentage
FROM Portfolio_Project..Covid_Deaths
ORDER BY 1,2

--Looking at Total Cases vs Total Dealths in the US
SELECT location, date, total_cases, total_deaths, ROUND(total_deaths/total_cases*100,2) AS Death_Percentage
FROM Portfolio_Project..Covid_Deaths
WHERE location LIKE '%states%'
ORDER BY 1,2
 

--Looking at total cases vs population
--Shows what percentage of population got Covid
SELECT location, date, total_cases, population, ROUND(total_cases/population*100,5) AS Death_Percentage
FROM Portfolio_Project..Covid_Deaths
ORDER BY 1,2

--Looking higest infection rate compared to population
SELECT location, ROUND(MAX(total_cases/population*100),5) AS Higest_Infection_RATE
FROM Portfolio_Project..Covid_Deaths
GROUP BY location

--The highest country with infection rate
SELECT TOP 1 location, ROUND(MAX(total_cases/population*100),5) AS Higest_Infection_Rate
FROM Portfolio_Project..Covid_Deaths
GROUP BY location
ORDER BY Higest_Infection_Rate DESC

--The 5 highest countries with infection rate
SELECT TOP 5 location, ROUND(MAX(total_cases/population*100),5) AS Higest_Infection_Rate
FROM Portfolio_Project..Covid_Deaths
GROUP BY location
ORDER BY Higest_Infection_Rate DESC

--The higest total deaths
SELECT location, MAX(total_deaths) AS Total_death_count
FROM Portfolio_Project..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_death_count DESC;


--The highest country with death rate
SELECT TOP 1 location, ROUND(MAX(total_deaths/population*100),5) AS Higest_Death_Rate
FROM Portfolio_Project..Covid_Deaths
GROUP BY location
ORDER BY Higest_Death_Rate DESC
 
--The 5 highest countries with death rate
SELECT TOP 5 location, ROUND(MAX(total_deaths/population*100),5) AS Higest_Death_Rate
FROM Portfolio_Project..Covid_Deaths
GROUP BY location
ORDER BY Higest_Death_Rate DESC


--LET'S BREAK THINGS DOWN TO CONTINENT

--death counts
SELECT location, MAX(total_deaths) AS Total_death_count
FROM Portfolio_Project..Covid_Deaths
WHERE continent IS NULL AND location NOT LIKE '%income%' AND location NOT LIKE '%Union%'
GROUP BY location
ORDER BY Total_death_count DESC;


--GLOBAL NUMBERS
--death rate
SELECT continent, ROUND(MAX(total_deaths/population*100),5) AS Higest_Death_Rate
FROM Portfolio_Project..Covid_Deaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%' AND location NOT LIKE '%Union%'
GROUP BY continent 
ORDER BY Higest_Death_Rate DESC

--cases and deaths counts by continent
SELECT continent, SUM(total_cases) AS total_cases, SUM(total_deaths) AS total_deaths
FROM Portfolio_Project..Covid_Deaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%' AND location NOT LIKE '%Union%'
GROUP BY continent


--Join covid_deaths and covid_vaccinations
--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Portfolio_Project..Covid_Deaths AS dea
JOIN Portfolio_Project..Covid_Vaccinations AS vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
ORDER BY 1,2,3

--Rolling numbers of total new vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_total_new_vaccinations
FROM Portfolio_Project..Covid_Deaths AS dea
JOIN Portfolio_Project..Covid_Vaccinations AS vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
ORDER BY 1,2,3


--USE the last query as CTE

WITH Pop_vs_Vac (Continent, Location, Date, Population, new_vaccinations,rolling_total_new_vaccinations)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_total_new_vaccinations
FROM Portfolio_Project..Covid_Deaths AS dea
JOIN Portfolio_Project..Covid_Vaccinations AS vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rolling_total_new_vaccinations/Population)*100
FROM Pop_vs_Vac





-- TEMP TABLE

DROP TABLE IF EXISTS #Percent_Poppulation_Vaccinated
CREATE TABLE #Percent_Poppulation_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_total_new_vaccinations numeric
)

INSERT INTO #Percent_Poppulation_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_total_new_vaccinations
FROM Portfolio_Project..Covid_Deaths AS dea
JOIN Portfolio_Project..Covid_Vaccinations AS vac
ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
--ORDER BY 2,3

SELECT *, (rolling_total_new_vaccinations/Population)*100
FROM #Percent_Poppulation_Vaccinated




--Creating View to store data for later visualization

CREATE VIEW Percentage_Population_Vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_total_new_vaccinations
FROM Portfolio_Project..Covid_Deaths AS dea
JOIN Portfolio_Project..Covid_Vaccinations AS vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
--ORDER BY 2,3

--Use this view for visualization
SELECT *
FROM Percentage_Population_Vaccinated