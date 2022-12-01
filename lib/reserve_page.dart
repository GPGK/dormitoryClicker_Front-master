import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_info.dart';
import 'reservation_data.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyTime{
  static String set_Day = getToday(daySelect: 0);
  static String set_Day2 = "0000-00-00";

  static String startHour = '00';
  static String endHour = '00';

  static bool isStartTimeSelected = false;
  static bool isEndTimeSelected = false;

  static int duration = 0;

  static String getToday({required int daySelect}) {
    var now = DateTime.now();
    DateTime day = DateTime(now.year, now.month, now.day + daySelect);
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String strToday = formatter.format(day);
    return strToday;
  }

  static void popping() {
    set_Day = getToday(daySelect: 0);
    startHour = '00';
    endHour = '00';
    isStartTimeSelected = false;
    isEndTimeSelected = false;
    duration = 0;
  }
}

class ReservePage extends StatefulWidget {
  const ReservePage({Key? key}) : super(key: key);

  @override
  State<ReservePage> createState() => _ReservePageState();
}

class _ReservePageState extends State<ReservePage> {

  final AsyncMemoizer _memoizer = AsyncMemoizer();

  Future _getDataSetting1(String dormitory, String machineNum)
  => _memoizer.runOnce(() => getReservationData(dormitory, machineNum));

  Future<String> getReservationData(String dormitory, String machineNum) async {
    http.Response res = await http.get(Uri.parse(
        'https://www.dormitoryclicker.shop/reservation?dormitory=$dormitory&machineNum=$machineNum'
    ));

    String jsonData = res.body;

    if (jsonData == "There's no machine") { return "404: Machine Not Found"; }
    else {
      for(int i = 0; i < jsonDecode(jsonData)['startDatetime']!.length; i++){
        reservationData.reservations['startDatetime'].add(DateTime.parse(jsonDecode(jsonData)['startDatetime']![i]));
        reservationData.reservations['endDatetime'].add(DateTime.parse(jsonDecode(jsonData)['endDatetime']![i]));
      }

      return "Success";
    }
  }

  Future<String> putReservationData(String userId, String dormitory, String machineNum, DateTime startDatetime, DateTime endDatetime) async {
    http.Response res = await http.post(Uri.parse('https://www.dormitoryclicker.shop/reservation'),
        body: {
          'userId': userId,
          'dormitory': dormitory,
          'machineNum': machineNum,
          'startDatetime': DateFormat('yyyy-MM-dd HH:mm:00').format(startDatetime),
          'endDatetime': DateFormat('yyyy-MM-dd HH:mm:00').format(endDatetime),
        }
    );

    return res.body;
  }

  /***********************토글 버튼 관련*************************/
  bool dDay_0 = false;
  bool dDay_1 = false;
  bool dDay_2 = false;
  late List<bool> isDateSelected;

  void initState(){
    isDateSelected = [dDay_0, dDay_1, dDay_2];
    super.initState();
  }

  void toggleDateSelect(value) {
    if (value == 0) {
      MyTime.set_Day = MyTime.getToday(daySelect: value);

      dDay_0 = true;
      dDay_1 = false;
      dDay_2 = false;
    }
    else if (value == 1) {
      MyTime.set_Day = MyTime.getToday(daySelect: value);

      dDay_0 = false;
      dDay_1 = true;
      dDay_2 = false;
    }
    else if (value == 2) {
      MyTime.set_Day = MyTime.getToday(daySelect: value);

      dDay_0 = false;
      dDay_1 = false;
      dDay_2 = true;
    }
    setState(() {
      isDateSelected = [dDay_0, dDay_1, dDay_2];
    });
  }
  /*************************************************************/


  /****************************리스트 뷰 관련*****************************/
  final List<String> timeList = [
    '00시', '01시', '02시', '03시', '04시', '05시', '06시', '07시', '08시', '09시', '10시', '11시',
    '12시', '13시', '14시', '15시', '16시', '17시', '18시', '19시', '20시', '21시', '22시', '23시'
  ];
  final List<String> durationList = ['1시간', '2시간'];

  int count = 0;
  int? selectedStartIndex;
  int? selectedEndIndex;
  int durationCount = 0;
  int? selectedDurationIndex;

  List<List<bool>> isEnableTile = [
    List.generate(24, (i) => true),
    List.generate(24, (i) => true),
    List.generate(24, (i) => true)
  ];
  List<List<int>> listViewState = [
    List.generate(24, (i) => 2),
    List.generate(24, (i) => 2),
    List.generate(24, (i) => 2)
  ];
  List<bool> isEnableDuration = [true, true];
  List<int> durationState = [2, 2];

  List<List<int>> disableStartTimeList = [
    List<int>.empty(growable: true),
    List<int>.empty(growable: true),
    List<int>.empty(growable: true)
  ];
  List<List<int>> disableEndTimeList = [
    List<int>.empty(growable: true),
    List<int>.empty(growable: true),
    List<int>.empty(growable: true),
  ];
  List<int> disableDurationList = List<int>.empty(growable: true);

  Color? setListViewColor(int index){
    if (dDay_0 == true) {
      if(listViewState[0][index] == 0) { return Colors.black26; }
      else if(listViewState[0][index] == 1) { return Colors.greenAccent; }
      else { return Colors.white; }
    } else if (dDay_1 == true) {
      if(listViewState[1][index] == 0) { return Colors.black26; }
      else if(listViewState[1][index] == 1) { return Colors.greenAccent; }
      else { return Colors.white; }
    } else if (dDay_2 == true) {
      if(listViewState[2][index] == 0) { return Colors.black26; }
      else if(listViewState[2][index] == 1) { return Colors.greenAccent; }
      else { return Colors.white; }
    }
    return null;
  }
  Color? setDurationColor(int index){
    if (durationState[index] == 0) { return Colors.black26; }
    else if (durationState[index] == 1) { return Colors.greenAccent; }
    else { return Colors.white; }
  }

  bool isPastTime(int index) {
    if (DateTime.now().difference(DateTime.parse('${MyTime.set_Day} ${timeList[index][0]}${timeList[index][1]}:00:00')).inSeconds > 0) {
      return true;
    }
    return false;
  }

  ReservationData clearListView(ReservationData reservationData){
    Map<String, List<DateTime>> tempMachine = reservationData.reservations;

    List<DateTime>? tempStartTime = tempMachine['startDatetime'];
    List<DateTime>? tempEndTime = tempMachine['endDatetime'];

    for(int i = 0; i < tempStartTime!.length; i++){
      String tempStart = DateFormat('yyyy-MM-dd HH:mm:00').format(tempStartTime[i]);
      String tempEnd = DateFormat('yyyy-MM-dd HH:mm:00').format(tempEndTime![i]);
      for(int j = 0; j < timeList.length; j++){
        if(tempStart[8] + tempStart[9] == DateFormat('dd').format(DateTime.now())
            && tempStart[11] + tempStart[12] == timeList[j][0] + timeList[j][1]){
          disableStartTimeList[0].add(j);
        }
        if((tempEnd[8] + tempEnd[9] == DateFormat('dd').format(DateTime.now())
            || tempEnd[8] + tempEnd[9] == DateFormat('dd').format(DateTime.now().add(const Duration(days: 1))))
            && tempEnd[11] + tempEnd[12] == timeList[j][0] + timeList[j][1]){
          disableEndTimeList[0].add(j);
        }

        if(tempStart[8] + tempStart[9] == DateFormat('dd').format(DateTime.now().add(const Duration(days: 1)))
            && tempStart[11] + tempStart[12] == timeList[j][0] + timeList[j][1]){
          disableStartTimeList[1].add(j);
        }
        if((tempEnd[8] + tempEnd[9] == DateFormat('dd').format(DateTime.now().add(const Duration(days: 1)))
            || tempEnd[8] + tempEnd[9] == DateFormat('dd').format(DateTime.now().add(const Duration(days: 2))))
            && tempEnd[11] + tempEnd[12] == timeList[j][0] + timeList[j][1]){
          disableEndTimeList[1].add(j);
        }

        if(tempStart[8] + tempStart[9] == DateFormat('dd').format(DateTime.now().add(const Duration(days: 2)))
            && tempStart[11] + tempStart[12] == timeList[j][0] + timeList[j][1]){
          disableStartTimeList[2].add(j);
        }
        if((tempEnd[8] + tempEnd[9] == DateFormat('dd').format(DateTime.now().add(const Duration(days: 2)))
            || tempEnd[8] + tempEnd[9] == DateFormat('dd').format(DateTime.now().add(const Duration(days: 3))))
            && tempEnd[11] + tempEnd[12] == timeList[j][0] + timeList[j][1]){
          disableEndTimeList[2].add(j);
        }
      }
    }

    count = 0;
    selectedStartIndex = null;
    selectedEndIndex = null;

    for(int i = 0; i < timeList.length; i++){
      if (dDay_0 == true) {
        isEnableTile[0][i] = true;
        listViewState[0][i] = 2;
      } else if (dDay_1 == true) {
        isEnableTile[1][i] = true;
        listViewState[1][i] = 2;
      } else if (dDay_2 == true) {
        isEnableTile[2][i] = true;
        listViewState[2][i] = 2;
      }
    }

    int nowTime = int.parse(DateTime.now().hour.toString()) * 60 + int.parse(DateTime.now().minute.toString());

    for(int i = 0; i < isEnableTile[0].length; i++){
      int tempHour = int.parse(timeList[i][0] + timeList[i][1]);
      if(tempHour * 60 <= nowTime){
        isEnableTile[0][i] = false;
        listViewState[0][i] = 0;
      }
    }

    if (disableStartTimeList[0].isNotEmpty) {
      for(int i = 0; i < disableStartTimeList[0].length; i++){
        if (disableStartTimeList[0][i] > disableEndTimeList[0][i]) {
          for(int j = disableStartTimeList[0][i]; j < timeList.length; j++){
            isEnableTile[0][j] = false;
            listViewState[0][j] = 0;
          }
          if (disableEndTimeList[0][i] != 0) {
            isEnableTile[1][0] = false;
            listViewState[1][0] = 0;
          }
        } else {
          for(int j = disableStartTimeList[0][i]; j < disableEndTimeList[0][i]; j++){
            isEnableTile[0][j] = false;
            listViewState[0][j] = 0;
          }
        }
      }
    }
    if (disableStartTimeList[1].isNotEmpty) {
      for(int i = 0; i < disableStartTimeList[1].length; i++){
        if (disableStartTimeList[1][i] > disableEndTimeList[1][i]) {
          for(int j = disableStartTimeList[1][i]; j < timeList.length; j++){
            isEnableTile[1][j] = false;
            listViewState[1][j] = 0;
          }
          if (disableEndTimeList[1][i] != 0) {
            isEnableTile[2][0] = false;
            listViewState[2][0] = 0;
          }
        } else {
          for(int j = disableStartTimeList[1][i]; j < disableEndTimeList[1][i]; j++){
            isEnableTile[1][j] = false;
            listViewState[1][j] = 0;
          }
        }
      }
    }
    if (disableStartTimeList[2].isNotEmpty) {
      for(int i = 0; i < disableStartTimeList[2].length; i++){
        if (disableStartTimeList[2][i] > disableEndTimeList[2][i]) {
          for(int j = disableStartTimeList[2][i]; j < timeList.length; j++){
            isEnableTile[2][j] = false;
            listViewState[2][j] = 0;
          }
        } else {
          for(int j = disableStartTimeList[2][i]; j < disableEndTimeList[2][i]; j++){
            isEnableTile[2][j] = false;
            listViewState[2][j] = 0;
          }
        }
      }
    }

    disableStartTimeList[0].clear();
    disableEndTimeList[0].clear();
    disableStartTimeList[1].clear();
    disableEndTimeList[1].clear();
    disableStartTimeList[2].clear();
    disableEndTimeList[2].clear();

    MyTime.isStartTimeSelected = false;
    MyTime.isEndTimeSelected = false;
    MyTime.duration = 0;

    return reservationData;
  }
  /**********************************************************************/

  var userInfo;
  var reservationData;

  @override
  Widget build(BuildContext context) {
    userInfo = Provider.of<UserInfo>(context, listen: true);
    reservationData = Provider.of<ReservationData>(context, listen: true);

    return WillPopScope(
        child: Scaffold(
            body: FutureBuilder(
                future: _getDataSetting1(userInfo.getDormitory(), userInfo.getMachineNum()),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Row(
                            children: [
                              Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(top: 30.0, left: 15.0),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.lightBlue,
                                    size: 25.0,
                                  ),
                                  onPressed: () {
                                    MyTime.popping();
                                    reservationData.reservations['startDatetime'].clear();
                                    reservationData.reservations['endDatetime'].clear();
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.only(top: 30.0),
                                child: Text(
                                  '${userInfo.getDormitory()} ${userInfo.getMachineNum()} 예약',
                                  style: const TextStyle(color: Colors.lightBlue, fontSize: 20.0),
                                ),
                              )
                            ]
                        ),
                        Flexible(
                          flex: 4,
                          fit: FlexFit.tight,
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.only(top: 20),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0x0a0a0aff),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: RichText(
                                    text: const TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '< 예약시 주의사항 >\n\n',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                          ),
                                        ),
                                        TextSpan(
                                          text: '최대 2시간까지만 예약 가능합니다.\n',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                          ),
                                        ),
                                        TextSpan(
                                          text: '최대 한번까지만 예약이 가능합니다.\n',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: Text(
                                    (dDay_0 == false && dDay_1 == false && dDay_2 == false) ?
                                    "날짜를 선택해주세요" : (count == 0) ?
                                    "시작 시간을 선택해주세요" : (count == 1) ?
                                    "지속 시간을 선택해주세요" : "예약 버튼을 눌러주세요",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 25
                                    ),
                                  ),
                                ),

                                Flexible(
                                  flex: 4,
                                  fit: FlexFit.tight,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                          flex: 1,
                                          fit: FlexFit.loose,
                                          child: Container(
                                              alignment: Alignment.center,
                                              child: ToggleButtons(
                                                isSelected: isDateSelected,
                                                direction: Axis.vertical,
                                                onPressed: (value){
                                                  toggleDateSelect(value);
                                                  setState(() {
                                                    reservationData = clearListView(reservationData);
                                                  });
                                                },
                                                selectedColor: Colors.black,
                                                fillColor: Colors.greenAccent,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                                    child: Text(
                                                      '${DateTime.parse(MyTime.getToday(daySelect: 0)).month}월 '
                                                          '${DateTime.parse(MyTime.getToday(daySelect: 0)).day}일',
                                                      //style: TextStyle(fontSize: 18),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                                    child: Text(
                                                      '${DateTime.parse(MyTime.getToday(daySelect: 1)).month}월 '
                                                          '${DateTime.parse(MyTime.getToday(daySelect: 1)).day}일',
                                                      //style: TextStyle(fontSize: 18),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                                    child: Text(
                                                      '${DateTime.parse(MyTime.getToday(daySelect: 2)).month}월 '
                                                          '${DateTime.parse(MyTime.getToday(daySelect: 2)).day}일',
                                                      //style: TextStyle(fontSize: 18),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              )
                                          )
                                      ),

                                      Flexible(
                                        flex: 2,
                                        fit: FlexFit.loose,
                                        child: Visibility(
                                          visible: (dDay_0 == true || dDay_1 == true ||dDay_2 == true) ?
                                          true : false,
                                          child: Center(
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: timeList.length,
                                              itemBuilder: (BuildContext context, int index) {
                                                return _buildItem(timeList[index], index);
                                              },
                                            ),
                                          ),
                                        ),
                                      ),

                                      Flexible(
                                          flex: 2,
                                          fit: FlexFit.loose,
                                          child: Visibility(
                                              visible: (MyTime.isStartTimeSelected == true) ?
                                              true : false,
                                              child: Center(
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: durationList.length,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      return _buildDurationItem(durationList[index], index);
                                                    },
                                                  )
                                              )
                                          )
                                      )
                                    ],
                                  ),
                                ),

                                Flexible(
                                    flex: 1,
                                    fit: FlexFit.tight,
                                    child: Row(
                                      children: [
                                        Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child: Visibility(
                                                visible: (count >= 1) ?
                                                true : false,
                                                child: Text(
                                                  "시작 시간 - "
                                                      "${DateTime.parse('${MyTime.set_Day} ${MyTime.startHour}:00:00').month}월 "
                                                      "${DateTime.parse('${MyTime.set_Day} ${MyTime.startHour}:00:00').day}일 "
                                                      "${DateTime.parse('${MyTime.set_Day} ${MyTime.startHour}:00:00').hour}시",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                )
                                            )
                                        ),
                                        Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child: Visibility(
                                                visible: (count == 2) ?
                                                true : false,
                                                child: Text(
                                                  "종료 시간 - "
                                                      "${DateTime.parse('${MyTime.set_Day2} ${MyTime.endHour}:00:00').month}월 "
                                                      "${DateTime.parse('${MyTime.set_Day2} ${MyTime.endHour}:00:00').day}일 "
                                                      "${DateTime.parse('${MyTime.set_Day2} ${MyTime.endHour}:00:00').hour}시",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                )
                                            )
                                        ),
                                      ],
                                    )
                                ),

                                Flexible(
                                    flex: 1,
                                    fit: FlexFit.tight,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          flex: 1,
                                          fit: FlexFit.loose,
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: ElevatedButton(
                                              onPressed: (){
                                                setState(() {
                                                  reservationData = clearListView(reservationData);
                                                });
                                              },
                                              child: const Text("초기화"),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 1,
                                          fit: FlexFit.loose,
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: ElevatedButton(
                                              onPressed: (){
                                                DateTime newStartTime = DateTime.parse('${MyTime.set_Day} ${MyTime.startHour}:00:00');
                                                DateTime newEndTime = DateTime.parse('${MyTime.set_Day2} ${MyTime.endHour}:00:00');

                                                if(MyTime.isStartTimeSelected == false || MyTime.isEndTimeSelected == false) {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          content: const Text('시간을 지정해주세요.'),
                                                          actions: [
                                                            Center(
                                                              child: ElevatedButton(
                                                                child: const Text('확인'),
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                  );
                                                } else {
                                                  putReservationData(userInfo.getUserId(), userInfo.getDormitory(), userInfo.getMachineNum(), newStartTime, newEndTime).then((value) {
                                                    if(value == "already reservation"){
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              content: const Text('이미 예약된 내역이 있습니다.'),
                                                              actions: [
                                                                Center(
                                                                  child: ElevatedButton(
                                                                    child: const Text('확인'),
                                                                    onPressed: () {
                                                                      Navigator.pop(context);
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          }
                                                      );
                                                    } else if (value == "There's no machine") {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              content: const Text('기기 확인이 불가능합니다.'),
                                                              actions: [
                                                                Center(
                                                                  child: ElevatedButton(
                                                                    child: const Text('확인'),
                                                                    onPressed: () {
                                                                      Navigator.pop(context);
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          }
                                                      );
                                                    } else if (value == "success") {
                                                      userInfo.putCanReservation(false);
                                                      userInfo.putStartTime(DateFormat('yyyy-MM-dd HH:00:00').format(newStartTime));
                                                      userInfo.putEndTime(DateFormat('yyyy-MM-dd HH:00:00').format(newEndTime));

                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              content: Text("예약되었습니다.\n\n"
                                                                  "${userInfo.getStartTime().month}월 ${userInfo.getStartTime().day}일 "
                                                                  "${userInfo.getStartTime().hour}시 ${userInfo.getStartTime().minute}분"
                                                                  " - "
                                                                  "${userInfo.getEndTime().month}월 ${userInfo.getEndTime().day}일 "
                                                                  "${userInfo.getEndTime().hour}시 ${userInfo.getEndTime().minute}분"),
                                                              actions: [
                                                                Center(
                                                                  child: ElevatedButton(
                                                                    child: const Text('확인'),
                                                                    onPressed: () {
                                                                      MyTime.popping();
                                                                      reservationData.reservations['startDatetime'].clear();
                                                                      reservationData.reservations['endDatetime'].clear();
                                                                      Navigator.popAndPushNamed(context, '/mypage');
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          }
                                                      );
                                                    }
                                                  });
                                                }
                                              },
                                              child: const Text("예약"),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(12),
                            child: Text(
                              'Error: ${snapshot.error}', // 에러명을 텍스트에 뿌려줌
                              style: TextStyle(fontSize: 15),
                            )
                        )
                    );
                  } else {
                    return Center(
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(12),
                            child: const Center(
                              child: SpinKitFadingCircle(
                                color: Colors.black,
                                size: 80.0,
                              ),
                            )
                        )
                    );
                  }
                }
            )
        ),
        onWillPop: (){
          setState(() {
            MyTime.popping();
            reservationData.reservations['startDatetime'].clear();
            reservationData.reservations['endDatetime'].clear();
          });
          return Future(() => false);
        }
    );
  }

  Widget _buildItem(String timeListElement, int index) {
    return Card(
      elevation: 1,
      child: Visibility(
        visible: (isPastTime(index) == true) ?
        false : true,
        child: ListTile(
          title: Text(
            timeListElement,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          tileColor: setListViewColor(index),
          onTap: ((dDay_0 == true) ?
          isEnableTile[0][index] : (dDay_1 == true) ?
          isEnableTile[1][index] : isEnableTile[2][index]) ? (){
            int flag = (dDay_0 == true) ? 0 : (dDay_1 == true) ? 1 : 2;
            setState(() {
              if(listViewState[flag][index] == 2){
                if(count == 0) {
                  selectedStartIndex = index;
                  listViewState[flag][index] = 1;
                  isEnableTile[flag][index] = false;
                  MyTime.isStartTimeSelected = true;
                  MyTime.startHour = timeList[selectedStartIndex!][0] + timeList[selectedStartIndex!][1];
                  count = 1;

                  durationState = [2, 2];
                  isEnableDuration = [true, true];

                  List<DateTime> tempReservationList = reservationData.reservations['startDatetime'];
                  for(int i = 0; i < tempReservationList.length; i++){
                    if (DateTime.parse('${MyTime.set_Day} ${NumberFormat('00').format(int.parse(MyTime.startHour) + 1)}:00:00')
                        == tempReservationList[i]) {
                      durationState[1] = 0;
                      isEnableDuration[1] = false;
                    }
                  }
                } else {
                  listViewState[flag][selectedStartIndex!] = 2;
                  isEnableTile[flag][selectedStartIndex!] = true;

                  selectedStartIndex = index;
                  listViewState[flag][index] = 1;
                  isEnableTile[flag][index] = false;
                  MyTime.startHour = timeList[selectedStartIndex!][0] + timeList[selectedStartIndex!][1];
                  count = 1;

                  durationState = [2, 2];
                  isEnableDuration = [true, true];

                  List<DateTime> tempReservationList = reservationData.reservations['startDatetime'];
                  for(int i = 0; i < tempReservationList.length; i++){
                    if (DateTime.parse('${MyTime.set_Day} ${NumberFormat('00').format(int.parse(MyTime.startHour) + 1)}:00:00')
                        == tempReservationList[i]) {
                      durationState[1] = 0;
                      isEnableDuration[1] = false;
                    }
                  }
                }
              } else if(listViewState[flag][index] == 1) {
                listViewState[flag][index] = 1;
              }
            });
          } : null,
        ),
      ),
    );
  }

  Widget _buildDurationItem(String durationListElement, int index) {
    return Card(
      elevation: 1,
      child: ListTile(
        title: Text(
          durationListElement,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        tileColor: setDurationColor(index),
        onTap: (isEnableDuration[index]) ? (){
          setState(() {
            if(durationState[index] == 2){
              if (durationCount == 0) {
                selectedDurationIndex = index;
                durationState[index] = 1;
                isEnableDuration[index] = false;

                durationCount = 1;

                MyTime.duration = (durationListElement == '1시간') ? 1 : 2;

                String tempHour = NumberFormat('00').format(int.parse(MyTime.startHour) + MyTime.duration);
                DateTime temp = DateTime.parse('${MyTime.set_Day} $tempHour:00:00');

                MyTime.set_Day2 = DateFormat('yyyy-MM-dd').format(temp);
                MyTime.endHour = DateFormat('HH').format(temp);
                MyTime.isEndTimeSelected = true;
                count = 2;
              } else if (durationCount == 1) {
                durationState[selectedDurationIndex!] = 2;
                isEnableDuration[selectedDurationIndex!] = true;

                selectedDurationIndex = index;
                durationState[index] = 1;
                isEnableDuration[index] = false;

                MyTime.duration = (durationListElement == '1시간') ? 1 : 2;

                String tempHour = NumberFormat('00').format(int.parse(MyTime.startHour) + MyTime.duration);
                DateTime temp = DateTime.parse('${MyTime.set_Day} $tempHour:00:00');

                MyTime.set_Day2 = DateFormat('yyyy-MM-dd').format(temp);
                MyTime.endHour = DateFormat('HH').format(temp);
                MyTime.isEndTimeSelected = true;
                count = 2;
              }
            } else if(durationState[index] == 1) {
              durationState[index] = 1;
            }
          });
        } : null,
      ),
    );
  }
}