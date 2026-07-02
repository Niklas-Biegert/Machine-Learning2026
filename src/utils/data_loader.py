from pathlib import Path

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[2]
RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"


def load_student_performance() -> pd.DataFrame:
    """Load the synthetic student performance sample dataset."""
    path = RAW_DATA_DIR / "student_performance_sample.csv"
    return pd.read_csv(path)
