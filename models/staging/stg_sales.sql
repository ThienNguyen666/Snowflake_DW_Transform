with d as (
    select *
    from {{ source('raw', 'SALESORDERDETAIL') }}
),

h as (
    select *
    from {{ source('raw', 'SALESORDERHEADER') }}
)

select
    d.salesorderid,
    d.productid,
    h.customerid,
    h.orderdate,
    d.orderqty,
    d.unitprice,
    d.linetotal

from d
join h
    on d.salesorderid = h.salesorderid