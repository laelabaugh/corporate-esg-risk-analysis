-- =============================================================================
-- ESG Risk Ratings Analysis: Data Cleaning & Preparation Queries
-- =============================================================================
-- Purpose: Clean and prepare data for analysis
-- Dataset: S&P 500 ESG Risk Ratings (Sustainalytics)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Remove Duplicate Records (if any)
-- -----------------------------------------------------------------------------
-- Create a clean version keeping only first occurrence of duplicates
CREATE TABLE companies_clean AS
SELECT DISTINCT *
FROM companies;

-- Verify deletion of duplicates
SELECT COUNT(*) as original_count FROM companies;
SELECT COUNT(*) as clean_count FROM companies_clean;

-- -----------------------------------------------------------------------------
-- 2. Standardize text fields
-- -----------------------------------------------------------------------------
-- Trim whitespace and standardize case for categorical fields
UPDATE companies_clean
SET 
    company_name = TRIM(company_name),
    sector = TRIM(sector),
    industry = TRIM(industry),
    esg_risk_category = TRIM(esg_risk_category),
    controversy_level = TRIM(controversy_level);

-- -----------------------------------------------------------------------------
-- 3. Handle missing values
-- -----------------------------------------------------------------------------
-- Check for any missing values in critical fields
SELECT 
    company_name,
    sector,
    industry,
    environmental_risk_score,
    social_risk_score,
    governance_risk_score
FROM companies_clean
WHERE 
    environmental_risk_score IS NULL 
    OR social_risk_score IS NULL 
    OR governance_risk_score IS NULL
    OR sector IS NULL
    OR industry IS NULL;

-- If missing values exist, options are:
-- Option A: Delete records with missing critical values
-- DELETE FROM companies_clean WHERE environmental_risk_score IS NULL;

-- Option B: Impute with sector average (example for environmental_risk_score)
-- UPDATE companies_clean c
-- SET environmental_risk_score = (
--     SELECT ROUND(AVG(environmental_risk_score), 2)
--     FROM companies_clean
--     WHERE sector = c.sector AND environmental_risk_score IS NOT NULL
-- )
-- WHERE c.environmental_risk_score IS NULL;

-- -----------------------------------------------------------------------------
-- 4. Validate risk category assignment
-- -----------------------------------------------------------------------------
-- Verify risk categories align with score ranges
-- Sustainalytics Risk Categories:
-- Negligible: 0-10, Low: 10-20, Medium: 20-30, High: 30-40, Severe: 40+

SELECT 
    company_name,
    total_esg_risk_score,
    esg_risk_category,
    CASE 
        WHEN total_esg_risk_score < 10 THEN 'Negligible'
        WHEN total_esg_risk_score < 20 THEN 'Low'
        WHEN total_esg_risk_score < 30 THEN 'Medium'
        WHEN total_esg_risk_score < 40 THEN 'High'
        ELSE 'Severe'
    END as expected_category
FROM companies_clean
WHERE esg_risk_category != CASE 
        WHEN total_esg_risk_score < 10 THEN 'Negligible'
        WHEN total_esg_risk_score < 20 THEN 'Low'
        WHEN total_esg_risk_score < 30 THEN 'Medium'
        WHEN total_esg_risk_score < 40 THEN 'High'
        ELSE 'Severe'
    END;

-- -----------------------------------------------------------------------------
-- 5. Create derived columns for analysis
-- -----------------------------------------------------------------------------
-- Add useful calculated fields
ALTER TABLE companies_clean ADD COLUMN env_risk_pct REAL;
ALTER TABLE companies_clean ADD COLUMN social_risk_pct REAL;
ALTER TABLE companies_clean ADD COLUMN gov_risk_pct REAL;
ALTER TABLE companies_clean ADD COLUMN company_size_category TEXT;

-- Calculate percentage contribution of each risk type
UPDATE companies_clean
SET 
    env_risk_pct = ROUND(environmental_risk_score / total_esg_risk_score * 100, 1),
    social_risk_pct = ROUND(social_risk_score / total_esg_risk_score * 100, 1),
    gov_risk_pct = ROUND(governance_risk_score / total_esg_risk_score * 100, 1);

-- Categorize company size
UPDATE companies_clean
SET company_size_category = CASE 
    WHEN full_time_employees < 10000 THEN 'Small (<10K)'
    WHEN full_time_employees < 50000 THEN 'Medium (10K-50K)'
    WHEN full_time_employees < 100000 THEN 'Large (50K-100K)'
    ELSE 'Enterprise (100K+)'
END;

-- -----------------------------------------------------------------------------
-- 6. Create Lookup Tables for Normalization
-- -----------------------------------------------------------------------------
-- Sectors lookup table
CREATE TABLE IF NOT EXISTS sectors (
    sector_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sector_name TEXT UNIQUE NOT NULL
);

INSERT OR IGNORE INTO sectors (sector_name)
SELECT DISTINCT sector FROM companies_clean ORDER BY sector;

-- Industries lookup table
CREATE TABLE IF NOT EXISTS industries (
    industry_id INTEGER PRIMARY KEY AUTOINCREMENT,
    industry_name TEXT UNIQUE NOT NULL,
    sector_name TEXT NOT NULL
);

INSERT OR IGNORE INTO industries (industry_name, sector_name)
SELECT DISTINCT industry, sector FROM companies_clean ORDER BY sector, industry;

-- Risk Categories lookup table
CREATE TABLE IF NOT EXISTS risk_categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT UNIQUE NOT NULL,
    min_score REAL,
    max_score REAL
);

INSERT OR REPLACE INTO risk_categories VALUES 
    (1, 'Negligible', 0, 10),
    (2, 'Low', 10, 20),
    (3, 'Medium', 20, 30),
    (4, 'High', 30, 40),
    (5, 'Severe', 40, 100);

-- -----------------------------------------------------------------------------
-- 7. Final data quality summary
-- -----------------------------------------------------------------------------
SELECT 
    'Total Companies' as metric,
    COUNT(*) as value
FROM companies_clean
UNION ALL
SELECT 
    'Unique Sectors',
    COUNT(DISTINCT sector)
FROM companies_clean
UNION ALL
SELECT 
    'Unique Industries',
    COUNT(DISTINCT industry)
FROM companies_clean
UNION ALL
SELECT 
    'Records with Complete Data',
    SUM(CASE WHEN 
        company_name IS NOT NULL 
        AND sector IS NOT NULL 
        AND environmental_risk_score IS NOT NULL 
        AND social_risk_score IS NOT NULL 
        AND governance_risk_score IS NOT NULL 
    THEN 1 ELSE 0 END)
FROM companies_clean;
