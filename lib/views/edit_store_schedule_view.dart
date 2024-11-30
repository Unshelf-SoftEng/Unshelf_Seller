import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/models/store_model.dart';
import 'package:unshelf_seller/viewmodels/store_schedule_viewmodel.dart';

class EditStoreSchedView extends StatelessWidget {
  final StoreModel storeDetails;

  EditStoreSchedView({required this.storeDetails});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoreScheduleViewModel(storeDetails),
      child: Consumer<StoreScheduleViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Edit Store Schedule'),
              backgroundColor: const Color(0xFF6A994E),
              foregroundColor: const Color(0xFFFFFFFF),
              titleTextStyle: TextStyle(
                  color: const Color(0xFFFFFFFF),
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Color(0xFF386641),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(4.0),
                child: Container(
                  color: Color(0xFFC8DD96),
                  height: 4.0,
                ),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          'Monday',
                          'Tuesday',
                          'Wednesday',
                          'Thursday',
                          'Friday',
                          'Saturday',
                          'Sunday'
                        ].map((day) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(day, style: TextStyle(fontSize: 18)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  viewModel.storeSchedule[day]!['open'] ==
                                          'Closed'
                                      ? const Text('Closed all day',
                                          style: TextStyle(color: Colors.red))
                                      : Text(
                                          'Open: ${viewModel.storeSchedule[day]!['open']} - ${viewModel.storeSchedule[day]!['close']}'),
                                  SizedBox(height: 8.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          final TimeOfDay? pickedTime =
                                              await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now(),
                                          );
                                          if (pickedTime != null) {
                                            viewModel.selectTime(
                                                day, 'open', pickedTime);
                                          }
                                        },
                                        child: Text('Set Opening Time'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          final TimeOfDay? pickedTime =
                                              await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now(),
                                          );
                                          if (pickedTime != null) {
                                            viewModel.selectTime(
                                                day, 'close', pickedTime);
                                          }
                                        },
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
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(const Color(0xFFA7C957)),
                        foregroundColor:
                            WidgetStatePropertyAll(const Color(0xFF386641)),
                      ),
                      onPressed: () async {
                        await viewModel.saveProfile(
                            context, storeDetails.userId);
                        Navigator.pop(context);
                      },
                      child: Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
