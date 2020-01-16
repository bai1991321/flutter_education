class SessionModel {
  String _difficultyLevel;
  String _score;
  int _frequency;

  SessionModel(
    this._difficultyLevel,
    this._score,
    this._frequency,
  );

  SessionModel.toMap(dynamic obj) {
    this._difficultyLevel = obj['difficultyLevel'];
    this._score = obj['score'];
    this._frequency = obj['frequency'];
  }

  String get difficultyLevel => _difficultyLevel;

  String get score => _score;

  int get frequency => _frequency;

  Map<String, dynamic> toJson() => {
        'difficultyLevel': _difficultyLevel,
        'score': _score,
        'frequency': _frequency,
      };
}
