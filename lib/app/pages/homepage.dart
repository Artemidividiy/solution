import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:solution/app/components/userTile.dart';
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
          Text("drag to refresh"),
          Expanded(
            child: RefreshIndicator(
                onRefresh: getContent,
                child: FutureBuilder<List<Content>>(
                  future: getContent(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.done) {
                      snapshot.data!.removeWhere(
                          (element) => element.reciever != User.id);
                      return ListView(
                        shrinkWrap: true,
                        children: [
                          Text("Notifications"),
                          Column(
                              children:
                                  List.generate(snapshot.data!.length, (index) {
                            if (snapshot.data![index].sender != User.id!)
                              return RequestWidget(data: snapshot.data![index]);
                            return Container();
                          })),
                          Divider(),
                          Text("Your requests"),
                          Column(
                            children:
                                List.generate(snapshot.data!.length, (index) {
                              if (snapshot.data![index].sender == User.id!)
                                return RequestWidget(
                                    data: snapshot.data![index]);
                              return Container();
                            }),
                          )
                        ],
                      );
                    }
                    return CircularProgressIndicator();
                  },
                )),
          ),
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: send,
        child: Text("send"),
      ),
    );
  }

  Future<List<Content>> getContent() async {
    final client = PocketBase("http://pelerin-solutions.ru:10011");
    final result = await client.records.getList(
      'content',
      page: 1,
      perPage: 50,
      filter: 'created >= "2022-01-01 00:00:00"',
    );
    return List.generate(
        result.totalItems, (index) => Content.fromMap(result.items[index]));
  }

  send() async {
    final ImagePicker picker = ImagePicker();
    XFile? img = await picker.pickImage(source: ImageSource.camera);
    if (img != null) {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              child: FutureBuilder<Widget>(
                future: getUsers(img),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return snapshot.data!;
                  }
                  return CircularProgressIndicator();
                },
              ),
            );
          });
    }
  }

  Future<Widget> getUsers(XFile img) async {
    final client = PocketBase("http://pelerin-solutions.ru:10011");
    await client.admins
        .authViaEmail('artemiy.kasyanik@gmail.com', 'hajta4-dakDif-fezkud');
    List<UserModel> users = await client.users.getFullList();
    List<Widget> data = [Text("Pick reciever")];

    data.addAll(List.generate(
        users.length, (index) => UserTile(user: users[index], img: img)));

    return Column(
      children: data,
    );
  }
}
