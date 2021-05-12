import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ungpeaofficer/models/informaiont_model.dart';
import 'package:ungpeaofficer/models/job_model.dart';
import 'package:ungpeaofficer/widgets/show_progress.dart';

class RecordJob extends StatefulWidget {
  final InformationModel model;
  RecordJob({@required this.model});
  @override
  _RecordJobState createState() => _RecordJobState();
}

class _RecordJobState extends State<RecordJob> {
  InformationModel informationModel;
  List<JobModel> jobModels = [];
  List<JobModel> jobModelsForName = [];
  bool load = true;

  List<String> names = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    informationModel = widget.model;
    readData();
  }

  Future<Null> readData() async {
    String apiJob =
        'https://wesafe.pea.co.th/webservicejson/api/values/task/0,${informationModel.ownerID}';

    // print('apiJob == $apiJob');

    await Dio().get(apiJob).then((value) {
      // print('## value = > $value');
      for (var item in value.data) {
        JobModel model = JobModel.fromJson(item);
        names.add(model.menuMainName);
        jobModels.add(model);
      }

      
      String name = names[0];
      jobModelsForName.add(jobModels[0]);
      bool found = false;

      for (var i = 0; i < jobModels.length; i++) {
        if (name == jobModels[i].menuMainName && !found) {
          found = true;
        } else if (name != jobModels[i].menuMainName) {
          setState(() {
            load = false;
            jobModelsForName.add(jobModels[i]);
          });
          name = jobModels[i].menuMainName;
          found = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: load
          ? ShowProgress()
          : ListView.builder(
              itemCount: jobModelsForName.length,
              itemBuilder: (context, index) =>
                  Text(jobModelsForName[index].menuMainName),
            ),
    );
  }
}
