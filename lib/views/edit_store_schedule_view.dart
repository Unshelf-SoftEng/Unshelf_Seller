import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/components/custom_button.dart';
import 'package:unshelf_seller/models/store_model.dart';
import 'package:unshelf_seller/utils/colors.dart';
import 'package:unshelf_seller/viewmodels/store_schedule_viewmodel.dart';

class EditStoreScheduleView extends StatelessWidget {
  final StoreModel storeDetails;

  const EditStoreScheduleView({super.key, required this.storeDetails});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoreScheduleViewModel(storeDetails),
      child: Consumer<StoreScheduleViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: CustomAppBar(
                title: 'Edit Store Schedule',
                onBackPressed: () {
                  Navigator.pop(context);
                }),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: viewModel.storeSchedule.keys.map((day) {
                        bool isActive = viewModel.storeSchedule[day]!['isOpen'];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                                        style: const TextStyle(
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
                                  const SizedBox(height: 8.0),
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
                  const SizedBox(height: 20),
                  CustomButton(
                      text: 'Save Changes',
                      onPressed: () async {
                        await viewModel.saveProfile(
                            context, storeDetails.userId);
                        // Do not call Navigator.pop(context) here.
                      }),
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
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4.0),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.palmLeaf,
            foregroundColor: Colors.white,
          ),
          child: Text(time.isEmpty ? 'Set Time' : time),
        ),
      ],
    );
  }
}
