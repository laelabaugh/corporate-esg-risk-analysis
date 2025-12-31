-- =============================================================================
-- ESG Risk Ratings Analysis: Data Inspection Queries
-- =============================================================================
-- Purpose: Initial data quality checks
-- Dataset: S&P 500 ESG Risk Ratings (Sustainalytics)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Basic table overview
-- -----------------------------------------------------------------------------
-- Check total row count and column structure
SELECT 
    COUNT(*) as total_records
FROM companies;

-- Preview first 10 rows
SELECT * 
FROM companies 
LIMIT 10;

-- -----------------------------------------------------------------------------
-- 2. Check for null values
-- -----------------------------------------------------------------------------
-- Count nulls in each key column
SELECT 
    SUM(CASE WHEN company_name IS NULL THEN 1 ELSE 0 END) as null_company_name,
    SUM(CASE WHEN sector IS NULL THEN 1 ELSE 0 END) as null_sector,
    SUM(CASE WHEN industry IS NULL THEN 1 ELSE 0 END) as null_industry,
    SUM(CASE WHEN environmental_risk_score IS NULL THEN 1 ELSE 0 END) as null_env_risk,
    SUM(CASE WHEN social_risk_score IS NULL THEN 1 ELSE 0 END) as null_social_risk,
    SUM(CASE WHEN governance_risk_score IS NULL THEN 1 ELSE 0 END) as null_gov_risk,
    SUM(CASE WHEN total_esg_risk_score IS NULL THEN 1 ELSE 0 END) as null_total_risk,
    SUM(CASE WHEN esg_risk_category IS NULL THEN 1 ELSE 0 END) as null_risk_category,
    SUM(CASE WHEN controversy_score IS NULL THEN 1 ELSE 0 END) as null_controversy_score,
    SUM(CASE WHEN full_time_employees IS NULL THEN 1 ELSE 0 END) as null_employees
FROM companies;

-- -----------------------------------------------------------------------------
-- 3. Check for duplicate company names
-- -----------------------------------------------------------------------------
SELECT 
    company_name,
    COUNT(*) as occurrence_count
FROM companies
GROUP BY company_name
HAVING COUNT(*) > 1;

-- -----------------------------------------------------------------------------
-- 4. Verify risk score calculation accuracy
-- -----------------------------------------------------------------------------
-- Ensure total_esg_risk_score = env + social + gov (with tolerance for rounding)
SELECT 
    company_name,
    environmental_risk_score,
    social_risk_score,
    governance_risk_score,
    total_esg_risk_score,
    (environmental_risk_score + social_risk_score + governance_risk_score) as calculated_total,
    ABS(total_esg_risk_score - (environmental_risk_score + social_risk_score + governance_risk_score)) as difference
FROM companies
WHERE ABS(total_esg_risk_score - (environmental_risk_score + social_risk_score + governance_risk_score)) > 0.5;

-- -----------------------------------------------------------------------------
-- 5. Unique value counts for category columns
-- -----------------------------------------------------------------------------
-- Sectors
SELECT 
    sector,
    COUNT(*) as company_count
FROM companies
GROUP BY sector
ORDER BY company_count DESC;

-- Industries
SELECT 
    industry,
    COUNT(*) as company_count
FROM companies
GROUP BY industry
ORDER BY company_count DESC;

-- Risk Categories
SELECT 
    esg_risk_category,
    COUNT(*) as company_count
FROM companies
GROUP BY esg_risk_category
ORDER BY company_count DESC;

-- Controversy Levels
SELECT 
    controversy_level,
    COUNT(*) as company_count
FROM companies
GROUP BY controversy_level
ORDER BY company_count DESC;

-- -----------------------------------------------------------------------------
-- 6. Score range validation
-- -----------------------------------------------------------------------------
-- Check score distributions and identify potential outliers
SELECT 
    'environmental_risk_score' as metric,
    MIN(environmental_risk_score) as min_val,
    MAX(environmental_risk_score) as max_val,
    ROUND(AVG(environmental_risk_score), 2) as avg_val
FROM companies
UNION ALL
SELECT 
    'social_risk_score',
    MIN(social_risk_score),
    MAX(social_risk_score),
    ROUND(AVG(social_risk_score), 2)
FROM companies
UNION ALL
SELECT 
    'governance_risk_score',
    MIN(governance_risk_score),
    MAX(governance_risk_score),
    ROUND(AVG(governance_risk_score), 2)
FROM companies
UNION ALL
SELECT 
    'total_esg_risk_score',
    MIN(total_esg_risk_score),
    MAX(total_esg_risk_score),
    ROUND(AVG(total_esg_risk_score), 2)
FROM companies;

-- -----------------------------------------------------------------------------
-- 7. Check employee count
-- -----------------------------------------------------------------------------
SELECT 
    company_name,
    full_time_employees
FROM companies
WHERE full_time_employees < 100 OR full_time_employees > 2000000
ORDER BY full_time_employees DESC;
