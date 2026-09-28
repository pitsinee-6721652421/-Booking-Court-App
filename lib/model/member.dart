
class Member {
  final int? id;
  final String name;
  final String id1;
  final String image;

  

  const Member({
    this.id,
    required this.name,
    required this.id1,
    required this.image,
   
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'id1': id1,
      
      'image': image,
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] as int?,
      name: map['name'] as String,
      id1: map['id1'] as String,
      
       image: map['image'] as String,
    );
  }
}