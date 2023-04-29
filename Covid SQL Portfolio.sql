/*
SQL Portfolio
*/

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelyhood of dying from Covid in The UK between 2020 to 2021

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%kingdom%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS CasesPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%kingdom%'
ORDER BY 1,2


-- Looking at country with most covid cases compare to population

SELECT Location, Population, MAX(total_cases) AS HighestCaseCount, MAX((total_cases/population))*100 AS PercentageInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentageInfected desc


-- Showing country with most death count per population

SELECT Location, MAX(CAST (total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY TotalDeathCount desc

---- Showing country with most death count per population BY CONTINENT

--SELECT continent, MAX(CAST (total_deaths AS INT)) as TotalDeathCount
--FROM PortfolioProject..CovidDeaths
--WHERE continent IS NOT NULL
--GROUP BY continent
--ORDER BY TotalDeathCount desc

--Showing the continents with highest death counts

-- World Wide Death Numbers Per Day

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/
SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%kingdom%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--World Wide death

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/
SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%kingdom%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Looking on Population VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.date) AS RollinVaccinatedPeople
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE

WITH PopsvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinatedPeople)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.date) AS RollingVaccinatedPeople
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingVaccinatedPeople/Population)*100
FROM PopsvsVac
ORDER BY 2,3

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinatedPeople numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.Date) AS RollingVaccinatedPeople
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
SELECT *, (RollingVaccinatedPeople/Population)*100
FROM #PercentPopulationVaccinated


--View for Data Visualizations

Create VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.Date) AS RollingVaccinatedPeople
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated