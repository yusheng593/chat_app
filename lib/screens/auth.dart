import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  String _enteredEmail = 'test@haha.com';
  String _enteredPassword = '123456';
  String _enteredUsername = '密斯特路';
  File? _selectedImage;
  bool _isAuthenticating = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = _enteredEmail;
    _passwordController.text = _enteredPassword;
    _usernameController.text = _enteredUsername;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return; // 檢查組件是否仍掛載
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _submit() async {
    final formState = _from.currentState;
    if (formState != null && formState.validate()) {
      formState.save();

      try {
        setState(() {
          _isAuthenticating = true;
        });
        if (_hasAccount) {
          final userCredentials = await _firebase.signInWithEmailAndPassword(
              email: _enteredEmail, password: _enteredPassword);
        } else {
          if (_selectedImage != null) {
            final userCredentials =
                await _firebase.createUserWithEmailAndPassword(
                    email: _enteredEmail, password: _enteredPassword);

            final userId = userCredentials.user?.uid;
            if (userId != null) {
              final storageRef = FirebaseStorage.instance
                  .ref()
                  .child('user_image')
                  .child('$userId.jpg');

              await storageRef.putFile(_selectedImage!);
              final imageUrl = await storageRef.getDownloadURL();

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .set({
                'username': _enteredUsername,
                'email': _enteredEmail,
                'image_url': imageUrl,
              });
            } else {
              _showMessage('註冊失敗');
            }
          } else {
            _showMessage('請先設置頭像');
          }
        }
      } on FirebaseAuthException catch (error) {
        _showMessage(error.message ?? '註冊失敗');
      }
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    } else {
      return;
    }
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
                              if (!_hasAccount)
                                UserImagePicker(
                                  onPickImage: (pickImage) {
                                    _selectedImage = pickImage;
                                  },
                                ),
                              TextFormField(
                                controller: _emailController,
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
                              if (!_hasAccount)
                                TextFormField(
                                  controller: _usernameController,
                                  decoration:
                                      const InputDecoration(labelText: '暱稱'),
                                  enableSuggestions: false,
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value.trim().length > 6) {
                                      return '請輸入六個字以內';
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    if (newValue != null) {
                                      _enteredUsername = newValue;
                                    }
                                  },
                                ),
                              TextFormField(
                                controller: _passwordController,
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
                        if (_isAuthenticating)
                          const CircularProgressIndicator(),
                        if (!_isAuthenticating)
                          ElevatedButton(
                            onPressed: _submit,
                            child: Text(_hasAccount ? '登入' : '註冊'),
                          ),
                        if (!_isAuthenticating)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _hasAccount = !_hasAccount;
                              });
                            },
                            child: Text(_hasAccount ? '我要註冊' : '我要登入'),
                          )
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
