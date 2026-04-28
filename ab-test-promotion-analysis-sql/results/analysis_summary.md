# Analysis Summary

## Project Purpose

I built this SQL-focused project to demonstrate how I would analyze an A/B test as a Junior Data Analyst.

The project uses simulated iGaming-style data where players were assigned to either a Control group or a Variant group. The Variant group received a stronger promotional offer, and the goal was to determine whether the promotion improved deposit conversion, retention, and net revenue.

## Main Analysis Areas

### 1. Data Quality Validation

Before analyzing the test, I checked for:

- Duplicate player assignments
- Missing test groups
- Invalid test groups
- Negative monetary values
- Events outside the 14-day test window
- Events tied to missing players

This matters because bad assignment data can make a test result unreliable.

### 2. Clean Test Population

I created a clean test population by keeping one valid assignment per player and excluding invalid rows.

In a real business setting, I would confirm deduplication rules with the data owner before finalizing the analysis.

### 3. Sample Balance

I checked whether the Control and Variant groups were reasonably balanced by player segment.

This is important because a test can be biased if one group has more VIPs, Regulars, or high-value players than the other.

### 4. Main A/B Test Performance

I compared Control and Variant on:

- Deposit conversion rate
- 14-day retention rate
- Total deposit amount
- Gross revenue
- Bonus cost
- NGR
- Average NGR per assigned player

### 5. Conversion Lift

I calculated absolute lift and relative lift.

For the simulated dataset:

| Metric | Approximate Result |
|---|---|
| Control Conversion Rate | 32.01% |
| Variant Conversion Rate | 32.12% |
| Absolute Lift | 0.11% |
| Relative Lift | 0.33% |
| Approximate P-Value | 0.9638 |

### 6. Practical Significance

I checked whether the Variant improved net revenue, not just conversion.

This is important because a promotion can increase deposits while also increasing bonus costs enough to reduce profitability.

### 7. Business Recommendation

The final SQL query converts the analysis into a recommendation-style output.

The recommendation logic considers both conversion and NGR because I would not recommend rolling out a promotion based on conversion alone.

## Business Takeaway

The biggest takeaway from this project is that A/B testing is not only about asking, 'Which group converted better?'

A stronger analysis asks:

- Was the test data clean?
- Were the groups balanced?
- Was the lift statistically meaningful?
- Was the lift commercially meaningful?
- Did the Variant improve revenue after bonus cost?
- Did the Variant work across segments?
- Should the business actually roll it out?

## Interview Talking Point

If I were explaining this in an interview, I would say:

'I built this project to show how I would analyze an A/B test from raw data to business recommendation. I started with data quality checks, created a clean test population, compared Control and Variant performance, calculated lift, reviewed statistical inputs, checked segment-level results, and ended with a recommendation based on both conversion and net revenue.'
