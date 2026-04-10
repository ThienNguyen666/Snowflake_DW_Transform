select
    productid,
    name as product_name,
    productsubcategoryid,
    standardcost,
    listprice
from {{ source('raw', 'PRODUCT') }}