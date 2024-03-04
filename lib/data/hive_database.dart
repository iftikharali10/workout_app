import 'package:hive_flutter/hive_flutter.dart';
import 'package:workout_app/datetime/date_time.dart';
import 'package:workout_app/models/excercise.dart';

import '../models/workout.dart';

class HiveDataBase {
  // reference our hive box
  final _mybox = Hive.box("workout_database");
  // check if there is already data stored , if not , record the start date
  bool previousDataExists() {
    if (_mybox.isEmpty) {
      print("Previous data doesn't exist");
      _mybox.put("START_DATE", todaysDateYYYYMMDD());
      return false;
    } else {
      print("previous data does exist");
      return true;
    }
  }

  // return start date as yyyymmdd
  String getStartDate() {
    return _mybox.get("START_DATE");
  }

  // write data
  void saveToDataBase(List<Workout> workouts) {
    // convert workout objects into list of strings so that we can save in hive
    final workoutList = convertObjectToWorkoutList(workouts);
    final excerciseList = convertObjectToExcerciseList(workouts);

    /*

    check if any excercise has been done 
    we will put 0 or 1 for each yyyymmdd date     

    */
    if (excerciseCompleted(workouts)) {
      _mybox.put("COMPLETION_STATUS_${todaysDateYYYYMMDD()}", 1);
    } else {
      _mybox.put("COMPLETION_STATUS_${todaysDateYYYYMMDD()}", 0);
    }

    // save into hive
    _mybox.put("WORKOUTS", workoutList);
    _mybox.put("EXCERCISES", excerciseList);
  }

  // read data and return list of workouts
  List<Workout> readFromDatabase() {
    List<Workout> mySavedWorkouts = [];

    List<String> workoutNames = _mybox.get("WORKOUTS");
    final excerciseDetails = _mybox.get("EXCERCISES");

    // create workout objects
    for (int i = 0; i < workoutNames.length; i++) {
      // each workout can have multiple excercises
      List<Excercise> excerciseInEachWorkout = [];

      for (int j = 0; j < excerciseDetails[i].length; j++) {
        // so add each excercise into list
        excerciseInEachWorkout.add(Excercise(
          name: excerciseDetails[i][j][0],
          weight: excerciseDetails[i][j][1],
          reps: excerciseDetails[i][j][2],
          sets: excerciseDetails[i][j][3],
          isCompleted: excerciseDetails[i][j][4] == 'true' ? true : false,
        ));
      }

      // create individual workout
      Workout workout = Workout(name: workoutNames[i], excercises: excerciseInEachWorkout);

      // add individual workout to overall list 
      mySavedWorkouts.add(workout);
    }
    return mySavedWorkouts;
  }
  // check if any excercise has been done
  bool excerciseCompleted(List<Workout> workouts) {
    // go through each workout
    for (var workout in workouts) {
      // go through each excercise in workout
      for (var excercise in workout.excercises) {
        if (excercise.isCompleted) {
          return true;
        }
      }
    }
    return false;
  }

  // return completion status of a given yyyymmdd
  int getCompletedStatus(String yyyymmdd) {
    // returns 0 or 1 , if null then return 0 
    int completionStatus = _mybox.get("COMPLETION_STATUS$yyyymmdd") ?? 0;
    return completionStatus;
  }
}

// converts workout objects into a list
List<String> convertObjectToWorkoutList(List<Workout> workouts) {
  List<String> workoutList = [
    // e.g [upperbody , lowerbody]
  ];

  for (int i = 0; i < workouts.length; i++) {
    // in each workout , add time , followed by the lists of excercises
    workoutList.add(workouts[i].name);
  }
  return workoutList;
}

// converts the excercise in a workout object into a list of strings
List<List<List<String>>> convertObjectToExcerciseList(List<Workout> workouts) {
  List<List<List<String>>> excerciseList = [
    /*

  [
  UpperBody
  [ [Biceps, 10kg , 10reps ,3 sets], [triceps, 20kg, 10reps, 3 sets ] ],

  LowerBody 
    [ [Squats, 25kg , 10reps ,3 sets], [Legraise, 30kg, 10reps, 3 sets ], [calf, 10kg , 10reps, 3 sets] ],

  ]

  */
  ];

  // go through each workout
  for (int i = 0; i < workouts.length; i++) {
    // get excercises from each workout
    List<Excercise> excercisesInWorkout = workouts[i].excercises;

    List<List<String>> individualWorkout = [
      // Upper Body
      // [ [Biceps, 10kg, 10 reps, 3 sets], [triceps, 20kg, 10reps , 3 sets ] ],
    ];

    // go through each excercise in workout
    for (int j = 0; j < excercisesInWorkout.length; j++) {
      List<String> individualExcercise = [
        // [biceps, 10kg, 10 reps , 3 sets]
      ];
      individualExcercise.addAll(
        [
          excercisesInWorkout[j].name,
          excercisesInWorkout[j].weight,
          excercisesInWorkout[j].reps,
          excercisesInWorkout[j].sets,
          excercisesInWorkout[j].isCompleted.toString(),
        ],
      );
      individualWorkout.add(individualExcercise);
    }
    excerciseList.add(individualWorkout);
  }
  return excerciseList;
}
