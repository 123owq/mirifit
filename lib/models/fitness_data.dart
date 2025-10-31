class FitnessData {
  double calories;
  double caloriesGoal;
  double weightGoal;
  double weightRemaining;
  String selectedPeriod;
  String exerciseType;
  int exerciseDuration; // 분

  FitnessData({
    this.calories = 1847,
    this.caloriesGoal = 2200,
    this.weightGoal = 5.0,
    this.weightRemaining = 1.0,
    this.selectedPeriod = '6개월',
    this.exerciseType = '상체 운동',
    this.exerciseDuration = 45,
  });

  // 칼로리 진행률 계산
  double get caloriesProgress => calories / caloriesGoal;

  // 체중 감량 진행률 계산
  double get weightProgress => (weightGoal - weightRemaining) / weightGoal;

  // 데이터 복사 (불변성 유지)
  FitnessData copyWith({
    double? calories,
    double? caloriesGoal,
    double? weightGoal,
    double? weightRemaining,
    String? selectedPeriod,
    String? exerciseType,
    int? exerciseDuration,
  }) {
    return FitnessData(
      calories: calories ?? this.calories,
      caloriesGoal: caloriesGoal ?? this.caloriesGoal,
      weightGoal: weightGoal ?? this.weightGoal,
      weightRemaining: weightRemaining ?? this.weightRemaining,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      exerciseType: exerciseType ?? this.exerciseType,
      exerciseDuration: exerciseDuration ?? this.exerciseDuration,
    );
  }
}
