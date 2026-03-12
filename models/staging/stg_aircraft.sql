select
    aircraft_id,
    tail_number,
    model_id,
    serial_number,
    manufacture_date,
    in_service_date,
    ownership_type,
    current_status,
    home_base_airport_id,
    created_at
from {{ source('fleet', 'aircraft') }}