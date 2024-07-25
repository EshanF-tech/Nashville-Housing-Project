
# Cleaning Data in SQL Queries

alter table `nashville housing data for data cleaning` rename to nashvillehousing;

select *
from nashvillehousing
;

-- standardize format

select saledate, STR_TO_DATE(saledate, '%M %d, %Y') as formatted_date
from nashvillehousing;

update nashvillehousing
set saledate = STR_TO_DATE(saledate, '%M %d, %Y')
;

update nashvillehousing
set propertyaddress = null
where propertyaddress = ''
;

update nashvillehousing
set owneraddress = null
where owneraddress = ''
;

ALTER TABLE nashvillehousing
CHANGE LanUse LandUse NVARCHAR(255);


-- Populate Property Address rows

select uniqueid, propertyaddress
from nashvillehousing
where propertyaddress is null
;

select *
from nashvillehousing
order by parcelid;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.propertyaddress, b.propertyaddress)
from nashvillehousing a
join nashvillehousing b
	on a.ParcelID = b.ParcelID
    and a.UniqueID != b.uniqueID
where a.propertyaddress is null
;

update nashvillehousing a
join nashvillehousing b
	on a.ParcelID = b.ParcelID
    and a.UniqueID != b.uniqueID
set a.propertyaddress = ifnull(a.propertyaddress, b.propertyaddress)
where a.propertyaddress is null
;


-- Breaking out Address into Invdividual Columns (Address, City, State)

select propertyaddress
from nashvillehousing
;


SELECT 
    CASE 
        WHEN INSTR(propertyaddress, ',') > 0 
        THEN SUBSTRING(propertyaddress, 1, INSTR(propertyaddress, ',') - 1) 
        ELSE propertyaddress 
    END AS Address,
    CASE 
		WHEN INSTR(propertyaddress, ',') > 0 
         THEN SUBSTRING(propertyaddress, INSTR(propertyaddress, ',') + 1,  LENGTH(propertyaddress))
        ELSE propertyaddress 
	END as Address
FROM nashvillehousing;

alter table nashvillehousing 
 add PropertySplitAddress Nvarchar(255)
;

update nashvillehousing
 set propertysplitAddress = SUBSTRING(propertyaddress, 1, INSTR(propertyaddress, ',') - 1) 
;


alter table nashvillehousing 
 add PropertySplitCity Nvarchar(255)
;

update nashvillehousing
 set PropertySplitCity = SUBSTRING(propertyaddress, INSTR(propertyaddress, ',') + 1,  LENGTH(propertyaddress))
;

select *
from nashvillehousing
;

select owneraddress
from nashvillehousing
;

select 
substring_index(REPLACE(owneraddress, ',', '.'), '.', -3),
substring_index(REPLACE(owneraddress, ',', '.'), '.', -2),
substring_index(REPLACE(owneraddress, ',', '.'), '.', -1) 
from nashvillehousing;

SELECT 
    SUBSTRING_INDEX(owneraddress, ',', 1) AS OwnerSplitAddress,
    SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1) AS OwnerSplitCity,
    SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 3), ',', -1) AS OwnerSplitState
FROM 
    nashvillehousing;


alter table nashvillehousing 
 add OwnerSplitAddress Nvarchar(255)
;

update nashvillehousing
 set OwnerSplitAddress = SUBSTRING_INDEX(owneraddress, ',', 1)
;


alter table nashvillehousing 
 add OwnerSplitCity Nvarchar(255)
;

update nashvillehousing
 set OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1)
;

alter table nashvillehousing 
 add OwnerSplitState Nvarchar(255)
;

update nashvillehousing
 set OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 3), ',', -1)
;


select *
from nashvillehousing
;

-- Change Y and N to Yes and No in "Sold as Vavant" field

select distinct(soldasvacant), count(soldasvacant)
from nashvillehousing
group by soldasvacant
order by 2
;


select soldasvacant,
	case
		when soldasvacant = 'Y' then 'Yes'
        when soldasvacant = 'N' then 'No'
        else soldasvacant
	end
from nashvillehousing
;


update nashvillehousing
	set soldasvacant = 
		case
			when soldasvacant = 'Y' then 'Yes'
			when soldasvacant = 'N' then 'No'
			else soldasvacant
		end 
;


-- remove duplicates

WITH rownumcte AS (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY parcelid,
                            propertyaddress,
                            saleprice,
                            saledate,
                            legalreference
               ORDER BY uniqueid
           ) AS row_num
    FROM nashvillehousing
)
select *
FROM rownumcte
where row_num > 1 
order by propertyaddress
;

WITH rownumcte AS (
    SELECT uniqueid,
           ROW_NUMBER() OVER(
               PARTITION BY parcelid,
                            propertyaddress,
                            saleprice,
                            saledate,
                            legalreference
               ORDER BY uniqueid
           ) AS row_num
    FROM nashvillehousing
)
DELETE FROM nashvillehousing
WHERE uniqueid IN (
    SELECT uniqueid
    FROM rownumcte
    WHERE row_num > 1
);


-- delete unused columns

select *
from nashvillehousing
;

ALTER TABLE nashvillehousing
DROP COLUMN owneraddress,
DROP COLUMN TaxDistrict,
DROP COLUMN propertyaddress;

















