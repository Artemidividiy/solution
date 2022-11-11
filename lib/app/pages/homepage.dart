import 'package:flutter/material.dart';

import 'package:pocketbase/pocketbase.dart';
import '../components/requestwidget.dart';
import 'package:solution/app/pages/authpage.dart';

import '../models/content.dart';
import '../models/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(User.id!),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () async {
                await User.logout();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => AuthPage(),
                ));
              })),
      body: Column(
        children: [
          Text("some value"),
          FutureBuilder<List<Content>>(
            future: getContent(),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                snapshot.data!
                    .removeWhere((element) => element.reciever != User.id);
                return Expanded(
                  child: ListView(
                    children: List.generate(snapshot.data!.length,
                        (index) => RequestWidget(data: snapshot.data![index])),
                  ),
                );
              }
              return CircularProgressIndicator();
            },
          )
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: null,
        child: Text("send"),
      ),
    );
  }

  Future<List<Content>> getContent() async {
    final client = PocketBase("http://127.0.0.1:8090");
    final result = await client.records.getList(
      'content',
      page: 1,
      perPage: 50,
      filter: 'created >= "2022-01-01 00:00:00"',
    );
    return List.generate(result.totalItems,
        (index) => Content.fromMap(result.items[index].data));
  }
}
