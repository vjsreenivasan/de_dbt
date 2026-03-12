with aircraft as (
    select
        a.aircraft_id,
        a.model_id,
        a.current_status
    from {{ ref('stg_aircraft') }} a
),

aircraft_models as (
    select
        model_id,
        manufacturer,
        model_code,
        model_name
    from {{ ref('stg_aircraft_models') }}
)

select
    m.manufacturer,
    m.model_code,
    m.model_name,
    count(*) as total_aircraft,
    sum(case when a.current_status = 'Active' then 1 else 0 end) as active_aircraft,
    sum(case when a.current_status = 'Maintenance' then 1 else 0 end) as maintenance_aircraft,
    sum(case when a.current_status = 'Grounded' then 1 else 0 end) as grounded_aircraft,
    sum(case when a.current_status = 'Retired' then 1 else 0 end) as retired_aircraft,
    round(100.0 * sum(case when a.current_status = 'Active' then 1 else 0 end) / nullif(count(*), 0), 2) as active_pct
from aircraft a
join aircraft_models m
    on a.model_id = m.model_id
group by
    m.manufacturer,
    m.model_code,
    m.model_name