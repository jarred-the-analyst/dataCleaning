-- correcting the landuse column wear the wording is different but its the same refrence.
select replace(landuse, 'VACANT RES LAND', 'VACANT RESIDENTIAL LAND')
from nashville_housing
where landuse like '%Va%';

update nashville_housing
set landuse=replace(landuse, 'VACANT RES LAND', 'VACANT RESIDENTIAL LAND');

select landuse
from nashville_housing
where landuse like '%Va%';
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
-- converting the timestamp to format it where it is just the date. the time column is empty wtih zeros and unnessary.
select 
	convert(saledate, date) as saledate
from
	nashville_housing;
    
alter table nashville_housing
add SaleDates date;

update  nashville_housing
set SaleDates=date(SaleDate);

alter table nashville_housing
drop column SaleDate;
    
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
-- the PropertyAddress is both the address and state I want to seprate this into a state colum and a address column.
select 
	substring(PropertyAddress,1,locate(',',PropertyAddress)-1) as street_adress,
	substring(PropertyAddress, locate(',', PropertyAddress)+2, length(PropertyAddress)) as state
from 
	nashville_housing;
    
alter table nashville_housing
add  street_adress varchar(255),
add state varchar(255);

update nashville_housing
set street_adress=substring(PropertyAddress,1,locate(',',PropertyAddress)-1),
state=substring(PropertyAddress, locate(',', PropertyAddress)+2, length(PropertyAddress));

alter table nashville_housing
drop column PropertyAddress;
    
-- -------------------------------------------------------------------------------------------------------------------------------------------------------
-- seperating state , city , and address from the owner column
select 
	substring(OwnerAddress,locate(',', OwnerAddress)+ 1,
    locate( ',',OwnerAddress,locate(',',OwnerAddress)+1)-locate(',', OwnerAddress)-1) as city,
    substring(OwnerAddress,1,locate(',',OwnerAddress)-1) as address,
    substring(OwnerAddress,locate(',' ,OwnerAddress,locate(',',OwnerAddress)+1)+1, length(OwnerAddress)) as st,
    street_adress,
    state
from 
	nashville_housing
where state is null;

alter table nashville_housing
add owner_city varchar(255), 
add owner_address varchar(255), 
add	owner_state varchar(255);

update nashville_housing
set owner_city=substring(OwnerAddress,locate(',', OwnerAddress)+ 1,locate( ',',OwnerAddress,locate(',',OwnerAddress)+1)-locate(',', OwnerAddress)-1),
owner_address=substring(OwnerAddress,1,locate(',',OwnerAddress)-1),
owner_state=substring(OwnerAddress,locate(',' ,OwnerAddress,locate(',',OwnerAddress)+1)+1, length(OwnerAddress));



-- -----------------------------------------------------------------------------------------------------------------------------------------------------------
-- replacing the null address values. the values that had the same parcelid had the same address I match the the parcelid that had address to ones that did not
-- and changed the null address.
select 
	nh1.ParcelID,  nh1.street_adress, nh2.ParcelID, nh2.street_adress, IfNULL(nh1.street_adress, nh2.street_adress) 
from 
	nashville_housing as nh1 join nashville_housing as nh2 on nh1.ParcelID=nh2.ParcelID
	and nh1.uniqueID<>nh2.uniqueID;
    
update nashville_housing as  nh1
join nashville_housing as nh2 on nh1.ParcelID=nh2.ParcelID
	and nh1.uniqueID<>nh2.uniqueID
set nh1.street_adress=IfNULL(nh1.street_adress, nh2.street_adress),
	nh1.state=ifnull(nh1.state, nh2.state)
where 
	nh1.street_adress is null;

    
-- -----------------------------------------------------------------------------------------------------------------------------------------------------
-- soldasvacant changing the column to have the same format Y and N will be turned into yes and no    
update nashville_housing
set soldasvacant=replace(replace(soldasvacant,'N','NO'), 'NOO', 'NO'),
soldasvacant=replace(replace(soldasvacant, 'Y','Yes'),'yeses','YES');

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------
-- remove duplicates
with tmp as
(select *,
	row_number() over (partition by ParcelID,SaleDates,street_adress,LegalReference,SalePrice) as duplicates
from 
	nashville_housing)

delete 
from tmp
where duplicates > 1;

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------



	
	
