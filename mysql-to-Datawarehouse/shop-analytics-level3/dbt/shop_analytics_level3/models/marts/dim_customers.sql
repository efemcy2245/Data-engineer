with customers as (

    select *
    from {{ ref('stg_customers') }}

)

select
    customer_id as customer_key,
    customer_id,
    first_name,
    last_name,
    concat(first_name, ' ', last_name) as full_name,
    email
from customers