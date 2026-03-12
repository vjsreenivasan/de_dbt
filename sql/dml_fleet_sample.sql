-- DML seed data for airline fleet demo objects used by dbt models
-- Run against database: airline_demo

begin;

truncate table
    fleet.aircraft_status_history,
    fleet.aircraft,
    fleet.aircraft_models
restart identity cascade;

insert into fleet.aircraft_models (manufacturer, model_code, model_name, max_seats, range_km)
values
    ('Airbus', 'A320-200', 'Airbus A320-200', 180, 6150),
    ('Airbus', 'A321neo', 'Airbus A321neo', 220, 7400),
    ('Boeing', '737-800', 'Boeing 737-800', 189, 5436),
    ('Boeing', '787-9', 'Boeing 787-9 Dreamliner', 296, 14140),
    ('Embraer', 'E190', 'Embraer E190', 114, 4537);

insert into fleet.aircraft (
    tail_number,
    model_id,
    serial_number,
    manufacture_date,
    in_service_date,
    ownership_type,
    current_status,
    home_base_airport_id
)
select
    v.tail_number,
    m.model_id,
    v.serial_number,
    v.manufacture_date,
    v.in_service_date,
    v.ownership_type,
    v.current_status,
    null
from (
    values
        ('N101AF', 'Airbus', 'A320-200', 'MSN-A320-1001', date '2016-03-12', date '2016-06-01', 'Owned', 'Active'),
        ('N201AF', 'Airbus', 'A321neo', 'MSN-A321-2001', date '2020-09-22', date '2020-11-14', 'Owned', 'Active'),
        ('N301AF', 'Boeing', '737-800', 'MSN-B738-3001', date '2015-02-20', date '2015-05-11', 'Owned', 'Active'),
        ('N401AF', 'Boeing', '787-9', 'MSN-B789-4001', date '2019-04-15', date '2019-07-20', 'Leased', 'Maintenance'),
        ('N501AF', 'Embraer', 'E190', 'MSN-E190-5001', date '2018-08-03', date '2018-10-18', 'Leased', 'Grounded')
) as v(tail_number, manufacturer, model_code, serial_number, manufacture_date, in_service_date, ownership_type, current_status)
join fleet.aircraft_models m
    on m.manufacturer = v.manufacturer
   and m.model_code = v.model_code;

insert into fleet.aircraft_status_history (aircraft_id, status, status_start, status_end, reason)
select
    a.aircraft_id,
    s.status,
    s.status_start,
    s.status_end,
    s.reason
from fleet.aircraft a
join (
    values
        ('N101AF', 'Maintenance', timestamptz '2026-01-01 00:00:00+00', timestamptz '2026-01-10 00:00:00+00', 'Planned line check'),
        ('N101AF', 'Active', timestamptz '2026-01-10 00:00:00+00', null::timestamptz, 'Returned to service'),

        ('N201AF', 'Grounded', timestamptz '2026-01-05 00:00:00+00', timestamptz '2026-01-08 12:00:00+00', 'Awaiting spare part'),
        ('N201AF', 'Active', timestamptz '2026-01-08 12:00:00+00', null::timestamptz, 'Part replaced and released'),

        ('N301AF', 'Active', timestamptz '2025-12-15 00:00:00+00', null::timestamptz, 'Scheduled operations'),

        ('N401AF', 'Maintenance', timestamptz '2026-02-20 06:00:00+00', null::timestamptz, 'C-check in progress'),

        ('N501AF', 'Grounded', timestamptz '2026-02-10 09:30:00+00', null::timestamptz, 'Engine vibration investigation')
) as s(tail_number, status, status_start, status_end, reason)
    on a.tail_number = s.tail_number;

commit;