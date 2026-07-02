data_path <- file.path("data", "raw", "student_performance_sample.csv")
student_data <- read.csv(data_path)

regression_model <- lm(
  final_score ~ study_hours + attendance_rate + previous_grade + exercise_score,
  data = student_data
)

classification_model <- glm(
  passed ~ study_hours + attendance_rate + previous_grade + exercise_score,
  data = student_data,
  family = binomial()
)

print(summary(regression_model))
print(summary(classification_model))
