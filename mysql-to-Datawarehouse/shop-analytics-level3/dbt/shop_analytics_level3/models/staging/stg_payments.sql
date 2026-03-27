with source as (

    select *
    from {{ source('raw', 'raw_payments') }}

)

select
    safe_cast(payment_id as int64) as payment_id,
    safe_cast(order_id as int64) as order_id,
    safe_cast(payment_date as timestamp) as payment_date,
    trim(cast(payment_method as string)) as payment_method,
    trim(cast(payment_status as string)) as payment_status,
    safe_cast(amount as numeric) as amount
from source