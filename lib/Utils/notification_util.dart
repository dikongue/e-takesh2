import 'package:cached_network_image/cached_network_image.dart';
import 'package:etakesh_client/DAO/Presenters/CoursesPresenter.dart';
import 'package:etakesh_client/DAO/Rest_dt.dart';
import 'package:etakesh_client/Database/DatabaseHelper.dart';
import 'package:etakesh_client/Models/clients.dart';
import 'package:etakesh_client/Models/commande.dart';
import 'package:etakesh_client/Utils/AppSharedPreferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:intl/intl.dart';

class NotificationUtil extends StatefulWidget {
  BuildContext context;
  bool _etat1 = false;
  bool _etat2 = false;
  String _token;
  RestDatasource api = new RestDatasource();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  CommandeDetail cmdToSend;
  CommandeNotifPresenter _presenter;
  init(BuildContext context) {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    this.context = context;
    notification();
  }

  //  Action a effectuer lorsqu'on clique sur la notification
  Future onSelectNotification(String payload) async {
    if (payload != '') {
      debugPrint('Cmd to send at the next page' + payload);
    }
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext contex) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            height: 350.0,
            width: 200.0,
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      height: 150.0,
                    ),
                    Container(
                      height: 100.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0)),
                          color: Colors.black),
                    ),
                    Positioned(
                      top: 50.0,
                      left: 94.0,
                      child: ClipRRect(
                              borderRadius: BorderRadius.circular(45.0),
                              child: new CachedNetworkImage(
                                imageUrl: cmdToSend
                                    .prestation
                                    .prestataire
                                    .image +
                                        "?access_token=" +
                                        _token,
                                height: 90.0,
                                width: 90.0,
                                fit: BoxFit.cover,
                                placeholder:(context, url) =>
                                Center(child: CircularProgressIndicator()),
                                 errorWidget: (context, url, error) =>
                                new Icon(Icons.error),
                              ),
                            ),
                    )
                  ],
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child:
                      Text("Mr " + cmdToSend.prestation.prestataire.nom,
                      style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                Text("Service : " + cmdToSend.prestation.service.intitule),
                _etat1
                    ? (_etat2
                        ? Text("Le " +cmdToSend.date_fin.toString()
                             )
                        : Text("Le " + cmdToSend.date_acceptation.toString()
                           ))
                    : Text("Le " +cmdToSend.date_acceptation.toString()
                        ),
                _etat1
                    ? (_etat2
                        ? Text("Commande Terminée",
                            style: TextStyle(
                                fontSize: 14.0, color: Color(0xFF33B841)))
                        : Text("Commande Refusée",
                            style: TextStyle(
                                fontSize: 14.0, color: Color(0xFFC72230))))
                    : Text("Commande acceptée",
                        style: TextStyle(
                            fontSize: 14.0, color: Color(0xFF0C60A8))),
                SizedBox(height: 20.0),
               Center(
                child : FlatButton(
                    color: Colors.black,
                    padding: EdgeInsets.only(
                                  left: 15.0,
                                  right: 15.0,
                                  top: 10.0,
                                  bottom: 10.0),
                      child: Text(
                        "OK",
                        style:
                            TextStyle(fontSize: 14.0, color: Colors.white),
                      ),
                  
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
               )
              ],
            ),
          ),
        );
      },
    );
  }

  /// Active la notification avec sound customiser cmd valide
  Future _showNotificationCmdVal() async {
    AppSharedPreferences().setOrderCreate(true);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        icon: '@mipmap/ic_launcher',
        sound: 'iphone_notification',
        importance: Importance.Max,
        priority: Priority.High);
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(sound: "slow_spring_board.aiff");
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'ETakesh',
      'Commande acceptée',
      platformChannelSpecifics,
      payload: cmdToSend == null ? '' : 'Datas',
    );
  }

  /// Active la notification pour les livraisons terminees
  Future _showNotificationCmdLV() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        icon: '@mipmap/ic_launcher',
        sound: 'iphone_notification',
        importance: Importance.Max,
        priority: Priority.High);
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(sound: "slow_spring_board.aiff");
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'ETakesh',
      'Commande terminée',
      platformChannelSpecifics,
      payload: cmdToSend == null ? '' : 'Datas',
    );
  }

  /// Active la notification pour les livraisons terminees
  Future _showNotificationCmdRe() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        icon: '@mipmap/ic_launcher',
        sound: 'iphone_notification',
        importance: Importance.Max,
        priority: Priority.High);
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(sound: "slow_spring_board.aiff");
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'ETakesh',
      'Commande non validée',
      platformChannelSpecifics,
      payload: cmdToSend == null ? '' : 'Datas',
    );
  }

  notification() {
    _presenter = new CommandeNotifPresenter();
    DatabaseHelper().getClient().then((Client1 c) {
      if (c != null)
        AppSharedPreferences().getToken().then((String token) {
          if (token != '')
          _token = token;
            _presenter
                .getCmdValideClient(token, c.client_id)
                .then((List<CommandeDetail> cmds) {
              if (cmds != null && cmds.length > 0) {
                print("Cmd Valide" + cmds.toString());
                ///        Cmd Validee
                new DatabaseHelper()
                    .getCmdVal()
                    .then((List<CommandeLocal> cmdlocal) {
                  if (cmdlocal == null) {
                    _etat1 = false;
                    for (int i = 0; i < cmds.length; i++) {
                      cmdToSend = cmds[i];
                      new DatabaseHelper().saveCmdVal(cmds[i]);
                      _showNotificationCmdVal();
                      api.updateCmdStatus(cmds[i], token).then((Commande cmd) {
                        print("cmd valide mise a jour");
                      });
                    }
                  } else {
//                    if (cmds.length > cmdlocal.length) {
                    for (int i = 0; i < cmds.length; i++) {
                      _etat1 = false;
                      cmdToSend = cmds[i];
                      new DatabaseHelper().saveCmdVal(cmds[i]);
                      _showNotificationCmdVal();
                      api.updateCmdStatus(cmds[i], token).then((Commande cmd) {
                        print("cmd mise a jour other exist");
                      });
                    }
//                    } else {
                    for (int j = 0; j < cmdlocal.length; j++) {
                      print("CMD Local");
                      print(cmdlocal[j].commandeId);
                      _presenter
                          .loadCmdDetail(
                              token, c.client_id, cmdlocal[j].commandeId)
                          .then((CommandeDetail cmd) {
                        if (cmd != null)
                        ///        Cmd terminees
                        if (cmd.is_terminated == true) {
                          _etat1 = true;
                          _etat2 = true;
                          cmdToSend = cmd;
                          _showNotificationCmdLV();
                          DatabaseHelper().clearCmdVal();
                          // stop the service to fetch orders
                          AppSharedPreferences().setOrderCreatedTrue(false);
                          // remove the scan button at the home screen
                          AppSharedPreferences().setOrderCreate(false);
//                          cmdlocal[j].commandeId
                        }
                      });
                    }
                  }
//                  }
                });
              } else {
                ///               si on a pas de cmd valide
                new DatabaseHelper()
                    .getCmdVal()
                    .then((List<CommandeLocal> cmdlocal) {
                  if (cmdlocal != null) {
                    for (int j = 0; j < cmdlocal.length; j++) {
                      print("CMD Local");
                      print(cmdlocal[j].commandeId);
                      _presenter
                          .loadCmdDetail(
                              token, c.client_id, cmdlocal[j].commandeId)
                          .then((CommandeDetail cmd) {
                        if (cmd != null)
                        ///        Cmd terminees
                        if (cmd.is_terminated == true) {
                          _etat1 = true;
                          _etat2 = true;
                          cmdToSend = cmd;
                          _showNotificationCmdLV();
                          DatabaseHelper().clearCmdVal();
                          // stop the service to fetch orders
                          AppSharedPreferences().setOrderCreatedTrue(false);
//                          cmdlocal[j].commandeId
                          // remove the scan button at the home screen
                          AppSharedPreferences().setOrderCreate(false);
                        }
                      });
                    }
                  }
                });
              }
            });

          ///          Cmd reffusee
          _presenter
              .getCmdRefuseClient(token, c.client_id)
              .then((List<CommandeDetail> cmdfs) {
            if (cmdfs != null && cmdfs.length > 0) {
              print("Cmd Refusee" + cmdfs.toString());
              _etat1 = true;
              _etat2 = false;
              for (int i = 0; i < cmdfs.length; i++) {
               cmdToSend = cmdfs[i];
                _showNotificationCmdRe();
                api.updateCmdStatus(cmdfs[i], token).then((Commande cmd) {
                  print("cmd refusee mise a jour");
                });
                // remet le compteur a 0 pour attendre une nouvelle commande
                AppSharedPreferences().setOrderCreatedTrue(false);
                print(cmdToSend.prestation.prestataire.image);
              }
            }
          });
        });
    });
  }

  @override
  State<StatefulWidget> createState() {
    return null;
  }
}
