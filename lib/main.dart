import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:wt/Notification/notifi_service.dart';
import 'package:wt/services/wake_device_plugin.dart';

// Define a constant for the task name
const task = 'firsttask';

/// This is the callback function that WorkManager will execute in the background.
/// The function must be a top-level or static function.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // Wake the device if it is asleep
    WakeDevicePlugin.wakeDevice();

    // Show a notification when the task runs
    NotificationService().showNotification(
      title: 'Sample title',
      body: 'It works!',
    );

    // Indicate that the task was successful
    return Future.value(true);
  });
}

void main() async {
  // Ensure that the Flutter framework is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the notification service
  await NotificationService().initNotification();

  // Initialize WorkManager with the callback function
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            TextButton(
              onPressed: () async {
                // Schedule the task at a specific time
                DateTime targetTime = DateTime.now().add(Duration(minutes: 1));
                await scheduleTaskAtSpecificTime(targetTime);
              },
              child: Text('Schedule task at specific time'),
            ),
          ],
        ),
      ),
    );
  }

  /// This function calculates the delay required to run the task at the target time.
  /// It then schedules the task using `Workmanager`.
  Future<void> scheduleTaskAtSpecificTime(DateTime targetTime) async {
    // Get the current time
    DateTime now = DateTime.now();

    // Calculate the difference between the target time and the current time
    Duration initialDelay = targetTime.difference(now);

    // If the target time is in the past, set the delay to zero (run the task immediately)
    if (initialDelay.isNegative) {
      initialDelay = Duration.zero;
    }

    // Generate a unique ID for the task
    var id = DateTime.now().millisecondsSinceEpoch.toString();

    // Register a one-off task to be executed after the calculated delay
    await Workmanager()
        .registerOneOffTask(id, task, initialDelay: initialDelay);

    // Log the task ID and confirmation message
    log('Task ID: $id');
    log('Task scheduled to run in: ${initialDelay.inMinutes} minutes');
  }
}



