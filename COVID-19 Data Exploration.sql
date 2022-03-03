
/*
COVID-19 Data Exploration

Skills used: Joins, CTEs, Temp Tables, Aggregate Functions, Creating Views, Converting Data Types 
*/
SELECT *
FROM dbo.CovidDeaths
WHERE Continent is not null
ORDER BY 3,4


-- Select data to start with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
WHERE Continent is not null
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows the probability of dying if you contract Covid-19 in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE location='Philippines'
AND Continent is not null
ORDER BY 1,2


-- Total Cases vs Population
-- Shows the percentage of population infected with Covid-19

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM dbo.CovidDeaths
--WHERE location='Philippines'
ORDER BY 1,2 DESC


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM dbo.CovidDeaths
--WHERE location='Phlippines'
GROUP BY location, population
ORDER BY 4 DESC


-- Countries with Highest Death Count per Population

SELECT Location, MAX(Cast(Total_Deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY 2 desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing Continents with the Highest Death Count per Population

SELECT Continent, MAX(Cast(Total_Deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY Continent
ORDER BY 2 desc



-- GLOBAL NUMBERS

SELECT Date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE Continent is not null
GROUP BY Date
ORDER BY 1,2

SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE Continent is not null
--GROUP BY Date
ORDER BY 1,2


-- Total Population vs Vaccination
-- Shows percentage of population that has received at least one Covid-19 vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.Location
, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.Location
, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac 


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.Location
, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Create View to store data for visualization

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.Location
, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated



