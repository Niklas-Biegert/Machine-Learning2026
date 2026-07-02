from src.utils.data_loader import load_student_performance


def test_load_student_performance_has_expected_columns():
    data = load_student_performance()

    expected_columns = {
        "student_id",
        "study_hours",
        "attendance_rate",
        "previous_grade",
        "exercise_score",
        "final_score",
        "passed",
    }

    assert expected_columns.issubset(data.columns)
    assert len(data) > 0
