select
    aircraft_id,
    count(*) as open_status_count
from {{ ref('stg_aircraft_status_history') }}
where status_end is null
group by aircraft_id
having count(*) > 1