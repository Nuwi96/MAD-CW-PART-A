import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'database_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> notes;
  List<Map<String, dynamic>> noteList;
  final List<int> colorCode = [900, 700, 500, 300, 100];
  TextEditingController editTitleController = TextEditingController();
  TextEditingController editNoteController = TextEditingController();
  TextEditingController editIDController = TextEditingController();


  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("TO DO LIST"),
          backgroundColor: Colors.indigo[900],
        ),
        body: SafeArea(
            child: Column(children: [
              Expanded(
                child: ListTileTheme(
                  contentPadding: EdgeInsets.all(15),
                  iconColor: Colors.white,
                  textColor: Colors.black54,
                  // tileColor: Colors.lightBlue[colorCode[index]],
                  style: ListTileStyle.list,
                  dense: true,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: notes?.length ?? 0,
                    itemBuilder: (_, index) =>
                        Card(
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            tileColor: Colors.lightBlue[colorCode[index]],
                            // title: Text(notes[index]['id']),
                            title: Text(notes[index]['title'] ?? '',
                                style: const TextStyle(color: Colors.white,
                                    fontSize: 18)),
                            subtitle: Text(notes[index]['note'] ?? '',
                                style: const TextStyle(color: Colors.white,
                                    fontSize: 15)),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () async {
                                      setData(notes[index]['id'].toString(),
                                          notes[index]['title'],
                                          notes[index]['note']);
                                      showForm(context);
                                    },
                                    icon: const Icon(Icons.edit)),
                                IconButton(
                                    onPressed: () async {
                                      DatabaseHelper.instance
                                          .delete(notes[index]['id']);
                                      await refresh();
                                    },
                                    icon: const Icon(Icons.delete)),
                              ],
                            ),
                          ),
                        ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: FloatingActionButton(
                    onPressed: () {
                      setData('', '', '');
                      showForm(context);
                    },
                    child: const Icon(Icons.add),
                    backgroundColor: Colors.blue,
                  ),
              )
            ])));
    // );
  }

  Future<void> showForm(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(
                      visible: false,
                      child: TextFormField(controller: editIDController),
                    ),
                    TextFormField(
                      controller: editTitleController,
                      validator: (value) {
                        return value.isNotEmpty ? null : "Invalid Filed";
                      },
                      decoration:
                      const InputDecoration(hintText: "Enter Title"),
                    ),
                    TextFormField(
                      controller: editNoteController,
                      maxLines: 6,
                      validator: (value) {
                        return value.isNotEmpty ? null : "Invalid Filed";
                      },
                      decoration:
                      const InputDecoration(hintText: "Enter Description"),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        if ('' == editIDController.text) {
                          await DatabaseHelper.instance.insert({
                            "title": editTitleController.text,
                            "note": editNoteController.text,
                          });
                          await refresh();
                        } else {
                          await DatabaseHelper.instance.update({
                            "id": int.parse(editIDController.text),
                            "title": editTitleController.text,
                            "note": editNoteController.text,
                          });
                          await refresh();
                        }
                        Navigator.of(context).pop();
                      }
                      await refresh();
                    },
                    child: Text("Save")),
                TextButton(
                    onPressed: () async {
                      await refresh();
                      Navigator.of(context).pop();
                    },
                    child: Text("Cancel"))
              ]);
        }).then((_) =>
        setState(() {
          getData();
        }));
  }

  getData() async {
    notes = await DatabaseHelper.instance.getAllNotes();
  }

  refresh() {
    getData();
    setState(() {});
  }

  setData(id, title, note) {
    if ('' != id) {
      editIDController.text = id;
      editTitleController.text = title;
      editNoteController.text = note;
    } else {
      editIDController.text = '';
      editTitleController.text = '';
      editNoteController.text = '';
    }
  }
}
