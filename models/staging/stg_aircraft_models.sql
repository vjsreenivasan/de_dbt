select
    model_id,
    manufacturer,
    model_code,
    model_name,
    max_seats,
    range_km
from {{ source('fleet', 'aircraft_models') }}