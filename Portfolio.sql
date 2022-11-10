--Data from 01.01.2020-06.11.2022

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM CovidVaccinations
ORDER BY 3,4

--Select data that we are going to be using
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Total Cases vs Total Deaths in North Macedonia by day
--Likelihoood of dying if you get infected
SELECT location,date,total_cases,total_deaths,ROUND((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM CovidDeaths
WHERE location='North Macedonia'
ORDER BY 1,2

--Total Cases vs Population in North Macedonia
--Percentage of the population that got infected by day
SELECT location,date,total_cases,population,ROUND((total_cases/population)*100,2)  AS InfectedPercentage
FROM CovidDeaths
WHERE location='North Macedonia'
ORDER BY 1,2


--Countries with Highest Number of Cases
SELECT location,population,MAX(total_cases) as TotalCases
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY TotalCases  DESC

--Countries with Highest Number of Deaths
SELECT location,population,MAX(CAST(total_deaths AS INT)) as TotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY TotalDeaths DESC

--Continents with Highest Number of Cases
SELECT location,MAX(total_cases) as TotalCases
FROM CovidDeaths
WHERE continent IS NULL
AND location NOT IN('World','High Income','Upper middle income','Lower middle income','Low Income','International','European Union')
GROUP BY location
ORDER BY TotalCases  DESC

--Continents with Highest Number of Deaths
SELECT location,MAX(CAST(total_deaths as int)) as TotalDeaths
FROM CovidDeaths
WHERE continent IS NULL
AND location NOT IN('World','High Income','Upper middle income','Lower middle income','Low Income','International','European Union')
GROUP BY location
ORDER BY TotalDeaths  DESC


--Countries with Highest Infection Rate by Population
SELECT location,population,MAX(total_cases) as total_cases,(MAX(total_cases)/population)*100 AS PercentageInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY PercentageInfected DESC


--Countries with highest percentage of Deaths per Infected
SELECT location,MAX(total_cases) AS TotalCases, MAX(cast(total_deaths as int)) as TotalDeaths,
MAX(cast(total_deaths as int))/MAX(total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY DeathPercentage DESC


--Highest percentage of Deaths per Population
SELECT location,population,MAX(CAST(total_deaths AS INT)) AS total_deaths,
MAX(CAST(total_deaths AS INT)/population)*100 AS PercentageDied
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY PercentageDied DESC

--GLOBAL Daily Cases vs Daily Deaths
SELECT date,
SUM(new_cases) AS TotalCases ,SUM(CAST(new_deaths as int)) as TotalDeaths,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--GLOBAL Total Cases,Total Deaths and Death Percentage
SELECT MAX(total_cases) as TotalCases,MAX(CAST(total_deaths as int)) as TotalDeaths,
MAX(CAST(total_deaths as int))/MAX(total_cases)*100 as DeathPercentage
FROM CovidDeaths


--Population,Vaccinations Daily,TotalVaccinations
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS total_vaccinations
FROM CovidDeaths as cd
JOIN CovidVaccinations as cv
ON cd.date=cv.date
AND cd.location=cv.location
WHERE cd.continent is NOT NULL
ORDER BY 2,3

--Population,Vaccinations Daily,TotalVaccinations,PercentageVaccinated
WITH pv (continent,location,date,population,new_vaccinations,total_vaccinations)
as (SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS total_vaccinations
FROM CovidDeaths as cd
JOIN CovidVaccinations as cv
ON cd.date=cv.date
AND cd.location=cv.location
WHERE cd.continent is NOT NULL
)
SELECT *,total_vaccinations/population*100 as PercentageVaccinated
FROM pv
ORDER BY location,date

--Creating View for later vizualization
CREATE VIEW Vaccination as 
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS total_vaccinations
FROM CovidDeaths as cd
JOIN CovidVaccinations as cv
ON cd.date=cv.date
AND cd.location=cv.location
WHERE cd.continent is NOT NULL
--ORDER BY 2,3)

--Vaccination Rate by Countries(Not including boosters)
SELECT cd.location,population,MAX(CAST(people_fully_vaccinated as bigint)) as VacinatedPeople,
MAX(CAST(people_fully_vaccinated as bigint))/population*100 as VaccinationPercentage
FROM CovidVaccinations cv
JOIN CovidDeaths cd
ON cd.date=cv.date
AND cd.location=cv.location
WHERE cd.continent is NOT NULL
GROUP BY cd.location,population
ORDER BY VacinatedPeople DESC

--Vaccination Rate in North Macedonia(not including booster)
SELECT cd.location,population,MAX(CAST(people_fully_vaccinated as bigint)) as VacinatedPeople,
MAX(CAST(people_fully_vaccinated as bigint))/population*100 as VaccinationPercentage
FROM CovidVaccinations cv
JOIN CovidDeaths cd
ON cd.date=cv.date
AND cd.location=cv.location
WHERE cd.continent is NOT NULL
GROUP BY cd.location,population
HAVING cd.location='North Macedonia'

