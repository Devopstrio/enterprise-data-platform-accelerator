import logging
import time
from fastapi import FastAPI, Request, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from prometheus_client import make_asgi_app
from pythonjsonlogger import jsonlogger

# Logger setup
logger = logging.getLogger("data-platform-api")
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter()
logHandler.setFormatter(formatter)
logger.addHandler(logHandler)
logger.setLevel(logging.INFO)

app = FastAPI(title="Enterprise Data Platform API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Metrics
metrics_app = make_asgi_app()
app.mount("/metrics", metrics_app)

@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    duration = time.time() - start_time
    logger.info(f"Path: {request.url.path} Duration: {duration:.4f}s Status: {response.status_code}")
    return response

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.post("/pipelines/run")
def run_pipeline(pipeline_id: str, target_env: str = "prod"):
    logger.info(f"Triggering data pipeline {pipeline_id} in {target_env}")
    return {"status": "IN_PROGRESS", "job_id": "pip_101_epsilon", "estimated_completion": "8m"}

@app.get("/catalog/assets")
def get_catalog_assets():
    return [
        {"id": "finance_gold", "name": "Institutional Ledger", "domain": "Finance", "status": "CERTIFIED", "quality": 0.99},
        {"id": "customer_silver", "name": "Cleaned Customer Master", "domain": "Sales", "status": "VALIDATED", "quality": 0.94},
        {"id": "iot_bronze", "name": "Raw Sensor Stream", "domain": "Operations", "status": "INGESTING", "quality": 0.88}
    ]

@app.get("/governance/status")
def get_governance_status():
    return {
        "catalog_coverage": "98%",
        "ownership_maturity": "ELITE",
        "pii_scanning": "ACTIVE",
        "policy_drift_detected": False
    }

@app.get("/costs/summary")
def get_costs_summary():
    return {
        "total_monthly_spend": 245000,
        "databricks_spend": 120000,
        "snowflake_spend": 85000,
        "bigquery_spend": 40000,
        "savings_identified": 24000,
        "budget_variance": "-1.2%"
    }

@app.get("/analytics/usage")
def get_analytics_usage():
    return {
        "active_users": 1250,
        "total_queries_daily": 45000,
        "slow_queries_count": 12,
        "most_active_domain": "Finance"
    }

@app.get("/scores/summary")
def get_scores_summary():
    return {
        "global_quality_score": 0.96,
        "platform_readiness": "OPTIMIZED",
        "uptime": "99.99%",
        "risk_level": "LOW"
    }

@app.get("/dashboard/summary")
def get_dashboard_summary():
    return {
        "total_pipelines": 452,
        "active_data_products": 142,
        "total_storage_pb": 2.4,
        "platform_status": "READY"
    }
