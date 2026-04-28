# A/B Test Promotion Analysis

## Project Overview

I built this as a SQL-focused A/B testing portfolio project to demonstrate how I would analyze a promotional experiment as a Junior Data Analyst.

The project uses a simulated iGaming-style dataset where players were split into a Control group and a Variant group. The Variant group received a stronger promotional offer, and the goal was to determine whether the promotion improved deposit conversion, retention, and net revenue.

I wanted this project to show more than just a conversion-rate comparison. I included data quality checks, sample balance checks, segment-level analysis, revenue impact, bonus cost, practical significance, and a final business recommendation.

## Business Questions

For this project, I focused on answering these questions:

1. Did the Variant group improve deposit conversion compared to the Control group?
2. Was the improvement large enough to matter commercially?
3. Did the Variant improve 14-day retention?
4. Did the Variant improve net revenue after accounting for bonus cost?
5. Did the test perform differently by player segment?
6. Were the Control and Variant groups reasonably balanced?
7. Are there data quality issues that should be fixed before trusting the result?
8. Should the business roll out the Variant promotion?

## Tools and Skills Used

This project demonstrates:

- SQL analysis using CTEs, joins, aggregations, and CASE logic
- A/B test setup and interpretation
- Control vs. Variant comparison
- Conversion-rate analysis
- Retention analysis
- Revenue and bonus-cost analysis
- Practical significance checks
- Two-proportion z-test input calculation
- Sample balance checks
- Data quality validation
- Business recommendation logic

## Dataset

The data is fully simulated and fictional. It represents a promotional A/B test for an iGaming-style business.

| Dataset | Description |
|---|---|
| `players.csv` | Player profile, segment, country, acquisition channel, and account status |
| `ab_test_assignments.csv` | Control/Variant assignment, conversion, retention, deposit amount, bonus cost, gross revenue, and NGR |
| `player_events.csv` | Event-level activity during the test window |

## Files Included

| File | Purpose |
|---|---|
| `schema/create_tables_redshift.sql` | Redshift-style table creation script |
| `queries/ab_test_promotion_analysis.sql` | Main SQL analysis file |
| `data_dictionary.md` | Dataset field definitions and KPI definitions |
| `results/analysis_summary.md` | Plain-English summary of the project and findings |
| `docs/interview_talking_points.md` | How I would explain the project in an interview |
| `datasets/players.csv` | Simulated player data |
| `datasets/ab_test_assignments.csv` | Simulated A/B test assignment and outcome data |
| `datasets/player_events.csv` | Simulated event-level activity data |

## KPIs and Test Metrics

| Metric | Definition Used |
|---|---|
| Deposit Conversion Rate | Players who deposited / assigned players |
| Absolute Lift | Variant conversion rate - Control conversion rate |
| Relative Lift | Absolute lift / Control conversion rate |
| 14-Day Retention Rate | Players retained after 14 days / assigned players |
| Gross Revenue | Simulated revenue before bonus cost |
| Bonus Cost | Promotional bonus cost given to players |
| NGR | Gross revenue - bonus cost |
| Average NGR per User | Total NGR / assigned players |
| Practical Significance | Whether the Variant improves the business outcome enough to justify rollout |

## SQL Work Included

The main SQL file includes:

- Duplicate assignment checks
- Missing or invalid test-group checks
- Negative monetary value checks
- Out-of-window event checks
- Clean test population logic
- Sample balance checks by player segment
- Main Control vs. Variant performance summary
- Conversion lift calculation
- Two-proportion z-test input calculation
- Segment-level performance comparison
- Practical significance check
- Final recommendation query

## Key Findings I Would Present

Based on the simulated data, the Variant promotion improved deposit conversion compared to the Control group.

However, I would not judge the test by conversion alone. The Variant also had higher bonus costs, so the important question is whether it improved net revenue after subtracting promotional cost.

The project is designed to show that a test can look good on the surface if conversion improves, but still require deeper analysis before rollout. A stronger analyst recommendation should consider conversion, retention, NGR, bonus cost, segment performance, and data quality.

## Statistical Significance Approach

The SQL file calculates the core inputs needed for a two-proportion z-test:

- Control sample size
- Control conversions
- Control conversion rate
- Variant sample size
- Variant conversions
- Variant conversion rate
- Pooled conversion rate
- Standard error
- Z-score

For this simulated dataset, the approximate headline result is:

| Metric | Approximate Result |
|---|---|
| Control Conversion Rate | 32.01% |
| Variant Conversion Rate | 32.12% |
| Absolute Lift | 0.11% |
| Relative Lift | 0.33% |
| Approximate P-Value | 0.9638 |
| Approximate 95% CI for Lift | -4.47% to 4.68% |

In a real business setting, I would pair statistical significance with practical significance before recommending a rollout.

## How I Would Explain This Project in an Interview

I built this project to show how I would analyze an A/B test from start to finish.

I started by validating the assignment table because the test result is only useful if the data is clean. I checked for duplicate assignments, missing test groups, invalid values, and events outside the test window.

After that, I created a clean test population and compared Control vs. Variant on conversion rate, retention, gross revenue, bonus cost, and net revenue. I also looked at segment-level performance because an experiment can perform well overall while still failing for certain player groups.

The main point of the project is that I would not recommend a rollout just because conversion improved. I would also check whether the Variant improved NGR after bonus costs and whether the result was meaningful enough for the business.

## Example Resume Bullet Version

This is how I would summarize this project on my resume:

- Built a SQL-focused A/B testing project using simulated iGaming data to compare Control vs. Variant performance across deposit conversion, 14-day retention, gross revenue, bonus cost, and NGR.
- Wrote Redshift-style SQL queries using CTEs, joins, aggregations, CASE logic, and validation checks to clean assignment data and summarize experiment results.
- Calculated conversion lift, relative lift, z-test inputs, segment-level performance, and practical revenue impact to support a business rollout recommendation.
- Added data quality checks for duplicate assignments, missing test groups, negative monetary values, and out-of-window events before trusting the test result.
- Summarized findings in plain English to show how A/B test results should be interpreted for non-technical stakeholders.

## How to Review This Project

Recommended review order:

1. Open `queries/ab_test_promotion_analysis.sql`
2. Review the data quality checks at the top of the SQL file
3. Review the Control vs. Variant performance summary
4. Review the conversion lift and z-test input queries
5. Review the segment-level analysis
6. Review `results/analysis_summary.md`
7. Review `docs/interview_talking_points.md`

## Project Structure

```text
ab-test-promotion-analysis-sql/
│
├── README.md
├── data_dictionary.md
│
├── schema/
│   └── create_tables_redshift.sql
│
├── queries/
│   └── ab_test_promotion_analysis.sql
│
├── datasets/
│   ├── players.csv
│   ├── ab_test_assignments.csv
│   └── player_events.csv
│
├── results/
│   └── analysis_summary.md
│
└── docs/
    └── interview_talking_points.md
```

## Disclaimer

All data in this project is simulated and fictional. No real gambling, customer, financial, or company data is included.
