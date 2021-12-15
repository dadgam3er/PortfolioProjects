select *
From Data_project..Covid_deaths
Where continent is not Null
order by 3,4

--select *
--from Data_project..Covid_vaxx
--order by 3,4

-- select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
From Data_project..Covid_deaths
order by 1,2

-- Looking at total cases vs total deaths
select location, date, total_cases, total_deaths,( total_deaths / total_cases ) * 100 as DeathPercentage
From Data_project..Covid_deaths
Where location like '%algeria%'
order by 1,2

-- total cases vs population
select location, date, total_cases, population, (total_cases / population) * 100 as PercentagePopulationInfected
From Data_project..Covid_deaths
Where location like '%algeria%'
order by 1,2


-- finding the countries with the highiest infection rate compared to Population

select location, population, MAX(total_cases) as HighiestInfectionCount, MAX((total_cases / population)) * 100 as PercentagePopulationInfected
From Data_project..Covid_deaths
Where continent is not Null
--Where location like '%states%'
Group by location, population
order by PercentagePopulationInfected desc

-- Show the countries with highiest Death count per Population

select location, MAX(cast(total_deaths as int)) as HighiestDeathRate
From Data_project..Covid_deaths
Where continent is not Null
--Where location like '%states%'
Group by location
order by HighiestDeathRate desc

-- Breaking the stats by Continent

select location, MAX(cast(total_deaths as int)) as HighiestDeathRate
From Data_project..Covid_deaths
Where continent is null
--Where location like '%states%'
Group by location
order by HighiestDeathRate desc

-- Showing the continent with the highiest death count per population

select continent, MAX(cast(total_deaths as int)) as HighiestDeathRate
From Data_project..Covid_deaths
Where continent is not null
--Where location like '%states%'
Group by continent
order by HighiestDeathRate desc

-- GLOBAL STATS

select SUM(new_cases) as TheSUMofTotalCases, SUM(cast(new_deaths as int)) as TheSumofNewDeaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as GLOBALDeathRate
From Data_project..Covid_deaths
--Where location like '%algeria%'
Where continent is not null
--Group by date
order by 1,2 

-- We are going to join the two tables together!!!
-- Total of population vs total of Vaxx

select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(Convert(int, vax.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Data_project..Covid_deaths dea
join Data_project..Covid_vaxx vax
	on dea.location = vax.location
	and dea.date = vax.date
Where dea.continent is not null
order by 2,3

-- let's use a CTE

with PopulationvsVaxx (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(Convert(bigint, vax.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100 as PopVaxxed
from Data_project..Covid_deaths dea
join Data_project..Covid_vaxx vax
	on dea.location = vax.location
	and dea.date = vax.date
Where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated / population) * 100 as PopVaxxed
from PopulationvsVaxx



-- TEMP TABLE
Drop Table if exists #PercentPopulationVaxxed
create Table #PercentPopulationVaxxed
(
continent nvarchar (225),
Location nvarchar (225),
date datetime,
Population numeric,
new_vaccinations numeric ,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaxxed
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(Convert(bigint, vax.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100 as PopVaxxed
from Data_project..Covid_deaths dea
join Data_project..Covid_vaxx vax
	on dea.location = vax.location
	and dea.date = vax.date
--Where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated / population) * 100 as PopVaxxed
from #PercentPopulationVaxxed


-- Creating View to store data for later Visualizations

CREATE VIEW PercentPopulationVaxxed as
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(Convert(bigint, vax.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100 as PopVaxxed
from Data_project..Covid_deaths dea
join Data_project..Covid_vaxx vax
	on dea.location = vax.location
	and dea.date = vax.date
Where dea.continent is not null
--order by 2,3

select * 
From PercentPopulationVaxxed

