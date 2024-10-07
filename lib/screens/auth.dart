import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _hasAccount = true;
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
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: '信箱'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                          ),
                        ),
                        Form(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: '密碼'),
                            obscureText: true,
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        ElevatedButton(
                            onPressed: () {},
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
