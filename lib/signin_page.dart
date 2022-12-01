import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'user_info.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();

  Future<String> sendSignInData(String userId, String password) async {
    http.Response res = await http.post(Uri.parse('https://www.dormitoryclicker.shop/signin'),
        body: {
          'userId': userId,
          'password': password
        }
    );

    //여기서는 응답이 객체로 변환된 res 변수를 사용할 수 있다.
    //여기서 res.body를 jsonDecode 함수로 객체로 만들어서 데이터를 처리할 수 있다.
    String jsonData = res.body;

    return jsonData; //작업이 끝났기 때문에 리턴
  }

  var userInfo;

  String? _tempId;
  String? _tempPw;
  Future _onPowerKey() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('어플을 종료합니다'),
          actions: [
            TextButton(
                onPressed: () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
                child: Text('확인')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('취소')),
          ],
        );
      }
    );
  }

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

    return WillPopScope(
      onWillPop: () async {
        await _onBackPressed(context);
        return false;
      },
      child: Scaffold(
          body: Column(
            children: [
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
                          _onPowerKey();
                        },
                      ),
                    ),
                    Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(top: 30.0),
                        child: const Text(
                          "로그인",
                          style: TextStyle(color: Colors.lightBlue, fontSize: 20.0),
                        )
                    ),
                    Text(
                        (isWeb == true) ? "Web" : (Platform.isAndroid == true) ? "Android" : (Platform.isIOS == true) ? "IOS" : "Nothing"
                    )
                  ]
              ),
              Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Center(
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 40.0),
                          children: <Widget>[
                            const SizedBox(height: 48.0),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              autofocus: false,
                              decoration: const InputDecoration(
                                icon: Icon(Icons.account_circle),
                                labelText: '학번',
                                contentPadding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
                              ),
                              validator: (value) {
                                if (value != null && value.isEmpty) {
                                  return '학번을 입력해주세요!';
                                }
                                _tempId = value;
                                return null;
                              },
                            ),
                            const SizedBox(height: 12.0),
                            TextFormField(
                              autofocus: false,
                              obscureText: true,
                              decoration: const InputDecoration(
                                icon: Icon(Icons.lock),
                                labelText: '비밀번호',
                                contentPadding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
                              ),
                              validator: (value) {
                                if (value != null && value.isEmpty) {
                                  return '비밀번호를 입력해주세요!';
                                }
                                _tempPw = value;
                                return null;
                              },
                            ),
                            const SizedBox(height: 24.0),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  if(_formKey.currentState!.validate()) {
                                    sendSignInData(_tempId!, _tempPw!).then((value) {
                                      if(value == 'failed'){
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                content: const Text("아이디 혹은 비밀번호가 유효하지 않습니다."),
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
                                      } else if (value == 'success') {
                                        userInfo.putUserId(_tempId);
                                        Navigator.pushReplacementNamed(context, '/');
                                      }
                                    });
                                  }
                                },
                                style: ButtonStyle(
                                    padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(12)),
                                    shape: MaterialStateProperty.resolveWith((states) {
                                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
                                      return null;
                                    })
                                ),
                                child: const Text('로그인', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            TextButton(
                              child: const Text(
                                'Create New Account',
                                style: TextStyle(
                                    color: Colors.black87,
                                    decoration: TextDecoration.underline),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                            ),
                          ],
                        ),
                      )
                  )
              )
            ],
          )
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
            child: Text('확인')),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('취소')),
      ],
    ),
  );
}