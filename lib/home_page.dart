import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dorm_data.dart';
import 'user_info.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';

class WeatherData {
  static List<Map<String, dynamic>> weathers = [];
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  final AsyncMemoizer _memoizer1 = AsyncMemoizer();

  Future _getDataSetting1() => _memoizer.runOnce(() => getMachineData());
  Future _getDataSetting2() => _memoizer1.runOnce(() => getWeatherData());

  Future<String> getMachineData() async {
    Map data = {'userId': userInfo.getUserId()};
    var body = json.encode(data);

    http.Response res = await http.post(Uri.parse('http://dormitoryclicker.shop:8080/dormitory'),
        headers: {'Content-Type': "application/json"},
        body: body
    );

    //여기서는 응답이 객체로 변환된 res 변수를 사용할 수 있다.
    //여기서 res.body를 jsonDecode 함수로 객체로 만들어서 데이터를 처리할 수 있다.
    String jsonData = res.body;

    if (jsonData == "Server Unavailable") { return "500: Server Unavailable"; }
    else if (jsonData == "Not found userId with ${userInfo.getUserId()}") { return "404: User Not Found"; }
    else {
      userInfo.putUserId(json.decode(jsonData)['userId']);
      userInfo.putDormitory(json.decode(jsonData)['dormitory']);
      userInfo.putCanReservation(json.decode(jsonData)['canReservation'] == 1 ? true : false);

      for(int i = 0; i < json.decode(jsonData)['machineStatus'].length; i++){
        dormData.machines[i]['machineNum'] = json.decode(jsonData)['machineStatus'][i]['machineNum'];
        dormData.machines[i]['state'] = json.decode(jsonData)['machineStatus'][i]['state'];
      }

      return "Success";
    }
  }

  Future<String> getWeatherData() async {
    http.Response res = await http.get(Uri.parse(
        'http://dormitoryclicker.shop:8080/api/weather'
    ));

    //여기서는 응답이 객체로 변환된 res 변수를 사용할 수 있다.
    //여기서 res.body를 jsonDecode 함수로 객체로 만들어서 데이터를 처리할 수 있다.
    String jsonData = res.body;

    for (int i = 0; i < json.decode(jsonData).length; i++) {
      WeatherData.weathers.add(json.decode(jsonData)[i]);
    }

    return 'Success';
  }

  var userInfo;
  var dormData;

  static const IconData washIcon = IconData(
      0xe398,
      fontFamily: 'MaterialIcons'
  );

  static const IconData dryIcon = IconData(
      0xf0575,
      fontFamily: 'MaterialIcons'
  );

  @override
  Widget build(BuildContext context) {
    userInfo = Provider.of<UserInfo>(context, listen: true);
    dormData = Provider.of<DormData>(context, listen: true);

    String getMachineName(int index) {
      String machineNum = dormData.machines[index]['machineNum'];
      if(machineNum.startsWith('W')){
        return "세탁 ${machineNum[1]}";
      } else {
        return "건조 ${machineNum[1]}";
      }
    }
    IconData getMachineIcon(int index) {
      String machineNum = dormData.machines[index]['machineNum'];
      if(machineNum.startsWith('W')){
        return washIcon;
      } else {
        return dryIcon;
      }
    }
    Color getMachineColor(int index) {
      int state = dormData.machines[index]['state'];
      if(state == 1){
        return Colors.greenAccent;
      } else {
        return Colors.redAccent;
      }
    }

    return WillPopScope(
      onWillPop: () async {
        await _onBackPressed(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("홈"),
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
                  Navigator.pushReplacementNamed(context, '/');
                },
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
              ListTile(
                title: const Text("마이페이지"),
                onTap: () {
                  Navigator.pushNamed(context, '/mypage');
                },
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
              ListTile(
                title: const Text("문의/건의"),
                onTap: () async {
                  final url = Uri(
                    scheme: 'mailto',
                    path: 'gmgpgk1713@gmail.com',
                    query: 'subject=기숙사 클리커 문의&body=[문의내용]\n',
                  );
                  if (await canLaunchUrl(url)) {
                    launchUrl(url);
                  }
                  else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: const Text('메일 앱에 접근할 수 없습니다.\n'
                                '아래의 연락처로 연락주세요.\n\n'
                                '[Email: dormiWork@kumoh.ac.kr]'),
                            actions: [
                              Center(
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("확인")
                                  )
                              )
                            ],
                          );
                        }
                    );
                  }
                },
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FutureBuilder(
                future: _getDataSetting2(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: Container(
                        margin: const EdgeInsets.only(left: 15.0, top: 15.0, right: 15.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: const Color(0x0a0a0aff),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: <Widget>[
                            Text(
                                DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                style: const TextStyle(fontSize: 17)
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                      fit: FlexFit.tight,
                                      flex: 1,
                                      child: Column(
                                        children: const [
                                          Icon(Icons.sunny),
                                          Text("일", textAlign: TextAlign.center)
                                        ],
                                      )
                                  ),
                                  Flexible(
                                      fit: FlexFit.tight,
                                      flex: 1,
                                      child: Column(
                                        children: const [
                                          Icon(Icons.sunny),
                                          Text("월", textAlign: TextAlign.center)
                                        ],
                                      )
                                  ),
                                  Flexible(
                                      fit: FlexFit.tight,
                                      flex: 1,
                                      child: Column(
                                        children: const [
                                          Icon(Icons.cloud),
                                          Text("화", textAlign: TextAlign.center)
                                        ],
                                      )
                                  ),
                                  Flexible(
                                      fit: FlexFit.tight,
                                      flex: 1,
                                      child: Column(
                                        children: const [
                                          Icon(Icons.cloudy_snowing),
                                          Text("수", textAlign: TextAlign.center)
                                        ],
                                      )
                                  ),
                                  Flexible(
                                      fit: FlexFit.tight,
                                      flex: 1,
                                      child: Column(
                                        children: const [
                                          Icon(Icons.cloud),
                                          Text("목", textAlign: TextAlign.center)
                                        ],
                                      )
                                  ),
                                  Flexible(
                                      fit: FlexFit.tight,
                                      flex: 1,
                                      child: Column(
                                        children: const [
                                          Icon(Icons.sunny),
                                          Text("금", textAlign: TextAlign.center)
                                        ],
                                      )
                                  ),
                                  Flexible(
                                      fit: FlexFit.tight,
                                      flex: 1,
                                      child: Column(
                                        children: const [
                                          Icon(Icons.sunny_snowing),
                                          Text("토", textAlign: TextAlign.center)
                                        ],
                                      )
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Flexible(
                        flex: 2,
                        fit: FlexFit.tight,
                        child: Container(
                            margin: const EdgeInsets.only(left: 15.0, top: 15.0, right: 15.0),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: const Color(0x0a0a0aff),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Error: ${snapshot.error}', // 에러명을 텍스트에 뿌려줌
                              style: TextStyle(fontSize: 15),
                            )
                        )
                    );
                  } else {
                    return Flexible(
                        flex: 2,
                        fit: FlexFit.tight,
                        child: Container(
                            margin: const EdgeInsets.only(left: 15.0, top: 15.0, right: 15.0),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: const Color(0x0a0a0aff),
                              borderRadius: BorderRadius.circular(20),
                            ),
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
              ),

              FutureBuilder(
                future: _getDataSetting1(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return Flexible(
                      flex: 8,
                      fit: FlexFit.tight,
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: <Widget>[
                            const Flexible(
                                flex: 1,
                                fit: FlexFit.tight,
                                child: Text(
                                  '기기 선택',
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                )
                            ),
                            Flexible(
                                flex: 9,
                                fit: FlexFit.tight,
                                child: GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 3,
                                    crossAxisSpacing: 3,
                                    childAspectRatio: 3/5,
                                  ),
                                  itemCount: 6,
                                  itemBuilder: (BuildContext context, int index){
                                    return Card(
                                      margin: const EdgeInsets.all(2),
                                      elevation: 2,
                                      child: GridTile(
                                        footer: Container(
                                          height: 40,
                                          child: GridTileBar(
                                              backgroundColor: getMachineColor(index),
                                              title: Text(getMachineName(index), textAlign: TextAlign.center)
                                          ),
                                        ),
                                        child: IconButton(
                                          icon: Icon(getMachineIcon(index), size: 50,),
                                          onPressed: (){
                                            String machineNum = dormData.machines[index]['machineNum'];
                                            userInfo.putMachineNum(machineNum);
                                            Navigator.pushNamed(context, '/reservation');
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                )
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Flexible(
                      flex: 8,
                      fit: FlexFit.tight,
                      child: Container(
                        margin: const EdgeInsets.all(10.0),
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Error: ${snapshot.error}', // 에러명을 텍스트에 뿌려줌
                          style: TextStyle(fontSize: 15),
                        )
                      )
                    );
                  }
                  else {
                    return Flexible(
                        flex: 8,
                        fit: FlexFit.tight,
                        child: Container(
                            margin: const EdgeInsets.all(10.0),
                            padding: const EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(12),
                            ),
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
              ),
            ],
          ),
        ),
      )
    );
  }
}

Future<void> _onBackPressed(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('어플을 종료합니다'),
      actions: [
        TextButton(
            onPressed: () {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
            child: const Text('확인')),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('취소')),
      ],
    ),
  );
}