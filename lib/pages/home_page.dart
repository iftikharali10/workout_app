import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/components/heat_map.dart';
import 'package:workout_app/data/workout_data.dart';

import 'workout_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Provider.of<WorkoutData>(context,listen: false).initialzedWorkoutList();
  }

  // text controllers 
  final newWorkoutNameController = TextEditingController();


  // create a new workout 
  void createNewWorkout () {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("Create a new workout"),
      content: TextField(
        controller: newWorkoutNameController,
      ),
      actions: [
        // save button 
        MaterialButton(onPressed: save,
        child: Text("Save"),),

        // cancel button
        MaterialButton(onPressed: cancel,
        child: Text("cancel"),),
      ],
    ),);
  }

  // go to workout page 
  void goToWorkoutPage (String workoutName) { 
    Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutPage(
      workoutName: workoutName,
    ),),);

  }

  // save workout 
  void save () {
    // get workout name from text controller 
    String newWorkoutName = newWorkoutNameController.text;
    // add workout to workoutdata list 
    Provider.of<WorkoutData>(context, listen: false).addNewWorkout(newWorkoutName);

    // pop dialogbox 
    Navigator.pop(context);
    clear();
  } 

  // cancel 
  void cancel () {
    // pop dialogbox 
    Navigator.pop(context);
    clear();
  }

  // clear controller 
  void clear () {
    newWorkoutNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text("Workout Tracker"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewWorkout,
          child: const Icon(Icons.add),
        ),
        body: ListView(
          children: [
            // Heatmap
          MyHeatMap(datasets: value.heatMapDataSet, startDateYYYYMMDD: value.getStartDate()),
            // WORKOUT LIST
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
          itemCount: value.getWorkoutList().length,
          itemBuilder: (context, index) => ListTile(
            title: Text(value.getWorkoutList()[index].name),
            trailing: IconButton(icon: Icon(Icons.arrow_forward_ios),
            onPressed: () => goToWorkoutPage(value.getWorkoutList()[index].name),),
          ),
        ),
          ],
        )
      ),
    );
  }
}

  
