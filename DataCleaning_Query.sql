--Data Cleaning

SELECT * 
FROM PortfolioProject..NashvilleHousing;


--Standardizing Date Format

SELECT SaleDate
FROM PortfolioProject..NashvilleHousing;

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashVilleHousing
ADD SaleDateConverted Date

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted =  CONVERT(Date, SaleDate);

SELECT SaleDateConverted
FROM PortfolioProject..NashvilleHousing


--Populate Property Address

SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Breaking Out Address In indivdual Columns(Address, City, State)

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) ,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET SplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE NashvilleHousing
ADD SplitCity nvarchar(255)

UPDATE NashvilleHousing
SET SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

--View the Newly created Columns
--SELECT PropertyAddress, SplitAddress, SplitCity
--FROM NashvilleHousing

--Seperate Owner address
--SELECT OwnerAddress, 
--PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
--PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
--PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
--FROM PortfolioProject..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerAddressSplit nvarchar(255),
    OwnerCitySplit nvarchar(255),
	OwnerStateSplit nvarchar(255);

UPDATE NashvilleHousing
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
    OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
    OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress,',','.'), 1);

--SELECT OwnerAddress, OwnerAddressSplit, OwnerCitySplit, OwnerStateSplit
--FROM NashvilleHousing;

/*Change Y and N to Yes and No */
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant, 
CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

--remove duplicates

SELECT *, ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					PropertyAddress,
					Saledate, 
					SalePrice,
					LegalReference
					ORDER BY 
						UniqueID
					) AS row_num
FROM PortfolioProject..NashvilleHousing


WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					PropertyAddress,
					Saledate, 
					SalePrice,
					LegalReference
					ORDER BY 
						UniqueID
					) AS row_num
FROM PortfolioProject..NashvilleHousing
)
DELETE
--SELECT *
FROM RowNumCTE
WHERE row_num > 1;

--DELETE unused columns
SELECT *
--SELECT SaleDate, OwnerAddress, TaxDistrict, PropertyAddress 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress