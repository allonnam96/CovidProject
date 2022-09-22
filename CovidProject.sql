Select *
from CovidProject .. CovidDeaths
order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
from CovidProject .. CovidDeaths
order by 1,2

-- Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from CovidProject .. CovidDeaths
Where location like '%states%'
order by 1,2


--Total Cases vs Population
--Shows what percentage of population got Covid
Select location, date, Population, total_cases, (total_cases / Population) * 100 as CovidPercentage
from CovidProject .. CovidDeaths
Where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compated to Population
Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / Population)) * 100 as PercentPopulationInfected
from CovidProject .. CovidDeaths
group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidProject .. CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Showing Continent with Highest Death Count per Population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidProject .. CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global numbers
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int)) / SUM(new_cases) *100 as DeathPercentage
from CovidProject .. CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccinations

with PopvsVac (Continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidProject .. CovidDeaths dea
join CovidProject .. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac





-- Temp Table
DROP table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidProject .. CovidDeaths dea
join CovidProject .. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


