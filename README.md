# S&P 500 Corporate ESG Risk Analysis

## Project Background and Overview

Environmental, Social, and Governance (ESG) investing has become a key framework for evaluating corporate sustainability and ethical impact. ESG criteria help investors to screen companies based on their environmental practices, social responsibility, and corporate governance standards.

This project analyzes ESG Risk Ratings for 162 S&P 500 companies across 11 sectors. The data comes from Sustainalytics, an ESG research and ratings provider. The dataset captures ESG risk assessments measuring a company's unmanaged ESG risk exposure at one single point in time.

*This project was conducted in October 2025 and later uploaded to GitHub in December 2025.*

### Key business questions addressed:

- **Sector Risk Analysis:** Which sectors have the highest ESG risk, and what causes that risk?
- **Environmental Leadership:** Which sectors and companies are the best and worst-performing environmentally?
- **Controversy Assessment:** How do negative controversy incidents relate to overall ESG risk?
- **Risk Distribution:** What percentage of S&P 500 companies fall into each risk category?
- **Anomaly Detection:** Are there companies with high number of controversy incidents but misleadingly low ESG risk scores?

### Dataset Information

**Source:** [S&P 500 ESG Risk Ratings - Kaggle](https://www.kaggle.com/datasets/pritish509/s-and-p-500-esg-risk-ratings)

**Provider:** Sustainalytics ESG Risk Ratings

The SQL queries used to inspect, clean, and analyze data for this project can be found through the following links: 
[Inspecting Queries](/sql/03_data_inspection.sql),
[Cleaning Queries](/sql/04_data_cleaning.sql),
[Analysis Queries](/sql/05_analysis_queries.sql)

---

## Data Structure Overview

The dataset contains 162 companies with 11 attributes covering ESG risk metrics, controversy assessments, and company characteristics.

### Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              COMPANIES                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│  company_name              VARCHAR     Company name (Primary Key)           │
│  sector                    VARCHAR     Business sector classification       │
│  industry                  VARCHAR     Sub-industry classification          │
│  environmental_risk_score  FLOAT       Environmental risk (0-25)            │
│  social_risk_score         FLOAT       Social risk (0-21)                   │
│  governance_risk_score     FLOAT       Governance risk (0-15.5)             │
│  total_esg_risk_score      FLOAT       Combined ESG risk score              │
│  esg_risk_category         VARCHAR     Risk tier (Negligible to Severe)     │
│  controversy_score         INTEGER     Controversy incidents (0-5)          │
│  controversy_level         VARCHAR     Controversy severity classification  │
│  full_time_employees       INTEGER     Company workforce size               │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ 1:N
                                    ▼
┌─────────────────────────────┐    ┌─────────────────────────────┐
│         SECTORS             │    │        INDUSTRIES           │
├─────────────────────────────┤    ├─────────────────────────────┤
│  sector_id    INTEGER (PK)  │    │  industry_id  INTEGER (PK)  │
│  sector       VARCHAR       │    │  industry     VARCHAR       │
│                             │    │  sector       VARCHAR (FK)  │
└─────────────────────────────┘    └─────────────────────────────┘
```

### Data Dictionary

| Column | Description | Data Type | Range/Values |
|--------|-------------|-----------|--------------|
| `company_name` | Legal company name | VARCHAR | Unique identifier |
| `sector` | GICS sector classification | VARCHAR | 11 sectors |
| `industry` | Sub-industry classification | VARCHAR | 25+ industries |
| `environmental_risk_score` | Unmanaged environmental risk | FLOAT | 0.0 - 25.0 |
| `social_risk_score` | Unmanaged social risk | FLOAT | 1.0 - 21.0 |
| `governance_risk_score` | Unmanaged governance risk | FLOAT | 3.0 - 15.5 |
| `total_esg_risk_score` | Sum of E + S + G scores | FLOAT | 8.7 - 40.4 |
| `esg_risk_category` | Risk classification tier | VARCHAR | Negligible, Low, Medium, High, Severe |
| `controversy_score` | Controversy incident rating | INTEGER | 0 - 5 |
| `controversy_level` | Controversy severity | VARCHAR | None, Low, Moderate, Significant, High, Severe |
| `full_time_employees` | Company workforce size | INTEGER | 1,000 - 1,300,000+ |

---

## Executive Summary

### Overview of Findings

Across 162 S&P 500 companies, ESG risk varies widely by sector, with Energy leading as the highest-risk sector at an average total ESG risk score of 34.62 (57% above the market average of 22.09). Real Estate, on the other hand, demonstrates strong sustainability performance with an average score of just 12.58, approximately 43% below the average.

The majority of companies (51.2%) fall within the "Medium" risk category; only 11.1% fall under "High" or "Severe". Environmental factors result in the widest gap between sectors. Energy's environmental score (15.46) runs about 12 times higher than Communication Services (1.28).

### Key Performance Indicators

| Metric | Value | More info |
|--------|-------|---------|
| Companies Analyzed | 162 | S&P 500 subset |
| Average ESG Risk Score | 22.09 | Market baseline |
| Highest Sector Risk | Energy (34.62) | 57% above market |
| Lowest Sector Risk | Real Estate (12.58) | 43% below market |
| High/Severe Risk Companies | 18 (11.1%) | Needs attention |
| ESG Leaders (low risk) | 61 (37.7%) | Strong performers |

Below is a summary dashboard of key ESG performance indicators:

![Executive Dashboard](/visualizations/06_executive_dashboard.png)

---

## Insights Deep Dive

### 1. ESG Risk Distribution

The analysis reveals that over half of S&P 500 companies have Medium ESG risk, while extreme categories (Negligible and Severe) are more rare. Such a distribution suggests that most of these large corporations have made moderate progress on sustainability but still face significant unmanaged risks.

| Risk Category | Company Count | Percentage | Avg Risk Score |
|---------------|---------------|------------|----------------|
| Negligible | 3 | 1.9% | 9.27 |
| Low | 58 | 35.8% | 16.28 |
| Medium | 83 | 51.2% | 23.85 |
| High | 17 | 10.5% | 34.50 |
| Severe | 1 | 0.6% | 40.40 |

**Key Insight:** Only 3 companies reach "Negligible" risk status, so there is room for improvement overall. The concentration in the "Medium" category likely means that most companies have addressed obvious ESG risks but haven't achieved industry-leading practices.

---

### 2. Sector Performance

The Energy sector has strong ESG risk, with an average score 57% above the market average. This is primarily driven by environmental factors, which contribute 44.7% of the sector's total risk, the highest environmental contribution of any sector.

| Sector | Avg. Total Risk | Avg. Env Risk | Avg. Social Risk | Avg. Gov Risk |
|--------|----------------|--------------|-----------------|--------------|
| Energy | 34.62 | 15.46 | 10.73 | 8.43 |
| Materials | 24.55 | 11.12 | 8.16 | 5.28 |
| Utilities | 24.39 | 10.86 | 6.57 | 6.96 |
| Healthcare | 23.02 | 3.53 | 12.73 | 6.80 |
| Industrials | 22.53 | 7.34 | 8.29 | 6.89 |
| Financial Services | 22.32 | 2.21 | 10.58 | 9.51 |
| Consumer Staples | 20.96 | 5.27 | 10.07 | 5.62 |
| Consumer Discretionary | 20.58 | 4.67 | 9.25 | 6.63 |
| Communication Services | 20.54 | 1.28 | 9.12 | 10.18 |
| Technology | 16.84 | 1.96 | 7.59 | 7.27 |
| Real Estate | 12.58 | 2.29 | 4.67 | 5.61 |

**Key Insight:** While Energy struggles with environmental metrics, Healthcare faces its greatest challenge in social risk at 12.73 average. Drug pricing, clinical trial ethics, and healthcare access issues likely play a role. Financial Services and Communication Services show high governance risk, which probably reflects examination of executive pay, board diversity, and data privacy practices.

![Sector Deep Dive](/visualizations/07_sector_deep_dive.png)

---

### 3. Environmental Risk Analysis: Leaders vs. Laggards

Environmental factors show the widest spread across sectors, making them the primary differentiator in ESG performance. This can be segmented into three tiers:

**Environmental Leaders** (Avg. Environmental Risk < 3.0):
- Communication Services: 1.28
- Technology: 1.96  
- Financial Services: 2.21

**Environmental Laggards** (Avg. Environmental Risk > 10.0):
- Utilities: 10.86
- Materials: 11.12
- Energy: 15.46

| Sector | Avg Env Risk | Env Contribution |
|--------|--------------|------------------|
| Communication Services | 1.28 | 6.3% |
| Technology | 1.96 | 11.6% |
| Financial Services | 2.21 | 9.9% |
| Energy | 15.46 | 44.7% |
| Materials | 11.12 | 45.3% |

**Key Insight:** Environmental risk accounts for almost half of total ESG risk in Energy and Materials sectors, compared to less than 10% in Financial Services and Communication Services. This gap creates both the risk of new environmental regulation for laggards and investment opportunity for companies showing environmental leadership within high-risk sectors.

![Sector Heatmap](/visualizations/09_sector_heatmap.png)

---

### 4. Industry Spotlight

When you filter down from sectors to industries, it reveals that Renewable Energy paradoxically ranks as the highest-risk industry with an average score of 36.00. This likely reflects issues such as the capital-intensive nature of renewable projects, supply chain challenges (like raw materials that involve substances like rare earth minerals), and land-use disputes.

| Industry | Sector | Companies | Avg Total Risk | Avg Env Risk |
|----------|--------|-----------|----------------|--------------|
| Renewable Energy | Energy | 5 | 36.00 | 16.86 |
| Energy Equipment | Energy | 5 | 35.08 | 15.82 |
| Oil & Gas | Energy | 5 | 32.78 | 13.70 |
| Metals & Mining | Materials | 5 | 26.92 | 12.70 |
| Water Utilities | Utilities | 5 | 26.06 | 11.20 |
| Aerospace & Defense | Industrials | 4 | 25.07 | 8.75 |
| Healthcare Services | Healthcare | 3 | 24.43 | 4.63 |
| Paper & Packaging | Materials | 8 | 24.35 | 11.41 |

**Key Insight:** Investors seeking environmentally-beneficial investments through Renewable Energy companies should make note of the fact that these firms often have significant ESG risk due to complexed operations. The data suggests ESG-focused investing requires careful sector and industry-level analysis rather than simple screens.

---

### 5. Controversy Assessment: Hidden Risks

Analysis found 25 companies with high controversy scores ( greater than or equal to 3) but below-average ESG risk scores These may represent situations of possible hidden risk where headline incidents are not fully reflected in risk ratings.

**Notable Risk Anomalies:**

| Company | Sector | ESG Risk Score | Controversy Level |
|---------|--------|----------------|-------------------|
| Estee Lauder | Consumer Staples | 21.4 | Severe |
| Welltower Inc. | Real Estate | 14.1 | High |
| Texas Instruments | Technology | 15.2 | High |
| General Mills | Consumer Staples | 15.9 | High |
| Chipotle Mexican | Consumer Discretionary | 19.5 | High |
| Goldman Sachs | Financial Services | 19.3 | Significant |
| Walmart Inc. | Consumer Staples | 18.2 | Significant |
| JPMorgan Chase | Financial Services | 20.4 | Significant |

**Key Insight:** These companies need extra due diligence. A "Low" or "Medium" ESG risk rating combined with high controversy may suggest either recent incidents not yet reflected in ratings, or limitations in capturing reputational risk. Consumer Staples seems particularly prone to this disconnect, with 7 of its 15 companies (46.7%) showing high controversy.

---

### 6. ESG Leaders: Top Performing Companies

The top ESG performers are concentrated in Real Estate and Technology, reflecting lower environmental footprints and established governance frameworks.

| Company | Sector | ESG Risk Score | Risk Category |
|---------|--------|----------------|---------------|
| Kimco Realty | Real Estate | 8.7 | Negligible |
| Realty Income | Real Estate | 9.4 | Negligible |
| Ventas Inc. | Real Estate | 9.7 | Negligible |
| Public Storage | Real Estate | 11.2 | Low |
| Alphabet Inc. | Technology | 11.4 | Low |
| Equinix Inc. | Real Estate | 11.4 | Low |
| Alexandria Real Estate | Real Estate | 11.9 | Low |
| Oracle Corp. | Technology | 12.0 | Low |
| Equity Residential | Real Estate | 12.0 | Low |
| Sysco Corp. | Consumer Staples | 12.4 | Low |

**Key Insight:** Real Estate dominates ESG leadership positions, with 7 of the top 10 performers. This sector's inherent characteristics (long-lived assets, tenant relationships, and regulatory compliance requirements) might naturally align with ESG best practices.

---

### 7. Company Size and ESG Risk: Minimal Correlation

Analysis of ESG risk by employee count shows no clear relationship between company size and ESG performance. This goes against the assumption that larger companies with more resources necessarily manage ESG risks better.

| Company Size | Companies | Avg Total Risk | Avg Controversy |
|--------------|-----------|----------------|-----------------|
| Large (50K-100K) | 23 | 22.88 | 1.57 |
| Enterprise (100K+) | 21 | 22.66 | 1.81 |
| Medium (10K-50K) | 71 | 21.91 | 1.77 |
| Small (<10K) | 47 | 21.72 | 2.06 |

**Key Insight:** Smaller companies actually show marginally lower average ESG risk scores (21.72) than large enterprises (22.88), though they experience slightly higher controversy scores. This suggests ESG performance is driven more by industry exposure, business model, and management commitment than organizational scale.

![Risk Analysis](/visualizations/08_risk_analysis.png)

---

## Recommendations

Based on the analysis, the following are a few recommendations for key stakeholders:

### For ESG-Focused Investors:

1. **What sectors you invest in matters more for ESG risk than stock selection.** Since the Energy sector's average ESG risk is 57% above the market baseline, reducing exposure to Energy will improve a portfolio's ESG score more than carefully picking individual companies in already low-risk sectors.

2. **Look closer at high-controversy, low-score companies.** The 25 companies identified as risk anomalies warrant deeper analysis, particularly in Consumer Staples where 47% of companies show high controversy despite moderate risk scores.

3. **Don't assume "green" means low-risk.** Renewable Energy companies carry the highest industry-level ESG risk (36.00 average). Sustainable investing requires understanding operational risks, which goes beyond just a face of sustainability causes.

### For Corporate Sustainability Teams:

4. **Energy and Materials companies should prioritize environmental risk reduction.** It drives nearly half their total ESG risk score. Targeted initiatives in emissions reduction, waste management, and resource efficiency will likely result in the greatest score improvement.

5. **Healthcare companies should address social risk factors.** Drug pricing transparency, clinical trial ethics, and healthcare access contribute disproportionately to the sector's ESG profile.

6. **Financial Services and Communication Services should focus on governance improvements.** This includes board diversity, executive compensation alignment with ESG goals, and data privacy practices.

### For Risk Management:

7. **Monitor controversies alongside ESG scores.** Fixed risk ratings can miss real-time reputation issues. When a company's controversy level doesn't match its risk score, it can be an early warning sign.

8. **Real Estate tends to be a safer ESG option.** Consistently low risk scores and minimal controversy make it worth considering this sector for ESG-focused portfolios that want more stability.

---

## Limitations and Future Work

**Current Limitations:**
- This data represents a point-in-time snapshot, and trend analysis is not possible with single-period data.
- Only 162 of 500 S&P 500 companies are represented, so there may be coverage gaps in some sectors.
- ESG scoring methodologies may vary across providers, so results may differ with other data sources.

**Future Enhancements:**
- Incorporate time-series data to analyze ESG score trends and momentum.
- Add financial performance metrics to correlate ESG scores with returns.
- Expand to full S&P 500 coverage and international indices.
  
---

## Technical Implementation

### SQL Queries Reference

The analysis was conducted using SQLite with the following query categories:

| Query Type | Purpose | Example |
|------------|---------|---------|
| Aggregation | Sector/industry averages | `AVG()`, `COUNT()`, `GROUP BY` |
| Window Functions | Percentile rankings | `ROW_NUMBER() OVER()` |
| CTEs | Complex multi-step analysis | `WITH sector_stats AS (...)` |
| Conditional Logic | Risk categorization | `CASE WHEN... THEN...` |
| Subqueries | Market comparisons | `(SELECT AVG(...) FROM companies)` |

### Repository Structure

```
├── README.md             
├── data/
│   └── 02_sp500_esg_risk_ratings.csv
├── sql/
│   ├── 03_data_inspection.sql
│   ├── 04_data_cleaning.sql
│   └── 05_analysis_queries.sql
└── visualizations/
│   ├── 06_executive_dashboard.png
│   ├── 07_sector_deep_dive.png
│   └── 08_risk_analysis.png
│   └── 09_sector_heatmap.png
```
