Select *
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Show likelihood of dying if you  got covid in ur country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
From PortfolioProject..CovidDeaths
Where location like '%state%' and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Show what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%state%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%state%'
Group by location, population
order by PercentPopulationInfected DESC

--Showing Countries with Highest Death Count compared to Population

Select location, population, Max(cast(total_deaths as int)) as HighestDeathCount, Max((total_deaths/population))*100 as PercentPopulationDeath
From PortfolioProject..CovidDeaths
Where continent is not null -- Continents in database is count as location
Group by location, population
order by HighestDeathCount DESC

--Break thing down by Continent

--Showing Continent with Highest Death Rate Per Population
 
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null -- Asia in database is count as country
Group by continent
order by TotalDeathCount DESC

--GLOBAL NUMBERS

Select SUM( new_cases ) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, ( SUM(cast(new_deaths as int)) / SUM( new_cases ) )*100 as DeathPercent
From PortfolioProject..CovidDeaths
--Where location like '%state%' 
Where continent is not null
--Group by date
order by 1,2



--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
--SUM(Cast(vac.new_vaccinations as int)) OVER ( Partition by dea.location order by dea.date) as PeopleVaccinated,
----( PeopleVaccinated/population ) *100
--From PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--Where dea.continent is not null 
--order by 2,3 


--USE CTE

With PopVsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER ( Partition by dea.location order by dea.date,dea.location) as PeopleVaccinated
--, ( PeopleVaccinated/population ) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
--order by 2,3
)
Select *, (PeopleVaccinated/population)*100
From PopVsVac

--	TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
( 
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric,
)



Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER ( Partition by dea.location order by dea.date,dea.location) as PeopleVaccinated
--, ( PeopleVaccinated/population ) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null 
--order by 2,3

Select *, (PeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--	Creating View for later data visualization

USE PortfolioProject
GO

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER ( Partition by dea.location order by dea.date,dea.location) as PeopleVaccinated
--, ( PeopleVaccinated/population ) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
--order by 2,3

IF OBJECT_ID('PercentPopulationVaccinated', 'V') IS NOT NULL
    DROP VIEW PercentPopulationVaccinated;