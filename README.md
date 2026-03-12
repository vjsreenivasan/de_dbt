# airline_fleet_analysis

dbt project for airline fleet management analytics on PostgreSQL.

## Stack

- Database: PostgreSQL (Docker)
- dbt profile: `airline_fleet_analysis` in `~/.dbt/profiles.yml`
- Target database/schema: `airline_demo.fleet`

## Getting started in 5 minutes

Run from any terminal:

```bash
# 1) Start PostgreSQL in Docker
docker rm -f postgres-db >/dev/null 2>&1 || true
docker run -d --name postgres-db \
	-e POSTGRES_USER=postgres \
	-e POSTGRES_PASSWORD=postgres \
	-e POSTGRES_DB=appdb \
	-p 5432:5432 postgres:16

# 2) Create analytics database used by this project
docker exec -i postgres-db psql -U postgres -d postgres -c "CREATE DATABASE airline_demo;" 2>/dev/null || true

# 3) Move to project
cd /Users/shvj/Projects/dbt_demo/airline_fleet_analysis

# 4) Validate dbt connection (stable dbt binary)
/Users/shvj/Projects/dbt_demo/.venv-dbt312/bin/dbt debug --project-dir . --profiles-dir /Users/shvj/.dbt

# 5) Build models and run tests
/Users/shvj/Projects/dbt_demo/.venv-dbt312/bin/dbt build --fail-fast
```

Expected result: `Completed successfully` with passing models/tests.

## Project layout

- `models/staging/`
	- `stg_aircraft.sql`
	- `stg_aircraft_models.sql`
	- `stg_aircraft_status_history.sql`
	- `schema.yml` (sources + staging tests)
- `models/marts/`
	- `mart_fleet_overview.sql`
	- `schema.yml` (mart tests)
- `tests/`
	- custom singular tests for status history data quality

## Key data quality tests

### Staging tests

- PK tests (`unique`, `not_null`) on IDs
- FK relationships:
	- `stg_aircraft.model_id -> stg_aircraft_models.model_id`
	- `stg_aircraft_status_history.aircraft_id -> stg_aircraft.aircraft_id`
- domain checks (`accepted_values`) for:
	- `current_status`
	- `ownership_type`
	- `status`

### Custom status history guardrails

- `test_stg_aircraft_status_history_status_window.sql`
	- `status_end > status_start` when `status_end` is present
- `test_stg_aircraft_status_history_status_start_not_future.sql`
	- `status_start` is not in the future
- `test_stg_aircraft_status_history_status_start_datetime_format.sql`
	- validates timestamp rendering shape `YYYY-MM-DD HH24:MI:SS.MS ±HHMM`
- `test_stg_aircraft_status_history_no_overlap.sql`
	- no overlapping status intervals for the same aircraft
- `test_stg_aircraft_status_history_single_open_status.sql`
	- at most one open (`status_end is null`) status row per aircraft

## Common commands

From project root (`airline_fleet_analysis`):

```bash
# recommended stable binary
/Users/shvj/Projects/dbt_demo/.venv-dbt312/bin/dbt debug
/Users/shvj/Projects/dbt_demo/.venv-dbt312/bin/dbt test
/Users/shvj/Projects/dbt_demo/.venv-dbt312/bin/dbt build --fail-fast

# targeted runs
/Users/shvj/Projects/dbt_demo/.venv-dbt312/bin/dbt build --select staging+
/Users/shvj/Projects/dbt_demo/.venv-dbt312/bin/dbt build --select marts
/Users/shvj/Projects/dbt_demo/.venv-dbt312/bin/dbt test --select stg_aircraft_status_history+
```

## Notes

- Use one source definition per physical source table to avoid duplicate source compilation errors.
- Keep staging tests in `models/staging/schema.yml` and custom logic tests in `tests/`.
