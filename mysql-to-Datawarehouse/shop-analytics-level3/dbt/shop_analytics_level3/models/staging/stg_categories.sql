with source as (

    select *
    from {{ source('raw', 'raw_categories') }}

)

select
    safe_cast(category_id as int64) as category_id,
    trim(cast(category_name as string)) as category_name
from source