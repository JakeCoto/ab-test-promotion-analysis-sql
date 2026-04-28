-- queries/ab_test_promotion_analysis.sql
-- SQL-only A/B testing portfolio project.
-- Dialect: Redshift-style SQL.
-- Goal: Analyze whether a promotional Variant improved deposit conversion, retention, and revenue.

--------------------------------------------------------------------------------
-- 1. DATA QUALITY CHECKS
-- Purpose:
-- Before analyzing the test, I validate whether assignment data can be trusted.
--------------------------------------------------------------------------------

-- 1A. Duplicate player assignments
SELECT
    player_id,
    COUNT(*) AS assignment_count
FROM ab_test_assignments
GROUP BY player_id
HAVING COUNT(*) > 1
ORDER BY assignment_count DESC;

-- 1B. Missing or invalid test groups
SELECT *
FROM ab_test_assignments
WHERE test_group IS NULL
   OR test_group NOT IN ('Control', 'Variant');

-- 1C. Negative monetary values
SELECT *
FROM ab_test_assignments
WHERE deposit_amount_14d < 0
   OR bonus_cost_14d < 0
   OR gross_revenue_14d < 0;

-- 1D. Events outside the 14-day test window
SELECT *
FROM player_events
WHERE event_date < '2026-03-01'
   OR event_date >= '2026-03-15';

-- 1E. Events tied to missing players
SELECT e.*
FROM player_events e
LEFT JOIN players p
    ON e.player_id = p.player_id
WHERE p.player_id IS NULL;


--------------------------------------------------------------------------------
-- 2. CLEAN TEST POPULATION
-- Purpose:
-- Create a clean assignment set by keeping one valid assignment per player.
-- In a production setting, I would confirm de-duplication rules with the data owner.
--------------------------------------------------------------------------------

WITH ranked_assignments AS (
    SELECT
        a.*,
        ROW_NUMBER() OVER (
            PARTITION BY player_id
            ORDER BY test_start_date ASC
        ) AS assignment_rank
    FROM ab_test_assignments a
    WHERE test_group IN ('Control', 'Variant')
      AND deposit_amount_14d >= 0
      AND bonus_cost_14d >= 0
      AND gross_revenue_14d >= 0
)

SELECT *
FROM ranked_assignments
WHERE assignment_rank = 1;


--------------------------------------------------------------------------------
-- 3. SAMPLE BALANCE CHECK
-- Purpose:
-- Check whether Control and Variant groups are reasonably balanced by segment,
-- country, and acquisition channel.
--------------------------------------------------------------------------------

WITH clean_assignments AS (
    SELECT *
    FROM (
        SELECT
            a.*,
            ROW_NUMBER() OVER (
                PARTITION BY player_id
                ORDER BY test_start_date ASC
            ) AS assignment_rank
        FROM ab_test_assignments a
        WHERE test_group IN ('Control', 'Variant')
          AND deposit_amount_14d >= 0
          AND bonus_cost_14d >= 0
          AND gross_revenue_14d >= 0
    ) x
    WHERE assignment_rank = 1
)

SELECT
    ca.test_group,
    p.player_segment,
    COUNT(*) AS players,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY ca.test_group), 2) AS pct_of_group
FROM clean_assignments ca
JOIN players p
    ON ca.player_id = p.player_id
GROUP BY ca.test_group, p.player_segment
ORDER BY p.player_segment, ca.test_group;


--------------------------------------------------------------------------------
-- 4. MAIN A/B TEST SUMMARY
-- Purpose:
-- Compare Control and Variant on conversion, retention, revenue, bonus cost,
-- and net revenue.
--------------------------------------------------------------------------------

WITH clean_assignments AS (
    SELECT *
    FROM (
        SELECT
            a.*,
            ROW_NUMBER() OVER (
                PARTITION BY player_id
                ORDER BY test_start_date ASC
            ) AS assignment_rank
        FROM ab_test_assignments a
        WHERE test_group IN ('Control', 'Variant')
          AND deposit_amount_14d >= 0
          AND bonus_cost_14d >= 0
          AND gross_revenue_14d >= 0
    ) x
    WHERE assignment_rank = 1
)

SELECT
    test_group,
    COUNT(*) AS assigned_players,
    SUM(deposit_converted) AS deposit_conversions,
    ROUND(100.0 * SUM(deposit_converted) / NULLIF(COUNT(*), 0), 2) AS deposit_conversion_rate_pct,
    SUM(retained_14d) AS retained_14d_players,
    ROUND(100.0 * SUM(retained_14d) / NULLIF(COUNT(*), 0), 2) AS retention_14d_rate_pct,
    ROUND(SUM(deposit_amount_14d), 2) AS total_deposit_amount,
    ROUND(AVG(deposit_amount_14d), 2) AS avg_deposit_amount_per_assigned_player,
    ROUND(SUM(gross_revenue_14d), 2) AS total_gross_revenue_14d,
    ROUND(SUM(bonus_cost_14d), 2) AS total_bonus_cost_14d,
    ROUND(SUM(ngr_14d), 2) AS total_ngr_14d,
    ROUND(AVG(ngr_14d), 2) AS avg_ngr_per_assigned_player
FROM clean_assignments
GROUP BY test_group
ORDER BY test_group;


--------------------------------------------------------------------------------
-- 5. CONVERSION LIFT ANALYSIS
-- Purpose:
-- Calculate absolute lift and relative lift for Variant vs Control.
--------------------------------------------------------------------------------

WITH clean_assignments AS (
    SELECT *
    FROM (
        SELECT
            a.*,
            ROW_NUMBER() OVER (
                PARTITION BY player_id
                ORDER BY test_start_date ASC
            ) AS assignment_rank
        FROM ab_test_assignments a
        WHERE test_group IN ('Control', 'Variant')
          AND deposit_amount_14d >= 0
          AND bonus_cost_14d >= 0
          AND gross_revenue_14d >= 0
    ) x
    WHERE assignment_rank = 1
),

group_summary AS (
    SELECT
        test_group,
        COUNT(*) AS users,
        SUM(deposit_converted) AS converted,
        1.0 * SUM(deposit_converted) / NULLIF(COUNT(*), 0) AS conversion_rate,
        AVG(ngr_14d) AS avg_ngr
    FROM clean_assignments
    GROUP BY test_group
),

pivoted AS (
    SELECT
        MAX(CASE WHEN test_group = 'Control' THEN users END) AS control_users,
        MAX(CASE WHEN test_group = 'Control' THEN converted END) AS control_converted,
        MAX(CASE WHEN test_group = 'Control' THEN conversion_rate END) AS control_conversion_rate,
        MAX(CASE WHEN test_group = 'Control' THEN avg_ngr END) AS control_avg_ngr,

        MAX(CASE WHEN test_group = 'Variant' THEN users END) AS variant_users,
        MAX(CASE WHEN test_group = 'Variant' THEN converted END) AS variant_converted,
        MAX(CASE WHEN test_group = 'Variant' THEN conversion_rate END) AS variant_conversion_rate,
        MAX(CASE WHEN test_group = 'Variant' THEN avg_ngr END) AS variant_avg_ngr
    FROM group_summary
)

SELECT
    control_users,
    control_converted,
    ROUND(100.0 * control_conversion_rate, 2) AS control_conversion_rate_pct,

    variant_users,
    variant_converted,
    ROUND(100.0 * variant_conversion_rate, 2) AS variant_conversion_rate_pct,

    ROUND(100.0 * (variant_conversion_rate - control_conversion_rate), 2) AS absolute_lift_percentage_points,
    ROUND(100.0 * (variant_conversion_rate - control_conversion_rate) / NULLIF(control_conversion_rate, 0), 2) AS relative_lift_pct,

    ROUND(control_avg_ngr, 2) AS control_avg_ngr,
    ROUND(variant_avg_ngr, 2) AS variant_avg_ngr,
    ROUND(variant_avg_ngr - control_avg_ngr, 2) AS avg_ngr_lift
FROM pivoted;


--------------------------------------------------------------------------------
-- 6. TWO-PROPORTION Z-TEST INPUTS
-- Purpose:
-- Produce the values needed to validate statistical significance for conversion.
-- Note:
-- Some SQL warehouses have statistical functions; when they do not, I would
-- export these inputs or calculate p-value in a stats tool.
--------------------------------------------------------------------------------

WITH clean_assignments AS (
    SELECT *
    FROM (
        SELECT
            a.*,
            ROW_NUMBER() OVER (
                PARTITION BY player_id
                ORDER BY test_start_date ASC
            ) AS assignment_rank
        FROM ab_test_assignments a
        WHERE test_group IN ('Control', 'Variant')
          AND deposit_amount_14d >= 0
          AND bonus_cost_14d >= 0
          AND gross_revenue_14d >= 0
    ) x
    WHERE assignment_rank = 1
),

summary AS (
    SELECT
        SUM(CASE WHEN test_group = 'Control' THEN 1 ELSE 0 END) AS n_control,
        SUM(CASE WHEN test_group = 'Control' THEN deposit_converted ELSE 0 END) AS conversions_control,
        SUM(CASE WHEN test_group = 'Variant' THEN 1 ELSE 0 END) AS n_variant,
        SUM(CASE WHEN test_group = 'Variant' THEN deposit_converted ELSE 0 END) AS conversions_variant
    FROM clean_assignments
),

rates AS (
    SELECT
        n_control,
        conversions_control,
        1.0 * conversions_control / NULLIF(n_control, 0) AS control_rate,
        n_variant,
        conversions_variant,
        1.0 * conversions_variant / NULLIF(n_variant, 0) AS variant_rate,
        1.0 * (conversions_control + conversions_variant) / NULLIF(n_control + n_variant, 0) AS pooled_rate
    FROM summary
)

SELECT
    n_control,
    conversions_control,
    ROUND(100.0 * control_rate, 2) AS control_rate_pct,
    n_variant,
    conversions_variant,
    ROUND(100.0 * variant_rate, 2) AS variant_rate_pct,
    ROUND(100.0 * (variant_rate - control_rate), 2) AS absolute_lift_points,
    pooled_rate,
    SQRT(pooled_rate * (1 - pooled_rate) * (1.0 / n_control + 1.0 / n_variant)) AS standard_error,
    (variant_rate - control_rate)
        / NULLIF(SQRT(pooled_rate * (1 - pooled_rate) * (1.0 / n_control + 1.0 / n_variant)), 0) AS z_score
FROM rates;


--------------------------------------------------------------------------------
-- 7. SEGMENT-LEVEL TEST PERFORMANCE
-- Purpose:
-- See whether the Variant worked consistently or only in certain player segments.
--------------------------------------------------------------------------------

WITH clean_assignments AS (
    SELECT *
    FROM (
        SELECT
            a.*,
            ROW_NUMBER() OVER (
                PARTITION BY player_id
                ORDER BY test_start_date ASC
            ) AS assignment_rank
        FROM ab_test_assignments a
        WHERE test_group IN ('Control', 'Variant')
          AND deposit_amount_14d >= 0
          AND bonus_cost_14d >= 0
          AND gross_revenue_14d >= 0
    ) x
    WHERE assignment_rank = 1
)

SELECT
    p.player_segment,
    ca.test_group,
    COUNT(*) AS players,
    ROUND(100.0 * SUM(ca.deposit_converted) / NULLIF(COUNT(*), 0), 2) AS conversion_rate_pct,
    ROUND(100.0 * SUM(ca.retained_14d) / NULLIF(COUNT(*), 0), 2) AS retention_14d_rate_pct,
    ROUND(AVG(ca.deposit_amount_14d), 2) AS avg_deposit_amount,
    ROUND(AVG(ca.bonus_cost_14d), 2) AS avg_bonus_cost,
    ROUND(AVG(ca.ngr_14d), 2) AS avg_ngr_14d
FROM clean_assignments ca
JOIN players p
    ON ca.player_id = p.player_id
GROUP BY p.player_segment, ca.test_group
ORDER BY p.player_segment, ca.test_group;


--------------------------------------------------------------------------------
-- 8. PRACTICAL SIGNIFICANCE CHECK
-- Purpose:
-- Show whether the test looks commercially useful, not just statistically better.
--------------------------------------------------------------------------------

WITH clean_assignments AS (
    SELECT *
    FROM (
        SELECT
            a.*,
            ROW_NUMBER() OVER (
                PARTITION BY player_id
                ORDER BY test_start_date ASC
            ) AS assignment_rank
        FROM ab_test_assignments a
        WHERE test_group IN ('Control', 'Variant')
          AND deposit_amount_14d >= 0
          AND bonus_cost_14d >= 0
          AND gross_revenue_14d >= 0
    ) x
    WHERE assignment_rank = 1
),

group_summary AS (
    SELECT
        test_group,
        COUNT(*) AS users,
        AVG(ngr_14d) AS avg_ngr_per_user,
        SUM(ngr_14d) AS total_ngr,
        AVG(bonus_cost_14d) AS avg_bonus_cost_per_user
    FROM clean_assignments
    GROUP BY test_group
),

pivoted AS (
    SELECT
        MAX(CASE WHEN test_group = 'Control' THEN avg_ngr_per_user END) AS control_avg_ngr,
        MAX(CASE WHEN test_group = 'Variant' THEN avg_ngr_per_user END) AS variant_avg_ngr,
        MAX(CASE WHEN test_group = 'Control' THEN avg_bonus_cost_per_user END) AS control_avg_bonus,
        MAX(CASE WHEN test_group = 'Variant' THEN avg_bonus_cost_per_user END) AS variant_avg_bonus,
        MAX(CASE WHEN test_group = 'Variant' THEN users END) AS variant_users
    FROM group_summary
)

SELECT
    ROUND(control_avg_ngr, 2) AS control_avg_ngr_per_user,
    ROUND(variant_avg_ngr, 2) AS variant_avg_ngr_per_user,
    ROUND(variant_avg_ngr - control_avg_ngr, 2) AS avg_ngr_lift_per_user,
    ROUND((variant_avg_ngr - control_avg_ngr) * variant_users, 2) AS estimated_incremental_ngr,
    ROUND(control_avg_bonus, 2) AS control_avg_bonus_per_user,
    ROUND(variant_avg_bonus, 2) AS variant_avg_bonus_per_user,
    CASE
        WHEN variant_avg_ngr > control_avg_ngr THEN 'Variant improves net revenue'
        ELSE 'Variant does not improve net revenue'
    END AS business_readout
FROM pivoted;


--------------------------------------------------------------------------------
-- 9. FINAL BUSINESS RECOMMENDATION QUERY
-- Purpose:
-- Turn SQL output into a simple recommendation-ready result.
--------------------------------------------------------------------------------

WITH clean_assignments AS (
    SELECT *
    FROM (
        SELECT
            a.*,
            ROW_NUMBER() OVER (
                PARTITION BY player_id
                ORDER BY test_start_date ASC
            ) AS assignment_rank
        FROM ab_test_assignments a
        WHERE test_group IN ('Control', 'Variant')
          AND deposit_amount_14d >= 0
          AND bonus_cost_14d >= 0
          AND gross_revenue_14d >= 0
    ) x
    WHERE assignment_rank = 1
),

summary AS (
    SELECT
        test_group,
        COUNT(*) AS users,
        1.0 * SUM(deposit_converted) / COUNT(*) AS conversion_rate,
        AVG(ngr_14d) AS avg_ngr,
        AVG(bonus_cost_14d) AS avg_bonus_cost,
        1.0 * SUM(retained_14d) / COUNT(*) AS retention_rate
    FROM clean_assignments
    GROUP BY test_group
),

pivoted AS (
    SELECT
        MAX(CASE WHEN test_group = 'Control' THEN conversion_rate END) AS control_conversion,
        MAX(CASE WHEN test_group = 'Variant' THEN conversion_rate END) AS variant_conversion,
        MAX(CASE WHEN test_group = 'Control' THEN avg_ngr END) AS control_ngr,
        MAX(CASE WHEN test_group = 'Variant' THEN avg_ngr END) AS variant_ngr,
        MAX(CASE WHEN test_group = 'Control' THEN retention_rate END) AS control_retention,
        MAX(CASE WHEN test_group = 'Variant' THEN retention_rate END) AS variant_retention
    FROM summary
)

SELECT
    ROUND(100.0 * control_conversion, 2) AS control_conversion_rate_pct,
    ROUND(100.0 * variant_conversion, 2) AS variant_conversion_rate_pct,
    ROUND(100.0 * (variant_conversion - control_conversion), 2) AS conversion_lift_points,
    ROUND(control_ngr, 2) AS control_avg_ngr,
    ROUND(variant_ngr, 2) AS variant_avg_ngr,
    ROUND(variant_ngr - control_ngr, 2) AS avg_ngr_lift,
    ROUND(100.0 * control_retention, 2) AS control_retention_rate_pct,
    ROUND(100.0 * variant_retention, 2) AS variant_retention_rate_pct,
    CASE
        WHEN variant_conversion > control_conversion
         AND variant_ngr > control_ngr
        THEN 'Recommend rollout: Variant improves conversion and net revenue'
        WHEN variant_conversion > control_conversion
         AND variant_ngr <= control_ngr
        THEN 'Do not roll out yet: Variant improves conversion but not net revenue'
        ELSE 'Do not roll out: Variant does not improve primary outcome'
    END AS recommendation
FROM pivoted;
