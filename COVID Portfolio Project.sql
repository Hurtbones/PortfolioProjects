Select *
	From PortfolioProject..CovidDeaths
	Where continent is not null
	order by 3,4

--Select *
--	From PortfolioProject..CovidVaccinations
--	order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying of covid by country
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got covid

Select Location, date, population, total_cases, (CONVERT(float, total_cases) / population) * 100 AS Contractedpercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((CONVERT(float, total_cases)) / population) * 100 AS Contractedpercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population 
order by Contractedpercentage desc

-- Showing Countries with highest death count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where ISNULL(continent,'') <> '' 
Group by Location 
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent 
order by TotalDeathCount desc


-- GLOBAL NUMBERS BY DATE

Select date, SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as Deathpercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where new_cases <> 0 AND new_deaths <> 0
group by date 
order by 1,2

-- GLOBAL DEATH PERCTANGE 2020-2024

Select SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as Deathpercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where new_cases <> 0 AND new_deaths <> 0
--group by date 
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where ISNULL(dea.continent,'') <> ''
order by 2,3




--USE CTE


With PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where ISNULL(dea.continent,'') <> ''
--order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
From PopvsVac




--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent varchar(50),
location varchar(50),
date varchar(50),
population numeric,
new_vaccinations varchar(50),
RollingPeopleVaccinated varchar(50)
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where ISNULL(dea.continent,'') <> ''
order by 2,3

Select*, RollingPeopleVaccinated/CONVERT(float,population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where ISNULL(dea.continent,'') <> ''
--order by 2,3

Select *
From PercentPopulationVaccinated