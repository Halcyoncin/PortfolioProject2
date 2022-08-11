--Cleaning Data in SQL Queries


Select *
From Portfolio_project.dbo.NashvilleHousing

--Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate)
From Portfolio_project.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

--Populate Property Address Data--finding NULL property addresses and using ParcelID to populate them

Select *
From Portfolio_project.dbo.NashvilleHousing
--WHERE PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_project.dbo.NashvilleHousing a
JOIN Portfolio_project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_project.dbo.NashvilleHousing a
JOIN Portfolio_project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null--when this is all executed, there are no results, which means this query worked!

--Breaking Out Address into Individual Columns (Address, City, State)
--Using Substrings
Select PropertyAddress
From Portfolio_project.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--Order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address  --this gets rid of comma in address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address

From Portfolio_project.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From Portfolio_project.dbo.NashvilleHousing

--Breaking Down the Address Using Parsename

Select OwnerAddress
From Portfolio_project.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)--replacing comma with a period so parsename works
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
From Portfolio_project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


--Change Y and N to Yes and No in "Sold as Vacant" Field

USE Portfolio_project;--making sure I'm in the correct database

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From Portfolio_project.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant 
	   END
From Portfolio_project.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	     When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant 
		 END


--Removing Duplicate Entries

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
From Portfolio_project.dbo.NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


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
From Portfolio_project.dbo.NashvilleHousing
--Order by ParcelID
)
DELETE 
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



--Deleting Unused Columns


ALTER TABLE Portfolio_project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict

ALTER TABLE Portfolio_project.dbo.NashvilleHousing
DROP COLUMN SaleDate