Select *
From PortofolioProject..CovidDeaths
Where continent is not NUll
Order by 3,4

--Select *
--FROM PortofolioProject..CovidVaccinations
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortofolioProject..CovidDeaths
Order by 1,2

--Looking at Total Caes vs Total Deaths
Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
Where location like '%Indo%'
Order by 1,2


--Looking at Total Cases vs Population
--Show what percentage of population got Covid

Select location, date, total_cases, population,(total_cases/population)*100 as PercentageOfpeopleGetCovid
From PortofolioProject..CovidDeaths
Where location like '%Indo%'
Order by 1,2

--Looking at Country with highest infection rate compared to population
Select location, population,  MAX(total_cases) as HighestInfect, Max((total_cases/population))*100 as PopulationInfect
From PortofolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by PopulationInfect desc


--Showing Countries with the Higest Death count per population
Select location, Max(Cast(total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
Where continent is not NUll
Group by location
Order by TotalDeathCount desc


--Break things down by continent
Select continent, Max(Cast(total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
Where continent is not NUll
Group by continent
Order by TotalDeathCount desc

--Showing continents with highest death count per population
Select continent, Max(Cast(total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
Where continent is not NUll
Group by continent
Order by TotalDeathCount desc


--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
 
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(convert(bigint, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 FROM PortofolioProject..CovidDeaths dea
 Join PortofolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
	Where dea.continent is not null
	order by 2,3

	---Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table

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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	
