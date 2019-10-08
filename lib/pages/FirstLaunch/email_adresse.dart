import 'package:etakesh_client/pages/FirstLaunch/create_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnterEmailPage extends StatefulWidget {
  final String phone_n;

  EnterEmailPage({Key key, this.phone_n}) : super(key: key);
  @override
  _EnterEmailPageState createState() => _EnterEmailPageState();
}

class _EnterEmailPageState extends State<EnterEmailPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _agreedToTOS = true;
  var _emailController = new TextEditingController();
  var _nomController = new TextEditingController();
  var _prenomController = new TextEditingController();
  var _villeController = new TextEditingController();
  var _naissanceController = new TextEditingController();
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
          'Données personnelles',
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      "Informations complémentaires pour votre compte",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.w300),
                    )),
              ),
              new TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  icon: Icon(Icons.email, color: Colors.black),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (String value) {
                  if (value.trim().isEmpty) {
                    return 'Adresse email obligatoire';
                  } else if (!new RegExp(
                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                      .hasMatch(value)) {
                    return "Email non valide";
                  }
                },
              ),
              new TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  icon: Icon(Icons.person, color: Colors.black),
                ),
                validator: (String value) {
                  if (value.trim().isEmpty) {
                    return 'Nom obligatoire';
                  }
                },
              ),
              new TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  icon: Icon(Icons.person, color: Colors.black),
                ),
                validator: (String value) {
                  if (value.trim().isEmpty) {
                    return 'Prénom obligatoire';
                  }
                },
              ),
//              new TextFormField(
//                controller: _naissanceController,
//                decoration: const InputDecoration(
//                    labelText: 'Date de naissance',
//                    icon: Icon(Icons.calendar_today, color: Colors.black)),
//                keyboardType: TextInputType.datetime,
//                validator: (String value) {
//                  if (value.trim().isEmpty) {
//                    return 'Date de naissance obligatoire';
//                  }
//                },
//              ),
              new TextFormField(
                controller: _villeController,
                decoration: const InputDecoration(
                    labelText: 'Ville de résidence',
                    icon: Icon(Icons.location_city, color: Colors.black)),
                validator: (String value) {
                  if (value.trim().isEmpty) {
                    return 'Ville obligatoire';
                  }
                },
              ),
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
                        "Je certifie avoir écris , lus \n et validé ces informations ",
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

  bool _submittable() {
    return _agreedToTOS;
  }

  void _submit() {
    if (_formKey.currentState.validate()) {
      Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => CreatePassWordPage(
                  phone_n: widget.phone_n,
                  email: _emailController.text,
                  nom: _nomController.text,
                  prenom: _prenomController.text,
                  ville: _villeController.text,
                  d_naissance: _naissanceController.text,
                )),
      );

      const SnackBar snackBar = SnackBar(content: Text('Form submitted'));

      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  void _setAgreedToTOS(bool newValue) {
    setState(() {
      _agreedToTOS = newValue;
    });
  }
}
