select
    productid,
    product_name,
    category_name,
    subcategory_name,
    standardcost,
    listprice
from {{ ref('stg_product_hierarchy') }}