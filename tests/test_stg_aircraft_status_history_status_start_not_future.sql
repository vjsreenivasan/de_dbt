select
    status_history_id,
    status_start
from {{ ref('stg_aircraft_status_history') }}
where status_start::date > current_date