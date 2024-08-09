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
            ),
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: viewModel.storeSchedule.keys.map((day) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(day, style: TextStyle(fontSize: 18)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  viewModel.storeSchedule[day]!['open'] ==
                                          'Closed'
                                      ? Text('Closed all day',
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
