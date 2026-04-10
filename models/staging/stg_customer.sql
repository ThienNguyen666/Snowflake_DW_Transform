select
    customerid,
    personid,
    storeid,
    territoryid,
    accountnumber,
    modifieddate
from {{ source('raw', 'CUSTOMER') }}