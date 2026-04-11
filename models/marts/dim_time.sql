{{ config(materialized='table') }}

with date_spine as (

    -- generate date range
    select 
        dateadd(day, seq4(), '2010-01-01') as date_day
    from table(generator(rowcount => 6000))  -- ~16 years

),

final as (

    select
        to_number(to_char(date_day, 'YYYYMMDD')) as date_key,
        date_day as date,

        year(date_day) as year,
        quarter(date_day) as quarter,
        month(date_day) as month,
        to_char(date_day, 'MMMM') as month_name,

        day(date_day) as day,
        dayofweek(date_day) as day_of_week,
        to_char(date_day, 'DY') as day_name,

        week(date_day) as week_of_year,

        case 
            when dayofweek(date_day) in (1,7) then true
            else false
        end as is_weekend

    from date_spine

)

select * from final