use portfolio_project;
show variables like "local_infile";
set@@GLOBAL.local_infile = 'ON';
set sql_mode='';
create table Nashville_Housing (UniqueID int ,ParcelID text ,
LandUse text, PropertyAddress text ,SaleDate Text,SalePrice int,
LegalReference text,SoldAsVacant text, OwnerName text,OwnerAddress text,
Acreage double,TaxDistrict text,LandValue int,BuildingValue int,
TotalValue int, YearBuilt int, Bedrooms int, FullBath int ,HalfBath int);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Nashville_Housing_Data.csv'
INTO TABLE portfolio_project.Nashville_Housing
FIELDS TERMINATED BY ","
optionally enclosed by '"'
LINES TERMINATED BY "\n"
ignore 1 lines
(@UniqueID,@ParcelID,@LandUse,@PropertyAddress,@SaleDate,
@SalePrice,@LegalReference,@SoldAsVacant,@OwnerName,
@OwnerAddress,@Acreage,@TaxDistrict,@LandValue,
@BuildingValue,@TotalValue,@YearBuilt,@Bedrooms,
@FullBath,@HalfBath)
set 
 UniqueID=if (@UniqueID='',NULL,@UniqueID),
 ParcelID=if (@ParcelID='',NULL,@ParcelID),
 LandUse=if (@LandUse='',NULL,@LandUse),
 PropertyAddress=if (@PropertyAddress='',NULL,@PropertyAddress),
 SaleDate=if (@SaleDate='',NULL,@SaleDate),
 SalePrice=if (@SalePrice='',NULL,@SalePrice),
 LegalReference=if (@LegalReference='',NULL,@LegalReference),
 SoldAsVacant=if (@SoldAsVacant='',NULL,@SoldAsVacant),
 OwnerName=if (@OwnerName='',NULL,@OwnerName),
 OwnerAddress=if (@OwnerAddress='',NULL,@OwnerAddress),
 Acreage=if (@Acreage='',NULL,@Acreage),
 TaxDistrict=if (@TaxDistrict='',NULL,@TaxDistrict),
LandValue=if (@LandValue='',NULL,@LandValue),
 BuildingValue=if (@BuildingValue='',NULL,@BuildingValue),
 TotalValue=if (@TotalValue='',NULL,@TotalValue),
 YearBuilt=if (@YearBuilt='',NULL,@YearBuilt),
 Bedrooms=if (@Bedrooms='',NULL,@Bedrooms),
 FullBath=if (@FullBath='',NULL,@FullBath),
 HalfBath=if (@HalfBath='',NULL,@HalfBath)
;

select  * from Nashville_Housing;

-- Cleaning data with SQL queries
-- Standardize date format
select SaleDate,str_to_date(SaleDate,"%M %e, %Y") from portfolio_project.nashville_housing;

Alter table Nashville_Housing 
Add Column ConvertedSaleDate Date;

update Nashville_Housing 
set ConvertedSaleDate=str_to_date(SaleDate,"%M %e, %Y");

-- Populate Property Address
select  * from Nashville_Housing where PropertyAddress is null;

select a.PropertyAddress,a.ParcelID,b.PropertyAddress,b.ParcelID
from Nashville_Housing a
join Nashville_Housing b
on 
a.ParcelID=b.ParcelID
and
a.UniqueID<> b.UniqueID
where a.PropertyAddress is null;

update  Nashville_Housing a
join Nashville_Housing b 
on 
a.ParcelID=b.ParcelID
and
a.UniqueID<> b.UniqueID
set a.PropertyAddress=b.PropertyAddress
where a.PropertyAddress is null;

-- Breaking out Address into individual columns(Address , City, State)
select  PropertyAddress from Nashville_Housing;

select substring_index(PropertyAddress,',',1) as Address,
substring_index(PropertyAddress,',',-1) as City
from Nashville_Housing;

Alter table Nashville_Housing 
Add column PropertySplitAddress text,
Add column PropertySplitCity text;

update  Nashville_Housing 
set 
PropertySplitAddress=substring_index(PropertyAddress,',',1),
PropertySplitCity=substring_index(PropertyAddress,',',-1) ;

select OwnerAddress from Nashville_Housing;

select substring_index(OwnerAddress,",",1) as address,
substring_index(substring_index(OwnerAddress,",",2),",",-1) as City,
substring_index(OwnerAddress,",",-1) as State
from Nashville_Housing;

alter table NAshville_Housing
Add column OwnerSplitAddress text,
Add column OwnerSplitCity text,
Add column OwnerSplitState text;

update Nashville_Housing
set 
OwnerSplitAddress=substring_index(OwnerAddress,",",1),
OwnerSplitCity=substring_index(substring_index(OwnerAddress,",",2),",",-1),
OwnerSplitState=substring_index(OwnerAddress,",",-1);

-- Change Y and N in SoldAsVacant feild to Yes and NO

select  distinct SoldAsVacant,count(SoldAsVacant) from Nashville_Housing 
group by SoldAsVacant;

select SoldAsVacant ,
case 
when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant ='N' then 'No'
else SoldAsVacant
end as casevacant
from Nashville_Housing;

update Nashville_Housing 
set 
SoldAsVacant=
case 
when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant ='N' then 'No'
else SoldAsVacant
end;

-- Remove Duplicates

with rownumcte as 
(
select * ,
row_number()over(
partition by
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
order by 
UniqueID) as row_num
from Nashville_Housing
)
delete  from Nashville_Housing 
using 
Nashville_Housing 
join 
rownumcte
on
Nashville_Housing.UniqueID=rownumcte.UniqueID
   where rownumcte.row_num>1 ;







