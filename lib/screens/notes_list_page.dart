import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:not_sepeti/models/category.dart';
import 'package:not_sepeti/models/note.dart';
import 'package:not_sepeti/screens/note_detail_page.dart';
import 'package:not_sepeti/utils/database_helper.dart';

import 'categories_page.dart';

class NotesListPage extends StatefulWidget {
  @override
  _NotesListPageState createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  DatabaseHelper dbhelper = DatabaseHelper();
  List<Note> noteList;
  final GlobalKey<FormState> _categoryFormKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Category> _categoryList;
  Category _desiredCategory;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbhelper.getNoteList().then((value) {
      setState(() {
        noteList = value;
      });
    });
    dbhelper.getCategoryList().then((value) {
      setState(() {
       _categoryList = value;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Not Defterim"),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: ListTile(
                    title: Text("Kategoriler"),
                    leading: Icon(Icons.category_outlined),
                    onTap: (){
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (c)=> CategoriesPage())
                      );
                    },
                  ),
                ),
              ] ;
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
              child: Icon(Icons.control_point_duplicate),
              tooltip: "Add Category",
              heroTag: "addCategory",
              mini: true,
              onPressed: () {
                addCategoryDialog(context);
              }),
          FloatingActionButton(
              heroTag: "addNote",
              child: Icon(Icons.add),
              tooltip: "Add Note",
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NoteDetailPage("Yeni Not")))
                    .then((value) {
                  if (value != null) {
                    dbhelper.addNote(value);
                    setState(() {
                      noteList.insert(0, value);
                    });
                  } else
                    print("vazgeçildi");
                });
              }),
        ],
      ),
      body: noteList == null
          ? Center(
        child: Text(
          "Not almaya hemen başla...",
          style: TextStyle(fontSize: 36),
        ),
      )
          : ListView.builder(
        itemCount: noteList.length,
        itemBuilder: (context, int i) {
          return buildNoteListTile(context, i);
        },
      ),
    );
  }

  Widget buildNoteListTile(BuildContext context, int index) {
    Note note = noteList[index];
    return Dismissible(
      key: Key(note.noteDate.toString() + note.noteId.toString()),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      NoteDetailPage(
                        note.noteTittle,
                        defaultNote: note,
                      ))).then((value) async {
            if (value != null) {
              setState(() {
                noteList[index] = value;
                note = value;
                //güncelleme sayfasından dönerken mevcut note'a dönen notu atadık ki değişiklik anlık olarak sayfaya yansısın.
              });
              await dbhelper.updateNote(
                  value); //gelen güncellenmiş notu database'de güncelledik
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text("Not Güncellendi"),
              ));
            }
          });
        },
        child: Stack(
          alignment: Alignment.centerLeft,
          overflow: Overflow.visible,
          children: [
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width - 40,
              decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(15)
              ),
              margin: EdgeInsets.only(top: 5, left: 5, right: 5),
              child: Card(
                margin: EdgeInsets.all(15),
                elevation: 0,
                color: Colors.yellow.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(note.noteTittle, style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),),
                    Text(
                      note.noteContent,
                      strutStyle: StrutStyle.disabled,
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.arrow_back, size: 15,),
                Icon(Icons.delete, size: 15,), SizedBox(width: 5,),
              ],
            )
          ],
        ),
      ),
      background: Container(
        alignment: Alignment.centerRight,
        color: Colors.red.shade600,
        child: IconButton(
          icon: Icon(Icons.delete_sweep_sharp),
          onPressed: () {
            dbhelper.deleteNote(note);
            setState(() {
              noteList.removeAt(index);
            });
          },
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (drag) {
        print(drag);
        dbhelper.deleteNote(note);
        setState(() {
          noteList.removeAt(index);
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Not silindi"),
          duration: Duration(seconds: 3),
        ));
      },
    );
  }

  void addCategoryDialog(BuildContext context) {
    /*kategori eklendiğinde çıkacak diyalog*/
    showDialog(
        context: context,
        builder: (context) {
          return Hero(
            tag: "addCategory",
            child: SimpleDialog(
              contentPadding: EdgeInsets.all(15),
              title: Text(
                "Kategory Ekle",
              ),
              children: [
                Form(
                  key: _categoryFormKey,
                  child: TextFormField(
                    autocorrect: true,
                    maxLength: 15,
                    maxLines: 1,
                    decoration: InputDecoration(
                      labelText: "Kategori ekleyin",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    onSaved: (value) {
                      dbhelper.addCategory(Category(categoryName: value));
                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text("Kategori eklendi : $value"),
                      ));
                    },
                  ),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceAround,
                  children: [
                    RaisedButton(
                      child: Text(
                        "İptal",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      color: Colors.red.shade400,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    RaisedButton(
                      child: Text(
                        "Ekle",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      color: Colors.yellowAccent,
                      onPressed: () {
                        _categoryFormKey.currentState.save();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

}
