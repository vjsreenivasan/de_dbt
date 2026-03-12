with status_ranges as (
    select
        status_history_id,
        aircraft_id,
        tstzrange(
            status_start,
            coalesce(status_end, 'infinity'::timestamptz),
            '[)'
        ) as status_window
    from {{ ref('stg_aircraft_status_history') }}
),

overlap_rows as (
    select
        a.aircraft_id,
        a.status_history_id as left_status_history_id,
        b.status_history_id as right_status_history_id
    from status_ranges a
    join status_ranges b
        on a.aircraft_id = b.aircraft_id
       and a.status_history_id < b.status_history_id
       and a.status_window && b.status_window
)

select *
from overlap_rows

