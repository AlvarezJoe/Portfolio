# MLOps Pipeline for Model Monitoring

A comprehensive MLOps framework demonstrating production machine learning best practices with automated model monitoring and drift detection.

## Project Overview

This project showcases a complete MLOps pipeline for housing price prediction with:
- **Model Training & Tracking**: MLflow integration for experiment management
- **Drift Detection**: Evidently AI for monitoring data and target drift
- **Automated Monitoring**: Scheduled drift reporting and alerts
- **Interactive Dashboard**: Streamlit app for real-time monitoring
- **Orchestration**: Prefect workflows for automation

## Architecture

```
├── data/
│   ├── raw/                     # Original dataset
│   └── processed/               # Cleaned and timestamped data
├── notebooks/                   # Jupyter notebooks for analysis
├── src/                         # Core Python modules
├── reports/                     # Generated drift reports
├── mlruns/                      # MLflow tracking artifacts
├── orchestrator/                # Prefect workflows
└── dashboard/                   # Streamlit monitoring app
```

## Quick Start

1. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

2. **Run Notebooks in Order**
   - `01_data_preparation.ipynb` - Data loading and preprocessing
   - `02_model_training.ipynb` - Model training with MLflow tracking
   - `03_simulate_drift.ipynb` - Simulate data drift scenarios
   - `04_monitoring_with_evidently.ipynb` - Generate drift reports

3. **Launch Dashboard**
   ```bash
   streamlit run dashboard/app.py
   ```

4. **View MLflow UI**
   ```bash
   mlflow ui
   ```

## Technologies Used

- **ML/AI**: XGBoost, scikit-learn, MLflow
- **Monitoring**: Evidently AI, Streamlit
- **Orchestration**: Prefect
- **Data**: pandas, NumPy

## Key Features

- ✅ End-to-end ML pipeline with tracking
- ✅ Automated drift detection and reporting
- ✅ Interactive monitoring dashboard
- ✅ Production-ready architecture
- ✅ Containerization support
