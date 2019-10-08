import 'dart:convert';
import 'dart:io';

import 'package:etakesh_client/DAO/Rest_dt.dart';
import 'package:etakesh_client/Utils/AppSharedPreferences.dart';
import 'package:etakesh_client/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class CreatePassWordPage extends StatefulWidget {
  final String phone_n;
  final String email;
  final String nom;
  final String prenom;
  final String d_naissance;
  final String ville;
  CreatePassWordPage(
      {Key key,
      this.phone_n,
      this.email,
      this.nom,
      this.prenom,
      this.ville,
      this.d_naissance})
      : super(key: key);
  @override
  _CreatePassWordPageState createState() => _CreatePassWordPageState();
}

class _CreatePassWordPageState extends State<CreatePassWordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _agreedToTOS = true;
  var _passwordController = TextEditingController();
  var _confirmPassController = TextEditingController();
  RestDatasource api = new RestDatasource();
  bool existemail;
  bool loading;
  bool error;
  double lat = 4.0923523;
  double lng = 9.7487852;
  @override
  void initState() {
    existemail = false;
    loading = false;
    error = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFF0C60A8),
          foregroundColor: Colors.white,
          child: Icon(Icons.arrow_forward),
          tooltip: "Adresse email",
          onPressed: _submittable() ? _submit : null),
      appBar: new AppBar(
        title: new Text(
          'Mot de passe',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: new SafeArea(
        top: false,
        bottom: false,
        child: Form(
          key: _formKey,
          child: new ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Container(
                    margin: EdgeInsets.only(bottom: 40.0, top: 50.0),
                    alignment: Alignment.center,
                    child: Text(
                      "Créez un mot de passe pour votre compte",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.w300),
                    )),
              ),
              loading
                  ? Container(
                      height: 25.0,
                      width: 20.0,
//                    padding: const EdgeInsets.only(
//                        left: 20, right: 20, top: 30.0, bottom: 15.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Container(),
              new TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  icon: Icon(
                    Icons.enhanced_encryption,
                    color: Colors.black,
                  ),
                ),
                obscureText: true,
                keyboardType: TextInputType.text,
                validator: validatePassword,
              ),
              new TextFormField(
                controller: _confirmPassController,
                decoration: const InputDecoration(
                  labelText: 'Confirmer votre mot de passe',
                  icon: Icon(
                    Icons.enhanced_encryption,
                    color: Colors.black,
                  ),
                ),
                obscureText: true,
                keyboardType: TextInputType.text,
                validator: validatePasswordMatching,
              ),
              error
                  ? Container(
//              padding: const EdgeInsets.only(left: 20, right: 20, top: 30.0, bottom: 15.0),
                      child: Center(
                        child: Text(
                          'Problème survenue , veillez réessayer.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                  : Container(),
              existemail
                  ? Container(
//              padding: const EdgeInsets.only(left: 20, right: 20, top: 30.0, bottom: 15.0),
                      child: Center(
                      child: new RichText(
                          text: new TextSpan(
                        text: 'Désole cette email : ',
                        style: TextStyle(color: Colors.red),
                        children: <TextSpan>[
                          new TextSpan(
                            text: this.widget.email,
                            style: new TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          new TextSpan(
                              text:
                                  ' \na deja été utiliser veuillez utiliser une autre adresse',
                              style: TextStyle(color: Colors.red)),
                        ],
                      )),
                    ))
                  : Container(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: <Widget>[
                    Checkbox(
                      activeColor: Color(0xFF0C60A8),
                      value: _agreedToTOS,
                      onChanged: _setAgreedToTOS,
                    ),
                    GestureDetector(
                      onTap: () => _setAgreedToTOS(!_agreedToTOS),
                      child: Text(
                        "J'accèpte les conditions d'utilisation \nde l'application E-Takesh",
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w300,
                            color: _agreedToTOS ? Colors.black87 : Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String validatePassword(String value) {
    if (value.length == 0) {
      return "Mot de passe obligatoire";
    } else if (value.length < 6) {
      return "Le Mot de passe doit comporter au moins 6 caractères";
    }
    return null;
  }

  String validatePasswordMatching(String value) {
    if (value.length == 0) {
      return "Confirmation vide";
    } else if (value != _passwordController.text) {
      return 'Ne correspond pas avec le mot de passe entré précdement';
    }
    return null;
  }

  bool _submittable() {
    return _agreedToTOS;
  }

  void _submit() {
    if (_formKey.currentState.validate()) {
      createUser();
    }
  }

  Future createUser() async {
    setState(() {
      loading = true;
      existemail = false;
      error = false;
    });
//    on creer le User
    final response1 = await http.post(
      Uri.encodeFull("http://www.api.e-takesh.com:26525/api/Users"),
      body: {"email": this.widget.email, "password": _passwordController.text},
      headers: {HttpHeaders.acceptHeader: "application/json"},
    );

    if (response1.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      var convertDataToJson1 = json.decode(response1.body);
      print(convertDataToJson1["email"]);
      print(convertDataToJson1["id"]);
//    on connecte le User pour avoir le Token
      final response2 = await http.post(
        Uri.encodeFull("http://www.api.e-takesh.com:26525/api/Users/login"),
        body: {
          "email": this.widget.email,
          "password": _passwordController.text
        },
        headers: {HttpHeaders.acceptHeader: "application/json"},
      );

      if (response2.statusCode == 200) {
//        on utilise le token pour creer le client en question

        var convertDataToJson2 = json.decode(response2.body);
        print("Token");
        print(convertDataToJson2["id"]);

        final response3 = await http.post(
          Uri.encodeFull(
              "http://www.api.e-takesh.com:26525/api/positions?access_token=" +
                  convertDataToJson2["id"]),
          body: {
            "latitude": lat.toString(),
            "longitude": lng.toString(),
            "libelle": "Ma position"
          },
          headers: {HttpHeaders.acceptHeader: "application/json"},
        );
        if (response3.statusCode == 200) {
          var convertDataToJson3 = json.decode(response3.body);
           final response4 = await http.post(
          Uri.encodeFull(
              "http://www.api.e-takesh.com:26525/api/clients?access_token=" +
                  convertDataToJson2["id"]),
          body: {
            "UserId": convertDataToJson1["id"].toString(),
            "email": this.widget.email,
            "password": _passwordController.text,
            "nom": this.widget.nom,
            "prenom": this.widget.prenom,
            "adresse": "RAS",
            "image":
                "http://www.api.e-takesh.com:26525/api/containers/Clients/download/no_profile.png",
            "date_creation": DateTime.now().toString(),
            "code": "ET" +
                DateTime.now().month.toString() +
                DateTime.now().day.toString() +
                DateTime.now().hour.toString() +
                DateTime.now().second.toString() +
                "CLT" +
                DateTime.now().year.toString(),
            "telephone": this.widget.phone_n,
            "ville": this.widget.ville,
            "positionId": convertDataToJson3["positionid"].toString(),
            "date_naissance": "1990-01-01",
            "status": "CREATED",
            "pays": "Cameroun"
          },
          headers: {HttpHeaders.acceptHeader: "application/json"},
        );
        if (response4.statusCode == 200) {
          setState(() {
            loading = false;
            existemail = false;
            error = false;
          });
//          redirige a la page de connexion
          AppSharedPreferences().setAccountCreate(true);
          Navigator.push(
            context,
            new MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          setState(() {
            loading = false;
            existemail = false;
            error = true;
          });
          // If that call was not successful, throw an error.
          throw Exception(
              'Erreur de creation du client' + response4.body.toString());
        }
        }
      } else {
        setState(() {
          loading = false;
          existemail = false;
          error = true;
        });
        // If that call was not successful, throw an error.
        throw Exception(
            'Erreur de connexion du User' + response2.body.toString());
      }
    } else if (response1.statusCode == 422) {
      setState(() {
        loading = false;
        existemail = true;
        error = false;
      });
    } else {
      setState(() {
        loading = false;
        existemail = false;
        error = true;
      });
      // If that call was not successful, throw an error.
      throw Exception(
          'Erreur de creation du User' + response1.statusCode.toString());
    }
  }

  void _setAgreedToTOS(bool newValue) {
    setState(() {
      _agreedToTOS = newValue;
    });
  }
}
