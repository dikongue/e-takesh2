import 'dart:convert';
import 'dart:io';

import 'package:etakesh_client/DAO/Presenters/LoginPresenter.dart';
import 'package:etakesh_client/Database/DatabaseHelper.dart';
import 'package:etakesh_client/Models/clients.dart';
import 'package:etakesh_client/Utils/AppSharedPreferences.dart';
import 'package:etakesh_client/pages/FirstLaunch/main_page.dart';
import 'package:etakesh_client/pages/home_page.dart';
import "package:flutter/material.dart";
import 'package:http/http.dart' as http;

class LoginPage extends StatelessWidget {
  BoxDecoration decoration = BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xEEFFFFFF), width: 1.0)));

  TextStyle CustomTextStyle() {
    return TextStyle(color: Colors.white30, fontSize: 15.0);
  }

  Widget CustomSizeBox({double height}) {
    return SizedBox(
      height: height,
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  FocusNode emailNode = FocusNode();
  FocusNode passawordNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(child: Login())),
    );
  }
}

class Login extends StatefulWidget {
  createState() => LoginState();
}

class LoginState extends State<Login> implements LoginContract {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool loading = false;
  var _passwordController = TextEditingController();
  var _emailController = TextEditingController();
  FocusNode emailNode;
  FocusNode passawordNode;
  LoginPresenter _presenter;

  LoginState() {
    _presenter = new LoginPresenter(this);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    passawordNode = FocusNode();
    emailNode = FocusNode();
    loading = false;
  }

  BoxDecoration decoration = BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xEEFFFFFF), width: 1.0)));

  TextStyle CustomTextStyle() {
    return TextStyle(color: Colors.black, fontSize: 15.0);
  }

  InputDecoration CustomTextDecoration({String text, IconData icon}) {
    return InputDecoration(
      labelStyle: TextStyle(color: Colors.black87),
      labelText: text,
      prefixIcon: Icon(icon, color: Colors.black),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey[700])),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
      errorBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
    );
  }

  Widget CustomSizeBox({double height}) {
    return SizedBox(
      height: height,
    );
  }

  Widget LoginButton(BuildContext context) {
    return new SizedBox(
      height: 45.0,
      width: double.infinity,
      child: new RaisedButton(
        color: Color(0xFFDEA807),
        child: Text(
          "CONNEXION",
          style: TextStyle(color: Color(0xFF0C60A8)),
        ),
        onPressed: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          if (_formKey.currentState.validate()) {
            setState(() {
              loading = true;
            });

            Future.delayed(Duration(seconds: 2), () async {
              //connecte le user 10 ans (token)
              final response1 = await http.post(
                Uri.encodeFull("http://www.api.e-takesh.com:26525/api/Users/login"),
                body: {
                  "email": _emailController.text,
                  "password": _passwordController.text,
                  "ttl": "315360000"
                },
                headers: {HttpHeaders.acceptHeader: "application/json"},
              );
              if (response1.statusCode == 200) {
                Login2 login;
                login = Login2.fromJson(json.decode(response1.body));

//                var convertDataToJson1 = json.decode(response1.body);
                AppSharedPreferences().setAccountCreate(true);
                AppSharedPreferences().setAppLoggedIn(true);
                setState(() {
                  loading = false;
                });
                print("User" + login.token);
                AppSharedPreferences().setUserToken(login.token);
                Scaffold.of(context).showSnackBar(new SnackBar(
                  content: new Text(
                    "Connexion réussite",
                    style: TextStyle(color: Colors.blue),
                  ),
                ));
                Navigator.of(context).pushAndRemoveUntil(
                    new MaterialPageRoute(builder: (context) => HomePage()),
                    ModalRoute.withName(Navigator.defaultRouteName));
                new DatabaseHelper().saveUser(login);
              } else {
                setState(() {
                  loading = false;
                });
                Scaffold.of(context).showSnackBar(new SnackBar(
                  content: new Text(
                    "Indentifiants non valides",
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                ));
                // If that call was not successful, throw an error.
                throw Exception('Erreur de connexion du client' +
                    response1.body.toString());
              }
            });
          } else {
            setState(() {
              _autoValidate = true;
            });
          }
        },
      ),
    );
  }

  Widget LoginUi() {
    return Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            color: Color(0xFF0C60A8),
            child: Image.asset("assets/images/login_icon.png",
                height: 95.0, width: 95.0),
          ),
          CustomSizeBox(height: 50.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              children: <Widget>[
                Container(decoration: decoration),
                TextFormField(
                  controller: _emailController,
                  enabled: true,
                  enableInteractiveSelection: true,
                  focusNode: emailNode,
                  style: CustomTextStyle(),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration:
                      CustomTextDecoration(icon: Icons.email, text: "Email"),
                  textCapitalization: TextCapitalization.none,
                  onFieldSubmitted: (term) {
                    emailNode.unfocus();
                    FocusScope.of(context).requestFocus(passawordNode);
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Veillez saisir votre email';
                    } else if (!new RegExp(
                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                        .hasMatch(value)) {
                      return "Email non valide";
                    }
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  enabled: true,
                  enableInteractiveSelection: true,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  style: CustomTextStyle(),
                  focusNode: passawordNode,
                  decoration: CustomTextDecoration(
                      icon: Icons.lock, text: "Mot de Passe"),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Veillez saisir votre mot de passe';
                    } else if (value.length < 6) {
                      return 'Mot de passe tres court';
                    }
                  },
                ),
                CustomSizeBox(height: 20.0),
                loading
                    ? Container(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 30.0, bottom: 15.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(1.0),
                        child: Column(
                          children: <Widget>[
                            LoginButton(context),
                            CustomSizeBox(height: 20.0),
                            InkWell(
                           child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                "Mot de passe oubliez ?",
                                style: TextStyle(
                                  color: Color(0xFF0C60A8),
                                ),
                              ),
                            ),
                            onTap: (){
                              Scaffold.of(context).showSnackBar(new SnackBar(
                                content: new Text(
                                  "Module en cours de développement:Veillez contacter E-Takesh",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ));
                            },
                            ),
                            InkWell(
                              child: Container(
                                  padding: EdgeInsets.only(
                                      top: 5.0,
                                      left: 20.0,
                                      right: 20.0,
                                      bottom: 20.0),
                                  alignment: Alignment.center,
                                  child: new Text(
                                    "Vous n'avez pas compte ?",
                                    style: new TextStyle(
                                        fontSize: 15.0,
                                        color: Color(0xFFDEAC17)),
                                  ) //variable above
                                  ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => MainLaunchPage()),
                                );
                              },
                            )
                          ],
                        ),
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _loadingIndicator() {
    return Positioned(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[700],
        child: Center(
          child: SizedBox(
            height: 50.0,
            width: 50.0,
            child: CircularProgressIndicator(
              strokeWidth: 0.7,
              backgroundColor: Color(0xFF0C60A8),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[LoginUi()],
    );
  }

  @override
  void onLoginError() {
    setState(() {
      loading = false;
    });
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text(
        "Indentifiants non valides",
        style: TextStyle(color: Colors.red),
      ),
    ));
  }

  @override
  void onConnectionError() {
    setState(() {
      loading = false;
    });
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text(
        "Verifiez votre connexion internet",
        style: TextStyle(color: Colors.orange),
      ),
    ));
  }

  @override
  void onLoginSuccess(Client1 datas) async {
    setState(() => loading = false);
    if (datas != null) {
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(
          "Connexion reussite",
          style: TextStyle(color: Colors.green),
        ),
      ));
      print("sucess login " + datas.toString());
    }
  }
}
