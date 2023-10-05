import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todo_firebasedb/screens/add_task.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String uid = '';

  @override
  void initState() {
    getuid();
    super.initState();
  }

  getuid() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      uid = user!.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO'),
        actions: [
          IconButton(onPressed: () async {
            await FirebaseAuth.instance.signOut();
          }, icon: const Icon(Icons.logout)),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery
              .of(context)
              .size
              .height,
          width: MediaQuery
              .of(context)
              .size
              .width,
          color: Colors.deepPurple.shade100,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('tasks').doc(uid)
                .collection('myTasks')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                final docs = snapshot.data?.docs;
                return ListView.builder(
                  itemCount: docs?.length,
                  itemBuilder: (context, index) {
                    var timestamp = docs?[index]['timestamp'];
                      DateTime parsedDateTime = DateFormat(
                          "yyyy-MM-dd HH:mm:ss")
                          .parse((docs?[index]['timestamp']));

                    return
                      //  message: "${docs![index]['description']}\n"+docs[index]['time'],
                      InkWell(
                        onTap: () {

                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: 10, right: 5, left: 5),
                          height: 70,
                          decoration: BoxDecoration(
                            //  color:  const Color(0x1F012AFF),
                              color: Colors.deepPurple.shade300,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(left: 20),
                                    child: Text(docs?[index]['title'],
                                      style: GoogleFonts.roboto(
                                          fontSize: 18, color: Colors.white),),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 20),
                                    child: Text( timestamp != null?
                                        DateFormat('dd-MM-yyy   hh:mm').format(
                                            parsedDateTime) : "",
                                        style: GoogleFonts.roboto(
                                            fontSize: 12, color: Colors.white) ,),
                                  )
                                ],),
                              IconButton(
                                icon: Icon(
                                  Icons.delete, color: Colors.red.shade900,),
                                onPressed: () async {
                                  await FirebaseFirestore.instance.collection(
                                      'tasks').doc(uid)
                                      .collection('myTasks')
                                      .doc(docs?[index]['time'])
                                      .delete();
                                },
                              )
                            ],
                          ),
                        ),
                      );
                  },
                );
              }
            },),
        ),
      ),

      floatingActionButton: InkResponse(
        child: FloatingActionButton(
          backgroundColor: Theme
              .of(context)
              .primaryColor,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddTask()));
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
