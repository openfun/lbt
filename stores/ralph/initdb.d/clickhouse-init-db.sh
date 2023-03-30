#!/bin/bash
set -e
clickhouse client -n <<-EOSQL
    SET allow_experimental_object_type=1;
    CREATE TABLE IF NOT EXISTS xapi.xapi_events_all (
    event_id UUID NOT NULL,
    emission_time DateTime64(6) NOT NULL,
    event JSON NOT NULL,
    event_str String NOT NULL
    )
    ENGINE MergeTree ORDER BY (emission_time, event_id)
    PRIMARY KEY (emission_time, event_id);
EOSQL
