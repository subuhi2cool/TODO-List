import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'home.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool focusDesc = false;
  //------------------------------------------------------------------------
  addTaskToFirebase() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;
      var time = DateTime.now();
      // Reference to the Firestore collection for user tasks
      CollectionReference userTasksCollection = FirebaseFirestore.instance
          .collection('tasks')
          .doc(uid)
          .collection('myTasks');
      try {
        await userTasksCollection.doc(time.toString()).set({
          'title': titleController.text,
          'description': descriptionController.text,
          'time': time.toString(),
          'timestamp': _selectedDateTime.toString(),
        });
        Fluttertoast.showToast(msg: 'Task Added', backgroundColor: Colors.deepPurple, textColor: Colors.white);
      } catch (e) {
        Fluttertoast.showToast(msg: 'Something went wrong!!', backgroundColor: Colors.deepPurple, textColor: Colors.white);
        Fluttertoast.showToast(msg: 'Error adding task: $e',backgroundColor: Colors.deepPurple, textColor: Colors.white);
      }
    } else {
      Fluttertoast.showToast(msg: 'User is not logged in',backgroundColor: Colors.deepPurple, textColor: Colors.white);
    }
  }

  Future<void> _presentDatePicker() async {

    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    ).then((pickedDate) async {
      if (pickedDate == null) {
        return;
      }
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );
      if (pickedTime != null && pickedTime != _selectedTime) {
        _selectedTime = pickedTime;
      }
      setState(() {
        _selectedDateTime = pickedDate;
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          pickedTime!.hour,
          pickedTime.minute,
        );
        focusDesc=false;
        FocusScope.of(context).unfocus();
      });
    });
  }

   //------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Task'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: Image(
                  image: const AssetImage("assets/images/img2.jpg"),
                  height: MediaQuery.of(context).size.height * 0.3,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                autofocus: true,
                showCursor: true,
                controller: titleController,
                decoration: const InputDecoration(
                    labelText: 'Enter Title', border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: descriptionController,
                showCursor: focusDesc,
                decoration: const InputDecoration(
                    labelText: 'Enter Description',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Date: ${DateFormat.yMd().add_jm().format(_selectedDateTime)}',style: GoogleFonts.roboto(fontSize: 16),
                  ),
                  TextButton(
                    onPressed:_presentDatePicker,
                    child: const Text('Any other DateTime?'),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.all(5),
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text != "") {
                      addTaskToFirebase();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Home()));
                    } else {
                      FocusScope.of(context).unfocus();
                      Fluttertoast.showToast(msg: 'Enter some task.',backgroundColor: Colors.deepPurple, textColor: Colors.white );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Add Task',
                    style: GoogleFonts.roboto(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
