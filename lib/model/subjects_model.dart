import 'package:firebase_database/firebase_database.dart';

class SubjectsModel {
  String _subjectName;
  String _color;
  String _icon;

  SubjectsModel(this._subjectName, this._color, this._icon);

  SubjectsModel.map(dynamic obj) {
    this._subjectName = obj['subject_name'];
    this._color = obj['color'];
    this._icon = obj['icon'];
  }

  String get subjectName => _subjectName;

  String get color => _color;

  String get icon => _icon;

  SubjectsModel.fromSnapshot(DataSnapshot snapshot) {
    _subjectName = snapshot.value['subject_name'];
    _color = snapshot.value['color'];
    _icon = snapshot.value['icon'];
  }
}

class CategoryModel {
  String _categoryName;
  String _color;
  String _icon;

  CategoryModel(this._categoryName, this._color, this._icon);

  CategoryModel.map(dynamic obj) {
    this._categoryName = obj['category_name'];
    this._color = obj['color'];
    this._icon = obj['icon'];
  }

  String get categoryName => _categoryName;

  String get color => _color;

  String get icon => _icon;

  CategoryModel.fromSnapshot(DataSnapshot snapshot) {
    _categoryName = snapshot.value['category_name'];
    _color = snapshot.value['color'];
    _icon = snapshot.value['icon'];
  }
}

class ClassModel {
  String _className;
  String _color;
  String _icon;

  ClassModel(this._className, this._color, this._icon);

  ClassModel.map(dynamic obj) {
    this._className = obj['class_name'];
    this._color = obj['color'];
    this._icon = obj['icon'];
  }

  String get className => _className;

  String get color => _color;

  String get icon => _icon;

  ClassModel.fromSnapshot(DataSnapshot snapshot) {
    _className = snapshot.value['class_name'];
    _color = snapshot.value['color'];
    _icon = snapshot.value['icon'];
  }
}


