class Address {
  List<String> hashes; // list of hashes
  int count; // total number of hashes
  int length; // length of data in each hash

  Address({this.hashes, this.count, this.length});

  Address.fromJson(Map<String, dynamic> json) {
    hashes = json['hash'];
    count = json['count'];
    length = json['length'];
  }

  Map<String, dynamic> toJson() => {
        'hash': hashes,
        'count': count,
        'length': length,
      };
}
