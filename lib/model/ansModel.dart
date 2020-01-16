class AnsModel {
  String _questionKey;
  String _answerText;

  AnsModel(
    this._questionKey,
    this._answerText,
  );

  AnsModel.toMap(dynamic obj) {
    this._questionKey = obj['questionKey'];
    this._answerText = obj['answerText'];
  }

  String get questionKey => _questionKey;

  String get answerText => _answerText;

  Map<String, dynamic> toJson() => {
        'questionKey': _questionKey,
        'answerText': _answerText,
      };
}
