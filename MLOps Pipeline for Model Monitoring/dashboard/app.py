# streamlit dashboard for MLOps model monitoring
import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import os
import sys
import json
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

# add src to path for imports
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'src'))

# page configuration
st.set_page_config(
    page_title="MLOps Monitoring Dashboard",
    page_icon="📊",
    layout="wide",
    initial_sidebar_state="expanded"
)

# custom CSS
st.markdown("""
<style>
    .main-header {
        font-size: 3rem;
        color: #1f77b4;
        text-align: center;
        margin-bottom: 2rem;
    }
    .metric-card {
        background-color: #f0f2f6;
        padding: 1rem;
        border-radius: 0.5rem;
        margin: 0.5rem 0;
    }
    .drift-alert {
        background-color: #ffebee;
        border-left: 5px solid #f44336;
        padding: 1rem;
        margin: 1rem 0;
    }
    .no-drift {
        background-color: #e8f5e8;
        border-left: 5px solid #4caf50;
        padding: 1rem;
        margin: 1rem 0;
    }
</style>
""", unsafe_allow_html=True)

# title and description
st.markdown('<h1 class="main-header">🏠 MLOps Model Monitoring Dashboard</h1>', unsafe_allow_html=True)
st.markdown("""
**Real-time monitoring for housing price prediction model**
Monitor data drift, model performance, and data quality in production.
""")

# sidebar for data selection
st.sidebar.header("📋 Data Selection")

# load available data files
data_dir = os.path.join(os.path.dirname(__file__), '..', 'data', 'processed')
if os.path.exists(data_dir):
    available_files = [f for f in os.listdir(data_dir) if f.endswith('.csv') and 'day_' in f]
    available_files.sort()
else:
    available_files = []

# file selection
if available_files:
    selected_file = st.sidebar.selectbox(
        "Select Production Data:",
        available_files,
        index=len(available_files)-1 if available_files else 0
    )
else:
    st.error("No data files found. Please run the data preparation notebook first.")
    st.stop()

# load reference and current data
@st.cache_data
def load_data():
    try:
        # load baseline reference data
        baseline_path = os.path.join(data_dir, 'baseline_reference.csv')
        reference_data = pd.read_csv(baseline_path)
        
        # load current production data
        current_path = os.path.join(data_dir, selected_file)
        current_data = pd.read_csv(current_path)
        
        return reference_data, current_data
    except Exception as e:
        st.error(f"Error loading data: {e}")
        return None, None

reference_data, current_data = load_data()

if reference_data is None or current_data is None:
    st.stop()

# model loading
@st.cache_resource
def load_model():
    try:
        import joblib
        model_path = os.path.join(os.path.dirname(__file__), '..', 'models', 'best_housing_model.joblib')
        if os.path.exists(model_path):
            model_data = joblib.load(model_path)
            return model_data
        else:
            return None
    except Exception:
        return None

model_data = load_model()

# main dashboard layout
col1, col2, col3 = st.columns([1, 2, 1])

with col2:
    st.info(f"📅 Monitoring data from: **{selected_file}**")

# key metrics row
st.subheader("📊 Key Metrics")
metric_col1, metric_col2, metric_col3, metric_col4 = st.columns(4)

with metric_col1:
    st.metric(
        label="Reference Data Points",
        value=f"{len(reference_data):,}",
        delta=None
    )

with metric_col2:
    st.metric(
        label="Current Data Points", 
        value=f"{len(current_data):,}",
        delta=f"{len(current_data) - len(reference_data):+,}"
    )

with metric_col3:
    missing_ref = reference_data.isnull().sum().sum()
    missing_cur = current_data.isnull().sum().sum()
    st.metric(
        label="Missing Values",
        value=missing_cur,
        delta=f"{missing_cur - missing_ref:+d}"
    )

with metric_col4:
    # calculate a simple drift score (difference in means)
    numeric_cols = reference_data.select_dtypes(include=[np.number]).columns
    numeric_cols = [col for col in numeric_cols if col in current_data.columns]
    
    drift_scores = []
    for col in numeric_cols:
        if col not in ['timestamp']:
            ref_mean = reference_data[col].mean()
            cur_mean = current_data[col].mean()
            if ref_mean != 0:
                drift_score = abs((cur_mean - ref_mean) / ref_mean)
                drift_scores.append(drift_score)
    
    avg_drift = np.mean(drift_scores) if drift_scores else 0
    st.metric(
        label="Avg Feature Drift",
        value=f"{avg_drift:.3f}",
        delta=f"{'High' if avg_drift > 0.1 else 'Normal'}"
    )

# Data distribution comparison
st.subheader("📈 Feature Distribution Comparison")

# Select features to compare
numeric_features = [col for col in reference_data.select_dtypes(include=[np.number]).columns 
                   if col not in ['timestamp'] and col in current_data.columns]

selected_features = st.multiselect(
    "Select features to compare:",
    numeric_features,
    default=numeric_features[:4] if len(numeric_features) >= 4 else numeric_features
)

if selected_features:
    # Create subplots for distribution comparison
    n_features = len(selected_features)
    cols = 2
    rows = (n_features + 1) // 2
    
    fig = make_subplots(
        rows=rows, cols=cols,
        subplot_titles=selected_features,
        vertical_spacing=0.1
    )
    
    for i, feature in enumerate(selected_features):
        row = i // cols + 1
        col = i % cols + 1
        
        # Reference distribution
        fig.add_trace(
            go.Histogram(
                x=reference_data[feature],
                name=f"Reference",
                opacity=0.7,
                nbinsx=30,
                legendgroup="reference",
                showlegend=(i == 0)
            ),
            row=row, col=col
        )
        
        # Current distribution
        fig.add_trace(
            go.Histogram(
                x=current_data[feature],
                name=f"Current",
                opacity=0.7,
                nbinsx=30,
                legendgroup="current",
                showlegend=(i == 0)
            ),
            row=row, col=col
        )
    
    fig.update_layout(
        height=300 * rows,
        title_text="Feature Distributions: Reference vs Current",
        barmode='overlay'
    )
    
    st.plotly_chart(fig, use_container_width=True)

# Statistical comparison table
st.subheader("📋 Statistical Summary Comparison")

if selected_features:
    comparison_data = []
    
    for feature in selected_features:
        ref_stats = reference_data[feature].describe()
        cur_stats = current_data[feature].describe()
        
        comparison_data.append({
            'Feature': feature,
            'Ref Mean': f"{ref_stats['mean']:.3f}",
            'Cur Mean': f"{cur_stats['mean']:.3f}",
            'Mean Diff': f"{cur_stats['mean'] - ref_stats['mean']:.3f}",
            'Ref Std': f"{ref_stats['std']:.3f}",
            'Cur Std': f"{cur_stats['std']:.3f}",
            'Std Diff': f"{cur_stats['std'] - ref_stats['std']:.3f}"
        })
    
    comparison_df = pd.DataFrame(comparison_data)
    st.dataframe(comparison_df, use_container_width=True)

# Target variable analysis
st.subheader("🎯 Target Variable Analysis")

if 'MedHouseVal' in reference_data.columns and 'MedHouseVal' in current_data.columns:
    target_col1, target_col2 = st.columns(2)
    
    with target_col1:
        # Target distribution comparison
        fig_target = go.Figure()
        
        fig_target.add_trace(go.Histogram(
            x=reference_data['MedHouseVal'],
            name="Reference",
            opacity=0.7,
            nbinsx=40
        ))
        
        fig_target.add_trace(go.Histogram(
            x=current_data['MedHouseVal'],
            name="Current",
            opacity=0.7,
            nbinsx=40
        ))
        
        fig_target.update_layout(
            title="Target Variable Distribution",
            xaxis_title="Median House Value",
            yaxis_title="Frequency",
            barmode='overlay'
        )
        
        st.plotly_chart(fig_target, use_container_width=True)
    
    with target_col2:
        # Target statistics
        ref_target_mean = reference_data['MedHouseVal'].mean()
        cur_target_mean = current_data['MedHouseVal'].mean()
        target_drift = (cur_target_mean - ref_target_mean) / ref_target_mean * 100
        
        st.metric(
            label="Reference Target Mean",
            value=f"${ref_target_mean:.2f}",
        )
        
        st.metric(
            label="Current Target Mean",
            value=f"${cur_target_mean:.2f}",
            delta=f"{target_drift:+.2f}%"
        )
        
        # Drift alert
        if abs(target_drift) > 10:
            st.markdown(f"""
            <div class="drift-alert">
                <strong>⚠️ Target Drift Alert!</strong><br>
                Target variable has shifted by {target_drift:.2f}%
            </div>
            """, unsafe_allow_html=True)
        else:
            st.markdown(f"""
            <div class="no-drift">
                <strong>✅ Target Stable</strong><br>
                Target drift within acceptable range ({target_drift:.2f}%)
            </div>
            """, unsafe_allow_html=True)

# Model predictions (if model is available)
if model_data is not None:
    st.subheader("🤖 Model Performance Monitoring")
    
    try:
        # Prepare current data for prediction
        feature_columns = model_data['feature_columns']
        current_features = current_data[feature_columns]
        
        # Make predictions
        predictions = model_data['model'].predict(current_features)
        
        if 'MedHouseVal' in current_data.columns:
            # Calculate performance metrics
            actual = current_data['MedHouseVal']
            
            from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
            
            rmse = np.sqrt(mean_squared_error(actual, predictions))
            mae = mean_absolute_error(actual, predictions)
            r2 = r2_score(actual, predictions)
            
            perf_col1, perf_col2, perf_col3 = st.columns(3)
            
            with perf_col1:
                st.metric("RMSE", f"{rmse:.3f}")
            
            with perf_col2:
                st.metric("MAE", f"{mae:.3f}")
            
            with perf_col3:
                st.metric("R² Score", f"{r2:.3f}")
            
            # Prediction vs Actual scatter plot
            fig_pred = px.scatter(
                x=actual, y=predictions,
                labels={'x': 'Actual Values', 'y': 'Predicted Values'},
                title="Prediction vs Actual Values"
            )
            
            # Add perfect prediction line
            min_val = min(actual.min(), predictions.min())
            max_val = max(actual.max(), predictions.max())
            fig_pred.add_trace(go.Scatter(
                x=[min_val, max_val],
                y=[min_val, max_val],
                mode='lines',
                name='Perfect Prediction',
                line=dict(dash='dash', color='red')
            ))
            
            st.plotly_chart(fig_pred, use_container_width=True)
    
    except Exception as e:
        st.error(f"Error generating predictions: {e}")

# Data quality checks
st.subheader("🔍 Data Quality Monitoring")

quality_col1, quality_col2 = st.columns(2)

with quality_col1:
    st.write("**Missing Values by Feature:**")
    missing_comparison = pd.DataFrame({
        'Reference': reference_data.isnull().sum(),
        'Current': current_data.isnull().sum()
    })
    missing_comparison['Difference'] = missing_comparison['Current'] - missing_comparison['Reference']
    missing_comparison = missing_comparison[missing_comparison.sum(axis=1) > 0]
    
    if len(missing_comparison) > 0:
        st.dataframe(missing_comparison)
    else:
        st.success("✅ No missing values detected")

with quality_col2:
    st.write("**Data Types Consistency:**")
    ref_dtypes = reference_data.dtypes
    cur_dtypes = current_data.dtypes
    
    dtype_issues = []
    for col in ref_dtypes.index:
        if col in cur_dtypes.index:
            if ref_dtypes[col] != cur_dtypes[col]:
                dtype_issues.append({
                    'Feature': col,
                    'Reference Type': str(ref_dtypes[col]),
                    'Current Type': str(cur_dtypes[col])
                })
    
    if dtype_issues:
        st.error("⚠️ Data type inconsistencies found:")
        st.dataframe(pd.DataFrame(dtype_issues))
    else:
        st.success("✅ All data types consistent")

# Footer
st.markdown("---")
st.markdown("""
**MLOps Model Monitoring Dashboard** | 
Built with Streamlit | 
Last updated: {}
""".format(datetime.now().strftime("%Y-%m-%d %H:%M:%S")))

# Instructions
with st.sidebar:
    st.markdown("---")
    st.subheader("📖 Instructions")
    st.markdown("""
    1. **Select Data**: Choose a production data file to analyze
    2. **Monitor Metrics**: Check key metrics at the top
    3. **Compare Distributions**: Review feature distribution changes
    4. **Check Target**: Monitor target variable drift
    5. **Model Performance**: Evaluate current model accuracy
    6. **Data Quality**: Ensure data integrity
    
    **🚨 Alerts:**
    - Red indicators show potential issues
    - Green indicators show normal behavior
    """)
    
    st.markdown("---")
    st.info("💡 **Tip**: Refresh the page or select different data files to see updated monitoring results.")
