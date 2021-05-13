import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ungpeaofficer/models/job_model.dart';
import 'package:ungpeaofficer/models/record_model.dart';
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
          visibles.add(false);
          load = false;
          indexVisibles.add(indexVisible);
        });
        indexVisible++;
      }
      print('#### vistual ==>>$visibles');
    });
  }

  Widget buildJob() {
    return Column(
      children: [
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
                    setState(() {
                      nameJob = jobController.text;
                    });
                  }
                },
                icon: Icon(Icons.arrow_downward),
                label: Text('Next'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildFormRecord() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      width: size * 0.6,
      child: TextFormField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.book_outlined),
          labelText: 'บันทึกข้อความ :',
          border: OutlineInputBorder(),
        ),
      ),
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
              nameJob == null
                  ? buildJob()
                  : ShowTitle(title: 'NameJob => $nameJob'),
              buildListView(),
            ],
          ),
        ),
      );

  Widget buildListView() {
    return Container(
      margin: EdgeInsets.all(16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: recordModels.length,
        itemBuilder: (context, index) => Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShowTitle(
                  title: recordModels[index].menuChecklistName,
                  index: 1,
                ),
                createType(recordModels[index]),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  Widget type0() => Text('No Job');
  Widget type1(RecordModel model, int index) => Column(
        children: [
          ShowTitle(title: model.menuChecklistName),
          ElevatedButton(
            onPressed: () {},
            child: Text('Check'),
          ),
          visibles[indexVisibles[index]]
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_downward),
                      label: Text('Next123'),
                    ),
                  ],
                )
              : SizedBox(),
        ],
      );

  Widget type2(RecordModel model, int index) {
    int amountPic = model.quantityImg;
    List<File> files = [];
    for (var i = 0; i < amountPic; i++) {
      files.add(null);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShowTitle(title: model.menuChecklistName),
        ShowTitle(title: 'จำนวนรูปภาพที่ต้องการ $amountPic รูป'),
        Divider(
          thickness: 1,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemCount: files.length,
          itemBuilder: (context, index) => Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    child: ShowIconImage(),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.add_a_photo),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.add_photo_alternate),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              Divider(
                thickness: 1,
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.arrow_downward),
              label: Text('Next'),
            ),
          ],
        ),
      ],
    );
  }

  Widget type3(RecordModel model, int index) => Column(
        children: [
          ShowTitle(title: model.menuChecklistName),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildFormRecord(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.arrow_downward),
                label: Text('Next'),
              ),
            ],
          ),
        ],
      );

  Widget type4(RecordModel model, int index) {
    chooses.add(null);
    print('### chooses ==> $chooses');
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: size * 0.4,
              child: RadioListTile(
                value: '1',
                groupValue: chooses[indexChoose],
                onChanged: (value) {
                  setState(() {
                    chooses[indexChoose] = value;
                  });
                },
                title: ShowTitle(title: model.menuChecklistName),
              ),
            ),
            Container(
              width: size * 0.4,
              child: RadioListTile(
                value: '0',
                groupValue: chooses[indexChoose],
                onChanged: (value) {
                  setState(() {
                    chooses[indexChoose] = value;
                  });
                },
                title: ShowTitle(title: 'ไม่ต้อง ${model.menuChecklistName}'),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.arrow_downward),
              label: Text('Next'),
            ),
          ],
        ),
      ],
    );
  }

  int indexChooseType = -1;

  Widget createType(RecordModel recordModel) {
    indexChooseType ++;
    switch (int.parse(recordModel.type)) {
      
      case 1:     
        return type1(recordModel, indexChooseType);
        break;
      case 2:
        return type2(recordModel, indexChooseType);
        break;
      case 3:
        return type3(recordModel, indexChooseType);
        break;
      case 4:
        indexChoose++;
        return type4(recordModel, indexChooseType);
        break;
      default:
        return type0();
        break;
    }
  }
}
