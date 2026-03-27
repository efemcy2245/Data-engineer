with products as (

    select *
    from {{ ref('stg_products') }}

),

categories as (

    select *
    from {{ ref('stg_categories') }}

)

select
    p.product_id as product_key,
    p.product_id,
    p.category_id,
    c.category_name,
    p.product_name,
    p.sku,
    p.unit_price as price,
    p.stock_quantity,
    p.is_active,
    p.created_at
from products p
left join categories c
    on p.category_id = c.category_id