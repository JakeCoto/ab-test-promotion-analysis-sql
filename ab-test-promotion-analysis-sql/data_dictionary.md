# Data Dictionary

This project uses simulated iGaming-style data for an A/B test promotion analysis.

## players.csv

| Field | Description |
|---|---|
| player_id | Unique player identifier |
| registration_date | Date the player registered |
| country | Player country or market |
| player_segment | Player segment at the time of the test |
| acquisition_channel | How the player was acquired |
| account_status | Account status |

## ab_test_assignments.csv

| Field | Description |
|---|---|
| player_id | Player assigned to the test |
| test_group | Control or Variant |
| test_start_date | Date the experiment started |
| deposit_converted | Whether the player made a deposit during the 14-day test window |
| retained_14d | Whether the player was retained after 14 days |
| deposit_amount_14d | Deposit amount during the test window |
| bonus_cost_14d | Promotional bonus cost during the test window |
| gross_revenue_14d | Simulated gross revenue before bonus cost |
| ngr_14d | Net gaming revenue after bonus cost |

## player_events.csv

| Field | Description |
|---|---|
| event_id | Unique event identifier |
| player_id | Player tied to the event |
| event_type | Assignment, deposit, bonus awarded, gaming revenue, or retained event |
| event_date | Date the event occurred |
| test_group | Control or Variant |
| amount | Monetary amount tied to the event, when applicable |

## KPI Definitions

| KPI | Definition |
|---|---|
| Deposit Conversion Rate | Converted players / assigned players |
| Absolute Lift | Variant conversion rate - Control conversion rate |
| Relative Lift | Absolute lift / Control conversion rate |
| 14-Day Retention Rate | Retained players / assigned players |
| Gross Revenue | Revenue before bonus cost |
| Bonus Cost | Promotional cost given to the player |
| NGR | Gross revenue - bonus cost |
| Average NGR per User | Total NGR / assigned players |
| Practical Significance | Whether the test result is large enough to justify a business rollout |
