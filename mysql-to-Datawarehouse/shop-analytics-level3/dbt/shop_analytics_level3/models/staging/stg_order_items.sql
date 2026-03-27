with source as (

    select *
    from {{ source('raw', 'raw_order_items') }}

)

select
    safe_cast(order_item_id as int64) as order_item_id,
    safe_cast(order_id as int64) as order_id,
    safe_cast(product_id as int64) as product_id,
    safe_cast(quantity as int64) as quantity,
    safe_cast(unit_price as numeric) as unit_price,
    safe_cast(quantity as numeric) * safe_cast(unit_price as numeric) as line_total
from source