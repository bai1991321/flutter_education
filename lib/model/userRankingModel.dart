class UserRankingModel {
  String _userId;
  double _per;

  UserRankingModel(
    this._userId,
    this._per,
  );

  UserRankingModel.toMap(dynamic obj) {
    this._userId = obj['userId'];
    this._per = obj['performance'];
  }

  String get userId => _userId;

  double get performance => _per;

  Map<String, dynamic> toJson() => {
        'userId': _userId,
        'performance': _per,
      };
}
