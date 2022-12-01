import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_info.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with WidgetsBindingObserver {
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  Future _getDataSetting(String userId)
  => _memoizer.runOnce(() => getUserData(userId));

  Future<String> getUserData(String userId) async {
    Map data = {'userId': userId};
    var body = json.encode(data);

    http.Response res = await http.post(Uri.parse('https://www.dormitoryclicker.shop/user'),
        headers: {'Content-Type': "application/json"},
        body: body
    );

    //여기서는 응답이 객체로 변환된 res 변수를 사용할 수 있다.
    //여기서 res.body를 jsonDecode 함수로 객체로 만들어서 데이터를 처리할 수 있다.
    String jsonData = res.body;

    if (jsonData == "Not found userId with $userId") {
      return "404: User Not Found";
    } else if (jsonData == "Server Unavailable") {
      return "500: Server Unavailable";
    } else {
      userInfo.putUserId(jsonDecode(jsonData)['userId']);
      userInfo.putPassword(jsonDecode(jsonData)['password']);
      userInfo.putUserName(jsonDecode(jsonData)['userName']);
      userInfo.putDormitory(jsonDecode(jsonData)['dormitory']);
      if (jsonDecode(jsonData)['reservation_time'] != null) {
        userInfo.putCanReservation(false);
        userInfo.putStartTime(jsonDecode(jsonData)['reservation_time']['start']);
        userInfo.putEndTime(jsonDecode(jsonData)['reservation_time']['end']);
      } else {
        userInfo.putCanReservation(true);
        userInfo.putStartTime("");
        userInfo.putEndTime("");
      }

      return "Success";
    }
  }

  Future<String> cancelReservation(String userId) async {
    http.Response res = await http.post(Uri.parse('https://www.dormitoryclicker.shop/cancel'),
        body: {
          'userId': userId
        }
    );

    //여기서는 응답이 객체로 변환된 res 변수를 사용할 수 있다.
    //여기서 res.body를 jsonDecode 함수로 객체로 만들어서 데이터를 처리할 수 있다.
    String jsonData = res.body;

    if (jsonData == "Not found userId with $userId") {
      return "404: Not Found User Id";
    } else if (jsonData == "Server Unavailable") {
      return "500: Server Unavailable";
    } else {
      return "success";
    }
  }

  //*************** 이메일 보내기 [ email_sender ] *******************

  void _sendEmail() async {
    final Email email = Email(
      body: '[사용 문의]\n',
      subject: '[세탁기 클리커 사용 문의]',
      recipients: ['gmgpgk1713@gmail.com'],
      cc: ['gmgpgk1713@gmail.com'],
      bcc: ['gmgpgk1713@gmail.com'],
      attachmentPaths: [],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch(error) {
      String title = "기본 메일 앱을 사용할 수 없기 때문에 앱에서 바로 문의를 전송하기 어려운 상황입니다.";
      //String message = "";
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('확인')),
          ],
        ),
      );
    }
  }

  //*********[ 알림 관련 (flutter_local_notification)]******************

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }
  //앱 아이콘의 Badge를 초기화하는 코드를 기본적으로 제공하지 않는다.
  //따라서 FlutterAppBader을 사용하여 '앱이 Foreground 상태가 될때 뱃지를 초기화할 필요가 있다.'

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      FlutterAppBadger.removeBadge();
    }
  }

  Future<void> _init() async {
    await _configureLocalTimeZone();
    await _initializeNotification();
  }
  // flutter_local_notification 초기화
  // ..를 사용하여 특정 시간에 로컬 푸시 메시지를 표시하기 위해서는 '초기화 필요.'

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName!));
  } // 위 코드를 사용하여 [현재 단말기의 현재 시간을 등록]합니다.


  // 또한, 다음과 같이 [iOS의 메시지 권한 요청을 초기화]
  // iOS의 초기화시, 권한 요청 메시지가 바로 표시되지 않도록 하기 위해 모든 값을 false로 설정
  //
  // Android는 ic_notification을 사용하여 [푸시 메시지의 아이콘을 설정].
  // 해당 아이콘은 drawable* 폴더에 저장합니다.
  Future<void> _initializeNotification() async {
    // ios
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    // Android
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_notification');   // ic_notification은 drawable의 이미지 파일(알람 아이콘)
    // ios & Android
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // [메시지 등록 취소]
  // 새로운 메시지를 등록할 때, 이전에 등록된 메시지를 모두 취소하기 위해 'cancelAll'함수를 사용
  Future<void> _cancelNotification() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // [권한 요청]
  // 푸시 메시지를 등록하기 전에, ios의 푸시 메시지 권한을 요청
  // 이 코드는 사용자가 권한 요청 화면에서 권한을 결정하면, 다시 사용자의 권한을 요청하지 않음
  Future<void> _requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // [메시지 등록]
  // 마지막으로, 현재 시간에서 (1분후)에 메시지가 표시될 수 있도록 푸시 메시지를 등록
  // 이 메시지는 (매일 동일한 시간에 메시지가 표시)
  Future<void> _registerMessage({
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minutes,
    required message,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      year,
      month,
      day,
      hour,
      minutes,
    );
    // zonedSchedule의 ID를 동일하게 설정하면,
    // 동일한 메시지가 현재 표시중이면, 메시지를 중복하여 표시하지 않음
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,                                  // 알람 ID
      '세탁기 클리커 알람',      // ☆ 메시지 타이틀
      message,                            // 메시지 내용
      scheduledDate,
      NotificationDetails(
        // AndroidNotificationDetails의 ongoing을 true로 설정하면,
        // 앱을 실행해야만 메시지가 사라지도록 설정할 수 있음
        android: AndroidNotificationDetails(
          'channel id',
          'channel name',
          importance: Importance.max,
          priority: Priority.high,
          ongoing: false,
          styleInformation: BigTextStyleInformation(message),
          icon: 'ic_notification',
        ),
        iOS: const DarwinNotificationDetails(
          badgeNumber: 1,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      //matchDateTimeComponents: DateTimeComponents.time,    -> 주기적으로 알림을 띄움
    );
  }

  int? timeYear;
  int? timeMonth;
  int? timeDay;
  int? timeHour;
  int? timeMin;

  DateTime? dateTime;


  //****************************************************************************



  bool isSettedAlarm = false;

  var userInfo;

  @override
  Widget build(BuildContext context) {
    userInfo = Provider.of<UserInfo>(context, listen: true);

    bool? isWeb;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        isWeb = false;
      } else {
        isWeb = true;
      }
    } catch (e) {
      isWeb = true;
    }



    String calculateTimeDifference(
        {required DateTime? startTime, required DateTime? endTime}) {
      int diffSec = endTime!.difference(DateTime.now()).inSeconds;
      if (diffSec <= 0){
        return '예약 시간이 종료되었습니다';
      }

      int check = DateTime.now().difference(startTime!).inSeconds;
      if (check <= 0) return '예약 시간이 되지 않았습니다';

      int hr = diffSec ~/ 3600;
      int min = (diffSec - 3600 * hr) ~/ 60;
      int sec = diffSec % 60;

      return '$hr시간 $min분 $sec초 남음';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("마이페이지"),
        centerTitle: true,
        elevation: 0.0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                userInfo.getUserId(),
                style: const TextStyle(
                    fontSize: 30
                ),
              ),
              accountEmail: const Text(""),
              decoration: BoxDecoration(color: Colors.blue[300]),
            ),
            ListTile(
              title: const Text("홈"),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              title: const Text("마이페이지"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/mypage');
              },
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              title: const Text("문의/건의"),
              onTap: () async {
                if(isWeb == true) {
                  final url = Uri(
                    scheme: 'mailto',
                    path: 'gmgpgk1713@gmail.com',
                    query: 'subject=기숙사 클리커 문의&body=[문의내용]\n',
                  );
                  if (await canLaunchUrl(url)) {
                    launchUrl(url);
                  }
                  else {
                    print("Can't launch $url");
                  }
                }
                else {
                  //_sendEmail();
                  final url = Uri(
                    scheme: 'mailto',
                    path: 'gmgpgk1713@gmail.com',
                    query: 'subject=기숙사 클리커 문의&body=[문의내용]\n',
                  );
                  if (await canLaunchUrl(url)) {
                    launchUrl(url);
                  }
                  else {
                    print("Can't launch $url");
                  }
                }
              },
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: _getDataSetting(userInfo.getUserId()),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            dateTime = userInfo.getEndTime();  // DateTime을 여기에 연결
            //dateTime = DateTime.parse('2022-12-01 16:40:00'); (테스트용)
            // 년, 월, 일, 시, 분
            timeYear =  (dateTime != null) ? int.parse(dateTime!.year.toString()) : null;
            timeMonth = (dateTime != null) ? int.parse(dateTime!.month.toString()) : null;
            timeDay =   (dateTime != null) ? int.parse(dateTime!.day.toString()) : null;
            timeHour =  (dateTime != null) ? int.parse(dateTime!.hour.toString()) : null;
            timeMin =   (dateTime != null) ? int.parse(dateTime!.minute.toString()) : null;


            return Center(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                          fit: FlexFit.tight,
                          flex: 1,
                          child: Row(
                            children: const [
                              Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: Text(
                                    "이름",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  )
                              ),
                              Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: Text(
                                    "학번",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  )
                              ),
                              Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: Text(
                                    "기숙사",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  )
                              ),
                            ],
                          )
                      ),
                      Flexible(
                          fit: FlexFit.tight,
                          flex: 1,
                          child: Row(
                            children: [
                              Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: Text(
                                    userInfo.getUserName(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                    ),
                                  )
                              ),
                              Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: Text(
                                    userInfo.getUserId(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                    ),
                                  )
                              ),
                              Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: Text(
                                    userInfo.getDormitory(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                    ),
                                  )
                              ),
                            ],
                          )
                      ),

                      const Divider(
                        indent: 20,
                        endIndent: 20,
                      ),

                      Flexible(
                          flex: 7,
                          fit: FlexFit.tight,
                          child: TimerBuilder.periodic(
                              const Duration(seconds: 1),
                              builder: (context) {
                                return Center(
                                    child: Column(
                                      children: [
                                        Flexible(
                                            fit: FlexFit.tight,
                                            flex: 1,
                                            child: Center(
                                              child: Text(
                                                userInfo.getCanReservation() ?
                                                "예약 내역이 없습니다" : "예약 내역이 있습니다",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 30,
                                                ),
                                              ),
                                            )
                                        ),

                                        Visibility(
                                          visible: userInfo.getCanReservation() ?
                                          false : true,
                                          child: Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Center(
                                                  child: Text(
                                                    userInfo.getCanReservation() ? "" :
                                                    "${userInfo.getStartTime().month}월 ${userInfo.getStartTime().day}일 "
                                                        "${userInfo.getStartTime().hour}시"
                                                        " - "
                                                        "${userInfo.getEndTime().month}월 ${userInfo.getEndTime().day}일 "
                                                        "${userInfo.getEndTime().hour}시",
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(Icons.timelapse),
                                                    Text(
                                                      userInfo.getCanReservation() ? "" :
                                                      calculateTimeDifference(startTime: userInfo.getStartTime(), endTime: userInfo.getEndTime()),
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          ),
                                        ),

                                        Visibility(
                                          visible: userInfo.getCanReservation() ?
                                          false : true,
                                          child: Flexible(
                                              fit: FlexFit.tight,
                                              flex: 1,
                                              child: Center(
                                                child: OutlinedButton(
                                                  onPressed: () async {
                                                    if (isSettedAlarm == true) {
                                                      isSettedAlarm = false;    // 예약이 취소된다면 기존 알림도 없어지도록 하기
                                                      await _flutterLocalNotificationsPlugin.cancel(0);    // [메시지 등록 취소]
                                                    }
                                                    setState(()  {
                                                      cancelReservation(userInfo.getUserId()).then((value) {
                                                        String message = value;
                                                        if (value == "success") {
                                                          message = "예약을 취소했습니다.";
                                                        }
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              content: Text(message),
                                                              actions: [
                                                                Center(
                                                                  child: ElevatedButton(
                                                                    onPressed: () {
                                                                      if (value == "success") {
                                                                        userInfo.putCanReservation(true);
                                                                      }
                                                                      Navigator.pop(context);
                                                                    },
                                                                    child: const Text("확인")
                                                                  )
                                                                )
                                                              ],
                                                            );
                                                          }
                                                        );
                                                      });
                                                    });
                                                  },
                                                  child: const Text(
                                                    "예약취소",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              )
                                          ),
                                        ),
                                      ],
                                    )
                                );
                              }
                          )
                      ),

                      const Divider(
                        indent: 20,
                        endIndent: 20,
                      ),

                      Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: Row(
                            children: [
                              Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: IconButton(
                                      onPressed: (){
                                        Navigator.pushNamed(context, '/setting');
                                      },
                                      icon: const Icon(Icons.settings)
                                  )
                              ),
                              Flexible(
                                  fit: FlexFit.tight,
                                  flex: 1,
                                  child: IconButton(
                                      onPressed: (){
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                content: const Text("로그아웃 하시겠습니까?"),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
                                                      },
                                                      child: const Text('예')),
                                                  ElevatedButton(
                                                      onPressed: () => Navigator.of(context).pop(),
                                                      child: const Text('아니오')),
                                                ],
                                              );
                                            }
                                        );
                                      },
                                      icon: const Icon(Icons.logout)
                                  )
                              )
                            ],
                          )
                      )
                    ],
                  ),
                )
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
        },
      ),
      floatingActionButton: Visibility(
          visible: (userInfo.getCanReservation() == true) ?
          false : true,
          child: FloatingActionButton(
              child: (isSettedAlarm == false) ? const Icon(Icons.notifications) : getNotIcon(const Icon(Icons.notifications)),
              onPressed: (){
                if (isSettedAlarm == false) { // 만약 알림이 설정되어 있지않다면 -> 알림을 설정하고자함
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: const Text('해당 기기에 종료시간 알림을 받으시겠습니까?'),
                        actions: [
                          Center(
                            child: Row(
                              children: [
                                ElevatedButton(   // [확인 버튼]
                                  onPressed: () async {
                                    if (dateTime != null) {   // 에약정보가 있다면
                                      setState(() {   // 예약정보가 있음 & 알림이 설정되어 있지 않다면?
                                        isSettedAlarm = true;
                                      });
                                      await _cancelNotification();    // [메시지 등록 취소]
                                      await _requestPermissions();    // [권한 요청]

                                      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
                                      await _registerMessage(         // [메시지 등록]
                                        // 각 index에 맞게  값을 입력받음
                                        year: timeYear!,
                                        month: timeMonth!,
                                        day: timeDay!,
                                        hour: timeHour!,
                                        minutes: timeMin!,
                                        message: '현재 예약종료 시간이 되었습니다.', // ☆ 알람 메시지 내용
                                      );
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: const Text('알림 설정이 되었습니다.'),
                                            actions: [
                                              Center(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('확인'),
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                      );
                                    }
                                    else {    // dateTime이 null이라면    // 실제라면 일어나지 않을 팝업알림창
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: const Text('현재 예약된 정보가 없어 알림설정이 불가합니다.'),
                                            actions: [
                                              Center(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('확인'),
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: const Text('확인'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(   // [취소 버튼]
                                    onPressed: (){
                                      Navigator.pop(context);
                                    },
                                    child: const Text('취소'))
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  );
                }
                else {                    // 내가 이미 예약알림을 받은 상태에서 '예약을 끄고 싶을때'
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: const Text('기존 알림을 해제할까요?'),
                        actions: [
                          Center(
                            child: Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    setState(()  {
                                      Navigator.pop(context);
                                      isSettedAlarm = false;
                                    });
                                    await _flutterLocalNotificationsPlugin.cancel(0);// [메시지 등록 취소]
                                  },
                                  child: const Text('확인'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('취소'),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  );
                }
              }
          ),
      ),
    );
  }

  Widget getNotIcon(Widget icon){
    return Container(
      foregroundDecoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/ban.png'),
          fit: BoxFit.fitWidth
        )
      ),
      child: icon,
    );
  }
}
