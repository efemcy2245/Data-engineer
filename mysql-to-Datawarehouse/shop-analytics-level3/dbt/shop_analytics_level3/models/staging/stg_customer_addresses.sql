with source as (

    select *
    from {{ source('raw', 'raw_customers_addresses') }}

)

select *
from source