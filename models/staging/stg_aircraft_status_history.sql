select
    status_history_id,
    aircraft_id,
    status,
    status_start,
    status_end,
    reason
from {{ source('fleet', 'aircraft_status_history') }}