{{ config(materialized='view') }}

select
    t.year,
    t.month,
    t.month_name,

    sum(f.linetotal) as revenue,
    count(distinct f.salesorderid) as total_orders,
    sum(f.linetotal) / count(distinct f.salesorderid) as avg_order_value

from {{ ref('fct_sales') }} f
join {{ ref('dim_time') }} t
    on f.date_key = t.date_key

group by 1,2,3