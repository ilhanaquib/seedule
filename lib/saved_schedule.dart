import 'package:flutter/material.dart';
import 'package:seedule/database/db_helper.dart';
import 'package:seedule/global.dart';
import 'package:seedule/schedule.dart';

class SavedScheduleList extends StatefulWidget {
  const SavedScheduleList({super.key});

  @override
  State<SavedScheduleList> createState() => _SavedScheduleListState();
}

class _SavedScheduleListState extends State<SavedScheduleList> {
  late Future<List<Map<String, dynamic>>> savedPlans;

  @override
  void initState() {
    super.initState();
    savedPlans = DBHelper().getPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved Plans',
          style: TextStyle(color: AppColors.background),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: savedPlans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No saved plans'));
          } else {
            final plans = snapshot.data!;
            return ListView.builder(
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return ListTile(
                  title: Text(plan['plant_name']),
                  subtitle: Text('Tap to view details'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await DBHelper().deletePlan(plan['id']);
                      setState(() {
                        savedPlans = DBHelper().getPlans();
                      });
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ScheduleScreen(
                              savedPlanJson: plan['plan_json'],
                            ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
