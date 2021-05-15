import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ungpeaofficer/models/type2_sqlite_model.dart';
import 'package:ungpeaofficer/utility/sqlite_helper_type2.dart';
import 'package:ungpeaofficer/widgets/show_progress.dart';

class ShowSQLite extends StatefulWidget {
  @override
  _ShowSQLiteState createState() => _ShowSQLiteState();
}

class _ShowSQLiteState extends State<ShowSQLite> {
  bool load = true;
  List<Type2SQLiteModel> models = [];
  List<List<Widget>> listWidges = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readDataSQLite();
  }

  Future<Null> readDataSQLite() async {
    await SQLiteHelperType2().readDatabase().then((result) {
      if (result == null) {
        setState(() {
          load = false;
        });
      } else {
        setState(() {
          models = result;
          load = false;
          createImage();
        });
      }
    });
  }

  Future<Null> createImage() async {
    for (var item in models) {
      List<Widget> widgets = await convertStringToArrayWidget(item.image);
      setState(() {
        listWidges.add(widgets);
      });
    }
  }

  Future<List<Widget>> convertStringToArrayWidget(String string) async {
    String result = string.substring(1, string.length - 1);
    List<String> strings = result.split(',');
    List<Widget> widgets = [];
    for (var item in strings) {
      Uint8List uint8list = base64Decode(item.trim());
      Widget widget = Image.memory(uint8list);
      widgets.add(widget);
    }
    return widgets;
  }

  Future<Null> uploadAndInsertDataToServer() async {
    for (var item in models) {
      String object1 = 'masterUng123';
      String object2 = models[0].iddoc.trim();
      String object3 = models[0].namejob.trim();
      String object4 = item.image.trim();
      String api =
          'https://wesafe.pea.co.th/webservicejson/api/values/Insert_Record/$object1,$object2,$object3,$object4';
      await Dio().get(api).then((value) => print('##### response ==>> $value'));
    }
    SQLiteHelperType2().deleteAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.cloud_upload),
            onPressed: () => uploadAndInsertDataToServer(),
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () async {
              await SQLiteHelperType2().deleteAll().then((value) {
                models.clear();
                listWidges.clear();
                readDataSQLite();
              });
            },
          )
        ],
        title: Text('Show SQLITE'),
      ),
      body: load
          ? ShowProgress()
          : models.length == 0
              ? Center(child: Text('No Data'))
              : ListView.builder(
                  itemCount: models.length,
                  itemBuilder: (context, index) => Card(
                    color: index % 2 == 0 ? Colors.grey : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('NameJob = ${models[index].namejob}'),
                              Text('idDoc = ${models[index].iddoc}'),
                            ],
                          ),
                          ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemCount: listWidges[index].length,
                            itemBuilder: (context, index2) => Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  width: 100,
                                  child: listWidges[index][index2],
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                              onPressed: () async {
                                int id = models[index].id;
                                print('id Delete ==>> $id');
                                await SQLiteHelperType2()
                                    .deleteSQLiteById(id)
                                    .then((value) {
                                  models.clear();
                                  listWidges.clear();
                                  readDataSQLite();
                                });
                              },
                              icon: Icon(Icons.delete),
                              label: Text('Delete This Record'))
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
