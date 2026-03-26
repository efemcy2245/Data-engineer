with source as (

    select *
    from {{ source('src_shop', 'categories') }}

)

select *
from source