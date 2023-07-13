/*

Cleaning Data in SQL Queries

*/


SELECT *
FROM Portfolio_Project..Nashville_Housings

-- Standardize Data Format
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM Portfolio_Project..Nashville_Housings

UPDATE Nashville_Housings
SET SaleDate = CONVERT(Date,SaleDate) --This query does not work for some reasons

ALTER TABLE Nashville_Housings
ADD SaleDateConverted Date;

UPDATE Nashville_Housings
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM Portfolio_Project..Nashville_Housings
--That fixed the problem with the SaleDate columns


---------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address data
SELECT *
FROM Portfolio_Project..Nashville_Housings
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID 
-- This query is to see if when ParcelID is the same, is there any case where Property Address is Null, if there is, populate the address and fix the NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio_Project..Nashville_Housings AS a
JOIN Portfolio_Project..Nashville_Housings AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Update the NULL property address
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio_Project..Nashville_Housings AS a
JOIN Portfolio_Project..Nashville_Housings AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


------------------------------------------------------------------------------

--Breaking out Address into Indivual Columns (Address, City, State)

SELECT PropertyAddress
FROM Portfolio_Project..Nashville_Housings
--ORDER BY ParcelID 


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) AS Address --This is looking at the property address only (it breaks the information from the 1 index to after the comma)
, CHARINDEX(',',PropertyAddress) --This shows the comma sign index

FROM Portfolio_Project..Nashville_Housings



SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address --This is looking at the property address but doesn't include the comma

FROM Portfolio_Project..Nashville_Housings


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address --This is to get the address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))  AS City --This is to get the city ("+1" is to exclude the comma from the result we want to see)

FROM Portfolio_Project..Nashville_Housings


--Update the breakdowned address
ALTER TABLE Nashville_Housings
ADD Property_Split_Address NVARCHAR(255);
UPDATE Nashville_Housings
SET Property_Split_Address = CONVERT(NVARCHAR,SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1))


ALTER TABLE Nashville_Housings
ADD Property_Split_City NVARCHAR(255);
UPDATE Nashville_Housings
SET Property_Split_City = CONVERT(NVARCHAR,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)))


--Check if the address splitting is successful 
SELECT *
FROM Portfolio_Project..Nashville_Housings








SELECT OwnerAddress
FROM Portfolio_Project..Nashville_Housings


--Use Parsename to split OwnerAddress
SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Owner_Split_Address
,PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS Owner_Split_City
,PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS Owner_Split_State
FROM Portfolio_Project..Nashville_Housings


ALTER TABLE Portfolio_Project..Nashville_Housings
ADD Owner_Split_Address NVARCHAR(255);
UPDATE Portfolio_Project..Nashville_Housings
SET Owner_Split_Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE Portfolio_Project..Nashville_Housings
ADD Owner_Split_City NVARCHAR(255);
UPDATE Portfolio_Project..Nashville_Housings
SET Owner_Split_City = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE Portfolio_Project..Nashville_Housings
ADD Owner_Split_State NVARCHAR(255);
UPDATE Portfolio_Project..Nashville_Housings
SET Owner_Split_State = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--Check if the table is updated
SELECT *
FROM Portfolio_Project..Nashville_Housings





------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field


--See how many distinct values in SoldAsVacant
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio_Project..Nashville_Housings
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
	CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Portfolio_Project..Nashville_Housings

--Update the table
UPDATE Portfolio_Project..Nashville_Housings
SET SoldAsVacant = (CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END)

--Check whether the table is updated correctly
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio_Project..Nashville_Housings
GROUP BY SoldAsVacant



------------------------------------------------------------------------

--Remove Duplicates (We don't often delete data permanently when working as a data analyst) -- But we are doing it in this project
WITH Row_Num_CTE AS(
SELECT *, 
	ROW_NUMBER() OVER ( PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num 
	--That to create a column show the number of duplicate values (using window function)
FROM Portfolio_Project..Nashville_Housings
)

--Check duplicate rows
SELECT *
FROM Row_Num_CTE
WHERE row_num <> 1


--Delete Duplicate
WITH Row_Num_CTE AS(
SELECT *, 
	ROW_NUMBER() OVER ( PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num 
	--That to create a column show the number of duplicate values (using window function)
FROM Portfolio_Project..Nashville_Housings
)
DELETE
FROM Row_Num_CTE
WHERE row_num <> 1


--Check whether the duplicate rows were deleted 
WITH Row_Num_CTE AS(
SELECT *, 
	ROW_NUMBER() OVER ( PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num 
	--That to create a column show the number of duplicate values (using window function)
FROM Portfolio_Project..Nashville_Housings
)
SELECT *
FROM Row_Num_CTE
WHERE row_num <> 1


--There is none duplicate rows left



---------------------------------------------------------------------------------------------------------------

--Delete Unsued Columns (This doesn't happen often in real life, we do this in VIEW(when we look at the data))

SELECT *
FROM Portfolio_Project..Nashville_Housings


ALTER TABLE Portfolio_Project..Nashville_Housings
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict


-------------------------------------------------
--Project Finished-------------------------------
-------------------------------------------------










--This part is for the practicing purpose
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO