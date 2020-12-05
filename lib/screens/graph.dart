import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:xl_data_app/models/dataReading.dart';

enum Mode { RPM, TEMP }

class GraphPage extends StatefulWidget {
  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  Mode _mode = Mode.RPM;
  List<DataReading> tableDataArray = <DataReading>[];
  File file;

  void readExel() async {
    List<DataReading> tempList = <DataReading>[];
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    // ByteData data = await rootBundle.load('assets/xl.xlsm');
    // var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    // var excel = Excel.decodeBytes(bytes);
    var table = 'Sheet1';
    print("table name : $table"); //sheet Name
    print("max columns : ${excel.tables[table].maxCols}");
    print("max rows : ${excel.tables[table].maxRows}");
    int maxRows = excel.tables[table].maxRows;
    for (var i = 0; i < maxRows; i++) {
      var row = excel.tables[table].rows[i];
      if (i < 2) continue;
      if (row[0] == null) break;
      tempList.add(DataReading(
          date: row[0],
          time: row[1],
          rpm: row[2].toString(),
          temp: row[3].toString()));
      print("$row");
    }
    setState(() {
      tableDataArray = tempList;
    });
    print(tableDataArray.length);
  }

  void openFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result != null) {
      file = File(result.files.single.path);
      readExel();
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_mode == Mode.TEMP ? 'Temperature vs Time' : 'RPM vs Time'),
        actions: [
          FlatButton(
              onPressed: () {
                setState(() {
                  _mode = Mode.RPM;
                });
              },
              child: Text('RPM')),
          FlatButton(
              onPressed: () {
                setState(() {
                  _mode = Mode.TEMP;
                });
              },
              child: Text('TEMP')),
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                openFile();
              })
        ],
      ),
      body: Center(
        child: Container(
          child: file != null
              ? SfCartesianChart(
                  zoomPanBehavior: ZoomPanBehavior(
                      enablePinching: true, enablePanning: true),
                  primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Time')),
                  primaryYAxis: NumericAxis(
                      title:
                          AxisTitle(text: _mode == Mode.RPM ? 'RPM' : 'TEMP')),
                  series: <ChartSeries>[
                    LineSeries<DataReading, String>(
                        dataSource: tableDataArray,
                        xValueMapper: (DataReading data, _) => data.time,
                        yValueMapper: (DataReading data, _) => _mode == Mode.RPM
                            ? int.parse(data.rpm)
                            : int.parse(data.temp))
                  ],
                )
              : Container(
                  child: RaisedButton(
                    onPressed: () {
                      openFile();
                    },
                    child: Text('Open data file'),
                  ),
                ),
        ),
      ),
    );
  }
}
