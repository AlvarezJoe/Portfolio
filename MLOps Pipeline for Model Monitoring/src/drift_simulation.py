# drift simulation utilities for testing monitoring system
import pandas as pd
import numpy as np
import os

class DriftSimulator:
    
    def __init__(self, reference_data):
        self.reference_data = reference_data.copy()
        
    def simulate_feature_drift(self, data, feature_shifts, drift_intensity=0.3):
        # simulate feature drift by shifting distributions
        drifted_data = data.copy()
        
        for feature, shift in feature_shifts.items():
            if feature in drifted_data.columns:
                # apply gradual shift to feature
                current_values = drifted_data[feature].values
                shift_amount = shift * drift_intensity
                
                # add noise and shift
                noise = np.random.normal(0, 0.1, len(current_values))
                drifted_data[feature] = current_values + shift_amount + noise
                
        return drifted_data
    
    def simulate_target_drift(self, data, target_col="MedHouseVal", drift_factor=1.2):
        # simulate target drift (e.g., housing market changes)
        drifted_data = data.copy()
        
        # simulate market appreciation/depreciation
        drifted_data[target_col] = drifted_data[target_col] * drift_factor
        
        return drifted_data
    
    def simulate_missing_values(self, data, missing_features, missing_rate=0.1):
        # introduce missing values to simulate data quality issues
        drifted_data = data.copy()
        
        for feature in missing_features:
            if feature in drifted_data.columns:
                # randomly set values to NaN
                mask = np.random.random(len(drifted_data)) < missing_rate
                drifted_data.loc[mask, feature] = np.nan
                
        return drifted_data
    
    def create_drift_scenarios(self, output_dir="data/processed/"):
        # create multiple drift scenarios for testing
        os.makedirs(output_dir, exist_ok=True)
        
        scenarios = {
            "baseline": self.reference_data,
            
            "feature_drift_mild": self.simulate_feature_drift(
                self.reference_data,
                {"MedInc": 0.5, "HouseAge": -2.0},
                drift_intensity=0.2
            ),
            
            "feature_drift_severe": self.simulate_feature_drift(
                self.reference_data,
                {"MedInc": 1.5, "HouseAge": -5.0, "Population": 1000},
                drift_intensity=0.8
            ),
            
            "target_drift_appreciation": self.simulate_target_drift(
                self.reference_data,
                drift_factor=1.3
            ),
            
            "target_drift_depreciation": self.simulate_target_drift(
                self.reference_data,
                drift_factor=0.7
            ),
            
            "missing_values": self.simulate_missing_values(
                self.reference_data,
                ["MedInc", "HouseAge"],
                missing_rate=0.15
            ),
            
            "combined_drift": self.simulate_missing_values(
                self.simulate_feature_drift(
                    self.simulate_target_drift(self.reference_data, drift_factor=1.4),
                    {"MedInc": 1.0, "Population": 500},
                    drift_intensity=0.5
                ),
                ["HouseAge"],
                missing_rate=0.1
            )
        }
        
        # save all scenarios
        for scenario_name, scenario_data in scenarios.items():
            filepath = os.path.join(output_dir, f"{scenario_name}.csv")
            scenario_data.to_csv(filepath, index=False)
            print(f"Saved {scenario_name} scenario to {filepath}")
        
        print(f"\nCreated {len(scenarios)} drift scenarios in {output_dir}")
        return scenarios
    
    def create_temporal_drift(self, days=30, output_dir="data/processed/"):
        # create gradual drift over time (simulating real-world scenario)
        os.makedirs(output_dir, exist_ok=True)
        
        base_data = self.reference_data.copy()
        
        for day in range(1, days + 1):
            # gradually increase drift over time
            drift_intensity = min(day / days, 0.8)  # cap at 80% drift
            
            # simulate gradual market changes
            current_data = self.simulate_feature_drift(
                base_data,
                {"MedInc": 0.02 * day, "HouseAge": -0.1 * day},  # gradual changes
                drift_intensity=drift_intensity * 0.3
            )
            
            # add some target drift as well
            target_factor = 1 + (0.001 * day)  # 0.1% increase per day
            current_data = self.simulate_target_drift(current_data, drift_factor=target_factor)
            
            # save daily data
            filepath = os.path.join(output_dir, f"day_{day:02d}.csv")
            current_data.to_csv(filepath, index=False)
            
        print(f"Created {days} days of temporal drift data in {output_dir}")
