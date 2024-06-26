import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:provider/provider.dart';
import 'package:shopping/models/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  var enteredEmail = '';
  var enteredPassword = '';
  var isLogin = true;
  var isAuthenticating = false;
  var enteredName;
  var phoneNo;
  var address;

  Future<void> submit() async {
    if (!form.currentState!.validate()) {
      return;
    }
    form.currentState!.save();
    setState(() {
      isAuthenticating = true;
    });

    if (isLogin) {
      // login
      try {
        await Provider.of<Auth>(context, listen: false)
            .login(enteredEmail, enteredPassword);
      } catch (error) {
        Get.snackbar('An error occured', error.toString());
      }
    } else {
      // signup
      try {
        await Provider.of<Auth>(context, listen: false)
            .signup(enteredEmail, enteredPassword);
        Provider.of<UserData>(context, listen: false).addName(enteredName,phoneNo,address);
        // print(enteredName);
      } catch (error) {
        Get.snackbar('An error occured', error.toString());
      }
    }

    setState(() {
      isAuthenticating = false;
    });
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
                  top: 10,
                  bottom: 10,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/logo.png'),
              ),
              Card(
                margin: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  isLogin ? 'Login' : 'Sign Up',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  labelText: "Your Name",
                                  icon: Icon(Icons.person)),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.trim().length < 3) {
                                  return 'min lenght=4/Field can\'t be empty';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                enteredName = value!;
                              },
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (!isLogin)
                            TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  labelText: "Phone no",
                                  icon: Icon(Icons.phone)),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.trim().length < 10) {
                                  return 'Field can\'t be empty';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                phoneNo = value!;
                              },
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (!isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  labelText: "Address of delivery",
                                  icon: Icon(Icons.home)),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Field can\'t be empty';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                address = value!;
                              },
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                labelText: "Email Address",
                                icon: Icon(Icons.email)),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid Email';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              enteredEmail = value!;
                            },
                          ),
                         const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Password",
                              icon: Icon(Icons.lock),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.trim().length < 6) {
                                return 'Password must be at least 6 characters long';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                enteredPassword = value;
                              });
                            },
                            onSaved: (value) {
                              enteredPassword = value!;
                            },
                          ),
                         const SizedBox(
                            height: 10,
                          ),
                          if (isAuthenticating)const CircularProgressIndicator(),
                          if (!isAuthenticating)
                            ElevatedButton(
                              onPressed: submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Text(isLogin ? "Login" : "Sign Up"),
                            ),
                          if (!isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isLogin = !isLogin;
                                });
                              },
                              child: Text(isLogin
                                  ? "Create an Account"
                                  : "Already have an account?"),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
