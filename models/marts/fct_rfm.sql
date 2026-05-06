{{ config(materialized='table') }}

with customer_rfm as (
    select 
        customerid,
        datediff(day, max(orderdate), '2014-06-30') as recency,
        count(salesorderid) as frequency,
        sum(linetotal) as monetary
    from {{ ref('fct_sales') }}
    group by customerid
),

scores as (
    select *,
        ntile(5) over (order by recency asc) as r_score,
        ntile(5) over (order by frequency asc) as f_score,
        ntile(5) over (order by monetary asc) as m_score
    from customer_rfm
),

final as (
    select
        customerid,
        recency,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        (r_score + f_score + m_score) as total_rfm_score,
        case
            when r_score >= 4 and f_score >= 4 and m_score >= 4 then 'Champions'
            when r_score >= 3 and f_score >= 3 and m_score >= 3 then 'Loyal Customers'
            when r_score <= 2 and f_score >= 3 and m_score >= 3 then 'At Risk'
            when r_score >= 4 and f_score <= 2 then 'New Customers'
            when r_score <= 2 and f_score <= 2 and m_score <= 2 then 'Lost'
            else 'Potential Loyalists'
        end as segment
    from scores
)

select * from final