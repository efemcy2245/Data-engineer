with order_days as (

    select distinct
        date(order_date) as date_day
    from {{ ref('stg_orders') }}
    where order_date is not null

)

select
    cast(format_date('%Y%m%d', date_day) as int64) as date_key,
    date_day,
    extract(year from date_day) as year,
    extract(quarter from date_day) as quarter,
    extract(month from date_day) as month,
    format_date('%B', date_day) as month_name,
    extract(day from date_day) as day,
    extract(dayofweek from date_day) as day_of_week,
    format_date('%A', date_day) as day_name
from order_days