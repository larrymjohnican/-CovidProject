SELECT *
FROM [Portfolio Project #1]..CovidDeaths$
where continent is not null
order by 3,4	


--SELECT *
--FROM [Portfolio Project #1]..CovidVaccinations$
--order by 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project #1]..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project #1]..CovidDeaths$
Where continent like '%states%'
order by 1,2


-- Looking at Total Cases vs Population
SELECT location, date, Population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
FROM [Portfolio Project #1]..CovidDeaths$
-- Where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location,  Population, date, Max(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as
PercentPopulationInfected
FROM [Portfolio Project #1]..CovidDeaths$
-- Where location like '%states%'
Group by location, Population, date
order by PercentPopulationInfected desc

-- Showing Countries with highest Death Count per Popuilation
SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM [Portfolio Project #1]..CovidDeaths$
-- Where location like '%states%'
where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT


--Showing continents with the highest death count per population

SELECT continent, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project #1]..CovidDeaths$
-- Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT   SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
	(New_Cases)*100 as DeathPercentage
FROM [Portfolio Project #1]..CovidDeaths$
-- where location like '%states%'
Where continent is not null
-- Group By date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
,(RollingPeopleVaccinated/population)*100
From [Portfolio Project #1]..CovidDeaths$ dea
Join [Portfolio Project #1]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project #1]..CovidDeaths$ dea
Join [Portfolio Project #1]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
From PopvsVac



-- TEMP TABLE

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
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
From [Portfolio Project #1]..CovidDeaths$ dea
Join [Portfolio Project #1]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
From [Portfolio Project #1]..CovidDeaths$ dea
Join [Portfolio Project #1]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
 where dea.continent is not null
-- order by 2,3



Select*
From PercentPopulationVaccinated

