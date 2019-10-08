import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:etakesh_client/Models/clients.dart';
import 'package:etakesh_client/Models/commande.dart';
import 'package:etakesh_client/Models/prestataires.dart';
import 'package:etakesh_client/Models/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import 'NetworkUtil.dart';

const kGoogleApiKey = "AIzaSyBNm8cnYw5inbqzgw8LjXyt3rMhFhEVTjY";

class RestDatasource {
  NetworkUtil _netUtil = new NetworkUtil();
  static final BASE_URL = "http://www.api.e-takesh.com:26525/api/";
  static final LOGIN_URL = BASE_URL + "Users/login";
  static final ONE_USER = BASE_URL + "clients/findOne";
  static final CMD_URL = BASE_URL + "commandes";
  static final POSITIONS_URL = BASE_URL + "positions";
  static final SERVICE1_URL = BASE_URL + "services";
  static final SERVICE_URL = BASE_URL + "categorieservices?filter[include][services]";
  static final CREATE_USER = BASE_URL + "Users";
  static final CLIENT = BASE_URL + "clients";
  static final PRESTATAIRE_URL = BASE_URL + "prestataires";
  static final GOOGLE_MAP_URL =
      "https://maps.googleapis.com/maps/api/place/autocomplete/json";
  static final PRESTATION = BASE_URL + "prestations";
  static final VEHICULE = BASE_URL + "vehicules";
  static final ALLPRESTATAIRE =
      PRESTATION + "?filter[include]=vehicule&filter[include][prestataire]=position";
  static final ALLPRESTATAIREONLINE =
      VEHICULE + "?filter[include][prestataire]=position";
  static final CMD_PRESTATION = CMD_URL +
      "?filter[include][prestation]=service&filter[include][prestation]=vehicule&filter[include][prestation]=prestataire";
  static final CMD_PRESTATION_DETAIL =
      "?filter[include][prestation]=service&filter[include][prestation]=vehicule&filter[include][prestation]=prestataire";

  ///provisoire
  static final FILTER = "&filter[where][UserId]=";
  static final FILTERSERVICE = "&filter[where][serviceId]=";
  static final FILTERCLIENT = "&filter[where][clientId]=";
  static final CMDCREATE =
      "&filter[where][is_created]=true&filter[where][is_terminated]=false";
  static final CMDVALIDE =
      "&filter[where][status]=CREATED&filter[where][is_accepted]=true&filter[where][is_terminated]=false";
  static final CMDTREFUSEE =
      "&filter[where][status]=CREATED&filter[where][is_refused]=true";
  static final CMDOLD = "&filter[where][is_terminated]=true";
  static final TOKEN1 = "?access_token=";
  static final TOKEN2 = "&access_token=";

  ///retourne les informations(token) d'un compte client a partir de ses identifiants
  Future<Login2> login(String username, String password) {
    return _netUtil.post(LOGIN_URL,
        body: {"email": username, "password": password}).then((dynamic res) {
      if (res != null) {
        return Login2.fromJson(json.decode(res));
      } else
        return null;
    }).catchError(
        (onError) => new Future.error(new Exception(onError.toString())));
  }

  ///Retourne un client
  Future<Client1> getClient(int userID, String token) {
    return _netUtil
        .getOne(
      ONE_USER + TOKEN1 + token + FILTER + userID.toString(),
    )
        .then((dynamic res) {
      if (res != null)
        return Client1.fromJson(json.decode(res));
      else
        return null;
    }).catchError(
            (onError) => new Future.error(new Exception(onError.toString())));
  }

  ///Liste des services et categories de services offerts par ETakesh
  Future<List<CategorieService>> getServiceCat(String token) {
    return _netUtil.get(SERVICE_URL + TOKEN2 + token).then((dynamic res) {
      if (res != null)
        return (res as List).map((item) => new CategorieService.fromJson(item)).toList();
      else
        return null as List<CategorieService>;
    }).catchError(
        (onError) => new Future.error(new Exception(onError.toString())));
  }

  ///Liste des services offerts par ETakesh
  Future<List<Service>> getService(String token) {
    return _netUtil.get(SERVICE1_URL + TOKEN1 + token).then((dynamic res) {
      if (res != null)
        return (res as List).map((item) => new Service.fromJson(item)).toList();
      else
        return null as List<Service>;
    }).catchError(
        (onError) => new Future.error(new Exception(onError.toString())));
  }
  ///Liste toutes les commandes passees par client
  Future<List<CommandeDetail>> getNewCmdClient(String token, int clientId) {
    return _netUtil
        .get(CMD_PRESTATION +
            FILTERCLIENT +
            clientId.toString() +
            CMDCREATE +
            TOKEN2 +
            token)
        .then((dynamic res) {
      if (res != null)
        return (res as List)
            .map((item) => new CommandeDetail.fromJson(item))
            .toList();
      else
        return null as List<CommandeDetail>;
    }).catchError(
            (onError) => new Future.error(new Exception(onError.toString())));
  }

  ///Liste toutes les commandes acceptee du client
  Future<List<CommandeDetail>> getCmdValideClient(String token, int clientId) {
    return _netUtil
        .get(CMD_PRESTATION +
            FILTERCLIENT +
            clientId.toString() +
            CMDVALIDE +
            TOKEN2 +
            token)
        .then((dynamic res) {
      if (res != null)
        return (res as List)
            .map((item) => new CommandeDetail.fromJson(item))
            .toList();
      else
        return null as List<CommandeDetail>;
    }).catchError(
            (onError) => new Future.error(new Exception(onError.toString())));
  }

  ///Liste toutes les commandes refusee du client
  Future<List<CommandeDetail>> getCmdRefuseClient(String token, int clientId) {
    return _netUtil
        .get(CMD_PRESTATION +
            FILTERCLIENT +
            clientId.toString() +
            CMDTREFUSEE +
            TOKEN2 +
            token)
        .then((dynamic res) {
      if (res != null)
        return (res as List)
            .map((item) => new CommandeDetail.fromJson(item))
            .toList();
      else
        return null as List<CommandeDetail>;
    }).catchError(
            (onError) => new Future.error(new Exception(onError.toString())));
  }

  ///Details sur ume commande
  Future<CommandeDetail> getCmdClient(String token, int clientId, int cmdId) {
    return _netUtil
        .get(CMD_URL +
            "/" +
            cmdId.toString() +
            CMD_PRESTATION_DETAIL +
            FILTERCLIENT +
            clientId.toString() +
            TOKEN2 +
            token)
        .then((dynamic res) {
      if (res != null) return new CommandeDetail.fromJson(res);
    }).catchError(
            (onError) => new Future.error(new Exception(onError.toString())));
  }

  ///Retourne la position de prise en charge du client
  Future<PositionModel> getPositionById(String token, String postId) {
    return _netUtil
        .get(POSITIONS_URL + "/" + postId + TOKEN1 + token)
        .then((dynamic res) {
      if (res != null) return new PositionModel.fromJson(res);
    }).catchError(
            (onError) => new Future.error(new Exception(onError.toString())));
  }

  ///Retourne la position du prestatire
  Future<PositionModel> getPositionPrestatire(String token, int prestataireId) {
    return _netUtil
        .get(PRESTATAIRE_URL +
            "/" +
            prestataireId.toString() +
            "/" +
            "position" +
            TOKEN1 +
            token)
        .then((dynamic res) {
      if (res != null) return new PositionModel.fromJson(res);
    }).catchError(
            (onError) => new Future.error(new Exception(onError.toString())));
  }

  ///Liste les anciennes commandes deja effectuees par client
  Future<List<CommandeDetail>> getOldCmdClient(String token, int clientId) {
    return _netUtil
        .get(CMD_PRESTATION +
            FILTERCLIENT +
            clientId.toString() +
            CMDOLD +
            TOKEN2 +
            token)
        .then((dynamic res) {
      if (res != null)
        return (res as List)
            .map((item) => new CommandeDetail.fromJson(item))
            .toList();
      else
        return null as List<CommandeDetail>;
    }).catchError(
            (onError) => new Future.error(new Exception(onError.toString())));
  }

  /// liste des prestataires avec leur vehicules et effectuants un service precis
  Future<List<PrestataireService>> getAllPrestatairesServices(
      String token, int serviceId) {
    return _netUtil
        .get(ALLPRESTATAIRE +
            FILTERSERVICE +
            serviceId.toString() +
            TOKEN2 +
            token)
        .then((dynamic res) {
      if (res != null)
        return (res as List)
            .map((item) => new PrestataireService.fromJson(item))
            .toList();
      else
        return null as List<PrestataireService>;
    }).catchError(
            (onError) => new Future.error(new Exception(onError.toString())));
  }

  /// liste des prestataires avec leur vehicules
  Future<List<PrestataireOnline>> getAllPrestataires(String token) {
    return _netUtil
        .get(ALLPRESTATAIREONLINE + TOKEN2 + token)
        .then((dynamic res) {
      if (res != null)
        return (res as List)
            .map((item) => new PrestataireOnline.fromJson(item))
            .toList();
      else
        return null as List<PrestataireOnline>;
    }).catchError(
            (onError) => new Future.error(new Exception(onError.toString())));
  }

  ///Enregistre une position(destination,position) dans le serveur
  Future<PositionModel> savePosition(
      double lat, double lng, String libele, String token) {
    return _netUtil.post(POSITIONS_URL + TOKEN1 + token, body: {
      "latitude": lat.toString(),
      "longitude": lng.toString(),
      "libelle": libele,
    }).then((dynamic res) {
      if (res != null) {
        return PositionModel.fromJson(json.decode(res));
      } else
        return null;
    }).catchError(
        (onError) => new Future.error(new Exception(onError.toString())));
  }

  ///Enregistre une commande dans le serveur
  Future<Commande> saveCmd(
      int montant,
      int post,
      int dest,
      int client,
      int prestation,
      int prestataire,
      String posit,
      String desti,
      String token) {
        print("Date d'envoie");
        print(DateTime.now().toString());
    return _netUtil.post(CMD_URL + TOKEN1 + token, body: {
      "montant": montant.toString(),
      "date": DateTime.now().toString(),
      "date_debut": DateTime.now().toString(),
      "date_fin": DateTime.now().toString(),
      "date_acceptation": DateTime.now().toString(),
      "date_prise_en_charge": DateTime.now().toString(),
      "rate_date": DateTime.now().toString(),
      "status": "CREATED",
      "position_prise_en_charge": posit,
      "position_destination": desti,
      "code": "ET" +
          DateTime.now().month.toString() +
          DateTime.now().day.toString() +
          DateTime.now().hour.toString() +
          DateTime.now().second.toString() +
          "CMD" +
          DateTime.now().year.toString(),
      "distance_client_prestataire": "3",
      "duree_client_prestataire": "30",
      "position_priseId": post.toString(),
      "position_destId": dest.toString(),
      "rate_comment": "No",
      "rate_value": "0",
      "is_created": true.toString(),
      "is_accepted": false.toString(),
      "is_refused": false.toString(),
      "is_terminated": false.toString(),
      "is_started": false.toString(),
      "clientId": client.toString(),
      "prestationId": prestation.toString(),
      "prestataireId": prestataire.toString()
    }).then((dynamic res) {
      if (res != null) {
        print("Save Cmd");
        return Commande.fromJson(json.decode(res));
      } else
        return null;
    }).catchError(
        (onError) => new Future.error(new Exception(onError.toString())));
  }

  ///Modifie le status d'une commande deja vue par le client
  Future<Commande> updateCmdStatus(CommandeDetail cmd, String token) {
    return _netUtil.put(CMD_URL + TOKEN1 + token, body: {
      "commandeid": cmd.commandeid.toString(),
      "montant": cmd.montant.toString(),
      "date": cmd.date,
      "date_debut": cmd.date_debut,
      "date_fin": cmd.date_fin,
      "date_acceptation": cmd.date_acceptation,
      "date_prise_en_charge": cmd.date_prise_en_charge,
      "rate_date": cmd.rate_date,
      "status": "READ",
      "position_prise_en_charge": cmd.position_prise_en_charge,
      "position_destination": cmd.position_destination,
      "code": cmd.code,
      "distance_client_prestataire": cmd.distance_client_prestataire,
      "duree_client_prestataire": cmd.duree_client_prestataire,
      "position_priseId": cmd.position_priseId,
      "position_destId": cmd.position_destId,
      "rate_comment": cmd.rate_comment,
      "rate_value": cmd.rate_value.toString(),
      "is_created": cmd.is_created.toString(),
      "is_accepted": cmd.is_accepted.toString(),
      "is_refused": cmd.is_refused.toString(),
      "is_terminated": cmd.is_terminated.toString(),
      "is_started": cmd.is_started.toString(),
      "clientId": cmd.clientId,
      "prestationId": cmd.prestationId.toString(),
      "prestataireId": cmd.prestation.prestataire.prestataireid.toString()
    }).then((dynamic res) {
      if (res != null) {
        print("Update Cmd");
        return Commande.fromJson(json.decode(res));
      } else
        return null;
    }).catchError(
        (onError) => new Future.error(new Exception(onError.toString())));
  }

  ///Modifie le status d'une commande pret a etre demarre
  Future<Commande> updateCmdStatusToStart(CommandeLocal cmd, String token) {
    return _netUtil.put(CMD_URL + TOKEN1 + token, body: {
      "commandeid": cmd.commandeId.toString(),
      "montant": cmd.montant.toString(),
      "date": cmd.date,
      "date_debut": cmd.date_debut,
      "date_fin": cmd.date_fin,
      "date_acceptation": cmd.date_acceptation,
      "date_prise_en_charge": cmd.date_prise_en_charge,
      "rate_date": cmd.rate_date,
      "status": "TERMINATED",
      "position_prise_en_charge": cmd.position_prise_en_charge,
      "position_destination": cmd.position_destination,
      "code": cmd.code,
      "distance_client_prestataire": cmd.distance_client_prestataire,
      "duree_client_prestataire": cmd.duree_client_prestataire,
      "position_priseId": cmd.position_priseId,
      "position_destId": cmd.position_destId,
      "rate_comment": cmd.rate_comment,
      "rate_value": cmd.rate_value.toString(),
      "is_created": cmd.is_created.toString(),
      "is_accepted": cmd.is_accepted.toString(),
      "is_refused": cmd.is_refused.toString(),
      "is_terminated": true.toString(),
      "is_started": cmd.is_started.toString(),
      "clientId": cmd.clientId.toString(),
      "prestationId": cmd.prestationId.toString(),
      "prestataireId": cmd.prestataireId.toString()
    }).then((dynamic res) {
      if (res != null) {
        print("Update Cmd");
        return Commande.fromJson(json.decode(res));
      } else
        return null;
    }).catchError(
        (onError) => new Future.error(new Exception(onError.toString())));
  }

  ///Modifie les donnees d'un client
  Future<Client1> updateClient(Client1 clt, String token) {
    print(clt.adresse);
    print(clt.image);
    return _netUtil
        .put(CLIENT + "/" + clt.client_id.toString() + TOKEN1 + token, body: {
    
      "adresse": clt.adresse,
      "date_creation": clt.date_creation,
      "date_naissance": clt.date_naissance,
      "email": clt.email,
      "image": clt.image,
      "code": clt.code,
      "nom": clt.nom,
      "pays": clt.pays,
      "prenom": clt.prenom,
      "status": clt.status,
      "telephone": clt.phone.toString(),
      "ville": clt.ville,
      "positionId": clt.positionId.toString(),
      "UserId": clt.user_id.toString()
      // clt.positionId.toString()
    }).then((dynamic res) {
      print(res);
      if (res != null) {
        print("Update Client");
        print(res);
        return Client1.fromJson(json.decode(res));
      } else
        return null;
    }).catchError(
            (onError) => new Future.error(new Exception(onError.toString())));
  }

    ///Modifie le status d'une commande deja vue par le client
  Future<PositionModel> updatePositionClient(String positionId, double lat, double lng,String token) {
    return _netUtil.put(POSITIONS_URL +"/"+positionId.toString()+ TOKEN1 + token, body: {
      "latitude": lat.toString(),
      "longitude": lng.toString(),
      "libelle": "Ma position",
    }).then((dynamic res) {
      if (res != null) {
        print("Update position");
        return PositionModel.fromJson(json.decode(res));
      } else
        return null;
    }).catchError(
        (onError) => new Future.error(new Exception(onError.toString())));
  }

  Future findLocation(String keyword, String lang, double lat, double lng) {
    var url = GOOGLE_MAP_URL +
        "?input=" +
        keyword +
        "&language=" +
        lang +
        "&key=" +
        kGoogleApiKey +
        "&location=" +
        lat.toString() +
        "," +
        lng.toString() +
        "&radius=800";
    return http.get(url);
  }

// Create a container (Folder) to host image profile of customer
 Future saveContainers(String clientCode, String token) {
    var url = BASE_URL + "/containers?access_token="+token;
    Map data = {'name': clientCode};
    var body = json.encode(data);
    return http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);
  }

  // Upload profiles images from server
   Future uploadClientImg(String container, File imgFile, String imgName, String token) {
    var url =
        BASE_URL + "/containers/"+container+"/upload?access_token="+token;
    FormData formData = new FormData.from({
      "file": new UploadFileInfo(imgFile, imgName)
    });
    Dio dio = new Dio();
    return dio.post(url, data: formData);
  }

  // get the url of image profile of customer
  String getProfileImgURL(String container, String imgName, String token) {
    String url =
        BASE_URL + "/containers/"+container+"/download/"+imgName+"?access_token="+token;
    return url;
  }
//TODO: fetch local data
  // get local JSON data
  Future<String> _loadServicesAsset() async {
  return await rootBundle.loadString('assets/images/service.json');
}
 Future<List<CategorieService>> loadServicesLocal(token) async {
     String jsonString = await _loadServicesAsset();
  final jsonResponse = json.decode(jsonString.toString()).cast<Map<String, dynamic>>();
    return jsonResponse.map<CategorieService>((json) => new CategorieService.fromJson(json)).toList();

  }
}
//dio 1.0.13 package for searh nearby place
//  Future<void> searchNearby(String keyword) async {
//    var dio = Dio();
//    var url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
//    var params = {
//      'key': kGoogleApiKey,
//      'location': '$mylat,$mylng',
//      'radius': '800',
//      'keyword': keyword,
//    };
//    var response = await dio.get(url, data: params);
//    print("Search Result");
//    print(response.data['results'].toString());
//  }
