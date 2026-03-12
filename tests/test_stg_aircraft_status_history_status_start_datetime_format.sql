select
    status_history_id,
    status_start,
    to_char(status_start, 'YYYY-MM-DD HH24:MI:SS.MS TZHTZM') as status_start_formatted
from {{ ref('stg_aircraft_status_history') }}
where status_start is null
   or to_char(status_start, 'YYYY-MM-DD HH24:MI:SS.MS TZHTZM') !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3} [+-][0-9]{4}$'