Select *
FROM Portfolio_Project..Covid_Deaths
where continent is not null
Order by 3,4

--Select *
--FROM Portfolio_Project..Covid_Vaccinations
--Order by 3,4


-------SELECTING DATA THAT IS TO BE USED

Select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..Covid_Deaths
Order by 1,2


------- TOTAL CASES VS TOTAL DEATHS
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from Portfolio_Project..Covid_Deaths
Order by 1,2

--Shows likelihood of dying if you contract covid in United States
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from Portfolio_Project..Covid_Deaths
where location like '%States%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 as Contact_Percentage
from Portfolio_Project..Covid_Deaths
--where location like '%India%'
Order by 1,2


--looking are countries with highest infection rate compared to population

Select location, population, max(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Contact_Percentage
from Portfolio_Project..Covid_Deaths
--where location like '%India%'
group by location , population
Order by Contact_Percentage desc

--countries with highest death count 

Select location, max(cast(total_deaths as int)) as Total_Death_Count
from Portfolio_Project..Covid_Deaths
--where location like '%India%'
where continent is not null
group by location 
Order by Total_Death_Count desc


-- breaking things by continent
-- showing the continents with the highest death count
Select continent, max(cast(total_deaths as int)) as Total_Death_Count
from Portfolio_Project..Covid_Deaths
where continent is not null
group by continent 
Order by Total_Death_Count desc


-- Sum of new cases each day
Select date, SUM(new_cases) as New_Cases_Per_Day
from Portfolio_Project..Covid_Deaths
where continent is not null
group by date
order by 1,2



-- Sum of new cases and new deaths each day and death percentage
Select date, SUM(new_cases) as New_Cases_Per_Day, SUM(cast(new_deaths as int)) as Deaths_Per_Day, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as Death_Percentage
from Portfolio_Project..Covid_Deaths
where continent is not null
group by date
order by 1,2


-- Total Cases in the world and Total Deaths in the world and Death Percentage
Select SUM(new_cases) as New_Cases_Per_Day, SUM(cast(new_deaths as int)) as Deaths_Per_Day, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as Death_Percentage
from Portfolio_Project..Covid_Deaths
where continent is not null
--group by date
order by 1,2


--Displaying all information from Vaccinationes file
Select * 
from Portfolio_Project..Covid_Vaccinations

-- Joining two tables the death table and the vaccination table
Select *
From Portfolio_Project..Covid_Deaths dea
Join Portfolio_Project..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date    = vac.date

-- Checking Total Population vs Vaccinations and arranging them according to summation using PARTITION
-- We use SQL PARTITION BY to divide the result set into partitions and perform computation on each subset of partitioned data.
Select  dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations as vac_perday, 
SUM (convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as rolling_vacs
,(rolling_vacs/population)*100

from Portfolio_Project..Covid_Deaths dea
join Portfolio_Project..Covid_Vaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 1,2,3



-- Converting to Percentage and Checking Total Population vs Vaccinations and arranging them according to summation 
--using PARTITION and (CTE) COMMON TABLE EXPRESSIONS
-- A Common Table Expression, also called as CTE in short form, is a temporary named result set that
--you can reference within a SELECT, INSERT, UPDATE, or DELETE statement. 

With Popu_VS_Vac (Continent, Location, Date, Population, new_vaccinations, rolling_vacs)
as
(
Select  dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations as vac_perday, 
SUM (convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_vacs


from Portfolio_Project..Covid_Deaths dea
join Portfolio_Project..Covid_Vaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 1,2,3
 )

Select *, (rolling_vacs/Population)*100
From Popu_VS_Vac


-- Another Method by creating a TEMPORARY TABLE

-- Another method can be to create a separate table > then insert the data into it > Apply calculations

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_vacs numeric
)


Insert into #PercentPopulationVaccinated
Select  dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations as vac_perday, 
SUM (convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_vacs


from Portfolio_Project..Covid_Deaths dea
join Portfolio_Project..Covid_Vaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 1,2,3

 Select *, (rolling_vacs/population)*100 as total_percent_vaccinated
 from #PercentPopulationVaccinated



Create View PercentPopulationVaccinated as
Select  dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations as vac_perday, 
SUM (convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_vacs


from Portfolio_Project..Covid_Deaths dea
join Portfolio_Project..Covid_Vaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 1,2,3


