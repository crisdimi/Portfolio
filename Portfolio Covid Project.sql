Select Continent, max(total_deaths) as 'Total Deaths'
From PortfolioProject..CovidDeaths
Where continent is NOT NULL
Group by continent
Order by 'Total Deaths' DESC

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases FLOAT

ALTER TABLE Portfolioproject..CovidDeaths
ALTER COLUMN pop float

Update PortfolioProject..CovidDeaths 
set new_cases = NULL 
where new_cases = 0

-- Death chance by Covid in Greece
Select Location, Date, Total_Cases as 'Total Cases', Total_Deaths as 'Total Deaths', ROUND((total_deaths/total_cases)* 100, 2) as 'Death Ratio' 
From PortfolioProject..CovidDeaths
Where location like 'Greece'
And
date >= '2020-02-29'
--AND continent is not null and Total_cases is not null and total_deaths is not null
Order by 2

-- Looking at Total Cases vs Greece's Population
-- Shows percentage of population infected at least once
Select Location, Date, Population, Total_cases, ROUND((total_cases/population)*100, 2) as 'Total Population Infected'
From PortfolioProject..CovidDeaths
Where location like 'Greece' AND date >= '2020-03-01 00:00:00.000' and total_cases is not null
Order by 1,2


-- Looking at Countries with Highest Infection Rate
Select Location, Population, MAX(Total_cases) AS HighestInfectionCount, ROUND(MAX((total_cases/population)), 4)*100 as HighestInfectionRatio
From PortfolioProject..CovidDeaths
Where total_cases is not null
Group by location, population
Order by HighestInfectionRatio desc

-- Showing Countries with Highest Death Count per Population
Select Location, Population, MAX(total_deaths) AS 'Totalt Death Count', ROUND(MAX(total_deaths/population)*100, 2) as 'Mortality Percentage'
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by location, population
Order by 'Mortality Percentage' desc

-- Show Highest Death Count by Continent & Income
Select Location, MAX(total_deaths) AS TotaltDeathCount
From PortfolioProject..CovidDeaths
Where continent is NULL
Group by Location
Order by TotaltDeathCount desc

-- Show things by Continent ?
Select Continent, MAX(total_deaths) AS TotaltDeathCount
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by Continent
Order by TotaltDeathCount desc

-- Show things by Continent per population
Select Location, MAX(total_deaths) AS TotaltDeathCount, Round(MAX(total_deaths/population)*100, 2) as 'Deaths/Population'
From PortfolioProject..CovidDeaths
Where continent is NULL
Group by Location
Order by TotaltDeathCount desc

--GLOBAL NUMBERS
Select SUM(TOTAL_CASES) AS 'Total Cases', SUM(new_cases) AS 'Total New Cases', SUM(new_deaths) AS 'Total New Deaths', ROUND(SUM(new_deaths)/SUM(new_cases)*100, 2) as 'Death Percentage WW'
From PortfolioProject..CovidDeaths
-- Where location like 'Greece' And date >= '2020-03-01'
Where continent is not null and new_cases is not null and  date >= '2020-03-01'
--Group by continent
Order by 1

-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalVaccinationsInCountry --,('Total Vaccinations/Country'/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and vac.new_vaccinations is not null 
Order by 2,3


-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalVaccinationsInCountry)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalVaccinationsInCountry --,(TotalVaccinationsInCountry/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and vac.new_vaccinations is not null
--Order 2,3
)
Select *--, ROUND((TotalVaccinationsInCountry/population)*100,2) AS PercentagePopulationVac
From PopvsVac


-- TEMP TABLE
DROP TABLE If exists #PercentOfPopulationVaccinated
Create Table #PercentOfPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
TotalVaccinationsInCountry numeric,
)
Insert into #PercentOfPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalVaccinationsInCountry --,(TotalVaccinationsInCountry/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and vac.new_vaccinations is not null
--Order 2,3
Select *, ROUND(cast(TotalVaccinationsInCountry/Population as float)*100, 2)AS PercentagePopulationVac
From #PercentOfPopulationVaccinated
Order by 7 desc

-- Create View to store Data for later visualizations
CREATE VIEW PercentOfPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalVaccinationsInCountry --,(TotalVaccinationsInCountry/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and vac.new_vaccinations is not null
-- Order 2,3

Select * 
From PercentOfPopulationVaccinated