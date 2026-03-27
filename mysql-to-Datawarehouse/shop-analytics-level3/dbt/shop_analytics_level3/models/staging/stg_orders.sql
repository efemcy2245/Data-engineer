with source as (

    select *
    from {{ source('raw', 'raw_orders') }}

)

select
    safe_cast(order_id as int64) as order_id,
    safe_cast(customer_id as int64) as customer_id,
    safe_cast(order_date as timestamp) as order_date,
    trim(cast(order_status as string)) as order_status
from source