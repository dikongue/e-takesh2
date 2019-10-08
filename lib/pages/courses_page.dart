import 'package:etakesh_client/DAO/Presenters/CoursesPresenter.dart';
import 'package:etakesh_client/Database/DatabaseHelper.dart';
import 'package:etakesh_client/Models/clients.dart';
import 'package:etakesh_client/Models/commande.dart';
import 'package:etakesh_client/Utils/AppSharedPreferences.dart';
import 'package:etakesh_client/Utils/Loading.dart';
import 'package:etakesh_client/Utils/PriceFormated.dart';
import 'package:etakesh_client/pages/Commande/details_cmd.dart';
import 'package:etakesh_client/pages/Commande/details_cmd_terminees.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CoursesPage extends StatefulWidget {
  @override
  State createState() => CoursesPageState();
}

class CoursesPageState extends State<CoursesPage> implements CoursesContract {
//class CoursesPage extends StatelessWidget {
  String _token;
  int _stateIndex;
  List<CommandeDetail> _ncmds;
  List<CommandeDetail> _ocmds;
  CoursesPresenter _presenter;
  bool _ncourses, _ocourses;
  Client1 client;
  DateFormat dateFormat ;
  @override
  void initState() {
    _ncourses = false;
    _ocourses = false;
    initializeDateFormatting();
    AppSharedPreferences().getToken().then((String token1) {
      if (token1 != '') {
        _token = token1;
        DatabaseHelper().getClient().then((Client1 c) {
          if (c != null) {
            client = c;
            _presenter = new CoursesPresenter(this);
            _presenter.loadCmd(token1, c.client_id);
          }
        });
      }
    }).catchError((err) {
      print("Not get Token " + err.toString());
    });
    _stateIndex = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (_stateIndex) {
      case 0:
        return ShowLoadingView();

      case 2:
        return ShowConnectionErrorView(_onRetryClick);

      default:
        return DefaultTabController(
            length: 2,
            child: Scaffold(
                appBar: new AppBar(
                  bottom: TabBar(
                    indicatorColor: Color(0xFF2773A1),
                    tabs: [
                      Tab(
                        child: Text(
                          "A venir",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Anciènnes",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  title: new Text(
                    'Mes courses',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.black,
                  iconTheme: IconThemeData(color: Colors.white),
                ),
                body: TabBarView(
                  children: [
                    _ncourses
                        ? ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.all(0.0),
                            scrollDirection: Axis.vertical,
                            itemCount: _ncmds.length,
                            itemBuilder: (BuildContext ctxt, int index) {
                              return InkWell(
                                  child: Container(child: getItemNew(index)),
                                  onTap: () {
                                    print("travail sur les dates");
                                    Navigator.of(context).push(
                                        new MaterialPageRoute(
                                            builder: (context) =>
                                                DetailsCmdPage(
                                                  commande: _ncmds[index],
                                                )));
                                  });
                            },
                            separatorBuilder: (context, index) {
                              return Divider();
                            },
                          )
                        :

                        ///si on n'a pas encore effectuer une course
                        Center(
                            child: Text(
                                "Vous n'avez pas de course planifiée ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color: Colors.black)),
                          ),
                    _ocourses
                        ? ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.all(0.0),
                            scrollDirection: Axis.vertical,
                            itemCount: _ocmds.length,
                            itemBuilder: (BuildContext ctxt, int index) {
                              return InkWell(
                                  child: Container(child: getItemOld(index)),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        new MaterialPageRoute(
                                            builder: (context) =>
                                                DetailsCmdTerminePage(
                                                  commande: _ocmds[index],
                                                )));
                                  });
                            },
                            separatorBuilder: (context, index) {
                              return Divider();
                            },
                          )
                        :
                        ///si on n'a pas aucune course programmee
                        Center(
                            child: Text(
                                "Vous n'avez pas encore effectué de course",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color: Colors.black)),
                          )
                  ],
                )));
    }
  }

  Widget getItemNew(indexItem) {
    DateTime dateCmd =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(_ncmds[indexItem].date);
        print("DateTime ");
        print(dateCmd);
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Container(
          color: Color(0x88F9FAFC),
          child: Row(
            children: <Widget>[
              new Padding(
                padding: new EdgeInsets.symmetric(horizontal: 32.0 - 12.0 / 2),
                child: new Container(
                  height: 12.0,
                  width: 12.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: getStatusCommandValueColor(_ncmds[indexItem])),
                ),
              ),
              new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      _ncmds[indexItem].prestation.service.intitule,
                      style:
                          new TextStyle(fontSize: 18.0, color: Colors.black87),
                    ),
                    SizedBox(
                      height: 7.0,
                    ),
                    new Text(
                       PriceFormatter.moneyFormat(_ncmds[indexItem].montant)+ ' XFA',
                      style: new TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              new Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    new Text(
                      DateFormat('EEEE d MMMM y','fr_CA').format(dateCmd),
                      style: new TextStyle(
                          fontSize: 12.0, color: Color(0xFF93BFD8)),
                    ),
                    SizedBox(
                      height: 7.0,
                    ),
                    new Text(
                      " à " + DateFormat.Hm().format(dateCmd) + " min",
                      style: new TextStyle(
                          fontSize: 12.0, color: Color(0xFF93BFD8)),
                    ),
                  ],
                ),
              ),
              Divider(),
            ],
          ),
        ));
  }

  Widget getItemOld(indexItem) {
    DateTime dateCmdo =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(_ocmds[indexItem].date);
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Container(
          color: Color(0x88F9FAFC),
          child: Row(
            children: <Widget>[
              new Padding(
                padding: new EdgeInsets.symmetric(horizontal: 32.0 - 12.0 / 2),
                child: new Container(
                  height: 12.0,
                  width: 12.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFF33B841)),
                ),
              ),
              new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      _ocmds[indexItem].prestation.service.intitule,
                      style:
                          new TextStyle(fontSize: 18.0, color: Colors.black87),
                    ),
                    SizedBox(
                      height: 7.0,
                    ),
                    new Text(
                     PriceFormatter.moneyFormat(_ocmds[indexItem].montant) + ' XFA',
                      style: new TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              new Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    new Text(DateFormat('EEEE d MMMM y','fr_CA').format(dateCmdo),
                      style: new TextStyle(
                          fontSize: 12.0, color: Color(0xFF93BFD8)),
                    ),
                    SizedBox(
                      height: 7.0,
                    ),
                    new Text(
                      " à " + DateFormat.Hm().format(dateCmdo) + " min",
                      style: new TextStyle(
                          fontSize: 12.0, color: Color(0xFF93BFD8)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  void _onRetryClick() {
    setState(() {
      _stateIndex = 0;
      _presenter.loadCmd(_token, client.client_id);
    });
  }

  ///soucis de connexion internet
  @override
  void onConnectionError() {
    setState(() {
      _stateIndex = 2;
    });
  }

  ///en cas de soucis
  @override
  void onLoadingError() {
    setState(() {
      _stateIndex = 1;
    });
  }

  ///si tout ce passe bien
  @override
  void onLoadingSuccess(
      List<CommandeDetail> ncmds, List<CommandeDetail> ocmds) {
    setState(() {
      _stateIndex = 3;
    });
    if (ncmds.length != 0)
      setState(() {
        _ncourses = true;
        this._ncmds = ncmds.reversed.toList();
      });
    if (ocmds.length != 0)
      setState(() {
        _ocourses = true;
        this._ocmds = ocmds.reversed.toList();
      });
  }

  Color getStatusCommandValueColor(CommandeDetail cmd) {
    if (cmd.is_created == true &&
        cmd.is_accepted == false &&
        cmd.is_refused == false) return Color(0xFFDEAC17);
    if (cmd.is_accepted == true &&
        cmd.is_created == true &&
        cmd.is_refused == false) return Color(0xFF0C60A8);
    if (cmd.is_refused == true &&
        cmd.is_created == true &&
        cmd.is_accepted == false) return Color(0xFFC72230);
    if (cmd.is_terminated == true && cmd.is_created == true)
      return Color(0xFF33B841);
  }
}
