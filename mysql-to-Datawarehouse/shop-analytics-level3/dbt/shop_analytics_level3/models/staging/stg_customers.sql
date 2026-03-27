with source as (

    select *
    from {{ source('raw', 'raw_customers') }}

)

select
    safe_cast(customer_id as int64) as customer_id,
    trim(cast(first_name as string)) as first_name,
    trim(cast(last_name as string)) as last_name,
    lower(trim(cast(email as string))) as email
from source