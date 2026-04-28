# Interview Talking Points

## Short Explanation

I built this SQL-focused A/B testing project to practice analyzing an experiment from start to finish. The test compares a Control group against a Variant group that received a stronger promotional offer.

The main question was whether the Variant improved deposit conversion, retention, and net revenue enough to justify rolling it out.

## What I Would Say in an Interview

I would explain it like this:

'I started by validating the data because an A/B test is only useful if the assignment data is clean. I checked for duplicate assignments, missing test groups, invalid values, negative monetary amounts, and events outside the test window.

Then I created a clean test population and compared Control vs. Variant on deposit conversion, retention, deposits, bonus cost, gross revenue, and NGR.

The important part is that I did not judge the test by conversion alone. Since this was a promotion, I also checked whether the Variant improved net revenue after accounting for bonus cost. That helped me separate statistical improvement from actual business value.'

## Questions I Can Answer From This Project

### What is the primary metric?

The primary metric is deposit conversion rate.

### What are secondary metrics?

Secondary metrics include 14-day retention, deposit amount, gross revenue, bonus cost, and NGR.

### Why not use conversion alone?

Because a promotional offer can increase conversion while also increasing bonus cost. If net revenue does not improve, the promotion may not be worth rolling out.

### What is absolute lift?

Absolute lift is the Variant conversion rate minus the Control conversion rate.

### What is relative lift?

Relative lift is the absolute lift divided by the Control conversion rate.

### What is the purpose of the z-test inputs?

The z-test inputs help determine whether the conversion-rate difference is likely due to the test treatment or random noise.

### What is practical significance?

Practical significance means the result is large enough to matter for the business. A result can be statistically significant but still too small or too expensive to justify.

### What would I do next in a real company?

I would confirm KPI definitions, verify the randomization process, check if the test ran long enough, review segment-level effects, and compare the incremental net revenue against the cost of the promotion.
