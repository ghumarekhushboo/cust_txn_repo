from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
import subprocess

def run_etl(ds, **kwargs):
    subprocess.run(["python", "/../load_customers.py", ds])

with DAG(
    "daily_etl",
    start_date=datetime(2026, 1, 1),
    schedule_interval="@daily",
    catchup=False,
) as dag:

    task = PythonOperator(
        task_id="run_etl_task",
        python_callable=run_etl,
        provide_context=True,
    )