SELECT * 
FROM PortfolioProject..covid_deaths
WHERE continent is not null
order by 3,4

--SELECT * 
--FROM PortfolioProject..covid_vaccinations
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..covid_deaths
WHERE continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying after contracting Covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject..covid_deaths
WHERE location like '%Canada%' and continent is not null
order by 1,2

--Looking at the total cases vs population
--Shows percentage of the population has gotten Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as cases_per_population
FROM PortfolioProject..covid_deaths
--WHERE location like '%Canada%'
WHERE continent is not null
order by 1,2

--Looking at countries with the highest infection rate compared to the population

SELECT location, population, MAX(total_cases) as highest_infection_count, MAX(total_cases/population)*100 as percentage_per_population
FROM PortfolioProject..covid_deaths
--WHERE location like '%Canada%'
WHERE continent is not null
GROUP BY location, population
order by percentage_per_population DESC

--Showing the countries with the highest mortality per population

SELECT location, MAX(cast (total_deaths as int)) as total_death_counts 
FROM PortfolioProject..covid_deaths
--WHERE location like '%Canada%'
WHERE continent is not null
GROUP BY location
order by total_death_counts DESC

--Let's look at continents data
--Showing the continents with the highest death count per population

SELECT continent, MAX(cast (total_deaths as int)) as total_death_counts 
FROM PortfolioProject..covid_deaths
--WHERE location like '%Canada%'
WHERE continent is not null
GROUP BY continent
order by total_death_counts DESC


--Global numbers

SELECT SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM PortfolioProject..covid_deaths 
WHERE continent is not null
order by 1,2

--Global numbers by date

SELECT date, SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM PortfolioProject..covid_deaths 
WHERE continent is not null
GROUP BY date
order by 1,2


--Looking at total population vs vaccination (rolling count)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as Rolling_people_vaccinated
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_people_vaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as Rolling_people_vaccinated
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (Rolling_people_vaccinated/Population)*100
FROM PopvsVac


--Temp Table 

DROP table if exists #Percent_population_vaccinated
Create Table #Percent_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
Rolling_people_vaccinated numeric
)

Insert into #Percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as Rolling_people_vaccinated
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--order by 2,3

SELECT *, (Rolling_people_vaccinated/Population)*100
FROM #Percent_population_vaccinated


--Creating view to store data for later visualizations

CREATE VIEW Percent_population_vaccinated2 as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as Rolling_people_vaccinated
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

CREATE VIEW Global_numbers as
SELECT date, SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM PortfolioProject..covid_deaths 
WHERE continent is not null
GROUP BY date

SELECT * FROM Global_numbers
Order by 1,2

