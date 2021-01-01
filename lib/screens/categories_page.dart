import 'package:flutter/material.dart';
import 'package:not_sepeti/models/category.dart';
import 'package:not_sepeti/models/note.dart';
import 'package:not_sepeti/utils/database_helper.dart';

class CategoriesPage extends StatefulWidget {
  CategoriesPage();

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  var _categories;
  DatabaseHelper _dbhelper;
  var newCategory;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _addCategoryFormKey = GlobalKey<FormState>();
  List<bool> _visibilityOfCategorizedNoteListTiles;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dbhelper = DatabaseHelper();
    _dbhelper.getCategoryList().then((value) {
      setState(() {
        _categories = value.toList();
      });
      _visibilityOfCategorizedNoteListTiles =
          List.generate(_categories.length, (index) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Kategori listesi"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              addCategoryDialog(context).then((value){
                if(value != null){
                  newCategory = value;
                  setState(() {
                    _categories.add(newCategory);
                  });
                }
              });

            },
          )
        ],
      ),
      body: _categories == null
          ? CircularProgressIndicator()
          : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return _categoryListTile(context, index);
              },
            ),
    );
  }

  Future<Category> addCategoryDialog(BuildContext context)async {
    /*kategori eklendiğinde çıkacak diyalog*/
    Category newCategory;
    await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(15),
            title: Text(
              "Kategory Ekle",
            ),
            children: [
              Form(
                key: _addCategoryFormKey,
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
                    newCategory = Category(categoryName: value);
                    _dbhelper.addCategory(newCategory);
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
                      _addCategoryFormKey.currentState.save();
                      _visibilityOfCategorizedNoteListTiles.add(false);
                      Navigator.pop(context, newCategory);
                    },
                  ),
                ],
              ),
            ],
          );
        });

      return Future.value(newCategory);
  }

  Widget _categoryListTile(BuildContext context, int index) {
    Category _category = _categories[index];
    return Dismissible(
      key: Key("sdfasdfasdfasdfadsf"+
          _category.categoryId.toString() + _category.categoryName.toString()),
      child: InkWell(
        onTap: () {
          setState(() {
            _visibilityOfCategorizedNoteListTiles[index] =
                !_visibilityOfCategorizedNoteListTiles[index];
          });
        },
        child: Stack(
          alignment: Alignment.centerLeft,
          overflow: Overflow.visible,
          children: [
            Column(
              key:
                  Key(_category.categoryName + _category.categoryId.toString()),
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                      color: Colors.yellow.shade100,
                      borderRadius: BorderRadius.circular(15)),
                  margin: EdgeInsets.only(top: 5, left: 5, right: 5),
                  child: Card(
                    margin: EdgeInsets.all(15),
                    elevation: 0,
                    color: Colors.yellow.shade100,
                    child: Text(
                      _category.categoryName,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Visibility(
                  //notlar kategoriye göre burada gösterilrecek
                  //categorylerin notları
                  visible: _visibilityOfCategorizedNoteListTiles[index],
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 200,
                    child: buildCategorizedNotesList(_category
                        .categoryId), //notları kategorize etme zinciri buradan başlıyor
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.arrow_back,
                  size: 15,
                ),
                Icon(
                  Icons.delete,
                  size: 15,
                ),
                SizedBox(
                  width: 5,
                ),
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
            _dbhelper.deleteCategory(_category);
            setState(() {
              _categories.removeAt(index);
            });
          },
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (drag) {
        print(drag);
        _dbhelper.deleteCategory(_category);
        setState(() {
          _categories.removeAt(index);
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Kategori silindi"),
          duration: Duration(seconds: 3),
        ));
      },
    );
  }

  buildCategorizedNotesList(int categoryId) {
    return FutureBuilder<List<Note>>(
      future: getCategorizedNoteList(categoryId),
      initialData: [],
      // ignore: missing_return
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          return CircularProgressIndicator();
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data.isEmpty) {
            return Text("Bu Kategori Boş");
          } else
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return buildNoteListTile(snapshot.data[index]);
              },
            );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LinearProgressIndicator(
            semanticsLabel: "Yükleniyor...",
          );
        }
      },
    );
  }

  Widget buildNoteListTile(Note note) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      decoration: BoxDecoration(
          color: Colors.yellow.shade100,
          borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.only(top: 5, left: 5, right: 5),
      child: Card(
        margin: EdgeInsets.all(15),
        elevation: 0,
        color: Colors.yellow.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.noteTittle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              note.noteContent,
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Note>> getCategorizedNoteList(int category_id) async {
    List<Note> _categorizedNoteList =
        await _dbhelper.getNoteList().then((value) {
      return value.where((element) {
        if (element.categoryId == category_id) {
          return true;
        } else
          return false;
      }).toList();
    });
    return _categorizedNoteList;
  }
}
