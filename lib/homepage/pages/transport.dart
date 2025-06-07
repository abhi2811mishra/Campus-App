// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';



class ScheduleTabs extends StatefulWidget {
  @override
  _ScheduleTabsState createState() => _ScheduleTabsState();
}

class _ScheduleTabsState extends State<ScheduleTabs> with SingleTickerProviderStateMixin {
  Uint8List? weekdaysImage;
  Uint8List? weekendsImage;

  Future<void> pickImage(bool isWeekday) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        if (isWeekday) {
          weekdaysImage = result.files.single.bytes;
        } else {
          weekendsImage = result.files.single.bytes;
        }
      });
    }
  }

  Widget buildImage(Uint8List? customImage, String assetPath) {
    return InteractiveViewer(
      maxScale: 5.0,
      child: customImage != null
          ? Image.memory(customImage)
          : Image.asset(assetPath),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Transport Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green,
          bottom: TabBar(
  tabs: [
    Tab(
      text: "Weekdays(Mon-Fri)",
      icon: IconButton(
        icon: Icon(Icons.upload_file, color: Colors.white),
        onPressed: () => pickImage(true),
      ),
    ),
    Tab(
      text: "Weekends(Sat-Sun & Holidays)",
      icon: IconButton(
        icon: Icon(Icons.upload_file, color: Colors.white),
        onPressed: () => pickImage(false),
      ),
    ),
  ],
),

          
        ),
        body: TabBarView(
          children: [
            buildImage(weekdaysImage, 'assets/images/image2.jpg'),
            buildImage(weekendsImage, 'assets/images/image3.jpg'),
          ],
        ),
      ),
    );
  }
}
