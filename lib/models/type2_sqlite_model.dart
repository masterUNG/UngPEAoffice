import 'dart:convert';

class Type2SQLiteModel {
  final int id;
  final String iddoc;
  final String namejob;
  final String image;
  Type2SQLiteModel({
     this.id,
     this.iddoc,
     this.namejob,
     this.image,
  });

  Type2SQLiteModel copyWith({
    int id,
    String iddoc,
    String namejob,
    String image,
  }) {
    return Type2SQLiteModel(
      id: id ?? this.id,
      iddoc: iddoc ?? this.iddoc,
      namejob: namejob ?? this.namejob,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'iddoc': iddoc,
      'namejob': namejob,
      'image': image,
    };
  }

  factory Type2SQLiteModel.fromMap(Map<String, dynamic> map) {
    return Type2SQLiteModel(
      id: map['id'],
      iddoc: map['iddoc'],
      namejob: map['namejob'],
      image: map['image'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Type2SQLiteModel.fromJson(String source) => Type2SQLiteModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Type2SQLiteModel(id: $id, iddoc: $iddoc, namejob: $namejob, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Type2SQLiteModel &&
      other.id == id &&
      other.iddoc == iddoc &&
      other.namejob == namejob &&
      other.image == image;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      iddoc.hashCode ^
      namejob.hashCode ^
      image.hashCode;
  }
}
