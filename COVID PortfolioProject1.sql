SELECT *
FROM dbo.CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM dbo.CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE location='Philippines'
ORDER BY 1,2

SELECT location, date, total_cases, population, (total_deaths/population)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE location='Philippines'
ORDER BY 1,2 DESC

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM dbo.CovidDeaths
--WHERE location='Phlippines'
GROUP BY location, population
ORDER BY 4 DESC

SELECT Location, MAX(Cast(Total_Deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY 2 desc

SELECT Continent, MAX(Cast(Total_Deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY Continent
ORDER BY 2 desc

--GLOBAL NUMBERS
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


-- Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location
, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
Order by 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
As (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location
, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac 


-- TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location
, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Create view for visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location
, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null


Select *, (RollingPeopleVaccinated/population)*100
From PercentPopulationVaccinated



