/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

create database Portfolio_Project;
use Portfolio_Project;
SHOW VARIABLES LIKE "local_infile";
show variables like "secure_file_priv";
set@@GLOBAL.local_infile = 'ON';
set sql_mode='';
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/covid_deaths.csv'
INTO TABLE portfolio_project.covid_deaths
FIELDS TERMINATED BY ","
LINES TERMINATED BY "\n"
ignore 1 lines;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/covid_vaccinations.csv'
INTO TABLE portfolio_project.covid_vaccinations
FIELDS TERMINATED BY ","
LINES TERMINATED BY "\n"
ignore 1 lines;
select * from portfolio_project.covid_deaths;
select * from portfolio_project.covid_vaccinations;
-- select date from portfolio_project.covid_deaths
-- order by cast( covid_deaths.date as datetime);
select str_to_date(date,"%m/%d/%Y") as new_date from portfolio_project.covid_deaths
order by new_date;

-- select data that we are going to be using

select location,str_to_date(date,"%m/%d/%Y") as new_date,total_cases,total_deaths,population 
from portfolio_project.covid_deaths 
order by location, new_date;

-- looking at total cases vs totaldeaths
-- shows the liklihood of dying if you contract covid by country

select location,str_to_date(date,"%m/%d/%Y") as new_date,
total_cases,total_deaths,
round((total_deaths/total_cases)*100,2) as death_percentage
from portfolio_project.covid_deaths
order by location,new_date;

-- looking at US deathpercentage vs infected count

select location,str_to_date(date,"%m/%d/%Y") as new_date,total_cases,
total_deaths,round((total_deaths/total_cases)*100,2) as death_percentage
from portfolio_project.covid_deaths
where location like '%states%'  and continent  not like ''
order by location, new_date;

-- looking at total cases vs population
-- shows what percent of population got covid

select location,str_to_date(date,"%m/%d/%Y") as new_date,population,
total_cases,
round((total_cases/population)*100,2) as infected_population_inpercent
from portfolio_project.covid_deaths
where continent not like ''
order by location, new_date;

-- looking at countries with highest infection rate vs population 

select location,population,max(total_cases) as highest_infection_count,
round((max(total_cases)/population )*100,2) as percent_of_population_infected
from portfolio_project.covid_deaths
group by location
order by percent_of_population_infected desc;

-- showing countries with highest death count vs population

select location,max(cast(total_deaths as unsigned  )) as death_count,
((max(cast(total_deaths as unsigned)))/population)*100 as death_percentage
from portfolio_project.covid_deaths
where continent not like ''
group by location
order by death_percentage desc;

-- Let's break things down by continent
-- showing highest death count in continents

select location,max(cast(total_deaths as unsigned  )) as death_count
from portfolio_project.covid_deaths
where continent  like ''
group by location
order by death_count desc;

-- looking at unique locations and their continent

select distinct location, continent from covid_deaths 
where continent not like '';

-- Global numbers 

select str_to_date(date,"%m/%d/%Y") as new_date, sum(new_cases) as total_cases,
sum(new_deaths ) as total_deaths,
round(sum(new_deaths )/sum(new_cases)*100,2) as deathpercentage
from portfolio_project.covid_deaths
where continent not like''
group by new_date;

-- Global numbers todate

select  sum(new_cases) as total_cases,
sum(new_deaths ) as total_deaths,
round(sum(new_deaths )/sum(new_cases)*100,2) as deathpercentage
from portfolio_project.covid_deaths
where continent not like'';

-- Total population vs Vaccination

select deaths.continent,deaths.location,
str_to_date(deaths.date,"%m/%d/%Y") as new_date,
deaths.population,
cast(vaccine.new_vaccinations as unsigned integer) as new_vaccinations,
sum(cast(vaccine.new_vaccinations as  unsigned int))over
(partition by deaths.location
 order by deaths.location, str_to_date(deaths.date,"%m/%d/%Y") ) 
as Rolling_Vaccinations
from portfolio_project.covid_deaths deaths
join  portfolio_project.covid_vaccinations vaccine
on deaths.location=vaccine.location
and deaths.date =vaccine.date
where deaths.continent not like ''
order by deaths.location,str_to_date(deaths.date,"%m/%d/%Y")
;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, 
New_Vaccinations, RollingPeopleVaccinated)
as
(select deaths.continent,deaths.location,deaths.date,
deaths.population,
cast(vaccine.new_vaccinations as unsigned integer) as new_vaccinations,
sum(cast(vaccine.new_vaccinations as  unsigned int))over
(partition by deaths.location
 order by deaths.location, str_to_date(deaths.date,'%m/%d/%Y') ) 
as Rolling_Vaccinations
from portfolio_project.covid_deaths deaths
join  portfolio_project.covid_vaccinations vaccine
on deaths.location=vaccine.location
and deaths.date =vaccine.date
where deaths.continent not like ''
)
Select *, 
round((RollingPeopleVaccinated/Population)*100,2) as percentage_vaccinated
From PopvsVac;



-- Creating View to store data for later visualizations

Create View vaccinatedpercentage as
select deaths.continent,deaths.location,
str_to_date(deaths.date,"%m/%d/%Y") as new_date,
deaths.population,
cast(vaccine.new_vaccinations as unsigned integer) as new_vaccinations,
sum(cast(vaccine.new_vaccinations as  unsigned int))over
(partition by deaths.location
 order by deaths.location, str_to_date(deaths.date,"%m/%d/%Y") ) 
as Rolling_Vaccinations
from portfolio_project.covid_deaths deaths
join  portfolio_project.covid_vaccinations vaccine
on deaths.location=vaccine.location
and deaths.date =vaccine.date
where deaths.continent not like '';










