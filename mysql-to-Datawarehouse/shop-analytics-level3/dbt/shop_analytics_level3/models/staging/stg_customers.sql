with source as (

    select *
    from {{ source('src_shop', 'customers') }}

)

select *
from source