# Healthcare Data Analytics with Python

Analysis of coverage post-ObamaCare using Python for data processing and visualization.

## Project Overview

This project examines the change in healthcare coverage across all 50 US states as a result of the Affordable Care Act and Health Care Education Reconciliation Act that went into effect in late 2013.

## Dataset

**Source**: [Kaggle Health Insurance Dataset](https://www.kaggle.com/datasets/hhs/health-insurance)

**Key Metrics Analyzed**:
- Health insurance coverage change (2010-2015)
- Uninsured rate changes by state
- Medicaid enrollment changes (2013-2016)
- State Medicaid expansion adoption (2016)

## Features

- **Interactive Menu System**: User-driven data exploration
- **Data Preprocessing**: Column cleaning and standardization
- **Statistical Analysis**: Summary statistics and data preview
- **Data Visualization**: 
  - Horizontal bar charts for state comparisons
  - Pie charts for expansion statistics
  - Time series analysis
  - Custom styling with fivethirtyeight theme

## Technologies Used

- **Python**: Core programming language
- **pandas**: Data manipulation and analysis
- **matplotlib**: Data visualization
- **CSV processing**: File I/O operations

## Data Source Information

**Dataset:** Health Insurance Coverage Data  
**Source:** Healthcare.gov and Census Bureau public datasets  
**Note:** The `healthinsurance.csv` file is excluded from git due to size constraints. 

**To obtain the dataset:**
1. Download from public healthcare data repositories
2. Use similar health insurance coverage datasets from data.gov
3. Contact repository owner for sample dataset access
4. The Python script (`HealthcareMain.py`) can work with any CSV containing state-level health metrics

**Required CSV format:**
- State names/codes
- Health insurance coverage percentages  
- Population demographics
- Pre/post policy implementation data

## Key Visualizations

1. **Coverage Change Analysis** - State-by-state insurance coverage improvements
2. **Uninsured Rate Reduction** - Ranking states by coverage gains
3. **Medicaid Enrollment Growth** - Impact of Medicaid expansion by state
4. **Expansion Adoption Rates** - Percentage of states expanding Medicaid
5. **Impact Analysis** - Total enrollment changes by expansion status

## How to Run

```bash
python HealthcareMain.py
```

Follow the interactive menu to explore different aspects of the healthcare data:
- Enter numbers 1-7 to view different analyses
- Enter 9 to quit the program

## Code Highlights

- **Efficient Data Handling**: Strategic file opening for memory management
- **Clean Data Processing**: Automated column name standardization
- **User-Friendly Interface**: Menu-driven exploration system
- **Production Patterns**: Error handling and input validation
- **Flexible Visualization**: Dynamic chart generation based on data

## Key Insights

The analysis reveals significant improvements in healthcare coverage following ACA implementation, with notable variations between states that expanded Medicaid versus those that did not.

---
*Part of Joemichael Alvarez's Data Analytics Portfolio*
