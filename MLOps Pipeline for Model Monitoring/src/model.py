# model training and prediction for MLOps pipeline
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
import xgboost as xgb
import mlflow
import mlflow.sklearn
import mlflow.xgboost
import joblib
import os

class HousingPriceModel:
    
    def __init__(self, model_type="xgboost"):
        self.model_type = model_type
        self.model = None
        self.feature_columns = None
        self.target_column = "MedHouseVal"
        
    def prepare_features(self, df):
        # prepare features and target for training
        feature_cols = [col for col in df.columns 
                       if col not in [self.target_column, 'timestamp', 'date']]
        
        X = df[feature_cols].copy()
        y = df[self.target_column].copy()
        
        self.feature_columns = feature_cols
        return X, y
    
    def train_model(self, X_train, y_train, X_val, y_val, experiment_name="housing_price_prediction"):
        # train model with MLflow tracking
        mlflow.set_experiment(experiment_name)
        
        with mlflow.start_run():
            # choose model based on type
            if self.model_type == "xgboost":
                self.model = xgb.XGBRegressor(
                    n_estimators=100,
                    max_depth=6,
                    learning_rate=0.1,
                    random_state=42
                )
                # log parameters
                mlflow.log_params({
                    "model_type": "xgboost",
                    "n_estimators": 100,
                    "max_depth": 6,
                    "learning_rate": 0.1
                })
            else:
                self.model = RandomForestRegressor(
                    n_estimators=100,
                    max_depth=10,
                    random_state=42
                )
                # log parameters
                mlflow.log_params({
                    "model_type": "random_forest",
                    "n_estimators": 100,
                    "max_depth": 10
                })
            
            # train model
            self.model.fit(X_train, y_train)
            
            # make predictions
            y_pred_train = self.model.predict(X_train)
            y_pred_val = self.model.predict(X_val)
            
            # calculate metrics
            metrics = {
                "train_rmse": np.sqrt(mean_squared_error(y_train, y_pred_train)),
                "val_rmse": np.sqrt(mean_squared_error(y_val, y_pred_val)),
                "train_mae": mean_absolute_error(y_train, y_pred_train),
                "val_mae": mean_absolute_error(y_val, y_pred_val),
                "train_r2": r2_score(y_train, y_pred_train),
                "val_r2": r2_score(y_val, y_pred_val)
            }
            
            # log metrics
            mlflow.log_metrics(metrics)
            
            # log model
            if self.model_type == "xgboost":
                mlflow.xgboost.log_model(self.model, "model")
            else:
                mlflow.sklearn.log_model(self.model, "model")
            
            # log feature importance
            if hasattr(self.model, 'feature_importances_'):
                feature_importance = pd.DataFrame({
                    'feature': X_train.columns,
                    'importance': self.model.feature_importances_
                }).sort_values('importance', ascending=False)
                
                mlflow.log_text(feature_importance.to_string(), "feature_importance.txt")
            
            print(f"Model trained successfully. Validation RMSE: {metrics['val_rmse']:.4f}")
            return metrics
    
    def predict(self, X):
        # make predictions
        if self.model is None:
            raise ValueError("Model not trained yet. Call train_model() first.")
        return self.model.predict(X)
    
    def save_model(self, filepath):
        # save model to disk
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        joblib.dump({
            'model': self.model,
            'feature_columns': self.feature_columns,
            'model_type': self.model_type
        }, filepath)
        print(f"Model saved to {filepath}")
    
    def load_model(self, filepath):
        # load model from disk
        model_data = joblib.load(filepath)
        self.model = model_data['model']
        self.feature_columns = model_data['feature_columns']
        self.model_type = model_data['model_type']
        print(f"Model loaded from {filepath}")
