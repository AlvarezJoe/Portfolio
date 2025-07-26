# monitoring utilities using Evidently AI for drift detection
import pandas as pd
from evidently.report import Report
from evidently.metric_preset import DataDriftPreset, TargetDriftPreset, RegressionPreset
from evidently.metrics import *
import os
from datetime import datetime
import json

class DriftMonitor:
    
    def __init__(self, reference_data, target_column="MedHouseVal"):
        self.reference_data = reference_data
        self.target_column = target_column
        self.reports_dir = "reports/drift_reports"
        os.makedirs(self.reports_dir, exist_ok=True)
        
    def generate_data_drift_report(self, current_data, report_name=None):
        # generate comprehensive data drift report
        if report_name is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            report_name = f"data_drift_report_{timestamp}"
        
        # create evidently report
        report = Report(metrics=[
            DataDriftPreset(),
            TargetDriftPreset(),
            RegressionPreset()
        ])
        
        # run the report
        report.run(reference_data=self.reference_data, current_data=current_data)
        
        # save HTML report
        html_path = os.path.join(self.reports_dir, f"{report_name}.html")
        report.save_html(html_path)
        
        # save JSON report for programmatic access
        json_path = os.path.join(self.reports_dir, f"{report_name}.json")
        report.save_json(json_path)
        
        # extract key metrics
        drift_summary = self._extract_drift_metrics(json_path)
        
        print(f"Drift report saved:")
        print(f"  HTML: {html_path}")
        print(f"  JSON: {json_path}")
        print(f"  Data drift detected: {drift_summary.get('data_drift_detected', 'Unknown')}")
        print(f"  Target drift detected: {drift_summary.get('target_drift_detected', 'Unknown')}")
        
        return drift_summary
    
    def generate_feature_drift_report(self, current_data, feature_list=None, report_name=None):
        # generate focused feature drift report
        if report_name is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            report_name = f"feature_drift_report_{timestamp}"
        
        # select features to monitor
        if feature_list is None:
            feature_list = [col for col in self.reference_data.columns 
                          if col not in [self.target_column, 'timestamp', 'date']]
        
        # create targeted report
        report = Report(metrics=[
            DatasetDriftMetric(),
            DataDriftTable(),
            DatasetMissingValuesMetric()
        ])
        
        report.run(reference_data=self.reference_data[feature_list + [self.target_column]], 
                  current_data=current_data[feature_list + [self.target_column]])
        
        # save reports
        html_path = os.path.join(self.reports_dir, f"{report_name}.html")
        json_path = os.path.join(self.reports_dir, f"{report_name}.json")
        
        report.save_html(html_path)
        report.save_json(json_path)
        
        drift_summary = self._extract_drift_metrics(json_path)
        
        print(f"Feature drift report saved: {html_path}")
        return drift_summary
    
    def monitor_model_performance(self, current_data, predictions, report_name=None):
        # monitor model performance drift
        if report_name is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            report_name = f"performance_drift_report_{timestamp}"
        
        # add predictions to current data
        current_data_with_pred = current_data.copy()
        current_data_with_pred['prediction'] = predictions
        
        # Create performance report
        report = Report(metrics=[
            RegressionPreset(),
            TargetDriftPreset()
        ])
        
        # For reference predictions, use a simple baseline
        reference_with_pred = self.reference_data.copy()
        reference_with_pred['prediction'] = reference_with_pred[self.target_column]  # Perfect predictions as baseline
        
        report.run(reference_data=reference_with_pred, 
                  current_data=current_data_with_pred)
        
        # Save reports
        html_path = os.path.join(self.reports_dir, f"{report_name}.html")
        json_path = os.path.join(self.reports_dir, f"{report_name}.json")
        
        report.save_html(html_path)
        report.save_json(json_path)
        
        performance_summary = self._extract_performance_metrics(json_path)
        
        print(f"Performance drift report saved: {html_path}")
        return performance_summary
    
    def _extract_drift_metrics(self, json_path):
        # extract key drift metrics from JSON report
        try:
            with open(json_path, 'r') as f:
                report_data = json.load(f)
            
            # extract summary metrics
            metrics_summary = {
                'report_generated_at': datetime.now().isoformat(),
                'json_path': json_path
            }
            
            # try to extract data drift information
            if 'metrics' in report_data:
                for metric in report_data['metrics']:
                    if 'metric' in metric and 'DatasetDriftMetric' in metric['metric']:
                        if 'result' in metric:
                            metrics_summary['data_drift_detected'] = metric['result'].get('dataset_drift', False)
                            metrics_summary['drift_share'] = metric['result'].get('drift_share', 0)
                            
            return metrics_summary
            
        except Exception as e:
            print(f"Error extracting metrics from {json_path}: {e}")
            return {'error': str(e)}
    
    def _extract_performance_metrics(self, json_path):
        # extract performance metrics from JSON report
        try:
            with open(json_path, 'r') as f:
                report_data = json.load(f)
            
            performance_summary = {
                'report_generated_at': datetime.now().isoformat(),
                'json_path': json_path
            }
            
            # extract performance metrics
            if 'metrics' in report_data:
                for metric in report_data['metrics']:
                    if 'result' in metric:
                        result = metric['result']
                        if 'current' in result:
                            current_metrics = result['current']
                            if 'mean_error' in current_metrics:
                                performance_summary['current_mae'] = current_metrics['mean_error']
                            if 'mean_abs_error' in current_metrics:
                                performance_summary['current_mae'] = current_metrics['mean_abs_error']
                                
            return performance_summary
            
        except Exception as e:
            print(f"Error extracting performance metrics: {e}")
            return {'error': str(e)}
    
    def batch_monitoring(self, data_dir, pattern="day_*.csv"):
        # run monitoring on multiple data files
        import glob
        
        # find all matching files
        file_pattern = os.path.join(data_dir, pattern)
        data_files = sorted(glob.glob(file_pattern))
        
        results = []
        
        for file_path in data_files:
            print(f"\nProcessing {file_path}...")
            
            # load current data
            current_data = pd.read_csv(file_path)
            
            # generate report
            filename = os.path.basename(file_path).replace('.csv', '')
            drift_summary = self.generate_data_drift_report(
                current_data, 
                report_name=f"batch_{filename}"
            )
            
            drift_summary['file_path'] = file_path
            drift_summary['filename'] = filename
            results.append(drift_summary)
        
        # save batch summary
        summary_path = os.path.join(self.reports_dir, "batch_monitoring_summary.json")
        with open(summary_path, 'w') as f:
            json.dump(results, f, indent=2)
            
        print(f"\nBatch monitoring complete. Summary saved to {summary_path}")
