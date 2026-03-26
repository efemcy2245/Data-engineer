with source as (

    select *
    from {{ source('src_shop', 'customer_addresses') }}

)

select *
from source