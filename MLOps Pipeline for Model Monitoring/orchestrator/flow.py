"""
Prefect workflow for automated MLOps monitoring
"""
from prefect import flow, task
import pandas as pd
import os
import sys
from datetime import datetime, timedelta
import numpy as np

# Add src to path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'src'))

from monitoring import DriftMonitor
from drift_simulation import DriftSimulator
import mlflow

@task(name="load_reference_data")
def load_reference_data(data_path: str = "../data/processed/baseline_reference.csv"):
    """Load reference data for drift monitoring"""
    try:
        reference_data = pd.read_csv(data_path)
        print(f"✅ Loaded reference data: {reference_data.shape}")
        return reference_data
    except Exception as e:
        print(f"❌ Error loading reference data: {e}")
        raise

@task(name="load_production_data")
def load_production_data(data_path: str):
    """Load current production data"""
    try:
        production_data = pd.read_csv(data_path)
        print(f"✅ Loaded production data: {production_data.shape}")
        return production_data
    except Exception as e:
        print(f"❌ Error loading production data: {e}")
        raise

@task(name="generate_drift_report")
def generate_drift_report(reference_data: pd.DataFrame, 
                         production_data: pd.DataFrame,
                         report_name: str = None):
    """Generate drift detection report using Evidently"""
    try:
        # Initialize drift monitor
        monitor = DriftMonitor(reference_data)
        
        # Generate comprehensive drift report
        drift_summary = monitor.generate_data_drift_report(
            production_data, 
            report_name=report_name
        )
        
        print(f"✅ Drift report generated: {report_name}")
        return drift_summary
        
    except Exception as e:
        print(f"❌ Error generating drift report: {e}")
        return {"error": str(e)}

@task(name="evaluate_model_performance")
def evaluate_model_performance(production_data: pd.DataFrame,
                             model_path: str = "../models/best_housing_model.joblib"):
    """Evaluate model performance on production data"""
    try:
        import joblib
        from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
        
        # Load model
        model_data = joblib.load(model_path)
        model = model_data['model']
        feature_columns = model_data['feature_columns']
        
        # Prepare data
        X = production_data[feature_columns]
        
        if 'MedHouseVal' in production_data.columns:
            y_true = production_data['MedHouseVal']
            y_pred = model.predict(X)
            
            # Calculate metrics
            performance_metrics = {
                'rmse': np.sqrt(mean_squared_error(y_true, y_pred)),
                'mae': mean_absolute_error(y_true, y_pred),
                'r2': r2_score(y_true, y_pred),
                'n_samples': len(production_data),
                'timestamp': datetime.now().isoformat()
            }
            
            print(f"✅ Model performance evaluated: RMSE={performance_metrics['rmse']:.3f}")
            return performance_metrics
        else:
            print("⚠️ No target variable found for performance evaluation")
            return {"error": "No target variable available"}
            
    except Exception as e:
        print(f"❌ Error evaluating model performance: {e}")
        return {"error": str(e)}

@task(name="log_metrics_to_mlflow")
def log_metrics_to_mlflow(performance_metrics: dict, drift_summary: dict):
    """Log monitoring metrics to MLflow"""
    try:
        mlflow.set_experiment("production_monitoring")
        
        with mlflow.start_run():
            # Log performance metrics
            if 'error' not in performance_metrics:
                mlflow.log_metrics({
                    'production_rmse': performance_metrics['rmse'],
                    'production_mae': performance_metrics['mae'],
                    'production_r2': performance_metrics['r2'],
                    'production_samples': performance_metrics['n_samples']
                })
            
            # Log drift metrics
            if 'error' not in drift_summary:
                if 'drift_share' in drift_summary:
                    mlflow.log_metric('drift_share', drift_summary['drift_share'])
                if 'data_drift_detected' in drift_summary:
                    mlflow.log_metric('data_drift_detected', 
                                    1 if drift_summary['data_drift_detected'] else 0)
            
            # Log timestamp
            mlflow.log_param('monitoring_timestamp', datetime.now().isoformat())
            
        print("✅ Metrics logged to MLflow")
        
    except Exception as e:
        print(f"❌ Error logging to MLflow: {e}")

@task(name="check_drift_alerts")
def check_drift_alerts(drift_summary: dict, performance_metrics: dict):
    """Check for alerts and generate notifications"""
    alerts = []
    
    try:
        # Check for data drift
        if drift_summary.get('data_drift_detected', False):
            alerts.append({
                'type': 'data_drift',
                'severity': 'high',
                'message': f"Data drift detected with {drift_summary.get('drift_share', 0):.2%} of features drifted"
            })
        
        # Check for performance degradation
        if 'error' not in performance_metrics:
            rmse = performance_metrics.get('rmse', 0)
            r2 = performance_metrics.get('r2', 1)
            
            # Define thresholds (these would be set based on baseline performance)
            rmse_threshold = 1.0  # Example threshold
            r2_threshold = 0.7   # Example threshold
            
            if rmse > rmse_threshold:
                alerts.append({
                    'type': 'performance_degradation',
                    'severity': 'medium',
                    'message': f"Model RMSE ({rmse:.3f}) exceeds threshold ({rmse_threshold})"
                })
            
            if r2 < r2_threshold:
                alerts.append({
                    'type': 'performance_degradation',
                    'severity': 'medium',
                    'message': f"Model R² ({r2:.3f}) below threshold ({r2_threshold})"
                })
        
        # Log alerts
        if alerts:
            print(f"🚨 {len(alerts)} alerts generated:")
            for alert in alerts:
                print(f"  [{alert['severity'].upper()}] {alert['type']}: {alert['message']}")
        else:
            print("✅ No alerts - system operating normally")
        
        return alerts
        
    except Exception as e:
        print(f"❌ Error checking alerts: {e}")
        return []

@flow(name="mlops_monitoring_pipeline")
def mlops_monitoring_pipeline(production_data_path: str,
                             reference_data_path: str = "../data/processed/baseline_reference.csv"):
    """
    Main MLOps monitoring pipeline
    
    This flow:
    1. Loads reference and production data
    2. Generates drift detection reports
    3. Evaluates model performance
    4. Logs metrics to MLflow
    5. Checks for alerts
    """
    
    print(f"🚀 Starting MLOps monitoring pipeline")
    print(f"Production data: {production_data_path}")
    print(f"Reference data: {reference_data_path}")
    
    # Load data
    reference_data = load_reference_data(reference_data_path)
    production_data = load_production_data(production_data_path)
    
    # Generate timestamp for reports
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = os.path.basename(production_data_path).replace('.csv', '')
    report_name = f"monitoring_{filename}_{timestamp}"
    
    # Generate drift report
    drift_summary = generate_drift_report(
        reference_data, 
        production_data, 
        report_name=report_name
    )
    
    # Evaluate model performance
    performance_metrics = evaluate_model_performance(production_data)
    
    # Log metrics to MLflow
    log_metrics_to_mlflow(performance_metrics, drift_summary)
    
    # Check for alerts
    alerts = check_drift_alerts(drift_summary, performance_metrics)
    
    # Summary
    summary = {
        'timestamp': datetime.now().isoformat(),
        'production_data_path': production_data_path,
        'report_name': report_name,
        'drift_summary': drift_summary,
        'performance_metrics': performance_metrics,
        'alerts': alerts
    }
    
    print(f"✅ MLOps monitoring pipeline completed")
    return summary

@flow(name="batch_monitoring_pipeline")
def batch_monitoring_pipeline(data_directory: str = "../data/processed/",
                             file_pattern: str = "day_*.csv"):
    """
    Batch monitoring pipeline to process multiple data files
    """
    import glob
    
    print(f"🔄 Starting batch monitoring pipeline")
    print(f"Directory: {data_directory}")
    print(f"Pattern: {file_pattern}")
    
    # Find all matching files
    file_pattern_full = os.path.join(data_directory, file_pattern)
    data_files = sorted(glob.glob(file_pattern_full))
    
    if not data_files:
        print(f"❌ No files found matching pattern: {file_pattern_full}")
        return
    
    print(f"📁 Found {len(data_files)} files to process")
    
    results = []
    
    # Process each file
    for file_path in data_files:
        print(f"\n📊 Processing: {os.path.basename(file_path)}")
        
        try:
            result = mlops_monitoring_pipeline(file_path)
            results.append(result)
        except Exception as e:
            print(f"❌ Error processing {file_path}: {e}")
            results.append({
                'file_path': file_path,
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            })
    
    print(f"\n✅ Batch monitoring completed: {len(results)} files processed")
    return results

# Scheduled monitoring flow
@flow(name="scheduled_daily_monitoring")
def scheduled_daily_monitoring():
    """
    Daily scheduled monitoring that can be run by Prefect scheduler
    """
    print(f"📅 Running scheduled daily monitoring - {datetime.now()}")
    
    # Get yesterday's data file (assuming daily files follow naming convention)
    yesterday = datetime.now() - timedelta(days=1)
    expected_file = f"../data/processed/day_{yesterday.strftime('%Y_%m_%d')}.csv"
    
    if os.path.exists(expected_file):
        result = mlops_monitoring_pipeline(expected_file)
        return result
    else:
        print(f"⚠️ Expected data file not found: {expected_file}")
        return {"error": f"Data file not found: {expected_file}"}

if __name__ == "__main__":
    # Example usage
    print("MLOps Monitoring Workflows")
    print("=" * 40)
    
    # Run single file monitoring
    print("\n1. Single file monitoring example:")
    try:
        # Example with one of the daily files
        example_file = "../data/processed/day_2023_07_01.csv"
        if os.path.exists(example_file):
            result = mlops_monitoring_pipeline(example_file)
            print(f"Monitoring result: {result}")
        else:
            print(f"Example file not found: {example_file}")
    except Exception as e:
        print(f"Error: {e}")
    
    # Run batch monitoring
    print("\n2. Batch monitoring example:")
    try:
        batch_results = batch_monitoring_pipeline()
        print(f"Batch results: {len(batch_results) if batch_results else 0} files processed")
    except Exception as e:
        print(f"Error: {e}")
    
    print("\n" + "=" * 40)
    print("To run with Prefect:")
    print("1. Install Prefect: pip install prefect")
    print("2. Start Prefect server: prefect server start")
    print("3. Run flow: python orchestrator/flow.py")
    print("4. View in UI: http://127.0.0.1:4200")
