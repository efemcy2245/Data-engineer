with order_items as (

    select *
    from {{ ref('stg_order_items') }}

),

orders as (

    select *
    from {{ ref('stg_orders') }}

),

payments as (

    select *
    from {{ ref('stg_payments') }}

),

dim_customers as (

    select *
    from {{ ref('dim_customers') }}

),

dim_products as (

    select *
    from {{ ref('dim_products') }}

)

select
    oi.order_id,
    oi.order_item_id,
    cast(format_date('%Y%m%d', date(o.order_date)) as int64) as date_key,
    dc.customer_key,
    dp.product_key,
    oi.quantity,
    oi.unit_price,
    oi.line_total,
    o.order_status,
    p.payment_method,
    p.payment_status
from order_items oi
left join orders o
    on oi.order_id = o.order_id
left join payments p
    on oi.order_id = p.order_id
left join dim_customers dc
    on o.customer_id = dc.customer_id
left join dim_products dp
    on oi.product_id = dp.product_id