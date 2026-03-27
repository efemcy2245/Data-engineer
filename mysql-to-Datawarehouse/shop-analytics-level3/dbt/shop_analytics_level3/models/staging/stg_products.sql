with source as (

    select *
    from {{ source('raw', 'raw_products') }}

)

select
    safe_cast(product_id as int64) as product_id,
    safe_cast(category_id as int64) as category_id,
    trim(cast(product_name as string)) as product_name,
    trim(cast(sku as string)) as sku,
    safe_cast(unit_price as numeric) as unit_price,
    safe_cast(stock_quantity as int64) as stock_quantity,
    safe_cast(is_active as int64) as is_active,
    cast(created_at as datetime) as created_at
from source