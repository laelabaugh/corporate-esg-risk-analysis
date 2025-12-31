-- =============================================================================
-- ESG Risk Ratings Analysis: Business Analysis Queries
-- =============================================================================
-- Purpose: Extract actionable insights on corporate ESG performance
-- Dataset: S&P 500 ESG Risk Ratings (Sustainalytics)
-- =============================================================================

-- =============================================================================
-- SECTION 1: OVERALL ESG RISK SUMMARY
-- =============================================================================

-- Query 1.1: High-Level Portfolio Statistics
-- Purpose: Establish baseline metrics for the entire dataset
SELECT 
    COUNT(*) as total_companies,
    ROUND(AVG(total_esg_risk_score), 2) as avg_total_risk,
    ROUND(AVG(environmental_risk_score), 2) as avg_env_risk,
    ROUND(AVG(social_risk_score), 2) as avg_social_risk,
    ROUND(AVG(governance_risk_score), 2) as avg_gov_risk,
    ROUND(MIN(total_esg_risk_score), 2) as min_total_risk,
    ROUND(MAX(total_esg_risk_score), 2) as max_total_risk
FROM companies;

-- Query 1.2: Risk Category Distribution
-- Purpose: Understand how companies are distributed across risk tiers
SELECT 
    esg_risk_category,
    COUNT(*) as company_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM companies), 1) as percentage,
    ROUND(AVG(total_esg_risk_score), 2) as avg_risk_score
FROM companies
GROUP BY esg_risk_category
ORDER BY avg_risk_score;


-- =============================================================================
-- SECTION 2: SECTOR-LEVEL ANALYSIS
-- =============================================================================

-- Query 2.1: ESG Risk by Sector (Comprehensive)
-- Purpose: Identify highest and lowest risk sectors
SELECT 
    sector,
    COUNT(*) as company_count,
    ROUND(AVG(total_esg_risk_score), 2) as avg_total_risk,
    ROUND(AVG(environmental_risk_score), 2) as avg_env_risk,
    ROUND(AVG(social_risk_score), 2) as avg_social_risk,
    ROUND(AVG(governance_risk_score), 2) as avg_gov_risk
FROM companies
GROUP BY sector
ORDER BY avg_total_risk DESC;

-- Query 2.2: Sector Risk Percentile Rankings vs Market
-- Purpose: Compare each sector against market average
WITH sector_stats AS (
    SELECT 
        sector,
        AVG(total_esg_risk_score) as avg_risk
    FROM companies
    GROUP BY sector
),
overall_stats AS (
    SELECT 
        AVG(total_esg_risk_score) as overall_avg,
        AVG(total_esg_risk_score) - 1.5 * 
            (SELECT AVG(ABS(total_esg_risk_score - (SELECT AVG(total_esg_risk_score) FROM companies))) FROM companies) as low_threshold,
        AVG(total_esg_risk_score) + 1.5 * 
            (SELECT AVG(ABS(total_esg_risk_score - (SELECT AVG(total_esg_risk_score) FROM companies))) FROM companies) as high_threshold
    FROM companies
)
SELECT 
    s.sector,
    ROUND(s.avg_risk, 2) as avg_risk_score,
    ROUND(o.overall_avg, 2) as market_avg,
    ROUND(s.avg_risk - o.overall_avg, 2) as vs_market,
    CASE 
        WHEN s.avg_risk > o.high_threshold THEN 'Above Average Risk'
        WHEN s.avg_risk < o.low_threshold THEN 'Below Average Risk'
        ELSE 'Average Risk'
    END as risk_assessment
FROM sector_stats s, overall_stats o
ORDER BY s.avg_risk DESC;


-- =============================================================================
-- SECTION 3: ENVIRONMENTAL RISK DEEP DIVE
-- =============================================================================

-- Query 3.1: Environmental Risk Analysis by Sector
-- Purpose: Identify sectors with highest environmental exposure
SELECT 
    sector,
    ROUND(AVG(environmental_risk_score), 2) as avg_env_risk,
    ROUND(MIN(environmental_risk_score), 2) as min_env_risk,
    ROUND(MAX(environmental_risk_score), 2) as max_env_risk,
    ROUND(AVG(environmental_risk_score) / AVG(total_esg_risk_score) * 100, 1) as env_contribution_pct
FROM companies
GROUP BY sector
ORDER BY avg_env_risk DESC;

-- Query 3.2: Environmental Leaders vs Laggards
-- Purpose: Categorize sectors into environmental performance tiers
WITH env_ranking AS (
    SELECT 
        sector,
        ROUND(AVG(environmental_risk_score), 2) as avg_env_risk,
        ROW_NUMBER() OVER (ORDER BY AVG(environmental_risk_score) ASC) as best_rank,
        ROW_NUMBER() OVER (ORDER BY AVG(environmental_risk_score) DESC) as worst_rank
    FROM companies
    GROUP BY sector
)
SELECT 
    sector,
    avg_env_risk,
    CASE 
        WHEN best_rank <= 3 THEN 'Environmental Leader'
        WHEN worst_rank <= 3 THEN 'Environmental Laggard'
        ELSE 'Middle Tier'
    END as env_performance
FROM env_ranking
ORDER BY avg_env_risk ASC;


-- =============================================================================
-- SECTION 4: CONTROVERSY ANALYSIS
-- =============================================================================

-- Query 4.1: Controversy Analysis by Sector
-- Purpose: Identify sectors with highest controversy incidents
SELECT 
    sector,
    COUNT(*) as total_companies,
    SUM(CASE WHEN controversy_score >= 3 THEN 1 ELSE 0 END) as high_controversy_count,
    ROUND(SUM(CASE WHEN controversy_score >= 3 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as high_controversy_pct,
    ROUND(AVG(controversy_score), 2) as avg_controversy_score
FROM companies
GROUP BY sector
ORDER BY avg_controversy_score DESC;

-- Query 4.2: Risk Anomalies - High Controversy + Low ESG Risk Score
-- Purpose: Identify companies where controversy may not be reflected in risk ratings
SELECT 
    company_name,
    sector,
    total_esg_risk_score,
    esg_risk_category,
    controversy_score,
    controversy_level
FROM companies
WHERE controversy_score >= 3 
    AND total_esg_risk_score < (SELECT AVG(total_esg_risk_score) FROM companies)
ORDER BY controversy_score DESC, total_esg_risk_score ASC;


-- =============================================================================
-- SECTION 5: TOP/BOTTOM PERFORMERS
-- =============================================================================

-- Query 5.1: Top 10 Highest ESG Risk Companies
-- Purpose: Identify companies requiring most attention
SELECT 
    company_name,
    sector,
    total_esg_risk_score,
    esg_risk_category,
    controversy_level
FROM companies
ORDER BY total_esg_risk_score DESC
LIMIT 10;

-- Query 5.2: Top 10 ESG Leaders (Lowest Risk)
-- Purpose: Identify best-in-class performers
SELECT 
    company_name,
    sector,
    total_esg_risk_score,
    esg_risk_category,
    controversy_level
FROM companies
ORDER BY total_esg_risk_score ASC
LIMIT 10;

-- Query 5.3: Best Performer by Sector
-- Purpose: Identify ESG leader within each sector
WITH ranked AS (
    SELECT 
        company_name,
        sector,
        total_esg_risk_score,
        ROW_NUMBER() OVER (PARTITION BY sector ORDER BY total_esg_risk_score ASC) as rank
    FROM companies
)
SELECT 
    sector,
    company_name as sector_leader,
    total_esg_risk_score
FROM ranked
WHERE rank = 1
ORDER BY total_esg_risk_score ASC;


-- =============================================================================
-- SECTION 6: INDUSTRY-LEVEL ANALYSIS
-- =============================================================================

-- Query 6.1: Top 10 Riskiest Industries
-- Purpose: Filter down below sector level to identify high-risk business lines
SELECT 
    industry,
    sector,
    COUNT(*) as company_count,
    ROUND(AVG(total_esg_risk_score), 2) as avg_total_risk,
    ROUND(AVG(environmental_risk_score), 2) as avg_env_risk
FROM companies
GROUP BY industry
HAVING COUNT(*) >= 3  -- Only industries with meaningful sample size
ORDER BY avg_total_risk DESC
LIMIT 10;

-- Query 6.2: Industry Risk Spread within Sectors
-- Purpose: Understand risk variation within sectors
SELECT 
    sector,
    COUNT(DISTINCT industry) as industry_count,
    ROUND(MIN(avg_risk), 2) as lowest_industry_risk,
    ROUND(MAX(avg_risk), 2) as highest_industry_risk,
    ROUND(MAX(avg_risk) - MIN(avg_risk), 2) as risk_spread
FROM (
    SELECT 
        sector,
        industry,
        AVG(total_esg_risk_score) as avg_risk
    FROM companies
    GROUP BY sector, industry
)
GROUP BY sector
ORDER BY risk_spread DESC;


-- =============================================================================
-- SECTION 7: COMPANY SIZE ANALYSIS
-- =============================================================================

-- Query 7.1: ESG Risk by Company Size
-- Purpose: Determine if larger companies manage ESG risk better
SELECT 
    CASE 
        WHEN full_time_employees < 10000 THEN 'Small (<10K)'
        WHEN full_time_employees < 50000 THEN 'Medium (10K-50K)'
        WHEN full_time_employees < 100000 THEN 'Large (50K-100K)'
        ELSE 'Enterprise (100K+)'
    END as company_size,
    COUNT(*) as company_count,
    ROUND(AVG(total_esg_risk_score), 2) as avg_total_risk,
    ROUND(AVG(controversy_score), 2) as avg_controversy
FROM companies
GROUP BY company_size
ORDER BY avg_total_risk DESC;


-- =============================================================================
-- SECTION 8: COMPOSITE SCORING & RANKINGS
-- =============================================================================

-- Query 8.1: Create composite ESG score with controversy adjustment
-- Purpose: Develop a risk-adjusted score incorporating controversy
SELECT 
    company_name,
    sector,
    total_esg_risk_score,
    controversy_score,
    ROUND(total_esg_risk_score * (1 + controversy_score * 0.1), 2) as adjusted_risk_score,
    RANK() OVER (ORDER BY total_esg_risk_score * (1 + controversy_score * 0.1) DESC) as risk_rank
FROM companies
ORDER BY adjusted_risk_score DESC
LIMIT 20;

-- Query 8.2: Sector-Relative Performance
-- Purpose: Rank companies relative to their sector peers
SELECT 
    company_name,
    sector,
    total_esg_risk_score,
    sector_avg,
    ROUND(total_esg_risk_score - sector_avg, 2) as vs_sector_avg,
    CASE 
        WHEN total_esg_risk_score < sector_avg * 0.8 THEN 'Outperformer'
        WHEN total_esg_risk_score > sector_avg * 1.2 THEN 'Underperformer'
        ELSE 'In-Line'
    END as sector_relative_performance
FROM companies c
JOIN (
    SELECT sector, ROUND(AVG(total_esg_risk_score), 2) as sector_avg
    FROM companies
    GROUP BY sector
) s ON c.sector = s.sector
ORDER BY vs_sector_avg ASC
LIMIT 20;


-- =============================================================================
-- SECTION 9: RISK CONCENTRATION ANALYSIS
-- =============================================================================

-- Query 9.1: Identify companies with single-factor risk concentration
-- Purpose: Find companies where one ESG pillar dominates total risk
SELECT 
    company_name,
    sector,
    total_esg_risk_score,
    ROUND(environmental_risk_score / total_esg_risk_score * 100, 1) as env_pct,
    ROUND(social_risk_score / total_esg_risk_score * 100, 1) as social_pct,
    ROUND(governance_risk_score / total_esg_risk_score * 100, 1) as gov_pct,
    CASE 
        WHEN environmental_risk_score / total_esg_risk_score > 0.5 THEN 'Environmental-Heavy'
        WHEN social_risk_score / total_esg_risk_score > 0.5 THEN 'Social-Heavy'
        WHEN governance_risk_score / total_esg_risk_score > 0.5 THEN 'Governance-Heavy'
        ELSE 'Balanced'
    END as risk_concentration
FROM companies
WHERE environmental_risk_score / total_esg_risk_score > 0.5
   OR social_risk_score / total_esg_risk_score > 0.5
   OR governance_risk_score / total_esg_risk_score > 0.5
ORDER BY total_esg_risk_score DESC;


-- =============================================================================
-- SECTION 10: SUMMARY STATISTICS FOR DASHBOARD
-- =============================================================================

-- Query 10.1: Key Metrics Summary Card
-- Purpose: Generate summary statistics for executive dashboard
SELECT 
    (SELECT COUNT(*) FROM companies) as total_companies,
    (SELECT ROUND(AVG(total_esg_risk_score), 2) FROM companies) as market_avg_risk,
    (SELECT sector FROM companies GROUP BY sector ORDER BY AVG(total_esg_risk_score) DESC LIMIT 1) as highest_risk_sector,
    (SELECT ROUND(AVG(total_esg_risk_score), 2) FROM companies GROUP BY sector ORDER BY AVG(total_esg_risk_score) DESC LIMIT 1) as highest_sector_risk,
    (SELECT sector FROM companies GROUP BY sector ORDER BY AVG(total_esg_risk_score) ASC LIMIT 1) as lowest_risk_sector,
    (SELECT ROUND(AVG(total_esg_risk_score), 2) FROM companies GROUP BY sector ORDER BY AVG(total_esg_risk_score) ASC LIMIT 1) as lowest_sector_risk,
    (SELECT COUNT(*) FROM companies WHERE esg_risk_category IN ('High', 'Severe')) as high_risk_count,
    (SELECT COUNT(*) FROM companies WHERE controversy_score >= 4) as severe_controversy_count;
