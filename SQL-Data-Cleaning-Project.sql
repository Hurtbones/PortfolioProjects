/*
Nashville Housing Data Cleaning Project

Skills used: Joins, CTE's, Window functions, Case statements, Converting data types, Table alteration

*/


-- Cleaning data in SQL Queries

-- Pulling data to see if it imported correctly


Select *
From PortfolioProject..NashvilleHousing

------------------------------------------------------------------------------


-- Standardize Date Format

-- Convert current datetime format into standard date format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing

-- Atempt to update SaleDate column in table, could not make work for me. Try it out and see if it works for you! 

Update PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- Alternative solution using Alter Table to add new SaleDateConverted column, then updating table to populate new column

ALTER TABLE PortfolioProject..NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

------------------------------------------------------------------------------------

-- Populate Property Address Data

-- Using "is null" in the where clause to find all null Property Address values (I just commented it out after so I didn't have to do any retyping, copy + paste ftw)
-- Ordered by Parcel ID to see where duplicate ID's exist

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

-- Populating property address on duplicate Parcel ID's using self-join

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Updating table to fill in property addresses where nulls were
-- After successfully updating run above query to check, should return nothing if successful

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

-- Using a substring and charindex to seperate address column

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City

From PortfolioProject..NashvilleHousing

-- Creating two new columns to populate new address and city values into

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

-- City

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



-- Using parsename to split owner address into address, city, and state
-- 'Replace' argument is to switch out commas for periods so parsename will function correctly

Select OwnerAddress
From PortfolioProject..NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing


-- Adding columns and updating table to add values

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)





-------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

--Seeing how many Y's and N's we have

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

--Changing them to Yes and No

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject..NashvilleHousing




Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-----------------------------------------------------------------------------------

-- Remove Duplicates
-- Partitioning data points to find duplicate rows and creating CTE


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

From PortfolioProject..NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate