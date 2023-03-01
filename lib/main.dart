import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:futurebuilderh/Screens/details.dart';
import 'package:http/http.dart' as http;

import 'models/users.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {

      _counter++;
    });
  }
Future<List<User>> getUsers() async{
    var url=Uri.parse('https://randomuser.me/api/?results=20');
    late http.Response response;
    List<User> users=[];
    try{
      response=await http.get(url);
      if(response.statusCode==200){
        Map peopleData=jsonDecode(response.body);
        print(peopleData);
        List<dynamic> peoples=peopleData["results"];
        print(peoples[0]['name']['first']);
        for(var item in peoples){
          var email=item['email'];
          var name=item['name']['first']+" "+item['name']['last'];
          var id=item['login']['uuid'];
          var avatar=item['picture']['large'];
          User user=User(id,name,email,avatar);
          users.add(user);

        }
        
      }else{
        return Future.error('Something goes wrong,${response.statusCode}');
      }
    }
    catch(e){
      return Future.error(e.toString());
    }
    return users;
}
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: getUsers(),
        builder: (BuildContext context,AsyncSnapshot snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(
              child: Text('Waiting'),
            );
          }else{
            if(snapshot.hasError){
              return Text(snapshot.error.toString());
            }else{
             return ListView.builder(
                 itemCount: snapshot.data.length,
                 itemBuilder: (BuildContext context,int index){
                   return ListTile(
                     leading: CircleAvatar(
                       backgroundImage:
                       NetworkImage(snapshot.data[index].avatar),
                     ),
                     title: Text(snapshot.data[index].name),
                     subtitle: Text(snapshot.data[index].email),
                     onTap: (){
                     Navigator.push(context,
                     MaterialPageRoute(builder: (context)=>
                     UserDetails(snapshot.data[index])
                     )
                     );
                     },
                   );
                 });
            }
          }
        },
      ),

    );
  }
}
