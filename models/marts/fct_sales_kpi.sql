select
    orderdate,
    sum(linetotal) as revenue,
    count(distinct salesorderid) as total_orders,
    sum(linetotal) / count(distinct salesorderid) as avg_order_value
from {{ ref('fct_sales') }}
group by orderdate