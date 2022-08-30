use Portfolio
go

Select* from NationalHousing
--Editing Date
Select SaleDate,CONVERT(date,SaleDate,101) 
from NationalHousing
 --Alter Table  NationalHousing drop column SaleDateConverted
  Update NationalHousing 
  Set SaleDate=CONVERT(date,SaleDate,101) 

  Alter Table  NationalHousing Add 
 SaleDateConverted Date 
 Update NationalHousing 
  Set SaleDateConverted=CONVERT(date,SaleDate,101) 

 --Populate Adress
 
Select *, PropertyAddress from NationalHousing
--Where PropertyAddress IS NULL
WHERE ParcelID= '018 07 0 109.00'
oRDER BY ParcelID

Select a.PropertyAddress,a.ParcelID,b.PropertyAddress,b.ParcelID
from NationalHousing a
Join  NationalHousing b ON
a.ParcelID= b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--Replacing a.propertyAddress Null values to b.b.PropertyAddress
Select a.PropertyAddress,a.ParcelID,b.PropertyAddress,b.ParcelID ,ISNULL(a.PropertyAddress,b.PropertyAddress)
from NationalHousing a
Join  NationalHousing b ON
a.ParcelID= b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null
  Update a
  Set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
from NationalHousing a
Join  NationalHousing b ON
a.ParcelID= b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null
--cONFIRMING NULL are eliminated from PropertyAddress column
Select PropertyAddress  from NationalHousing
where PropertyAddress= '' or PropertyAddress is null

--Breaking out Adrress into(Adress, City, State)

Select *, PropertyAddress  from NationalHousing

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) as Address
from NationalHousing
--checking Charindex of (,)

select PropertyAddress, CHARINDEX(',',PropertyAddress) from NationalHousing
--Getting rid of the (,), we used -1
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as address
from NationalHousing


--Creating columns for the new splitted addrereses
 Alter Table  NationalHousing Add 
 PropertySplitAddress nvarchar(255)
 Update NationalHousing 
  Set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

   Alter Table  NationalHousing Add 
 PropertySplitCity nvarchar(255) 
 Update NationalHousing 
  Set  PropertySplitCity =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))



  --Splitting OwnerAddress
  --You can either use substring  or parsename to splitt 
  --parsename is used when we have (.) on the string that why I replaced (,) with (.)

  Select top 3 OwnerAddress  from NationalHousing

  Select PARSENAME(Replace(OwnerAddress,',','.'),3),
   PARSENAME(Replace(OwnerAddress,',','.'),2) ,
	 PARSENAME(Replace(OwnerAddress,',','.'),1) from NationalHousing


	 Alter Table  NationalHousing Add 
 OwnerSplitAddress nvarchar(255)

 Update NationalHousing 
  Set OwnerSplitAddress= PARSENAME(Replace(OwnerAddress,',','.'),3)



   Alter Table  NationalHousing Add 
 OwnerSplitCity nvarchar(255) 

 Update NationalHousing 
  Set  OwnerSplitCity =   PARSENAME(Replace(OwnerAddress,',','.'),2) 


   --Alter Table  NationalHousing drop column
 --OwnerSplitState  

    Alter Table  NationalHousing Add 
 OwnerSplitState nvarchar(255) 


 Update NationalHousing 
  Set  OwnerSplitState =   PARSENAME(Replace(OwnerAddress,',','.'),1) 


  Select*,SoldAsVacant from NationalHousing

  --Replacing N, Y with NO, YES
  Select  Distinct SoldAsVacant  from NationalHousing

    Select Distinct SoldAsVacant, Count( SoldAsVacant) from NationalHousing
	Group by SoldAsVacant
	
	Select SoldAsVacant,
	Case when SoldAsVacant= 'Y'then 'Yes'
	 when SoldAsVacant= 'N' then 'NO' else 
	 SoldAsVacant
	 End
	from NationalHousing

	update NationalHousing
	set SoldAsVacant= Case when SoldAsVacant= 'Y'then 'Yes'
	 when SoldAsVacant= 'N' then 'NO' else 
	 SoldAsVacant
	 End
	from NationalHousing

	--Removing duplicates

	  
--Creating A CTE to see the duplicates


Select *,
	ROW_NUMBER() over (
	partition by ParcelID,PropertyAddress, SalePrice, SaleDate,LegalReference
	Order by  UniqueID) row_num
from NationalHousing 
order by ParcelID

With RownumCTE AS  (
Select *,
	ROW_NUMBER() over (
	partition by ParcelID,PropertyAddress, SalePrice, SaleDate,LegalReference
	Order by  UniqueID) row_num
from dbo.NationalHousing)

Select* from 
RownumCTE
Where Row_num >1 
Order by propertyAddress

--Deleting the above duplicates

With RownumCTE AS  (
Select *,
	ROW_NUMBER() over (
	partition by ParcelID,PropertyAddress, SalePrice, SaleDate,LegalReference
	Order by  UniqueID) row_num
from dbo.NationalHousing)

Delete from 
RownumCTE
Where Row_num >1 
--Order by propertyAddress


--Deleting unused columns

Select * from NationalHousing

Alter table NationalHousing
Drop column OwnerAddress, TaxDistrict, propertyAddress
Alter table NationalHousing
Drop column saledate