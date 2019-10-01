import '../database/database_helper.dart';
import '../database/clowder_instance.dart';
import 'dart:async';


abstract class HomeContract {
  void screenUpdate();
}

class HomePresenter {

  HomeContract _view;

  var db = new DatabaseHelper();

  HomePresenter(this._view);

  deleteClowderInstance(ClowderInstance user) {
    var db = new DatabaseHelper();
    db.deleteClowderInstances(user);
    updateScreen();
  }

  Future<List<ClowderInstance>> getClowderInstance() {
    return db.getClowderInstance();
  }

  updateScreen() {
    _view.screenUpdate();

  }


}
