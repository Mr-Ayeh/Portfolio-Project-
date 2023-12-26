
select *
from Project_Portfolio..CovidDeaths
where continent is not null
order by 3,4

select  *
from Project_Portfolio..CovidVaccination
order by 3,4

--select Data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population
from Project_Portfolio..CovidDeaths
where continent is not null
order by 1,2


--Looking at total cases vs Total Deaths
-- Likelhood of dying if you had covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Project_Portfolio..CovidDeaths
where location = 'Ghana'
and continent is not null
order by 1,2


-- Looking at the total cases vs Population
--Shows percentage of population with covid

select location, date, total_cases, population, (total_cases/population)*100 as PercentagewithCovid
from Project_Portfolio..CovidDeaths
--where location = 'Ghana'
where continent is not null
order by 1,2

--Countries with the Highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagewithCovid
from Project_Portfolio..CovidDeaths
--where location = 'Ghana'
Group by location, population
order by PercentagewithCovid desc


-- Countries with the highest Death Count Per Population

select location, Max(cast(total_deaths as int)) as TotalDeathCount
from Project_Portfolio..CovidDeaths
--where location = 'Ghana'
where continent is not null
Group by location
order by TotalDeathCount desc


--Let's Things down by Continent 
--Showing the continents with the highest death count 

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from Project_Portfolio..CovidDeaths
--where location = 'Ghana'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers 

select SUM(new_cases) as total_Cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM (new_cases)*100 as DeathPercentage
from Project_Portfolio..CovidDeaths
--where location = 'Ghana'
where continent is not null
--Group by date
order by 1,2

-- Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
from Project_Portfolio..CovidDeaths dea
JOIN  Project_Portfolio..CovidVaccination vac
	ON  dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE 

with PopsvsVAc (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
from Project_Portfolio..CovidDeaths dea
JOIN  Project_Portfolio..CovidVaccination vac
	ON  dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopsvsVAc


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
from Project_Portfolio..CovidDeaths dea
JOIN  Project_Portfolio..CovidVaccination vac
	ON  dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating view to store data for later visualiztion

Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
from Project_Portfolio..CovidDeaths dea
JOIN  Project_Portfolio..CovidVaccination vac
	ON  dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated