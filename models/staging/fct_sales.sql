select
    salesorderid,
    productid,
    customerid,
    orderdate,
    orderqty,
    unitprice,
    linetotal
from {{ ref('stg_sales') }}