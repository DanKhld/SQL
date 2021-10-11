select * from covid_project..CovidDeaths$
where continent is not null
order by 3, 4;

--select * from covid_project..CovidVacinaction$
--order by 3, 4;

-- The Percentage of death when getting Covid--19 in Malaysia
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_project..CovidDeaths$
where location = 'Malaysia'
order by 1,2;

-- Chances of getting Covid-19 in Malaysia
select location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
from covid_project..CovidDeaths$
where location = 'Malaysia'
order by 1,2;
 
-- Pecentage of Covid-19 cases per population
select location, population, max(total_cases) as HighestInfectionRate, Max((total_cases/population))*100 as CovidPercentageInfected
from covid_project..CovidDeaths$
group by location, population
order by CovidPercentageInfected desc;

-- Total deaths in each country
select location,  max(cast(total_deaths as int)) as HighestDeathRate
from covid_project..CovidDeaths$
where continent is not null
group by location
order by HighestDeathRate desc;

-- Percentage of Deaths per population in each country
select location, population, max(total_deaths) as HighestDeathRate, Max((total_deaths/population))*100 as CovidPercentageDeaths
from covid_project..CovidDeaths$
group by location, population
order by CovidPercentageDeaths desc;

-- Total deaths per Continent
select location, max(cast(total_deaths as int)) as DeathPerContinent
from covid_project..CovidDeaths$
where continent is null
group by location
order by DeathPerContinent desc;

-- Total percentage of case in Asia
select location, population, max(total_cases) as TotalCasesPerCountry
from covid_project..CovidDeaths$
Where continent = 'Asia'
group by location, population
order by TotalCasesPerCountry desc;

-- Percentage of deaths in countries in Asia
select location, max(cast(total_deaths as int)) as DeathPerContinent
from covid_project..CovidDeaths$
where continent = 'Asia'
group by location
order by DeathPerContinent desc;

-- Total of new cases per day in each country
select date, SUM(new_cases) as NewCasesPerDay, SUM(cast(new_deaths as int)) as DeathsPerDay 
from covid_project..CovidDeaths$
where continent is not null
group by date
order by 1, 2;

-- Total of new cases per day in Malaysia
select date, SUM(new_cases) as NewCasesPerDay, SUM(cast(new_deaths as int)) as DeathsPerDay, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPerCases
from covid_project..CovidDeaths$
where location = 'Malaysia'
group by date
order by date;

-- Vacinationatins per population per day
--CTE
with PopVsVac (continent, lcation, date, poplation, new_vacinations, RollingVac)
as
(
select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int) as new_vac,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingVac

from covid_project..CovidDeaths$ dea
join covid_project..CovidVacinaction$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (RollingVac/poplation)*100 as VacPerPop
from PopVsVac; 


with PopVsVac (continent, lcation, date, poplation, new_vacinations, RollingVac)
as
(
select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int) as new_vac,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingVac
from covid_project..CovidDeaths$ dea
join covid_project..CovidVacinaction$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.location = 'Malaysia'
)
select *, (RollingVac/poplation)*100 as VacPerPop
from PopVsVac 

--Temp Table
DROP Table if exists #PercentagePopVac
Create Table #PercentagePopVac
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vacinations numeric,
Rollingvac numeric
)

Insert into #PercentagePopVac
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int) as new_vac,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingVac
from covid_project..CovidDeaths$ dea
join covid_project..CovidVacinaction$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingVac/population)*100 as VacPerPop
from #PercentagePopVac


