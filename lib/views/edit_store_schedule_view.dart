import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/models/store_model.dart';
import 'package:unshelf_seller/viewmodels/store_schedule_viewmodel.dart';

class EditStoreScheduleView extends StatelessWidget {
  final StoreModel storeDetails;

  EditStoreScheduleView({required this.storeDetails});

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
                fontWeight: FontWeight.bold,
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Color(0xFF386641)),
                onPressed: () => Navigator.pop(context),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(4.0),
                child: Container(color: Color(0xFFC8DD96), height: 4.0),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: viewModel.storeSchedule.keys.map((day) {
                        bool isActive =
                            viewModel.storeSchedule[day]!['isOpen'] == 'true';
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(day,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    Switch(
                                      value: isActive,
                                      activeColor: const Color(0xFF6A994E),
                                      onChanged: (value) =>
                                          viewModel.toggleDay(day),
                                    ),
                                  ],
                                ),
                                if (isActive) ...[
                                  SizedBox(height: 8.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _TimePickerButton(
                                        label: 'Opening Time',
                                        time: viewModel
                                            .storeSchedule[day]!['open']!,
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
                                      ),
                                      _TimePickerButton(
                                        label: 'Closing Time',
                                        time: viewModel
                                            .storeSchedule[day]!['close']!,
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
                                      ),
                                    ],
                                  ),
                                ] else
                                  const Text(
                                    'Closed all day',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 14),
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
                      await viewModel.saveProfile(context, storeDetails.userId);
                      // Do not call Navigator.pop(context) here.
                    },
                    child: Text('Save Changes'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimePickerButton extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onPressed;

  _TimePickerButton(
      {required this.label, required this.time, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        SizedBox(height: 4.0),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A994E),
            foregroundColor: Colors.white,
          ),
          child: Text(time.isEmpty ? 'Set Time' : time),
        ),
      ],
    );
  }
}
