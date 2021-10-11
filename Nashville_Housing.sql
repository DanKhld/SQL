--Data Cleaning project

select * 
from NashvilleHouse;

-- Standardizing Date format

select SaleDate, CONVERT(Date, SaleDate) AS Date
from NashvilleHouse;

ALTER TABLE NashvilleHouse
ADD SalesDate2 Date;

Update NashvilleHouse
SET SalesDate2 =  CONVERT(Date, SaleDate);

Select SalesDate2 
from NashvilleHouse;


-- Populate Property Address data
Select PropertyAddress
From NashvilleHouse
order by ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) --ISNULL(col that is null, populate with)
From NashvilleHouse a
JOIN NashvilleHouse b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID] --Same PacelID but not Same UniqueID
Where a.PropertyAddress is null;

Update a 
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHouse a
JOIN NashvilleHouse b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID] 
Where a.PropertyAddress is null


-- Breaking out Address into Individual columns (Address, City, State)
Select PropertyAddress
From NashvilleHouse;

--separate from delimeter
Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From NashvilleHouse;

ALter Table NashvilleHouse
Add PropertySplitAddress Varchar(225);

Alter Table NashvilleHouse
Add PropertySplitCity Varchar(225);

Update NashvilleHouse
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

Update NashvilleHouse
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

SELECT * From NashvilleHouse;

-- Split Owner Address

Select OwnerAddress
From NashvilleHouse;

Select PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
, PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
, PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From NashvilleHouse;

Alter Table NashvilleHouse
Add OwnerSplitAddress varchar(225);

Alter Table NashvilleHouse
Add OwnerSplitCity varchar(225);

Alter Table NashvilleHouse
Add OwnerSplitState varchar(225);

Update NashvilleHouse
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3);

Update NashvilleHouse
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2);

Update NashvilleHouse
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1);

Select * 
From NashvilleHouse;

-- Change Y and N to Yes and No in 'Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHouse
Group by SoldAsVacant
Order by 2;

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant 
		End
From NashvilleHouse;

Update NashvilleHouse
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant 
		End;
	
-- Remove Duplicates

With RowNumCte as(
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID, 
				PropertyAddress, 
				SalePrice, 
				SaleDate, 
				LegalReference
				Order by UniqueID
				) row_num
From NashvilleHouse)
Delete
From RowNumCte
Where row_num > 1


--Delete Unused Columns (Use this for views)

Alter Table NashvilleHouse
Drop Column OwnerAddress, TaxDistrict, PropertyAddress;

Alter Table NashvilleHouse
Drop Column SaleDate;

