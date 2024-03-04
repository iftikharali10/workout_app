import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/components/excercise_tile.dart';
import 'package:workout_app/data/workout_data.dart';

class WorkoutPage extends StatefulWidget {
  final String workoutName;
  const WorkoutPage({super.key, required this.workoutName});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  // checkbox was tapped
  void onCheckBoxChanged(String workoutName, String excerciseName) {
    Provider.of<WorkoutData>(context, listen: false)
        .checkOffExcercise(workoutName, excerciseName);
  }

  // text controllers
  final excerciseNameController = TextEditingController();
  final weightController = TextEditingController();
  final repController = TextEditingController();
  final setController = TextEditingController();

  // create new excercise
  void createNewExcercise() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add a new excercise"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // excercise name
            TextField(
              controller: excerciseNameController,
            ),
            //weight
            TextField(
              controller: weightController,
            ),
            // reps
            TextField(
              controller: repController,
            ),
            // sets
            TextField(
              controller: setController,
            ),
          ],
        ),
        actions: [
          // save button
          MaterialButton(
            onPressed: save,
            child: Text("Save"),
          ),

          // cancel button
          MaterialButton(
            onPressed: cancel,
            child: Text("cancel"),
          ),
        ],
      ),
    );
  }

  // save workout
  void save() {
    // get excercise name from text controller
    String newExcerciseName = excerciseNameController.text;
    String weight = weightController.text;
    String reps = repController.text;
    String sets = setController.text;
    // add excercise to workoutdata
    Provider.of<WorkoutData>(context, listen: false).addExcercise(
      widget.workoutName,
      newExcerciseName,
      weight,
      reps,
      sets,
    );

    // pop dialogbox
    Navigator.pop(context);
    clear();
  }

  // cancel
  void cancel() {
    // pop dialogbox
    Navigator.pop(context);
    clear();
  }

  // clear controller
  void clear() {
    excerciseNameController.clear();
    weightController.clear();
    repController.clear();
    setController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: Text(widget.workoutName),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewExcercise,
          child: Icon(Icons.add),
        ),
        body: ListView.builder(
          itemCount: value.numberOfExcercisesInWorkout(widget.workoutName),
          itemBuilder: (context, index) => ExcerciseTile(
            excerciseName: value
                .getRelevantWorkout(widget.workoutName)
                .excercises[index]
                .name,
            weight: value
                .getRelevantWorkout(widget.workoutName)
                .excercises[index]
                .weight,
            reps: value
                .getRelevantWorkout(widget.workoutName)
                .excercises[index]
                .reps,
            sets: value
                .getRelevantWorkout(widget.workoutName)
                .excercises[index]
                .sets,
            isCompleted: value
                .getRelevantWorkout(widget.workoutName)
                .excercises[index]
                .isCompleted,
            onCheckBoxChanged: (val) => onCheckBoxChanged(
              widget.workoutName,
              value
                  .getRelevantWorkout(widget.workoutName)
                  .excercises[index]
                  .name,
            ),
          ),
        ),
      ),
    );
  }
}
