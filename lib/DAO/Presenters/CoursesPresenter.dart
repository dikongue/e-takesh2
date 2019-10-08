import 'package:etakesh_client/DAO/Rest_dt.dart';
import 'package:etakesh_client/Models/commande.dart';

abstract class CoursesContract {
  void onLoadingSuccess(List<CommandeDetail> ncmds, List<CommandeDetail> ocmds);
  void onLoadingError();
  void onConnectionError();
}

class CoursesPresenter {
  CoursesContract _view;

  RestDatasource api = new RestDatasource();

  CoursesPresenter(this._view);

  loadCmd(String token, int clientId) {
    api.getNewCmdClient(token, clientId).then((List<CommandeDetail> ncmds) {
      api.getOldCmdClient(token, clientId).then((List<CommandeDetail> ocmds) {
        _view.onLoadingSuccess(ncmds, ocmds);
      });
    }).catchError((onError) {
      _view.onConnectionError();
    });
  }
}

class CommandeNotifPresenter {
  RestDatasource api = new RestDatasource();

  ///commandes validees
  Future<List<CommandeDetail>> getCmdValideClient(String token, int clientId) {
    return api
        .getCmdValideClient(token, clientId)
        .then((List<CommandeDetail> commandes) {
      if (commandes != null)
        return commandes;
      else
        return null;
    }).catchError((onError) {
      print("Erreur liste cmd");
    });
  }

  ///detail sur une commande
  Future<CommandeDetail> loadCmdDetail(String token, int clientId, int cmdId) {
    return api
        .getCmdClient(token, clientId, cmdId)
        .then((CommandeDetail commande) {
      if (commande != null) {
        return commande;
      } else
        return null;
    }).catchError((onError) {
      print("Erreur get one cmd");
    });
  }

  ///commandes refusees
  Future<List<CommandeDetail>> getCmdRefuseClient(String token, int clientId) {
    return api
        .getCmdRefuseClient(token, clientId)
        .then((List<CommandeDetail> commandes) {
      if (commandes != null)
        return commandes;
      else
        return null;
    }).catchError((onError) {
      print("Erreur liste cmd");
    });
  }
}
