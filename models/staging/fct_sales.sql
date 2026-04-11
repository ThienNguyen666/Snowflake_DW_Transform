{{ config(materialized='view') }}

select
    s.salesorderid,
    s.productid,
    s.customerid,

    s.orderdate,
    t.date_key,

    s.orderqty,
    s.unitprice,
    s.linetotal

from {{ ref('stg_sales') }} s
left join {{ ref('dim_time') }} t
    on s.orderdate = t.date