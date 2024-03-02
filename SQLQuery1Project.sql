 select *
 from PortfolioProject..CovidDeaths1$
 order by 3,4

 select*from PortfolioProject..covidVaccinations$
 order by 3,4

 -- select data that we are going to use
 
 select location,date,total_cases,new_cases,total_deaths,population
 from PortfolioProject..CovidDeaths1$
 order by 1,2

 -- looking at total cases vs total deaths
 -- shows likelihood of dying if you contract covid in your country
 select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths1$
 where location like '%states%'
 order by 1,2

 --looking at total cases vs population
 --showing what percentage of population got infected with covid
  select location,date,population, total_cases,(total_cases/population)*100 as infectedPercentage
 from PortfolioProject..CovidDeaths1$
 where location like '%states%'
 order by 1,2

 --looking at countries with highest number of people got infected

  select location,population, max(total_cases) as HighestInfected,max((total_cases/population))*100 as infectedPercentage
 from PortfolioProject..CovidDeaths1$

 Group by location,population
 order by infectedPercentage desc

 --showing countries with highest death count per population
 select location, max(total_deaths) as DeathCount
 from PortfolioProject..CovidDeaths1$
 group by location
 order by DeathCount 

 -- GLOBAL NUMBERS
 select sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths,sum(cast(new_deaths as int))/ sum(new_cases)*100 as deathpercentage
 from PortfolioProject..CovidDeaths1$
 where continent is not null
 order by 1,2


 -- looking at total population vs vaccinations
 

 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations )) over
 (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/population_density)*100 to find percentage of population vaccinated
 from PortfolioProject..CovidDeaths1$ dea
 join PortfolioProject..covidVaccinations$ vac
 on dea.location = dea.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3
 
 -- using CTE
 
 
   with POPvsVAC (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
 AS
 (
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations )) over
 (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/population_density)*100 to find percentage of population vaccinated
 from PortfolioProject..CovidDeaths1$ dea
 join PortfolioProject..covidVaccinations$ vac
 on dea.location = dea.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3
  )
  select*,(RollingPeopleVaccinated/population)*100 as PercentageVaccinated
  from POPvsVAC

  -- TEMP TABLE
  drop table if exists #PercentPopulationVaccinated
  create table #PercentPopulationVaccinated
  (continent nvarchar(255),
  location nvarchar(255),
   date datetime,
   new_vaccinations numeric,
   population numeric,
   RollingPeopleVaccinated numeric
  )

   insert into #PercentPopulationVaccinated
   select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations )) over
 (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/population_density)*100 to find percentage of population vaccinated
 from PortfolioProject..CovidDeaths1$ dea
 join PortfolioProject..covidVaccinations$ vac
 on dea.location = dea.location
  and dea.date = vac.date
 -- where dea.continent is not null
  --order by 2,3
    select*,(RollingPeopleVaccinated/population_density)*100
  from #PercentPopulationVaccinated

  -- creating view to store date for later visualisation

create view PercentPopulationVaccinate as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations )) over
 (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/population_density)*100 to find percentage of population vaccinated
 from PortfolioProject..CovidDeaths1$ dea
 join PortfolioProject..covidVaccinations$ vac
 on dea.location = dea.location
  and dea.date = vac.date
 where dea.continent is not null
  --order by 2,3