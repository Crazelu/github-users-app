import 'package:flutter/material.dart';
import 'package:github_users/services/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:github_users/services/model.dart';
import 'package:url_launcher/url_launcher.dart';

class GitHubUsers extends StatefulWidget {
  @override
  _GitHubUsersState createState() => _GitHubUsersState();
}

class _GitHubUsersState extends State<GitHubUsers> {


  @override
  void initState() {
    super.initState();
  }

  
 
  @override
  Widget build(BuildContext context) {
   

    return _onlineListView();
  }

  _image(int index, AsyncSnapshot snapshot){
    return CircleAvatar(
      radius: 25,
      backgroundImage: NetworkImage(snapshot.data[index].imageUrl),
    
    );
  }

  _button(int index, AsyncSnapshot snapshot) {
    return Container(
      color: Colors.white,
      height: 40,
      width: 120,
      child: FlatButton(
        onPressed: (){
          _launchUrl(snapshot.data[index].url, context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'View Profile',
              style: Theme.of(context).textTheme.caption.copyWith(color: Colors.black45)
            ),
            Expanded(
              child: Image(image: AssetImage('assets/images/octocat.png'),),
            )
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.black54,
            width: 2
          )
        )
        ),
    );
  }

  Future<List<Users>> fetchUsers(context) async{
    while (true){
      try{
        String url = 'https://api.github.com/users?language=flutter';
    var response = await http.get(url);

    if (response.statusCode == 200){
      final items = json.decode(response.body).cast<Map<String, dynamic>>();

      List<Users> users = items.map<Users>((json){
        return Users.fromJson(json);
      }).toList();
      return users;
    }
    else{
      print('Error: ${response.statusCode}');
      continue;
    }
      }
      catch(e){
        print(e);
      }
    }
    
    
  }
  Future<SingleUser> fetchUser(String login) async{
    String url = 'https://api.github.com/users/$login';
    var response = await http.get(url);

    if (response.statusCode == 200){
      final items = json.decode(response.body);

      
        return SingleUser.fromJson(items);
    }
    else{
      print('Error here: $url');
      SingleUser(name:'', location:'Unavailable');
    }
    
  }

  _title(AsyncSnapshot snapshot, int index){
    return FutureBuilder(
                future: fetchUser(snapshot.data[index].login),
                builder: (ctx, snap){
                  if(snap.hasData && snap.connectionState == ConnectionState.done){
                    return Text(
                    snap.data.name?? snapshot.data[index].login,
                    style: Theme.of(context).textTheme.headline.copyWith(
                      color:Colors.black,
                      fontSize: 17),
                  );}
                  return Text(
                    snapshot.data[index].login,
                    style: Theme.of(context).textTheme.headline.copyWith(
                      color:Colors.black,
                      fontSize: 17),
                  );});
  }
  _location(AsyncSnapshot snapshot, int index){
    return FutureBuilder(
                future: fetchUser(snapshot.data[index].login),
                builder: (ctx, snap){
                  if(snap.hasData && snap.connectionState==ConnectionState.done){
                    return Text(
                    snap.data.location,
                    style: Theme.of(context).textTheme.caption.copyWith(color:Colors.grey[400]),
                  );}
                  return Text('Fetching...',
                  style: Theme.of(context).textTheme.caption.copyWith(color:Colors.grey[400]),
                  );});
  }

  _launchUrl(String url, BuildContext context) async{
    try{
    if (await canLaunch(url)){
      await launch(url, forceWebView: true);
    }}
    catch(e){
      showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
       title: Text('Error'),
       titleTextStyle: TextStyle(
         color: Colors.black,
         fontSize:16
       ),
       content: Text('Could not launch url'),
       contentTextStyle: TextStyle(color: Colors.black,
       fontSize:22),
     );}
        
        );
     
  }
  }

 Widget _onlineListView(){
    return FutureBuilder<List<Users>>(
      future: fetchUsers(context),
      builder: (context, snapshot){
        if (!snapshot.hasData){
         return Scaffold(appBar: AppBar(
           automaticallyImplyLeading: false,
          elevation: 0,
          title: Text(
            'GitHub Users',
            style: Theme.of(context).textTheme.headline.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20
              )
          ),
          backgroundColor: Colors.black87,
         ),
         body: Center(child: CircularProgressIndicator(
           backgroundColor: Colors.black,
         ))
         );
        }
         return  Scaffold(
        appBar: _appBar(),

        body: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: snapshot.data.length,
            itemBuilder: (context, index){
              return ListTile(
                  leading: _image(index, snapshot),
                  title: _title(snapshot, index),
                  subtitle: _location(snapshot, index),
                  trailing: _button(index, snapshot),
                  );
                  }
            
            ),
      );
      }
    );
  }

  _appBar(){
    return AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          actions: <Widget>[
            IconButton(
              onPressed: (){
                setState(() {
                  fetchUsers(context);
                });
              },
              icon:Icon(Icons.refresh,
            color:Colors.white))
          ],
          title: Text(
            'GitHub Users',
            style: Theme.of(context).textTheme.headline.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20
              )
          ),
          backgroundColor: Colors.black87,
        );
  }

  
}