--SELECT *
--FROM PortfolioProject1..covidDeaths
--ORDER BY 3,4

----SELECT *
----FROM PortfolioProject1..covidVaccinations
----order by 3,4

----SELECT THE DATA THAT WE ARE GOING TO BE USING

----SELECT Location,date,total_cases,new_cases,total_deaths,population
----FROM PortfolioProject1..covidDeaths
----order by 1,2

----looking at the total cases vs total deaths
----This essentially shows the likelihood of you dying if you where to contact the disease at any given point in time
----SELECT Location,date,total_cases,total_deaths, CONVERT(FLOAT,total_deaths)/CONVERT(FLOAT,total_cases)*100 as DeathPercentage
----FROM PortfolioProject1..covidDeaths
----where Location like '%STATES%'
----order by 1,2


----looking at the total deaths vs the populataion
----SELECT Location,date,total_deaths,population,(total_deaths/population)*100 as DeathToPopulation
----FROM PortfolioProject1..covidDeaths
----order by 1,2



----looking at the total cases vs the populataion
----looking at the total percent of the population that contracted covid
--SELECT Location,date,total_cases,population,(total_cases/population)*100 as casesToPopulation
--FROM PortfolioProject1..covidDeaths
--order by 1,2

----what countries have the highest infection rates compared to the population
--SELECT Location,max(total_cases) as TotalCases,Population,max((total_cases/population)*100) as casesToPopulation
--FROM PortfolioProject1..covidDeaths
--group by location,population
--order by casesToPopulation desc


----looking for the total deaths per location
--SELECT Location,Population,max(convert(float,total_deaths)) totalDeaths
--FROM PortfolioProject1..covidDeaths
--where continent is not null
--group by location,population
--order by totalDeaths desc

----looking at the total DEATHS vs the populataion
----looking at the total percent of the population that DIED
--SELECT Location,date,total_deaths,population,(total_deaths/population)*100 as deathsToPopulation
--FROM PortfolioProject1..covidDeaths
--order by 1,2

----what countries have the highest deaths rates compared to the population
--SELECT Location,max(total_deaths) as Totaldeaths,Population,max((total_deaths/population)*100) as deathsToPopulation
--FROM PortfolioProject1..covidDeaths
--group by location,population
--order by deathsToPopulation desc



SELECT *
FROM PortfolioProject1..covidDeaths
ORDER BY 3,4

--looking for the total deaths per continent

SELECT Continent,max(Population)population,max(convert(float,total_deaths)) totalDeaths
FROM PortfolioProject1..covidDeaths
where continent is not null
group by Continent
order by totalDeaths desc




--showing the continents with the highest death count

SELECT Continent,MAX(CONVERT(FLOAT,TOTAL_DEATHS)) TOTALDEATHS
FROM PortfolioProject1..covidDeaths
WHERE CONTINENT IS NOT NULL
GROUP BY CONTINENT
ORDER BY TOTALDEATHS DESC



--TOTAL NUMBER OF NEW CASES GLOBALLY SINCE THE BEGINNING OF THE PANDEMIC

SELECT DATE, sum(new_cases) TotalCases, sum(new_deaths) newDEATHS, (SUM(NEW_DEATHS)/SUM(CONVERT(FLOAT,TOTAL_CASES))) * 100 AS DP
FROM PortfolioProject1..covidDeaths
WHERE CONTINENT IS NOT NULL 
GROUP BY DATE
ORDER BY 1



--NOW TO START WORKING WITH THE VACCINATION DATABASE I GUESS

SELECT DEA.CONTINENT,DEA.LOCATION, DEA.DATE,DEA.POPULATION,VAC.new_vaccinations,
SUM(CONVERT(FLOAT,VAC.NEW_VACCINATIONS)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION,DEA.DATE) AS ROLLINGCOUNTOFVACCINATED
FROM PortfolioProject1..covidDeaths DEA
JOIN PortfolioProject1..covidVaccinations VAC
ON DEA.DATE=VAC.DATE AND DEA.LOCATION = VAC.LOCATION
WHERE DEA.CONTINENT IS NOT NULL
ORDER BY 1,2,3

WITH CTE_NEW (CONTINENT, LOCATION,DATE,POPULATION,NEWVAC,VACC)
AS (
SELECT DEA.CONTINENT,DEA.LOCATION, DEA.DATE,DEA.POPULATION,VAC.new_vaccinations,
SUM(CONVERT(FLOAT,VAC.NEW_VACCINATIONS)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION,DEA.DATE) AS VACCINATED
FROM PortfolioProject1..covidDeaths DEA
JOIN PortfolioProject1..covidVaccinations VAC
ON DEA.DATE=VAC.DATE AND DEA.LOCATION = VAC.LOCATION
WHERE DEA.CONTINENT IS NOT NULL
--ORDER BY 1,2,3
)

--SELECT *,MAX((VACC/POPULATION)*100) AS PERC
--FROM CTE_NEW
--GROUP BY CONTINENT,LOCATION,DATE,POPULATION,NEWVAC,VACC

--USING JUST THE MAX
SELECT CONTINENT,LOCATION,DATE,NEWVAC,MAX((VACC/POPULATION)*100) AS PERC
FROM CTE_NEW
GROUP BY CONTINENT,LOCATION,DATE,NEWVAC

SELECT *,(VACC/POPULATION)*100 AS PERCOVERPOP
FROM CTE_NEW
WHERE (VACC/POPULATION)*100 > 100


--USING TEMP TABLES

drop table if exists #popvsvac
CREATE TABLE #POPVSVAC 
(CONTINENT NVARCHAR(100),LOCATION NVARCHAR(100),DATE NVARCHAR(100),POPULATION FLOAT,vaccc int,newvacc float)


INSERT into #POPVSVAC 

SELECT DEA.CONTINENT,DEA.LOCATION, DEA.DATE,DEA.POPULATION,VAC.new_vaccinations,
SUM(CONVERT(FLOAT,VAC.NEW_VACCINATIONS)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION,DEA.DATE) AS ROLLINGCOUNTOFVACCINATED
FROM PortfolioProject1..covidDeaths DEA
JOIN PortfolioProject1..covidVaccinations VAC
ON DEA.DATE=VAC.DATE AND DEA.LOCATION = VAC.LOCATION
WHERE DEA.CONTINENT IS NOT NULL
ORDER BY 1,2,3

SELECT * 
FROM #POPVSVAC


--CREATING VIEWS FOR VISUALIZATION
create view DeathsPerContinent as
SELECT Continent,max(Population)population,max(convert(float,total_deaths)) totalDeaths
FROM PortfolioProject1..covidDeaths
where continent is not null
group by Continent
--order by totalDeaths desc



CREATE VIEW POPVSVAC AS 
WITH CTE_NEW (CONTINENT, LOCATION,DATE,POPULATION,NEWVAC,VACC)
AS (
SELECT DEA.CONTINENT,DEA.LOCATION, DEA.DATE,DEA.POPULATION,VAC.new_vaccinations,
SUM(CONVERT(FLOAT,VAC.NEW_VACCINATIONS)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION,DEA.DATE) AS VACCINATED
FROM PortfolioProject1..covidDeaths DEA
JOIN PortfolioProject1..covidVaccinations VAC
ON DEA.DATE=VAC.DATE AND DEA.LOCATION = VAC.LOCATION
WHERE DEA.CONTINENT IS NOT NULL
--ORDER BY 1,2,3
)


--USING JUST THE MAX
SELECT CONTINENT,LOCATION,DATE,NEWVAC,MAX((VACC/POPULATION)*100) AS PERC
FROM CTE_NEW
GROUP BY CONTINENT,LOCATION,DATE,NEWVAC