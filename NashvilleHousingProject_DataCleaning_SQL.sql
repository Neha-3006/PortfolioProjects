--Cleaning data with SQL queries

select * 
from PortfolioProject.dbo.NashvilleHousing;

--Standardize date format

select SaleDate, CONVERT(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing 
ALTER COLUMN SaleDate DATE

---------------------------------------------------------------------------------------------------------------------------------
--Populate Property Address Data

select h1.parcelID, h1.propertyaddress, h2.parcelid, h2.propertyaddress, ISNULL(h1.propertyaddress, h2.propertyaddress)
from PortfolioProject.dbo.NashvilleHousing h1
join
PortfolioProject.dbo.NashvilleHousing h2
on h1.ParcelID= h2.ParcelID AND h1.UniqueID<>h2.UniqueID
where h1.propertyaddress is null

update h1
set propertyaddress= ISNULL(h1.propertyaddress, h2.propertyaddress)
from PortfolioProject.dbo.NashvilleHousing h1
join
PortfolioProject.dbo.NashvilleHousing h2
on h1.ParcelID= h2.ParcelID AND h1.UniqueID<>h2.UniqueID
where h1.propertyaddress is null

---------------------------------------------------------------------------------------------------------------------------------
--Breaking out Address into individual columns (Address, City, State)

select propertyaddress
from PortfolioProject.dbo.NashvilleHousing

select 
substring (propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) as address
from PortfolioProject.dbo.NashvilleHousing;

select 
substring (propertyaddress, CHARINDEX(',',propertyaddress)+1, len(propertyaddress)) as city
from PortfolioProject.dbo.NashvilleHousing;

Alter table NashvilleHousing
add PropertySplitAddress NVARCHAR(255)

Update NashvilleHousing
set PropertySplitAddress= substring (propertyaddress, 1, CHARINDEX(',',propertyaddress)-1)

Alter table NashvilleHousing
add PropertySplitCity NVARCHAR(255)

Update NashvilleHousing
set PropertySplitCity =substring (propertyaddress, CHARINDEX(',',propertyaddress)+1, len(propertyaddress))

select 
PARSENAME(replace(owneraddress,',','.'),3) as OwnerSplitAddress,
PARSENAME(replace(owneraddress,',','.'),2) as OwnerSplitCity,
PARSENAME(replace(owneraddress,',','.'),1) as OwnerSplitState
from NashvilleHousing

Alter table NashvilleHousing
add OwnerSplitAddress NVARCHAR(255);
Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(owneraddress,',','.'),3);


Alter table NashvilleHousing
add OwnerSplitCity NVARCHAR(255);
Update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(owneraddress,',','.'),2);

Alter table NashvilleHousing
add OwnerSplitState NVARCHAR(255);
Update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(owneraddress,',','.'),3);

-----------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "SoldAsVacant"

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant= 'Y' then 'Yes'
       when SoldAsVacant= 'N' then 'No'
	   else SoldAsVacant
	   end
from PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant= case when SoldAsVacant= 'Y' then 'Yes'
					   when SoldAsVacant= 'N' then 'No'
					   else SoldAsVacant
					   end

---------------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates

with row_numCTE as (
select *,
	ROW_NUMBER() over (
	partition by parcelid,
				 propertyaddress,
				 saledate,
				 saleprice,
				 legalreference
				 order by 
					uniqueid
					) row_num						
from PortfolioProject.dbo.NashvilleHousing
)

/* select *
from row_numCTE
where row_num>1
order by ParcelID */

delete
from row_numCTE
where row_num>1
--order by ParcelID

-----------------------------------------------------------------------------------------------------------------------------------
--Delete unused columns

select *
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column owneraddress,
			taxdistrict,
			propertyaddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column saledate

