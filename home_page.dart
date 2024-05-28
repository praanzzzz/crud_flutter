import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_flutter/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //objects or class instances and state variables
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  bool showGridView = false;
  String searchQuery = "";

  //function to fill the dialog box if a note is selected (for update) and has content
  void openNoteBox(String? docID, {String? currentNote}) {
    if (currentNote != null) {
      textController.text = currentNote;
    }

    //method from flutter to show dialog box
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                firestoreService.addNote(textController.text);
              } else {
                firestoreService.updateNote(docID, textController.text);
              }
              textController.clear();
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    ).then((_) {
      textController.clear();
    });
  }

  //function for dialog box confirm delete
  void confirmDelete(String docID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
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
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text(
            "Gabijan Notes",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        titleSpacing: 0.0,
        centerTitle: false,
        toolbarHeight: 70.2,
        toolbarOpacity: 0.8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
        elevation: 0.00,
        backgroundColor: const Color.fromARGB(255, 0, 118, 215),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showGridView = !showGridView; //list and grid view
              });
            },
            icon: Icon(
              showGridView ? Icons.view_list : Icons.grid_view,
              color: Colors.white,
              size: 30.0,
            ),
            padding: const EdgeInsets.only(right: 16.0),
          ),
        ],
      ),

      //add note FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 0, 123, 224),
        onPressed: () => openNoteBox(null),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              //search bar
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[300],
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              ),
              style: TextStyle(color: Colors.grey[900]),

              //passing values to the query from user search
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getNotesStream(),
              builder: (context, snapshot) {
                //logic for search filter
                if (snapshot.hasData) {
                  List<DocumentSnapshot> notesList = snapshot.data!.docs;
                  //if theres corresponding value
                  if (searchQuery.isNotEmpty) {
                    notesList = notesList.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final noteText = data['note'] as String;
                      return noteText
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase());
                    }).toList();
                  }
                  //if empty
                  if (notesList.isEmpty) {
                    return const Center(
                      child: Text(
                        'No notes...',
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }
                  //grid view
                  if (showGridView) {
                    // If in grid view mode, return a GridView builder
                    return GridView.builder(
                      itemCount: notesList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            2, // Adjust for desired number of columns
                        mainAxisSpacing: 10.0, // Spacing between rows
                        crossAxisSpacing: 10.0, // Spacing between columns
                      ),
                      itemBuilder: (context, index) {
                        // Retrieve data for each note
                        DocumentSnapshot document = notesList[index];
                        String docID = document.id;
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String noteText = data['note'];

                        // Return a container representing each note
                        return Container(
                          color: Colors
                              .white, // Set container background color to white
                          margin: const EdgeInsets.all(
                              10.0), // Add margin to the container
                          padding: const EdgeInsets.all(
                              8.0), // Add padding inside the container
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    noteText,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Edit button
                                  IconButton(
                                    onPressed: () => openNoteBox(docID,
                                        currentNote: noteText),
                                    icon: const Icon(Icons.edit),
                                  ),
                                  // Delete button
                                  IconButton(
                                    onPressed: () => confirmDelete(docID),
                                    icon: const Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                    // If in list view mode
                  } else {
                    // If not in grid view mode, return a ListView builder
                    return ListView.builder(
                      itemCount: notesList.length,
                      itemBuilder: (context, index) {
                        // Retrieve data for each note
                        DocumentSnapshot document = notesList[index];
                        String docID = document.id;
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String noteText = data['note'];

                        // Return a container representing each note
                        return Column(
                          children: [
                            const SizedBox(
                                height: 10.0), // Add spacing between notes
                            Container(
                              color: Colors
                                  .white, // Set container background color to white
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal:
                                      8.0), // Add margin around the container
                              child: ListTile(
                                title: Text(
                                    noteText), // Display note text in ListTile
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Edit button
                                    IconButton(
                                      onPressed: () => openNoteBox(docID,
                                          currentNote: noteText),
                                      icon: const Icon(Icons.edit),
                                    ),
                                    // Delete button
                                    IconButton(
                                      onPressed: () => confirmDelete(docID),
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
                  //if walay notes from database
                } else {
                  return const Center(
                    child: Text(
                      'No notes...',
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
