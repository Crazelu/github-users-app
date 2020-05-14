class SingleUser{
  String name;
  String location;

  SingleUser({this.name, this.location});

  factory SingleUser.fromJson(Map<String, dynamic> json){
    return SingleUser(
      name: json['name'],
      location: json['location']??'Unavailable'
    );
  }

  
}