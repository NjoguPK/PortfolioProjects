 USE Portfolio
GO 
Select location,date, total_cases, new_cases,total_deaths,population 
from CovidDeaths$
Where continent is not null
order by 1,2

--looking at Total Cases vs Total Deaths
--reflection of dying after getting Covid in KENYA
Select location,date, total_cases,total_deaths,population, (total_deaths/total_cases)*100 AS death_percentage
from CovidDeaths$
--Where continent is not null and
 location like '%Kenya%'
order by 1,2

--Total cases vs population
--% population infected
Select location,date, total_cases,population, (total_cases/population)*100 AS cases_percentage
from CovidDeaths$
Where location like '%Kenya%' and 
 continent is not null
order by 1,2

--Checking countries with Highest infection rate compared to population--tableu table 4
Select location,date,MAX(total_cases)as highest_infectioncount,population, MAX((total_cases/population))*100 AS percentage_populationinfected
from CovidDeaths$
--Where location like '%Kenya%'
Group by location,population,date
order by percentage_populationinfected desc
--tableu 3
Select location,MAX(total_cases)as highest_infectioncount,population, MAX((total_cases/population))*100 AS percentage_populationinfected
from CovidDeaths$
--Where location like '%Kenya%'
Group by location,population
order by percentage_populationinfected desc

--Showing countries with the highset death count per population
Select location, MAX(cast(total_deaths as int)) as total_deathscount
from CovidDeaths$
---Where continent is not null
--Where location like '%Kenya%'
Group by location,population
order by total_deathscount desc



--Showing data at continent level


--Continents with the highest death count
Select continent, MAX(cast(total_deaths as int)) as total_deathscount
from CovidDeaths$
Where continent is not  null
--Where location like '%Kenya%'
Group by continent
order by total_deathscount desc


--Global numbers
Select SUM(new_cases)as total_cases,SUM (CAST(new_deaths AS int)) AS total_deaths,SUM (CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
from CovidDeaths$
Where continent is not null --and
 --location like '%Kenya%'--
order by 1,2

--World population vs total vaccinated

Select dea.continent,dea.location,dea.date,population, vac.new_vaccinations,SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location
order by dea.location, dea.date) as rolling_vaccnumber
from CovidDeaths$ dea
join CovidVaccinations$ vac on 
dea.location= vac.location 
and dea.date=vac.date
where dea.continent is not null --and  
--dea.location like '%Albania%'
order by 2,3


--USE COMMON TABLE EXPRESSIOIN (CTE)

With popvsvacc(continent,location,date,population,new_vaccinations,rolling_vaccnumber)
as 
(
Select dea.continent,dea.location,dea.date,population, vac.new_vaccinations,SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location
order by dea.location, dea.date) as rolling_vaccnumber
from CovidDeaths$ dea
join CovidVaccinations$ vac on 
dea.location= vac.location 
and dea.date=vac.date
where dea.continent is not null)

Select*,(rolling_vaccnumber/population)*100 as percentagepopvac from popvsvacc

--where location like '%Albania%'


--TEMP TABLE

Create Table  percentagepopvac 
(continent nvarchar(255),
Location nvarchar (255),
Population numeric,
new_vaccinations numeric,
Date datetime,
rolling_vaccnumber numeric)
--Dropping a Table 
drop table if exists percentagepopvac  
Create Table  percentagepopvac 
(continent nvarchar(255),
Location nvarchar (255),
Population numeric,
new_vaccinations numeric,
rolling_vaccnumber numeric)
select *from percentagepopvac
insert into
 percentagepopvac
 Select dea.continent,dea.location,dea.population, vac.new_vaccinations,SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location
order by dea.location, cast(dea.date as datetime)) as rolling_vaccnumber
from CovidDeaths$ dea
join CovidVaccinations$ vac on 
dea.location= vac.location 
and dea.date=vac.date
where dea.continent is not null
Select*,(rolling_vaccnumber/population)*100 as percentagepopvac from percentagepopvac 

--creating View 
create view  percentagepopvaccinated 
as
Select dea.continent,dea.location,dea.population, vac.new_vaccinations,SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location
order by dea.location, cast(dea.date as datetime)) as rolling_vaccnumber
from CovidDeaths$ dea
join CovidVaccinations$ vac on 
dea.location= vac.location 
and dea.date=vac.date
where dea.continent is not null


select * from percentagepopvaccinated 