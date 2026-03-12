-- DDL for airline fleet demo objects used by dbt models
-- Run against database: airline_demo

create schema if not exists fleet;

create table if not exists fleet.aircraft_models (
    model_id bigserial primary key,
    manufacturer text not null,
    model_code text not null,
    model_name text not null,
    max_seats integer check (max_seats > 0),
    range_km integer check (range_km > 0),
    unique (manufacturer, model_code)
);

create table if not exists fleet.aircraft (
    aircraft_id bigserial primary key,
    tail_number text unique not null,
    model_id bigint not null references fleet.aircraft_models(model_id),
    serial_number text unique not null,
    manufacture_date date,
    in_service_date date,
    ownership_type text not null check (ownership_type in ('Owned', 'Leased')),
    current_status text not null check (current_status in ('Active', 'Maintenance', 'Grounded', 'Retired')),
    home_base_airport_id bigint,
    created_at timestamptz not null default now()
);

create table if not exists fleet.aircraft_status_history (
    status_history_id bigserial primary key,
    aircraft_id bigint not null references fleet.aircraft(aircraft_id),
    status text not null check (status in ('Active', 'Maintenance', 'Grounded', 'Retired')),
    status_start timestamptz not null,
    status_end timestamptz,
    reason text,
    check (status_end is null or status_end > status_start)
);

create index if not exists idx_aircraft_model_id on fleet.aircraft(model_id);
create index if not exists idx_aircraft_current_status on fleet.aircraft(current_status);
create index if not exists idx_status_history_aircraft_id on fleet.aircraft_status_history(aircraft_id);
create index if not exists idx_status_history_status_start on fleet.aircraft_status_history(status_start);