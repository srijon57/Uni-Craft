import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class TimePlannerPage extends StatefulWidget {
  @override
  _TimePlannerPageState createState() => _TimePlannerPageState();
}

class _TimePlannerPageState extends State<TimePlannerPage> {
  List<Meeting> meetings = [];
  Meeting? selectedMeeting;
  Color selectedColor =
      const Color.fromARGB(255, 243, 193, 189); // Default color

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Time Planner"),
        backgroundColor: Colors.black.withOpacity(0.35),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _showAddMeetingDialog(context);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Add Meeting"),
                SizedBox(width: 10),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedMeeting = null;
                });
              },
              child: Column(
                children: [
                  Expanded(
                    child: SfCalendar(
                      view: CalendarView.week,
                      dataSource: MeetingDataSource(meetings),
                      onTap: (CalendarTapDetails details) {
                        if (details.targetElement ==
                            CalendarElement.appointment) {
                          setState(() {
                            selectedMeeting = details.appointments![0];
                          });
                        }
                      },
                    ),
                  ),
                  if (selectedMeeting != null) ...[
                    SizedBox(height: 10),
                    Container(
                      color: Colors.grey[200],
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Event Details'),
                          Text('Event Name: ${selectedMeeting!.eventName}'),
                          Text('Start Time: ${selectedMeeting!.from}'),
                          Text('End Time: ${selectedMeeting!.to}'),
                          // Add more details as needed
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddMeetingDialog(BuildContext context) async {
    TextEditingController eventNameController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedStartTime = TimeOfDay.now();
    TimeOfDay selectedEndTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Meeting'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: eventNameController,
                decoration: InputDecoration(labelText: 'Event Name'),
              ),
              SizedBox(height: 10),
              Text('Select Date:'),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != selectedDate) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child: Text(
                  'Choose Date',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 10),
              Text('Select Time Range:'),
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? pickedStartTime = await showTimePicker(
                    context: context,
                    initialTime: selectedStartTime,
                  );
                  if (pickedStartTime != null &&
                      pickedStartTime != selectedStartTime) {
                    setState(() {
                      selectedStartTime = pickedStartTime;
                    });
                  }
                },
                child: Text(
                  'Choose Start Time',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? pickedEndTime = await showTimePicker(
                    context: context,
                    initialTime: selectedEndTime,
                  );
                  if (pickedEndTime != null &&
                      pickedEndTime != selectedEndTime) {
                    setState(() {
                      selectedEndTime = pickedEndTime;
                    });
                  }
                },
                child: Text(
                  'Choose End Time',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 10),
              Text('Select Color:'),
              ElevatedButton(
                onPressed: () {
                  _openColorPicker(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: selectedColor,
                ),
                child: Text('Choose Color'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  meetings.add(
                    Meeting(
                      eventNameController.text,
                      DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedStartTime.hour,
                        selectedStartTime.minute,
                      ),
                      DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedEndTime.hour,
                        selectedEndTime.minute,
                      ),
                      selectedColor,
                      false,
                    ),
                  );
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openColorPicker(BuildContext context) async {
    Color pickerColor = selectedColor;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  selectedColor = pickerColor;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}