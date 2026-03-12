{% test no_overlap(model, group_by_column, start_column, end_column) %}

with status_ranges as (
    select
        {{ group_by_column }} as group_key,
        tstzrange(
            {{ start_column }},
            coalesce({{ end_column }}, 'infinity'::timestamptz),
            '[)'
        ) as status_window,
        row_number() over (order by {{ group_by_column }}, {{ start_column }}) as row_id
    from {{ model }}
),

overlap_rows as (
    select
        a.group_key,
        a.row_id as left_row_id,
        b.row_id as right_row_id
    from status_ranges a
    join status_ranges b
        on a.group_key = b.group_key
       and a.row_id < b.row_id
       and a.status_window && b.status_window
)

select *
from overlap_rows

{% endtest %}