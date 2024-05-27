import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_flutter/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //like import or create object of the firestore service.dart
  final FirestoreService firestoreService = FirestoreService();

  //text controller
  final TextEditingController textController = TextEditingController();

  //open dialog box
  void openNoteBox(String? docID, {String? currentNote}) {
    // If docID is not null, set the textController's text to the current note text
    if (currentNote != null) {
      textController.text = currentNote;
    }

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
                if (docID == null) {
                  firestoreService.addNote(textController.text);
                }
                //update an existing note
                else {
                  firestoreService.updateNote(docID, textController.text);
                }
                //clear the note
                textController.clear();
                //close the dialog box
                Navigator.pop(context);
              },
              child: const Text("Add"),
            )
          ]),
    ).then((_) {
      // Clear the text controller after the dialog is closed
      textController.clear();
    });
  }

  // function to show confirmation dialog before deleting a note
  void confirmDelete(String docID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          // Button to cancel the deletion
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          // Button to confirm the deletion
          TextButton(
            onPressed: () {
              firestoreService.deleteNote(docID);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
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
          backgroundColor: const Color.fromARGB(255, 0, 118, 215),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 0, 123, 224),
          // onPressed: openNoteBox,//from yt
          onPressed: () => openNoteBox(null), //corrected by gpt using null
          child: const Icon(
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

              // If the notesList is empty, show a centered "No notes" message
              if (notesList.isEmpty) {
                return const Center(
                  child: Text(
                    'No notes...',
                    style: TextStyle(fontSize: 20),
                  ),
                );
              }

              return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  // Get each individual doc
                  DocumentSnapshot document = notesList[index];
                  String docID = document.id;

                  // Get note from each doc
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String noteText = data['note'];

                  // Display as a ListTile within a gray Container

                  return Column(
                    children: [
                      const SizedBox(
                          height: 10.0), 
                      Container(
                        color: Colors
                            .grey[300], 
                        margin: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 8.0), 
                        child: ListTile(
                          title: Text(noteText),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Update
                              IconButton(
                                onPressed: () => openNoteBox(docID,
                                    currentNote:
                                        noteText), // Pass current note text
                                icon: const Icon(Icons.edit),
                              ),
                              // Delete
                              IconButton(
                                onPressed: () => confirmDelete(
                                    docID), // Changed to confirmDelete function
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }
            //if there is an error or no data, return nothing
            else {
              return const Center(
                child: Text(
                  'No notes...',
                  style: TextStyle(fontSize: 20),
                ),
              );
            }
          },
        ));
  }
}
