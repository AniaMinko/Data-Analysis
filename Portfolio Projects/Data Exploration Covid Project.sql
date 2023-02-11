
select *
from PortfolioProject..CovidDeath$
order by 3,4


select continent, location ,sum(total_cases) as sum_total_cases
from PortfolioProject..CovidDeath$
where location = 'Europe'
group by continent, location

select location, date, total_cases, total_deaths
from PortfolioProject..CovidDeath$
where continent is not null
order by 1,2


select location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeath$
where location like '%Belarus%'
and continent is not null
order by 1,2


-- looking at Total Cases vs Population
-- shows what percentage of population got Covid
select location, date, total_cases, population,
(total_cases/population) * 100 as covid_population_percentage
from PortfolioProject..CovidDeath$
where location = 'Belarus'
and continent is not null
order by 1,2


-- looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount,
max(total_cases/population) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeath$
where continent is not null
group by location, population
order by PercentPopulationInfected desc


-- showing countries with the highest death count per population
select location, max(cast(total_deaths as int)) as max_total_death
from PortfolioProject..CovidDeath$
where continent is not null
group by location
order by max_total_death desc

-- showing continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as max_total_death
from PortfolioProject..CovidDeath$
where continent is not null
group by continent
order by max_total_death desc


SELECT location, population, date, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeath$
GROUP BY location, population, date
ORDER BY PercentPopulationInfected desc

-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, 
sum(new_deaths) as total_deaths,
sum(new_deaths)/sum(new_cases)*100 as DeathsPercentage
from PortfolioProject..CovidDeath$
where continent is not null
order by 1,2


-- we take these out as they are not included in the above queries and want to stay consistent
-- European Union is part of Europe
SELECT location, SUM(new_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeath$
WHERE continent is null
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount desc

--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath$ dea
join PortfolioProject..CovidVaccinations$ vac on (dea.location = vac.location and dea.date = vac.date)
where dea.continent is not null
order by 2,3



with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath$ dea
join PortfolioProject..CovidVaccinations$ vac on (dea.location = vac.location and dea.date = vac.date)
where dea.continent is not null
)
select *,
(RollingPeopleVaccinated/population) *100 as VaccinatedPeoplePercentage
from PopvsVac



--creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath$ dea
join PortfolioProject..CovidVaccinations$ vac on (dea.location = vac.location and dea.date = vac.date)
where dea.continent is not null


select *
from PercentPopulationVaccinated