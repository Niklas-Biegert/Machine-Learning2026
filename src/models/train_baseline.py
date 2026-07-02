from pathlib import Path
import sys

import pandas as pd
from sklearn.linear_model import LinearRegression, LogisticRegression
from sklearn.metrics import accuracy_score, mean_absolute_error, r2_score
from sklearn.model_selection import train_test_split


PROJECT_ROOT = Path(__file__).resolve().parents[2]
sys.path.append(str(PROJECT_ROOT))

from src.utils.data_loader import load_student_performance  # noqa: E402


FEATURES = ["study_hours", "attendance_rate", "previous_grade", "exercise_score"]


def train_regression(data: pd.DataFrame) -> dict[str, float]:
    x = data[FEATURES]
    y = data["final_score"]
    x_train, x_test, y_train, y_test = train_test_split(
        x, y, test_size=0.25, random_state=42
    )

    model = LinearRegression()
    model.fit(x_train, y_train)
    predictions = model.predict(x_test)

    return {
        "mae": mean_absolute_error(y_test, predictions),
        "r2": r2_score(y_test, predictions),
    }


def train_classification(data: pd.DataFrame) -> dict[str, float]:
    x = data[FEATURES]
    y = data["passed"]
    x_train, x_test, y_train, y_test = train_test_split(
        x, y, test_size=0.25, random_state=42, stratify=y
    )

    model = LogisticRegression(max_iter=1000)
    model.fit(x_train, y_train)
    predictions = model.predict(x_test)

    return {"accuracy": accuracy_score(y_test, predictions)}


def main() -> None:
    data = load_student_performance()
    regression_metrics = train_regression(data)
    classification_metrics = train_classification(data)

    print("Regression baseline")
    for metric, value in regression_metrics.items():
        print(f"{metric}: {value:.3f}")

    print("\nClassification baseline")
    for metric, value in classification_metrics.items():
        print(f"{metric}: {value:.3f}")


if __name__ == "__main__":
    main()
