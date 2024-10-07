import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _from = GlobalKey<FormState>();
  bool _hasAccount = true;

  String _enteredEmail = '';
  String _enteredPassword = '';

  void _submit() async {
    final formState = _from.currentState;
    if (formState != null && formState.validate()) {
      formState.save();

      if (_hasAccount) {
        // log users in
      } else {
        try {
          final userCredentials =
              await _firebase.createUserWithEmailAndPassword(
                  email: _enteredEmail, password: _enteredPassword);
          print(userCredentials);
        } on FirebaseAuthException catch (error) {
          if (!mounted) return; // 檢查組件是否仍掛載
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.message ?? '註冊失敗'),
            ),
          );
        }
      }
    } else {
      return;
    }

    print('Email: $_enteredEmail, Password: $_enteredPassword');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 20, left: 20, right: 20),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Form(
                          key: _from,
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: '信箱',
                                  hintText: '請輸入您的信箱',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return '信箱不能空白';
                                  }
                                  final emailRegex = RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return '請輸入有效的信箱';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  if (newValue != null) {
                                    _enteredEmail = newValue;
                                  }
                                },
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: '密碼',
                                  hintText: '最多六位數',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return '密碼不能空白';
                                  }
                                  if (value.contains(' ')) {
                                    return '密碼不能包含空白鍵';
                                  }
                                  if (value.length > 6) {
                                    return '密碼長度必須在1到6個字元之間';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  if (newValue != null) {
                                    _enteredPassword = newValue;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        ElevatedButton(
                            onPressed: _submit,
                            child: Text(_hasAccount ? '登入' : '註冊')),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                _hasAccount = !_hasAccount;
                              });
                            },
                            child: Text(_hasAccount ? '我要註冊' : '我要登入'))
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
