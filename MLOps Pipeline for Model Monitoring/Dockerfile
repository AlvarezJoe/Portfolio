# Dockerfile for MLOps Pipeline
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p data/raw data/processed models reports/drift_reports mlruns

# Expose ports for MLflow and Streamlit
EXPOSE 5000 8501

# Environment variables
ENV PYTHONPATH=/app/src
ENV MLFLOW_TRACKING_URI=/app/mlruns

# Default command (can be overridden)
CMD ["streamlit", "run", "dashboard/app.py", "--server.port=8501", "--server.address=0.0.0.0"]
