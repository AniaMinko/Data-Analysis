Select *
From PortfolioProject..NashvilleHousing


-- Standardize Date Formant
Select SaleDateConverted
From PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

ALTER TABLE PortfolioProject..NashvilleHousing
Add SaleDateConverted Date;

-- Populate Property Address data
Select *
From PortfolioProject..NashvilleHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b 
	on(a.ParcelID = b.ParcelID 
	and a.[UniqueID ] <> b.[UniqueID ])
Where a.PropertyAddress is null

Update a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b 
	on(a.ParcelID = b.ParcelID 
	and a.[UniqueID ] <> b.[UniqueID ])
Where a.PropertyAddress is null



-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress, PropertySplitAddress, PropertySplitCity
From PortfolioProject..NashvilleHousing

Select PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 


ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) as State
from PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerState Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerState
from PortfolioProject..NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
SET SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end



-- Remove duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				   UniqueID) row_num
FROM PortfolioProject..NashvilleHousing )
select * --delete
FROM RowNumCTE
where row_num > 1


-- delete unused columns

select *
from PortfolioProject..NashvilleHousing 


ALTER TABLE PortfolioProject..NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing 
DROP COLUMN SaleDate