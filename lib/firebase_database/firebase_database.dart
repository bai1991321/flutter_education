import 'dart:async';

import 'package:education_app/utils/commonUtils.dart';
import 'package:firebase_database/firebase_database.dart';

abstract class FirebaseDb {
  // this is an interface, remember Java
  Future<void> signUpNewUser(
      DatabaseReference databaseReference,
      String id,
      String email,
      String firstName,
      String lastName,
      String role,
      String isSignUpWith,
      String signUpMethod,
      String gcmId,
      String handleName,
      String schoolName,
      String gradeLevel,
      String city,
      String state,
      String avtarUrl,
      String gender,
      String difficultyLevel);

  Future<void> quizQuestion(
      DatabaseReference databaseReference,
      String id,
      String email,
      String name,
      String subject,
      String category,
      String grade,
      String question,
      String answerOne,
      String answerTwo,
      String answerThree,
      String answerFour,
      String correctAnswer,
      String status);

  Future<void> quizAnswer(
      DatabaseReference databaseReference,
      String id,
      String email,
      String name,
      String subject,
      String category,
      String grade,
      String questionKey,
      String answerText,
      String quizType);

  Future<void> updateUserDifficultyLevel(
    DatabaseReference databaseReference,
    String id,
    String difficultyLevel,
  );

  Future<void> setLearningRate(
    DatabaseReference databaseReference,
    String id,
    String session,
    String learningRate,
    String grade,
    String subject,
    String score,
    String difficultyLevel,
  );

  Future<void> updateUserLastSeen(
      DatabaseReference databaseReference, String id);
}

class FirebaseDbAuth implements FirebaseDb {
  @override
  Future<void> signUpNewUser(
      DatabaseReference databaseReference,
      String id,
      String email,
      String firstName,
      String lastName,
      String role,
      String isSignUpWith,
      String signUpMethod,
      String gcmId,
      String handleName,
      String schoolName,
      String gradeLevel,
      String city,
      String state,
      String avtarUrl,
      String gender,
      String difficultyLevel) async {
    await databaseReference.child(id).set({
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'isSignUpWith': isSignUpWith,
      'signUpMethod': signUpMethod,
      'gcmId': gcmId,
      'handleName': handleName,
      'schoolName': schoolName,
      'gradeLevel': gradeLevel,
      'city': city,
      'state': state,
      'avtarUrl': avtarUrl,
      'gender': gender,
      'difficultyLevel': difficultyLevel,
      'lastSeen': CommonUtils.getCurrentDate(),
    }).then((_) {});
  }

  @override
  Future<void> quizQuestion(
      DatabaseReference databaseReference,
      String id,
      String email,
      String name,
      String subject,
      String category,
      String grade,
      String question,
      String answerOne,
      String answerTwo,
      String answerThree,
      String answerFour,
      String correctAnswer,
      String status) async {
    await databaseReference.child(id).push().set({
      'email': email,
      'name': name,
      'subject': subject,
      'category': category,
      'grade': grade,
      'question': question,
      'answerOne': answerOne,
      'answerTwo': answerTwo,
      'answerThree': answerThree,
      'answerFour': answerFour,
      'correctAnswer': correctAnswer,
      'status': status,
    }).then((_) {});
  }

  @override
  Future<void> quizAnswer(
    DatabaseReference databaseReference,
    String id,
    String email,
    String name,
    String subject,
    String category,
    String grade,
    String questionKey,
    String answerText,
    String quizType,
  ) async {
    await databaseReference.child(id).push().set({
      'email': email,
      'name': name,
      'subject': subject,
      'category': category,
      'grade': grade,
      'questionKey': questionKey,
      'answerText': answerText,
      'quizType': quizType,
    }).then((_) {});
  }

  @override
  Future<void> updateUserDifficultyLevel(DatabaseReference databaseReference,
      String id, String difficultyLevel) async {
    await databaseReference.child(id).update({
      'difficultyLevel': difficultyLevel,
    }).then((_) {});
  }

  @override
  Future<void> updateUserLastSeen(
      DatabaseReference databaseReference, String id) async {
    await databaseReference.child(id).update({
      'lastSeen': CommonUtils.getCurrentDate(),
    }).then((_) {});
  }

  @override
  Future<void> setLearningRate(
      DatabaseReference databaseReference,
      String id,
      String session,
      String learningRate,
      String grade,
      String subject,
      String score,
      String difficultyLevel) async {
    await databaseReference.child(id).push().set({
      'session': session,
      'learningRate': learningRate,
      'grade': grade,
      'subject': subject,
      'score': score,
      'difficultyLevel': difficultyLevel,
      'sessionDate': CommonUtils.getCurrentDate(),
    }).then((_) {});
  }
}
