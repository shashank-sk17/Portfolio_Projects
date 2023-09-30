--View table 
Select *
From DataExplorationProject..Covid_Deaths
order by 3,4
 
--Select *
--From DataExplorationProject..Covid_Vaccinations
--order by 3,4

--View total cases, new cases, total deaths and population
Select Location, date, total_cases, new_cases, total_deaths, population
From DataExplorationProject..Covid_Deaths
order by 1,2

--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From DataExplorationProject..Covid_Deaths
Where location like '%india%'
order by 1,2

--Looking at what percentage of population got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From DataExplorationProject..Covid_Deaths
Where location like '%india%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfected , MAX((total_cases/population))*100 as InfectedPopulationPercentage
From DataExplorationProject..Covid_Deaths
Group by population, location
order by InfectedPopulationPercentage desc

--Showing countries with highest death count per population
Select Location, MAX(total_deaths) as TotalDeathCount
From DataExplorationProject..Covid_Deaths
Where continent is not NULL
Group by location
order by TotalDeathCount desc

--Breaking things down by continent 
Select continent, MAX(total_deaths) as TotalDeathCount
From DataExplorationProject..Covid_Deaths
Where continent is not NULL
Group by continent
order by TotalDeathCount desc

--Showing continents with the highest death count per population
Select continent, MAX(total_deaths) as TotalDeathCount
From DataExplorationProject..Covid_Deaths
Where continent is not NULL
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
SET ARITHABORT OFF
SET ANSI_WARNINGS OFF
Select date, SUM(new_cases) as TotalNewCases, SUM(total_deaths) as SumTotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From DataExplorationProject..Covid_Deaths
Where continent is not NULL
group by date
order by 1,2


Select COALESCE(new_cases,0) as NEW_CASES
From DataExplorationProject..Covid_Deaths

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From DataExplorationProject..Covid_Deaths dea
Join DataExplorationProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From DataExplorationProject..Covid_Deaths dea
Join DataExplorationProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From DataExplorationProject..Covid_Deaths dea
Join DataExplorationProject..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 









 


