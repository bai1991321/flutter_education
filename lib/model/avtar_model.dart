import 'package:firebase_database/firebase_database.dart';

class AvtarModal {
  String _url;
  String _name;

  AvtarModal(this._url, this._name);

  AvtarModal.map(dynamic obj) {
    this._url = obj['image_url'];
    this._name = obj['name'];
  }

  String get url => _url;

  String get name => _name;

  AvtarModal.fromSnapshot(DataSnapshot snapshot) {
    _url = snapshot.value['image_url'];
    _name = snapshot.value['name'];
  }
}
