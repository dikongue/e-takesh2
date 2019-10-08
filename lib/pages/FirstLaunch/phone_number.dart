import 'package:etakesh_client/pages/FirstLaunch/phone_code.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnterPhoneNumberPage extends StatefulWidget {
  @override
  _EnterPhoneNumberPageState createState() => _EnterPhoneNumberPageState();
}

class _EnterPhoneNumberPageState extends State<EnterPhoneNumberPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _agreedToTOS = true;
  var _phoneController = new TextEditingController();
  String verificationId;
  bool loading;
  bool error;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loading = false;
    error = false;
  }

  Widget form() {
    return SafeArea(
      top: false,
      bottom: false,
      child: Form(
        key: this._formKey,
        child: new ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Container(
                  margin: EdgeInsets.only(bottom: 30.0, top: 50.0),
                  padding: EdgeInsets.only(right: 18.0, left: 18.0),
                  alignment: Alignment.center,
                  child: Text(
                    "Saisissez votre numéro de téléphone portable",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.w300),
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
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: '6 77 77 77 77',
                icon: Icon(
                  Icons.phone,
                  color: Colors.black,
                ),
                errorStyle: TextStyle(color: Colors.red, fontSize: 14),
                hintStyle: TextStyle(
                    fontSize: 23.0,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF9FA0A2)),
              ),
              autofocus: true,
              maxLength: 9,
              style: TextStyle(
                  fontSize: 23.0,
                  fontWeight: FontWeight.w300,
                  color: Colors.black87),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                WhitelistingTextInputFormatter.digitsOnly,
              ],
              validator: (String value) {
                if (value.trim().isEmpty) {
                  return "Vous n'avez pas renseigne le numéro \n de telephone ";
                } else if (value.length < 9) {
                  return 'Numéro de téléphone non valide';
                }
              },
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
                        "En continuant vous allez recevoire un \ncode de vérification par SMS.\n"
                            " Vous devez renseigner ce code \na la page suivante.",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w300,
                            color: _agreedToTOS ? Colors.black87 : Colors.red),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
          'Nouveau chez E-Takesh ?',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: form(),
    );
  }

  bool _submittable() {
    return _agreedToTOS;
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      verifyPhone(context);
    }
  }

  Future verifyPhone(context) async {
    setState(() {
      loading = true;
      error = false;
    });
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      setState(() {
        loading = false;
        error = false;
      });

      Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => EnterPhoneCodePage(
                phone_n: "+237" + _phoneController.text,
                ververId: this.verificationId)),
      );
    };

    final PhoneVerificationCompleted verifiedSuccess = (FirebaseUser user) {
      print('User ' + user.toString());
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      setState(() {
        loading = false;
        error = true;
      });

      print('${exception.message}');
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+237" + _phoneController.text,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 9),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }

  _setAgreedToTOS(bool newValue) {
    setState(() {
      _agreedToTOS = newValue;
    });
  }
}
