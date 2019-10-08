import 'package:etakesh_client/pages/FirstLaunch/phone_number.dart';
import 'package:etakesh_client/pages/FirstLaunch/social_media_page.dart';
import 'package:etakesh_client/pages/login_page.dart';
import 'package:flutter/material.dart';

class MainLaunchPage extends StatelessWidget {
  final backColor = Color(0xFF0C60A8);

  @override
  Widget build(BuildContext context) {
    double heigt = MediaQuery.of(context).size.height;
    return new Scaffold(
        body: Container(
      decoration: BoxDecoration(color: backColor),
      child: Column(
        children: [
          new Expanded(
            flex: 2,
            child: new Container(
              width: double
                  .infinity, // this will give you flexible width not fixed width
              height: heigt * 0.5,
              color: backColor, // variable
              child: new Column(
                children: <Widget>[
                  new Expanded(
                    flex: 1,
                    child: new Container(
                      alignment: Alignment.center,
//                        padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
                      child: Image.asset('assets/images/login_icon.png',
                          height: 95.0, width: 95.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
          new Expanded(
            flex: 2,
            child: new Container(
              width: double
                  .infinity, // this will give you flexible width not fixed width
              color: Colors.white,
              child: new Column(
                children: <Widget>[
                  new Expanded(
                    flex: 1,
                    child: new Container(
                        alignment: Alignment.center,
                        child: new Text(
                          'Deplacez vous avec E-Takesh',
                          overflow: TextOverflow.ellipsis,
                          style: new TextStyle(
                              fontSize: 25.0, color: Colors.black38),
                        )),
                  ),
                  new Expanded(
                    flex: 1,
                    child: new Container(
                        padding: EdgeInsets.only(left: 20.0, bottom: 20.0),
                        child: Row(
                          children: [
                            Container(
                              child: Image.asset(
                                  'assets/images/cameroun_flag.png',
                                  height: 20.0,
                                  width: 60.0),
                            ),
                            Container(
                                child: Text(
                              "+237",
                              overflow: TextOverflow.fade,
                              textAlign: TextAlign.justify,
                              style: new TextStyle(
                                fontSize: 23.0,
                                color: Colors.black,
                              ),
                            )),
                            InkWell(
                              // InkWell ici permet de lie la fonction onTap()  au container
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: 5.0, top: 2.0, bottom: 2.0),
//                                softWrap: true,
                                child: Text(
                                  "Saisissez votre \nnuméro de téléphone",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  softWrap: true,
                                  textAlign: TextAlign.left,
                                  style: new TextStyle(
                                    fontSize: 23.0,
                                    color: Colors.black12,
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) =>
                                          EnterPhoneNumberPage()),
                                );
                              },
                            )
                          ],
                        )),
                  ),
                  Divider(),
                  new Expanded(
                      flex: 1,
                      child: InkWell(
                        child: Container(
                            padding: EdgeInsets.only(left: 20.0, right: 20.0),
                            alignment: Alignment.center,
                            child: new Text(
                              "Ou connectez-vous a l'aide des reseaux sociaux",
                              style: new TextStyle(
                                  fontSize: 18.0, color: backColor),
                            ) //variable above
                            ),
                        onTap: () {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => SocialMediaPage()),
//
                          );
                        },
                      )),
                  new Expanded(
                      flex: 1,
                      child: InkWell(
                        child: Container(
                            padding: EdgeInsets.only(
                                left: 20.0, right: 20.0, bottom: 20.0),
                            alignment: Alignment.center,
                            child: new Text(
                              "Pocedez-vous deja un compte ?",
                              style: new TextStyle(
                                  fontSize: 18.0, color: backColor),
                            ) //variable above
                            ),
                        onTap: () {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                      )),
                ],
              ),
              //variable
            ),
          ),
        ],
      ),
    ));
  }
}
