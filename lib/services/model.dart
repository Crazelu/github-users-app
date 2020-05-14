class Users{
  String login;
  String url;
  String imageUrl;

  Users({this.login, this.url, this.imageUrl});

  factory Users.fromJson(Map<String, dynamic> json){
    return Users(
      login: json['login'],
      url: json['html_url'],
      imageUrl: json['avatar_url']
    );
  }

}