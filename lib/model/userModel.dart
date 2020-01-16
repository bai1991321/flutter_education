import 'package:firebase_database/firebase_database.dart';

class UserModel {
  String email;
  String firstName;
  String lastName;
  String role;
  String isSignUpWith;
  String signUpMethod;
  String gcmId;
  String handleName;
  String schoolName;
  String gradeLevel;
  String city;
  String state;
  String avtarUrl;
  String gender;
  String difficultyLevel;

  UserModel(
    this.email,
    this.firstName,
    this.lastName,
    this.role,
    this.isSignUpWith,
    this.signUpMethod,
    this.gcmId,
    this.handleName,
    this.schoolName,
    this.gradeLevel,
    this.city,
    this.state,
    this.avtarUrl,
    this.gender,
    this.difficultyLevel,
  );

  Map<String, dynamic> toJson() => {
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
      };

  UserModel.fromJson(Map<String, dynamic> obj)
      : email = obj['email'],
        firstName = obj['firstName'],
        lastName = obj['lastName'],
        role = obj['role'],
        isSignUpWith = obj['isSignUpWith'],
        signUpMethod = obj['signUpMethod'],
        gcmId = obj['gcmId'],
        handleName = obj['handleName'],
        schoolName = obj['schoolName'],
        gradeLevel = obj['gradeLevel'],
        city = obj['city'],
        state = obj['state'],
        avtarUrl = obj['avtarUrl'],
        gender = obj['gender'],
        difficultyLevel = obj['difficultyLevel'];

  UserModel.fromSnapshot(DataSnapshot snapshot) {
    email = snapshot.value['email'];
    firstName = snapshot.value['firstName'];
    lastName = snapshot.value['lastName'];
    role = snapshot.value['role'];
    isSignUpWith = snapshot.value['isSignUpWith'];
    signUpMethod = snapshot.value['signUpMethod'];
    gcmId = snapshot.value['gcmId'];
    handleName = snapshot.value['handleName'];
    schoolName = snapshot.value['schoolName'];
    gradeLevel = snapshot.value['gradeLevel'];
    city = snapshot.value['city'];
    state = snapshot.value['state'];
    avtarUrl = snapshot.value['avtarUrl'];
    gender = snapshot.value['gender'];
    difficultyLevel = snapshot.value['difficultyLevel'];
  }
}
