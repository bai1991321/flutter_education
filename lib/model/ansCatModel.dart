class AnsCatModel {
  String _questionKey;
  String _answerText;
  bool _isCorrect;

  AnsCatModel(
    this._questionKey,
    this._answerText,
    this._isCorrect,
  );

  AnsCatModel.toMap(dynamic obj) {
    this._questionKey = obj['questionKey'];
    this._answerText = obj['answerText'];
    this._isCorrect = obj['isCorrect'];
  }

  String get questionKey => _questionKey;

  String get answerText => _answerText;

  bool get isCorrect => _isCorrect;

  Map<String, dynamic> toJson() => {
        'questionKey': _questionKey,
        'answerText': _answerText,
        'isCorrect': _isCorrect,
      };
}
