-- Total Cases vs Total Deaths
-- Shows likelihood of dieing if you contract covid in India
SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location='India'
ORDER BY 1,2;

-- Total Cases vs Population
-- Shows what percentage contracted covid in India.
SELECT Location,date,total_cases,population,(total_cases/population)*100 AS ContractedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location='India'
ORDER BY 1,2;


-- Infected Count per Population

SELECT Location,population,
	MAX(total_cases) AS HighestInfectionCount, 
	(MAX(total_cases)/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location,population
ORDER BY PercentPopulationInfected DESC;

-- Death Count per Population

SELECT Location,population,
	MAX(total_deaths) AS TotalDeathCount, 
	(MAX(total_deaths)/population)*100 AS PercentPopulationDied
FROM PortfolioProject..CovidDeaths
GROUP BY Location,population
ORDER BY PercentPopulationDied DESC;

--Let's break things down by continent

-- Death Count in each continent
SELECT continent,
	MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Death Count per population in each continent

SELECT continent,SUM(population),
	MAX(total_deaths)/SUM(population) AS PercentDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY PercentDeathCount DESC;

--GLOBAL NUMBERS

-- Total cases vs Total Deaths
SELECT date AS Date,SUM(new_cases) AS 'Total cases',SUM(new_deaths)'Total Deaths' , (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
HAVING SUM(new_cases) > 0 AND SUM(new_deaths) > 0 AND SUM(new_deaths) < SUM(new_cases)
ORDER BY date


-- Total Population v/s Vaccination

SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations 
,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS PeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Percentage Population Vaccinated

SELECT 
	dea.location,
	dea.population,
	SUM(vac.new_vaccinations) as totalvaccinated,
	(SUM(vac.new_vaccinations)/dea.population)*100 as percentagevaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.location,dea.population
ORDER BY 2,3
-- Here, percentages above hundred is telling us that people have gone for their 2nd shot as well.

--Percentage People Vaccinated filter by date

With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as (
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations 
,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *,(RollingPeopleVaccinated/Population)*100 As PercentageVaccinated 
FROM PopvsVac
ORDER BY 2,3;

-- Using Temp Table for the above analysis

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
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations 
,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- CREATING VIEWS TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations 
,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT * FROM PercentPopulationVaccinated



