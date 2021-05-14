import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ungpeaofficer/models/job_model.dart';
import 'package:ungpeaofficer/models/record_model.dart';
import 'package:ungpeaofficer/states/process_record.dart';
import 'package:ungpeaofficer/utility/my_constant.dart';
import 'package:ungpeaofficer/widgets/show_icon_image.dart';
import 'package:ungpeaofficer/widgets/show_progress.dart';
import 'package:ungpeaofficer/widgets/show_title.dart';

class RecordNewJob extends StatefulWidget {
  final JobModel jobModel;
  RecordNewJob({@required this.jobModel});
  @override
  _RecordNewJobState createState() => _RecordNewJobState();
}

class _RecordNewJobState extends State<RecordNewJob> {
  // ElevatedButton.icon(onPressed: (){}, icon: Icon(Icons.arrow_downward), label: Text('Next'),),

  JobModel jobModel;
  bool load = true;
  double size;

  List<RecordModel> recordModels = [];
  String deptName, dateTimeNow;
  List<String> chooses = [];
  int indexChoose = -1;
  final formKey = GlobalKey<FormState>();
  TextEditingController jobController = TextEditingController();

  String nameJob;
  String idDoc;
  List<bool> visibles = [];
  int indexVisible = 0;
  List<int> indexVisibles = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    jobModel = widget.jobModel;
    readData();
  }

  Future<Null> readData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    deptName = preferences.getString(MyConstant.keyDEPTNAME);

    DateTime dateTime = DateTime.now();
    dateTimeNow = dateTime.toString();

    String api =
        'https://wesafe.pea.co.th/webservicejson/api/values/Select_WorkCheckList/${jobModel.menuMainID},${jobModel.menuSubID}';
    await Dio().get(api).then((value) {
      for (var item in value.data) {
        RecordModel model = RecordModel.fromJson(item);

        setState(() {
          recordModels.add(model);
          load = false;
        });
      }
    });
  }

  Widget buildJob() {
    idDoc = 'id${Random().nextInt(100000)}';

    return Column(
      children: [
        Text('Test Id => $idDoc'),
        Form(
          key: formKey,
          child: Container(
            margin: EdgeInsets.only(top: 16),
            width: size * 0.6,
            child: TextFormField(
              controller: jobController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please Fill Job';
                } else {
                  return null;
                }
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.work_outline),
                labelText: 'New Job :',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.only(right: 30),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (formKey.currentState.validate()) {
                    nameJob = jobController.text;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProcessRecord(
                            recordModels: recordModels,
                            nameRecord: nameJob,
                            idDoc: idDoc,
                          ),
                        ));
                  }
                },
                icon: Icon(Icons.arrow_right),
                label: Text('Next'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(jobModel.menuMainName),
      ),
      body: load ? ShowProgress() : buildContent(),
    );
  }

  Widget buildContent() => Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildHead(),
              buildSecond(),
              buildJob(),
              // nameJob == null
              //     ? buildJob()
              //     : ShowTitle(title: 'NameJob => $nameJob'),
              // buildListView(),
            ],
          ),
        ),
      );

  // Widget buildListView() {
  //   return Container(
  //     margin: EdgeInsets.all(16),
  //     child: ListView.builder(
  //       shrinkWrap: true,
  //       physics: ScrollPhysics(),
  //       itemCount: recordModels.length,
  //       itemBuilder: (context, index) => Card(
  //         child: Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               ShowTitle(
  //                 title: recordModels[index].menuChecklistName,
  //                 index: 1,
  //               ),
  //               createType(recordModels[index]),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Column buildSecond() {
    return Column(
      children: [
        ShowTitle(
          title: deptName,
          index: 1,
        ),
        ShowTitle(
          title: dateTimeNow,
          index: 1,
        ),
      ],
    );
  }

  ShowTitle buildHead() {
    return ShowTitle(
      title: jobModel.menuSubName,
      index: 0,
    );
  }

  int indexChooseType = -1;
}
