import 'package:flutter/material.dart';

class UserInfo extends ChangeNotifier{
  String _userName = "", _userId = "", _password = "", _dormitory = "";
  int _canReservation = 0;
  String _machineNum = "";
  DateTime? _startTime;
  DateTime? _endTime;

  String getUserName() { return _userName; }
  String getUserId(){ return _userId; }
  String getPassword(){ return _password; }
  String getDormitory(){ return _dormitory; }
  bool getCanReservation(){ return _canReservation == 1 ? true : false; }
  String getMachineNum() { return _machineNum; }
  DateTime? getStartTime(){ return _startTime; }
  DateTime? getEndTime(){ return _endTime; }

  void putUserName(String name){
    _userName = name;
    notifyListeners();
  }
  void putUserId(String id){
    _userId = id;
    notifyListeners();
  }
  void putPassword(String password){
    _password = password;
    notifyListeners();
  }
  void putDormitory(String dormitory){
    _dormitory = dormitory;
    notifyListeners();
  }
  void putCanReservation(bool flag){
    _canReservation = flag == true ? 1 : 0;
    notifyListeners();
  }
  void putMachineNum(String number){
    _machineNum = number;
    notifyListeners();
  }
  void putStartTime(String startTime){
    if(startTime == "") {
      _startTime = null;
    } else {
      _startTime = DateTime.parse(startTime);
    }
    notifyListeners();
  }
  void putEndTime(String endTime){
    if(endTime == "") {
      _endTime = null;
    } else {
      _endTime = DateTime.parse(endTime);
    }
    notifyListeners();
  }

  bool isEmpty(String str){
    return (str == "") ? true : false;
  }
}