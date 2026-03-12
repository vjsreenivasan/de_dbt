{% test single_open_status(model, group_by_column, end_column) %}

select
    {{ group_by_column }} as group_key,
    count(*) as open_status_count
from {{ model }}
where {{ end_column }} is null
group by {{ group_by_column }}
having count(*) > 1

{% endtest %}