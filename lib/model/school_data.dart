import 'package:firebase_database/firebase_database.dart';

class SchoolData {
  String _schoolName;
  String _address;
  String _city;
  String _state;
  String _zipCode;

  SchoolData(
    this._schoolName,
    this._address,
    this._city,
    this._state,
    this._zipCode,
  );

  String get schoolName => _schoolName;

  String get address => _address;

  String get city => _city;

  String get state => _state;

  String get zipCode => _zipCode;

  SchoolData.fromSnapshot(DataSnapshot snapshot) {
    _schoolName = snapshot.value['School_Name'];
    _address = snapshot.value['Address'];
    _city = snapshot.value['City'];
    _state = snapshot.value['State'];
    _zipCode = snapshot.value['Zip'];
  }

  static getSuggestions(List<SchoolData> list, String query) {
    final _filterList = new List<String>();
    for (int i = 0; i < list.length; i++) {
      var item = list[i].schoolName;

      if (item.contains(query)) {
        _filterList.add(item);
      }
    }

    if (query.length == 0) {
      _filterList.clear();
    }
    return _filterList.take(4).toList();
  }

  static getFilterGrade(List<String> list, String query) {
    final _filterList = new List<String>();
    for (int i = 0; i < list.length; i++) {
      var item = list[i];

      if (item.toLowerCase().contains(query.toLowerCase())) {
        _filterList.add(item);
      }
    }

    if (query.length == 0) {
      _filterList.clear();
    }
    return _filterList;
  }
}
