select
    status_history_id
from {{ ref('stg_aircraft_status_history') }}
where status_end is not null
  and status_end <= status_start