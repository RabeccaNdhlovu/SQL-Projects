
/*

Cleaning Data in SQL Queries

*/

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format 


select SaleDateConverted
from [Nashville Housing Data(Data Cleaning)]

select SaleDate, CONVERT (Date, SaleDate)
from [Nashville Housing Data(Data Cleaning)]

Update [Nashville Housing Data(Data Cleaning)]
SET SaleDate = CONVERT (Date, SaleDate)

--OR--

ALTER TABLE [Nashville Housing Data(Data Cleaning)]  
Add SaleDateConverted Date

Update [Nashville Housing Data(Data Cleaning)]   
SET SaleDateConverted = CONVERT (Date, SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select NHA.ParcelID, NHA.PropertyAddress, NHA1.ParcelID, NHA1.PropertyAddress, ISNULL(NHA.PropertyAddress, NHA1.PropertyAddress)
from [Nashville Housing Data(Data Cleaning)] NHA
JOIN[Nashville Housing Data(Data Cleaning)] NHA1
on  NHA.UniqueID <> NHA1.UniqueID
AND NHA.ParcelID = NHA1.ParcelID
where NHA.PropertyAddress is null

Update NHA
SET PropertyAddress = ISNULL(NHA.PropertyAddress, NHA1.PropertyAddress)
from [Nashville Housing Data(Data Cleaning)] NHA
JOIN[Nashville Housing Data(Data Cleaning)] NHA1
on  NHA.UniqueID <> NHA1.UniqueID
AND NHA.ParcelID = NHA1.ParcelID
where NHA.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

/* PropertyAddress*/

select
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))as Address
from [Nashville Housing Data(Data Cleaning)]

ALTER TABLE [Nashville Housing Data(Data Cleaning)]  
Add PropertyAddressSplitAddress Nvarchar(255)

Update [Nashville Housing Data(Data Cleaning)]   
SET PropertyAddressSplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE [Nashville Housing Data(Data Cleaning)]  
Add PropertyAddressSplitCity  Nvarchar(255)

Update [Nashville Housing Data(Data Cleaning)]   
SET PropertyAddressSplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


/*OwnerAddress*/

select 
PARSENAME(REPLACE (OwnerAddress, ',','.'), 3)
,PARSENAME(REPLACE (OwnerAddress, ',','.'), 2)
,PARSENAME(REPLACE (OwnerAddress, ',','.'), 1)
from [Nashville Housing Data(Data Cleaning)]


ALTER TABLE [Nashville Housing Data(Data Cleaning)]  
Add OwnerAddressSplitAddress Nvarchar(255)

Update [Nashville Housing Data(Data Cleaning)]   
SET OwnerAddressSplitAddress = PARSENAME(REPLACE (OwnerAddress, ',','.'), 3)


ALTER TABLE [Nashville Housing Data(Data Cleaning)]  
Add OwnerAddressSplitCity  Nvarchar(255)

Update [Nashville Housing Data(Data Cleaning)]   
SET OwnerAddressSplitCity = PARSENAME(REPLACE (OwnerAddress, ',','.'), 2)


ALTER TABLE [Nashville Housing Data(Data Cleaning)]  
Add OwnerAddressSplitState  Nvarchar(255)

Update [Nashville Housing Data(Data Cleaning)]   
SET OwnerAddressSplitState = PARSENAME(REPLACE (OwnerAddress, ',','.'), 1)



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select DISTINCT (SoldAsVacant), count (SoldAsVacant)
from [Nashville Housing Data(Data Cleaning)]
Group by SoldAsVacant
Order by 2

select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No' 
	 else SoldAsVacant
	 end
from [Nashville Housing Data(Data Cleaning)]

Update [Nashville Housing Data(Data Cleaning)]
SET SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No' 
	 else SoldAsVacant
	 end

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE as(
select *,
Row_NUMBER () OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY uniqueID ) row_num
from [Nashville Housing Data(Data Cleaning)]
-- order by ParcelID
)
Delete
from RowNumCTE
where row_num >1
--Order by PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE [Nashville Housing Data(Data Cleaning)]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

