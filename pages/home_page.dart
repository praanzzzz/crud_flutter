import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_flutter/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //like import or create object of the firestore service.dart
  final FirestoreService firestoreService = FirestoreService();

  //text controller
  final TextEditingController textController = TextEditingController();

  //open dialog box
  void openNoteBox(String? docID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          content: TextField(
            controller: textController,
          ),
          actions: [
            //button to save
            ElevatedButton(
              onPressed: () {
                //add the note
                if (docID == null){
                  firestoreService.addNote(textController.text);
                }
                //update an existing note
                else{
                  firestoreService.updateNote(docID, textController.text);
                }
                //clear the note
                textController.clear();
                //close the dialog box
                Navigator.pop(context);
              },
              child: Text("Add"),
            )
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Gabijan Notes",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          titleSpacing: 00.0,
          centerTitle: true,
          toolbarHeight: 70.2,
          toolbarOpacity: 0.8,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                bottomLeft: Radius.circular(25)),
          ),
          elevation: 0.00,
          backgroundColor: Color.fromARGB(255, 0, 118, 215),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color.fromARGB(255, 0, 123, 224),
          // onPressed: openNoteBox,//from yt
          onPressed: () => openNoteBox(null), //corrected by gpt using null
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getNotesStream(),
          builder: (context, snapshot) {
            //if we have data, get all the docs
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;

              //display as a list
              return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                //get each individual doc
                DocumentSnapshot document = notesList[index];
                String docID = document.id;

                //get note from each doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                //display as a list Tile
                return ListTile(
                  title: Text(noteText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //update
                      IconButton(
                        onPressed: () => openNoteBox(docID),//check here from gpt
                        // onPressed: () => openNoteBox(docID: docID),//from yt
                        icon: Icon(Icons.edit),
                      ),
                      //delete
                      IconButton(
                        onPressed: () => firestoreService.deleteNote(docID),
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  )
                );
              });
            }
            //if there is not data, return nothing
            else{
              return Text('No notes...');
            }
          },
        ));
  }
}
