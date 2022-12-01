import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'user_info.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  var userInfo;

  final List<String> _selectedTimer = [
    '10', '15', '20','25', '30',
  ];

  var _isChecked = false;
  String _initTimer = '10';

  String? tempDorm;
  String? dormFirst;
  String? dormSecond;

  @override
  Widget build(BuildContext context) {
    userInfo = Provider.of<UserInfo>(context, listen: true);

    //tempDorm = userInfo.getDormitory();
    //dormFirst = tempDorm!.split(' ')[0];
    //dormSecond = tempDorm!.split(' ')[1];
    String prevDormFirst = '오름';
    String prevDormSecond = '3';    // 기존 사용자 인적 정보

    return Scaffold(
      body: Column(
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
                      Navigator.pop(context);
                    },
                  ),
                ),
                Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(top: 30.0),
                    child: const Text(
                      "환경설정",
                      style: TextStyle(color: Colors.lightBlue, fontSize: 20.0),
                    )
                )
              ]
          ),

          Flexible(
            flex: 10,
            fit: FlexFit.tight,
            child: Container(
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Expanded(
                      child: Row(
                        children: <Widget>[
                          const Flexible(
                              flex: 8,
                              fit: FlexFit.tight,
                              child: Text("기숙사 설정", textAlign: TextAlign.left,)
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 3,
                            child: Container(
                              alignment: Alignment.center,
                              child: DropdownButton(
                                items: <String>['오름관', '푸름관'].map((value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                value: dormFirst,
                                onChanged: (String? value){
                                  setState(() {
                                    dormFirst = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Flexible(
                              fit: FlexFit.tight,
                              flex: 2,
                              child: Container(
                                alignment: Alignment.center,
                                child: DropdownButton(
                                  items: (dormFirst == "오름관") ?
                                  <String>['1동', '2동', '3동'].map((value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList() :
                                  <String>['1동', '2동', '3동', '4동'].map((value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  value: dormSecond,
                                  onChanged: (String? value){
                                    setState(() {
                                      dormSecond = value;
                                    });
                                  },
                                ),
                              )
                          ),
                        ],
                      )
                  ),
                  Divider(),
                  Container(
                    height: 35,
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                        onPressed: (){
                          if(dormFirst != null && dormSecond != null){
                            if(tempDorm != '${dormFirst!} ${dormSecond!}'){
                              userInfo.putDormitory(tempDorm);
                              //usersData.changeDormitory(userInfo.getUserId(), tempDorm);
                            } else if (tempDorm == '${dormFirst!} ${dormSecond!}') {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: const Text("변경 사항이 없습니다"),
                                      actions: [
                                        Center(
                                            child: ElevatedButton(
                                                onPressed: (){ Navigator.pop(context); },
                                                child: const Text("확인")
                                            )
                                        )
                                      ],
                                    );
                                  }
                              );
                              return;
                            }
                          } else if (dormFirst == null && dormSecond == null){
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: const Text("변경 사항이 없습니다"),
                                    actions: [
                                      Center(
                                          child: ElevatedButton(
                                              onPressed: (){ Navigator.pop(context); },
                                              child: const Text("확인")
                                          )
                                      )
                                    ],
                                  );
                                }
                            );
                            return;
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: const Text("변경 사항이 없습니다"),
                                    actions: [
                                      Center(
                                          child: ElevatedButton(
                                              onPressed: (){ Navigator.pop(context); },
                                              child: const Text("확인")
                                          )
                                      )
                                    ],
                                  );
                                }
                            );
                          }

                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: const Text("설정이 변경되었습니다"),
                                  actions: [
                                    Center(
                                        child: ElevatedButton(
                                            onPressed: (){ Navigator.pop(context); },
                                            child: const Text("확인")
                                        )
                                    )
                                  ],
                                );
                              }
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('저장')),
                  ),
                  Divider(),
                  Expanded(
                    //height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Flexible(
                          flex: 8,
                          fit: FlexFit.tight,
                          child: Text("알림 설정", textAlign: TextAlign.left,)
                        ),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: Switch(
                            value: _isChecked,
                            onChanged: (value){
                              setState(() {
                                _isChecked = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Expanded(
                    //height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Flexible(
                          flex: 8,
                          fit: FlexFit.tight,
                          child: Text("알림 시간 설정", textAlign: TextAlign.left,)
                        ),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: DropdownButton(
                            isExpanded: true,
                            value: _initTimer,
                            items: _selectedTimer.map(
                                  (value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                );
                              },
                            ).toList(),
                            onChanged: (String? value){
                              setState(() {
                                _initTimer = value!;
                              });
                            },
                          ),
                        ),
                        Text('분 전 알림'),
                      ],
                    ),
                  ),
                  Divider(),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}