with p as (
    select * from {{ ref('stg_product') }}
),

sc as (
    select *
    from {{ source('raw', 'PRODUCTSUBCATEGORY') }}
),

c as (
    select *
    from {{ source('raw', 'PRODUCTCATEGORY') }}
)

select
    p.productid,
    p.product_name,
    sc.name as subcategory_name,
    c.name as category_name,
    p.standardcost,
    p.listprice

from p
left join sc
    on p.productsubcategoryid = sc.productsubcategoryid
left join c
    on sc.productcategoryid = c.productcategoryid