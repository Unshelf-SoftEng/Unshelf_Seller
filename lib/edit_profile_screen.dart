import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:unshelf_seller/models/store_model.dart';

class EditStoreDetailsScreen extends StatefulWidget {
  final StoreModel userProfile;

  EditStoreDetailsScreen({required this.userProfile});

  @override
  _EditStoreDetailsScreenState createState() => _EditStoreDetailsScreenState();
}

class _EditStoreDetailsScreenState extends State<EditStoreDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, Map<String, String>> _storeSchedule;
  final DateFormat _timeFormatter = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    _storeSchedule = widget.userProfile.storeSchedule ??
        {
          'Monday': {'open': 'Closed', 'close': 'Closed'},
          'Tuesday': {'open': 'Closed', 'close': 'Closed'},
          'Wednesday': {'open': 'Closed', 'close': 'Closed'},
          'Thursday': {'open': 'Closed', 'close': 'Closed'},
          'Friday': {'open': 'Closed', 'close': 'Closed'},
          'Saturday': {'open': 'Closed', 'close': 'Closed'},
          'Sunday': {'open': 'Closed', 'close': 'Closed'},
        };
  }

  void _selectTime(BuildContext context, String day, String type) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      final timeString = _timeFormatter.format(
        DateTime(2023, 1, 1, pickedTime.hour, pickedTime.minute),
      );
      setState(() {
        _storeSchedule[day]![type] = timeString;
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userProfile.userId)
          .update({
        'store_schedule': _storeSchedule,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: _storeSchedule.keys.map((day) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(day, style: TextStyle(fontSize: 18)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _storeSchedule[day]!['open'] == 'Closed'
                                ? Text('Closed all day',
                                    style: TextStyle(color: Colors.red))
                                : Text(
                                    'Open: ${_storeSchedule[day]!['open']} - ${_storeSchedule[day]!['close']}'),
                            SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () =>
                                      _selectTime(context, day, 'open'),
                                  child: Text('Set Opening Time'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      _selectTime(context, day, 'close'),
                                  child: Text('Set Closing Time'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
