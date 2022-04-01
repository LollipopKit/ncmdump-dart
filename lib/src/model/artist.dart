/// json raw:
/// `["Artist Name", Artist ID Int]`
class Artist {
  String? name;
  int? id;
  Artist({this.name, this.id});

  Artist.fromJson(List json) {
    name = json[0];
    id = json[1];
  }

  List toJson() {
    final data = [];
    data[0] = name;
    data[1] = id;
    return data;
  }

  @override
  String toString() {
    return 'Artist<name: $name, id: $id>';
  }
}
