class ClowderInstance {
  int id;
  String _url;
  String _login_token;

  ClowderInstance(this._url, this._login_token);

  ClowderInstance.map(dynamic obj) {
    this._url = obj["url"];
    this._login_token = obj["login_token"];
  }

  String get url => _url;
  String get login_token => _login_token;


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    map["url"] = _url;
    map["login_token"] = _login_token;
    return map;
  }

  void setClowderInstanceId(int id) {
    this.id = id;
  }

  static List<ClowderInstance> getDefaultClowderInstances() {
    // ClowderInstance clowder_learn_4ceed = new ClowderInstance("https://learn.4ceed.illinois.edu", "two");
    // ClowderInstance clowder_ncsa = new ClowderInstance("https://clowder.ncsa.illinois.edu/clowder", "three");
    return [];
  }
}