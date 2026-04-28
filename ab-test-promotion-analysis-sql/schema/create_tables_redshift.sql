-- schema/create_tables_redshift.sql
-- Redshift-style schema for the A/B Test Promotion Analysis project.

DROP TABLE IF EXISTS player_events;
DROP TABLE IF EXISTS ab_test_assignments;
DROP TABLE IF EXISTS players;

CREATE TABLE players (
    player_id BIGINT PRIMARY KEY,
    registration_date DATE,
    country VARCHAR(10),
    player_segment VARCHAR(30),
    acquisition_channel VARCHAR(50),
    account_status VARCHAR(30)
);

CREATE TABLE ab_test_assignments (
    player_id BIGINT,
    test_group VARCHAR(20),
    test_start_date DATE,
    deposit_converted INTEGER,
    retained_14d INTEGER,
    deposit_amount_14d DECIMAL(12,2),
    bonus_cost_14d DECIMAL(12,2),
    gross_revenue_14d DECIMAL(12,2),
    ngr_14d DECIMAL(12,2)
);

CREATE TABLE player_events (
    event_id BIGINT PRIMARY KEY,
    player_id BIGINT,
    event_type VARCHAR(50),
    event_date DATE,
    test_group VARCHAR(20),
    amount DECIMAL(12,2)
);
