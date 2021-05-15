import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ungpeaofficer/models/informaiont_model.dart';
import 'package:ungpeaofficer/utility/my_constant.dart';
import 'package:ungpeaofficer/widgets/check_job.dart';
import 'package:ungpeaofficer/widgets/history.dart';
import 'package:ungpeaofficer/widgets/record_job.dart';
import 'package:ungpeaofficer/widgets/show_man.dart';
import 'package:ungpeaofficer/widgets/show_map.dart';
import 'package:ungpeaofficer/widgets/show_progress.dart';
import 'package:ungpeaofficer/widgets/show_title.dart';

class MyService extends StatefulWidget {
  @override
  _MyServiceState createState() => _MyServiceState();
}

class _MyServiceState extends State<MyService> {
  InformationModel informationModel;
  List<Widget> widgets = [];
  int index = 0;
  List<String> titles = [
    'บันทึกงานใหม่',
    'ประวัติการทำงาน',
    'ตรวจสอบสถานะงาน',
    'แสดง พิกัด แผนที่'
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readData();
    findToken();
  }

  Future<Null> findToken() async {
    await Firebase.initializeApp().then((value) async {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging
          .getToken()
          .then((value) => print('#### token ===>> $value'));
    });
  }

  Future<Null> readData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String employedid = preferences.getString(MyConstant.keyEmployedid);

    String apiInformation =
        'https://wesafe.pea.co.th/webservicejson/api/values/job/$employedid';
    await Dio().get(apiInformation).then((value) {
      // print('### value ==> $value');
      for (var item in value.data) {
        setState(() {
          informationModel = InformationModel.fromJson(item);

          widgets.add(RecordJob(
            model: informationModel,
          ));
          widgets.add(History(
            employedid: employedid,
          ));

          widgets.add(CheckJob(
            employedid: employedid,
          ));

          widgets.add(
            ShowMap(),
          );
        });
        // print('### name Login = ${informationModel.fIRSTNAME}');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(titles[index]),
        ),
        drawer: Drawer(
          child: Stack(
            children: [
              Column(
                children: [
                  buildUserAccountsDrawerHeader(),
                  buildMenuRecordJob(context),
                  buildMenuHistory(context),
                  buildMenuCheckJob(context),
                  buildMenuShowLocation(context),
                ],
              ),
              buildSignOut(),
            ],
          ),
        ),
        body: informationModel == null ? ShowProgress() : widgets[index]);
  }

  ListTile buildMenuHistory(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.dashboard,
        size: 36,
        color: MyConstant.primart,
      ),
      title: ShowTitle(
        title: 'ประวัติการทำงาน',
        index: 1,
      ),
      onTap: () {
        setState(() {
          index = 1;
        });
        Navigator.pop(context);
      },
    );
  }

  ListTile buildMenuRecordJob(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.date_range,
        size: 36,
        color: MyConstant.primart,
      ),
      title: ShowTitle(
        title: 'บันทึกงานใหม่',
        index: 0,
      ),
      onTap: () {
        setState(() {
          index = 0;
        });
        Navigator.pop(context);
      },
    );
  }

  ListTile buildMenuCheckJob(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.check_circle,
        size: 36,
        color: MyConstant.primart,
      ),
      title: ShowTitle(
        title: 'ตรวจสอบสถานะงาน',
        index: 1,
      ),
      subtitle: ShowTitle(title: 'ตรวจสอบสถานะงาน และ ปิดงาน'),
      onTap: () {
        setState(() {
          index = 2;
        });
        Navigator.pop(context);
      },
    );
  }

  ListTile buildMenuShowLocation(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.map,
        size: 36,
        color: MyConstant.primart,
      ),
      title: ShowTitle(
        title: 'Show Location',
        index: 1,
      ),
      subtitle: ShowTitle(title: 'แสดง พิกัดปัจุบัน'),
      onTap: () {
        setState(() {
          index = 3;
        });
        Navigator.pop(context);
      },
    );
  }

  UserAccountsDrawerHeader buildUserAccountsDrawerHeader() {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(color: MyConstant.primart),
      currentAccountPicture: ShowMan(),
      accountName: informationModel == null
          ? Text('Name :')
          : Text('${informationModel.fIRSTNAME} ${informationModel.lASTNAME}'),
      accountEmail: informationModel == null
          ? Text('Position :')
          : Text('ตำแหน่ง : ${informationModel.dEPTNAME}'),
    );
  }

  Column buildSignOut() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ListTile(
          onTap: () async {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            preferences.clear();

            Navigator.pushNamedAndRemoveUntil(
                context, '/authen', (route) => false);
          },
          tileColor: Colors.red.shade900,
          leading: Icon(Icons.exit_to_app, size: 36, color: Colors.white),
          title: ShowTitle(
            title: 'Sign Out',
            index: 3,
          ),
        ),
      ],
    );
  }
}
