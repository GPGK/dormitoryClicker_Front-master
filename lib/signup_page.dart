import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  Future<String> sendSignUpData(String userId, String password, String userName, String dormitory) async {
    http.Response res = await http.post(Uri.parse('https://www.dormitoryclicker.shop/signup'),
        body: {
          'userId': userId,
          'password': password,
          'userName': userName,
          'dormitory': dormitory
        }
    );

    //여기서는 응답이 객체로 변환된 res 변수를 사용할 수 있다.
    //여기서 res.body를 jsonDecode 함수로 객체로 만들어서 데이터를 처리할 수 있다.
    String jsonData = res.body;

    return jsonData; //작업이 끝났기 때문에 리턴
  }

  String? _userName;
  String? _userId;
  String? _password;
  String? _passCheck;
  String? _dormitory;

  String? _dormFirst;
  String? _dormSecond;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Navigator.pop(context);
                  },
                ),
              ),
              Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(top: 30.0),
                  child: const Text(
                    "회원가입",
                    style: TextStyle(color: Colors.lightBlue, fontSize: 20.0),
                  )
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
                  padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                  children: <Widget>[
                    const SizedBox(height: 24.0),
                    TextFormField(
                      keyboardType: TextInputType.name,
                      autofocus: false,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        labelText: '이름',
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      ),
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return '필수 항목입니다';
                        }
                        _userName = value;
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    DropdownButtonFormField(
                      items: <String>['오름관', '푸름관']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      autofocus: false,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.apartment),
                        labelText: '기숙사 관',
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      ),
                      value: _dormFirst,
                      onChanged: (String? value) {
                        setState(() {
                          _dormFirst = value;
                        });
                      },
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return '필수 항목입니다';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    DropdownButtonFormField(
                      items: (_dormFirst == null) ?
                      <String>[].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList() : (_dormFirst == "오름관") ?
                      <String>['1동', '2동', '3동'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList() :
                      <String>['1동', '2동', '3동', '4동'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      autofocus: false,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.apartment),
                        labelText: '기숙사 동',
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      ),
                      value: _dormSecond,
                      onChanged: (String? value) {
                        setState(() {
                          _dormSecond = value;
                        });
                      },
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return '필수 항목입니다';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      autofocus: false,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.account_circle),
                        labelText: '학번',
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      ),
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return '필수 항목입니다';
                        }
                        _userId = value;
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
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      ),
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return '필수 항목입니다';
                        }
                        _password = value;
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      autofocus: false,
                      obscureText: true,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.spellcheck),
                        labelText: '비밀번호 확인',
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      ),
                      validator: (value) {
                        if (value != null && value.isEmpty) {
                          return '필수 항목입니다';
                        }
                        _passCheck = value;
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if(_formKey.currentState!.validate()) {
                            if (_password == _passCheck){
                              _dormitory = '${_dormFirst![0]}${_dormFirst![1]}${_dormSecond![0]}';
                              sendSignUpData(_userId!, _password!, _userName!, _dormitory!).then((value) {
                                if(value == 'success'){
                                  Navigator.pop(context);
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: const Text("회원가입에 성공하였습니다."),
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
                                } else if (value == 'Id exists') {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: const Text("이미 존재하는 아이디입니다."),
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
                                } else if (value == 'Bad request') {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: const Text("입력이 정상적으로 이루어지지 않았습니다."),
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
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: const Text("서버에 문제가 발생했습니다."),
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
                              });
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: const Text("비밀번호 확인이 일치하지 않습니다."),
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
                          }
                        },
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(12)),
                            shape: MaterialStateProperty.resolveWith((states) {
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
                              return null;
                            })
                        ),
                        child: const Text('회원가입', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              )
            ),
          )
        ],
      )
    );
  }
}