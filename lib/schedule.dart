import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:seedule/auth/secret.dart';
import 'package:seedule/global.dart';
import 'database/db_helper.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, this.plant, this.savedPlanJson});
  final String? plant;
  final String? savedPlanJson;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String? response;
  final _generativeModel = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: '$geminiKey',
  );
  List<dynamic> dailyPlan = [];
  List<Map<String, bool>> checklistState = [];

  @override
  void initState() {
    super.initState();
    if (widget.plant != null) {
      generateResponse();
    } else {
      generateChecklist();
    }
  }

  void generateResponse() async {
    final plant = widget.plant;
    final prompt =
        'You are a plant expert. First, guess as accurate as possible at what stage the plant is in. Stage refers to either seed or sapling or age of the plant. afterwards, create a plan/schedule/checklist that can be used by the user to follow daily in order to grow their plant. i want you to return the response in as json where each step is seperated by a comma. this is what i want the format to look like. these are the data i want. plant_stage,daily_plan[day,morning,afternoon,evening]. if some days have the same plan, its okay to group them into one such as day 6-10. i would also like an eta on when the plant will fully grow and how long the total plan is';

    final content = [
      Content.multi([TextPart(plant!), TextPart(prompt)]),
    ];

    try {
      final genResponse = await _generativeModel.generateContent(content);
      final raw = genResponse.text ?? '';

      String cleaned = raw.replaceAll(RegExp(r'```json|```'), '').trim();
      final Map<String, dynamic> data = jsonDecode(cleaned);

      setState(() {
        response = raw;
        dailyPlan = data['daily_plan'];
        checklistState = List.generate(dailyPlan.length, (_) {
          return {'morning': false, 'afternoon': false, 'evening': false};
        });
      });
    } catch (e) {
      setState(() {
        response = 'Failed to generate content: $e';
        dailyPlan = [];
      });
    }
  }

  void generateChecklist() {
    try {
      final raw = widget.savedPlanJson ?? '';

      String cleaned = raw.replaceAll(RegExp(r'```json|```'), '').trim();
      final Map<String, dynamic> data = jsonDecode(cleaned);

      setState(() {
        response = raw;
        dailyPlan = data['daily_plan'];
        checklistState = List.generate(dailyPlan.length, (_) {
          return {'morning': false, 'afternoon': false, 'evening': false};
        });
      });
    } catch (e) {
      setState(() {
        response = 'Failed to generate content: $e';
        dailyPlan = [];
      });
    }
  }

  void savePlan() async {
    if (response != null) {
      // Show a dialog to ask for the plan name
      String? planName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          TextEditingController controller = TextEditingController();
          return AlertDialog(
            title: Text('Enter Plan Name'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: 'Enter plan name'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, controller.text);
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );

      if (planName != null && planName.isNotEmpty) {
        try {
          await DBHelper().savePlan(planName, response!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Plan "$planName" saved successfully!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to save plan: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seedule', style: TextStyle(color: AppColors.background)),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          widget.plant != null
              ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: generateResponse,
                  child: Text('Retry Plan'),
                ),
              )
              : SizedBox(),
          widget.plant != null
              ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: savePlan,
                  child: Text('Save Plan'),
                ),
              )
              : SizedBox(),
          Expanded(
            child:
                dailyPlan.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      itemCount: dailyPlan.length,
                      itemBuilder: (context, index) {
                        final day = dailyPlan[index];
                        return Card(
                          margin: EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Day ${day['day']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                CheckboxListTile(
                                  title: Text(
                                    'Morning: ${day['morning']}',
                                    style: TextStyle(
                                      decoration:
                                          checklistState[index]['morning']!
                                              ? TextDecoration.lineThrough
                                              : null,
                                    ),
                                  ),
                                  value: checklistState[index]['morning'],
                                  onChanged: (val) {
                                    setState(() {
                                      checklistState[index]['morning'] = val!;
                                    });
                                  },
                                ),
                                CheckboxListTile(
                                  title: Text(
                                    'Afternoon: ${day['afternoon']}',
                                    style: TextStyle(
                                      decoration:
                                          checklistState[index]['afternoon']!
                                              ? TextDecoration.lineThrough
                                              : null,
                                    ),
                                  ),
                                  value: checklistState[index]['afternoon'],
                                  onChanged: (val) {
                                    setState(() {
                                      checklistState[index]['afternoon'] = val!;
                                    });
                                  },
                                ),
                                CheckboxListTile(
                                  title: Text(
                                    'Evening: ${day['evening']}',
                                    style: TextStyle(
                                      decoration:
                                          checklistState[index]['evening']!
                                              ? TextDecoration.lineThrough
                                              : null,
                                    ),
                                  ),
                                  value: checklistState[index]['evening'],
                                  onChanged: (val) {
                                    setState(() {
                                      checklistState[index]['evening'] = val!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
