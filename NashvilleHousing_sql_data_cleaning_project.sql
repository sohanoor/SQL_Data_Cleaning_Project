select *
from PortfolioProject..NashvilleHousing


-----------------------------------------------------
-- Standardize Date Formate

--try to convert the existing column
select SaleDate, CONVERT(Date, SaleDate)
from PortfolioProject..NashvilleHousing

--create a new column
ALTER TABLE NashvilleHousing
add SaleDateConverted Date;

-- add value to new column
Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--check the new column
select SaleDateConverted
from PortfolioProject..NashvilleHousing

--check the table [ just in case ] 
select *
from PortfolioProject..NashvilleHousing


-----------------------------------------------------
-- Populate Property address data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

-- compare uniqe id and parcel id, find null property address, replace it

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- update the PropertyAddress column
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--check the table
select *
from PortfolioProject..NashvilleHousing
where PropertyAddress is null
order by ParcelID
--[output is empty means it worked]

-----------------------------------------------------

-- Breaking out PropertyAddress into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProject..NashvilleHousing

-- fist find the data as expected 
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, --took index 1, seperate by comma (,), remove (,) using -1
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address 
from PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255); -- create new column

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) -- put value to new column

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255); -- create new column

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) -- put value to new column


--check column in table 
select PropertyAddress, PropertySplitAddress, PropertySplitCity
from PortfolioProject..NashvilleHousing

-- check full table (just in case)
select *
from PortfolioProject..NashvilleHousing

-- style 2

select OwnerAddress
from PortfolioProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255); -- create new column

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) -- put value to new column

ALTER TABLE NashvilleHousing
Add OwnerSpliCity Nvarchar(255); -- create new column

Update NashvilleHousing
SET OwnerSpliCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) -- put value to new column

ALTER TABLE NashvilleHousing
Add OwnerSpliState Nvarchar(255); -- create new column

Update NashvilleHousing
SET OwnerSpliState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) -- put value to new column

-- check again
select OwnerAddress, OwnerSplitAddress, OwnerSpliCity, OwnerSpliState
from PortfolioProject..NashvilleHousing


-- check full table (just my habit)
select *
from PortfolioProject..NashvilleHousing


-----------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" Field

select SoldAsVacant
from PortfolioProject..NashvilleHousing

--let's do some digging 
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant 
order by 2

-- replacr Y and N
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- checking data
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant 
order by 2

Select *
from PortfolioProject..NashvilleHousing


-----------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS (
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
from PortfolioProject..NashvilleHousing
--Order by ParcelID
)
DELETE
From RowNumCTE
where row_num >1


Select *
from PortfolioProject..NashvilleHousing


-----------------------------------------------------
-- Remove Unused Columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate

Select *
from PortfolioProject..NashvilleHousing