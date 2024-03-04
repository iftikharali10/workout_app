import 'package:flutter/material.dart';
import 'package:workout_app/data/hive_database.dart';
import 'package:workout_app/datetime/date_time.dart';
import 'package:workout_app/models/excercise.dart';

import '../models/workout.dart';

class WorkoutData extends ChangeNotifier {

  final db = HiveDataBase();
  /*

  WORKOUT DATA STRUCTURE 

  -- This overall list contains the different workout 
  -- Each workout has a name , and list of excercies

  */

  List<Workout> workoutList = [
    // default workout
    Workout(name: "Upper Body", excercises: [
      Excercise(
        name: "Bicep Curls",
        weight: "10",
        reps: "10",
        sets: "10",
      ),
    ]),

    Workout(name: "Lower Body", excercises: [
      Excercise(
        name: "Squats",
        weight: "10",
        reps: "10",
        sets: "10",
      ),
    ])
  ];

  // if there are already workouts already in the database , then get that workout list ,
  
  void initialzedWorkoutList () {
    if (db.previousDataExists()) {
      workoutList = db.readFromDatabase();
    // otherwise use default workout,    
    } else {
      db.saveToDataBase(workoutList);
    }
    // load heatMap
    loadHeatMap();
  }
  // get the list of workouts
  List<Workout> getWorkoutList() {
    return workoutList;
  }

  // get the length of given workout
  int numberOfExcercisesInWorkout(String workoutName) {
    Workout relevantWorkout = getRelevantWorkout(workoutName);

    return relevantWorkout.excercises.length;
  }

  // add a workout
  void addNewWorkout(String name) {
    // add a new workout with a blank list of excercises
    workoutList.add(Workout(name: name, excercises: []));
    notifyListeners();
    // save to database 
    db.saveToDataBase(workoutList);
  }

  // add an excercise to workout
  void addExcercise(
    String workoutName,
    String excerciseName,
    String weight,
    String reps,
    String sets,
  ) {
    // find relevant workouts
    Workout relevantWorkout = getRelevantWorkout(workoutName);

    relevantWorkout.excercises.add(
      Excercise(
        name: excerciseName,
        weight: weight,
        reps: reps,
        sets: sets,
      ),
    );
    notifyListeners();
    // save to database 
    db.saveToDataBase(workoutList);
  }

  // check off the excercise
  void checkOffExcercise(String workoutName, String excerciseName) {
    // find relevant excercise in that workout
    Excercise relevantExcercise = getRelevantExcercise(
      workoutName,
      excerciseName,
    );

    // check off boolean to show user completed the excercise
    relevantExcercise.isCompleted = !relevantExcercise.isCompleted;

    notifyListeners();
    // save to database 
    db.saveToDataBase(workoutList);
    // load heatMap
    loadHeatMap();
  }

  // return relevant workout objects , given a workout name
  Workout getRelevantWorkout(String workoutName) {
    Workout relevantWorkout =
        workoutList.firstWhere((workout) => workout.name == workoutName);

    return relevantWorkout;
  }

  // return relevant excercise object , given a workout name + excercise name
  Excercise getRelevantExcercise(String workoutName, String excerciseName) {
    // find relevant workout first
    Workout relevantWorkout = getRelevantWorkout(workoutName);
    // then find relevant excercise in that workout
    Excercise relevantExcercise = relevantWorkout.excercises
        .firstWhere((excercise) => excercise.name == excerciseName);

    return relevantExcercise;
  }

  // get start date 
  String getStartDate () {
    return db.getStartDate();
  }
  /*

  HEAT MAP 


  */

  Map<DateTime, int> heatMapDataSet = {};

  void loadHeatMap() {
    DateTime startDate = createDateTimeObject(getStartDate());

    // count number of days to load 
    int daysInBetween = DateTime.now().difference(startDate).inDays;

    // go from start date to today , and add each completion status to the dataset 
    // "COMPLETION_STATUS_yyyymmdd" will be the key in the database

    for (int i = 0; i < daysInBetween+1; i++) {
      String yyyymmdd = convertDateTimeToYYYYMMDD(startDate.add(Duration(days: i)));

      // completion status = 0 or 1
      int completionStatus = db.getCompletedStatus(yyyymmdd);

      // year  
      int year = startDate.add(Duration(days: i)).year;
      
      // month 
      int month = startDate.add(Duration(days: i)).month;
      
      // day 
      int day = startDate.add(Duration(days: i)).day;

      final percentForEachDay = <DateTime, int> {
        DateTime(year,month,day) :completionStatus
      };
      // add to the heat map dataset 
      heatMapDataSet.addEntries(percentForEachDay.entries);
    }
  }
}
