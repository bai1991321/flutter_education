import 'package:firebase_database/firebase_database.dart';

class QuizModel {
  String _key;
  String _name;
  String _grade;
  String _subject;
  String _question;
  String _category;
  String _answerOne;
  String _answerTwo;
  String _answerThree;
  String _answerFour;
  String _correctAnswer;
  String _difficulty;
  String _priority;

  QuizModel(
      this._key,
      this._name,
      this._grade,
      this._subject,
      this._question,
      this._category,
      this._answerOne,
      this._answerTwo,
      this._answerThree,
      this._answerFour,
      this._correctAnswer, this._difficulty, this._priority);

  QuizModel.map(dynamic obj) {
    this._key = obj['key'];
    this._name = obj['name'];
    this._grade = obj['grade'];
    this._subject = obj['subject'];
    this._question = obj['question'];
    this._category = obj['category'];
    this._answerOne = obj['answerOne'];
    this._answerTwo = obj['answerTwo'];
    this._answerThree = obj['answerThree'];
    this._answerFour = obj['answerFour'];
    this._correctAnswer = obj['correctAnswer'];
    this._difficulty = obj['difficulty'];
    this._priority = obj['priority'];
  }

  String get key => _key;

  String get name => _name;

  String get grade => _grade;

  String get subject => _subject;

  String get question => _question;

  String get category => _category;

  String get answerOne => _answerOne;

  String get answerTwo => _answerTwo;

  String get answerThree => _answerThree;

  String get answerFour => _answerFour;

  String get correctAnswer => _correctAnswer;

  String get difficulty => _difficulty;

  String get priority => _priority;

  QuizModel.fromSnapshot(DataSnapshot snapshot) {
    _name = snapshot.value['name'];
    _grade = snapshot.value['grade'];
    _subject = snapshot.value['subject'];
    _question = snapshot.value['question'];
    _category = snapshot.value['category'];
    _answerOne = snapshot.value['answerOne'];
    _answerTwo = snapshot.value['answerTwo'];
    _answerThree = snapshot.value['answerThree'];
    _answerFour = snapshot.value['answerFour'];
    _correctAnswer = snapshot.value['correctAnswer'];
    _difficulty = snapshot.value['difficulty'];
    _priority = snapshot.value['priority'];
  }
}
