import 'package:flutter/material.dart';
import 'package:not_sepeti/models/category.dart';
import 'package:not_sepeti/models/note.dart';
import 'package:not_sepeti/utils/database_helper.dart';

class NoteDetailPage extends StatefulWidget {
  String noteTittle; // ekleme işlemi yapacaksak
  Note defaultNote; // güncelleme işlemi yapacaksak bu note gelecek

  NoteDetailPage(this.noteTittle, {this.defaultNote});

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  var _noteTittleInState;
  String _noteContent;
  final _formKey = GlobalKey<FormState>();
  final _tittleFormWidgetKey = GlobalKey<FormFieldState>();
  final _appbarKey = GlobalKey<RefreshIndicatorState>();
  static var priorityList = ["Düşük", "Orta", "Yüksek"];
  int _choosenPriority;
  DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Category> _categoryList = [];
  int _choosenCategoryId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _databaseHelper.getCategoryList().then((value) {
      setState(() {
        _categoryList = value;
      });
    });
    _noteTittleInState = widget.noteTittle;
    if (widget.defaultNote != null) {
      setState(() {
        _noteTittleInState = widget.defaultNote.noteTittle;
        _choosenCategoryId = widget.defaultNote.categoryId;
        _choosenPriority = widget.defaultNote.notePriority;
        _noteContent = widget.defaultNote.noteContent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.deepOrange,
          textTheme: TextTheme(
              title: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          )),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        scaffoldBackgroundColor: Colors.blueGrey.shade200,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_noteTittleInState),
          key: _appbarKey,
        ),
        body: _categoryList == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Container(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildCategoriesFormWidget(),
                        buildPriorityFormWidget(),
                        buildTittleFormWidget(),
                        buildContentFormWidget(),
                        buildFormButtons(),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 24,
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  buildCategoriesFormWidget() {
    return Center(
      child: Container(
        //tüm kategori widget'ını tutan container
        margin: EdgeInsets.all(6),
        child: Row(
          children: [
            Text(
              "Kategori : ",
              style: TextStyle(fontSize: 16),
            ),
            Expanded(
              child: Container(
                //DropDownButton'ı tutan container
                alignment: Alignment.center,
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.redAccent,
                    ),
                    borderRadius: BorderRadius.circular(5)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    focusColor: Colors.red,
                    items: buildCategoryDropdownItems(),
                    dropdownColor: Colors.black,
                    hint: Text("Kategori seçiniz"),
                    focusNode: FocusNode(
                        canRequestFocus: true,
                        debugLabel: "seçildi",
                        descendantsAreFocusable: true),
                    value: _choosenCategoryId,
                    onChanged: (value) {
                      setState(() {
                        _choosenCategoryId = value;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem> buildCategoryDropdownItems() {
    return _categoryList
        .map((category) => DropdownMenuItem(
              child: Text(
                category.categoryName,
                style: TextStyle(fontSize: 16, color: Colors.deepOrange),
              ),
              value: category.categoryId,
            ))
        .toList();
  }

  buildPriorityFormWidget() {
    return Center(
      child: Container(
        //tüm kategori widget'ını tutan container
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 6),
        child: Row(
          children: [
            Text(
              "Öncelik : ",
              style: TextStyle(fontSize: 16),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.deepOrange,
                    ),
                    borderRadius: BorderRadius.circular(5)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    focusColor: Colors.red,
                    dropdownColor: Colors.black,
                    items: priorityList.map((priority) {
                      return DropdownMenuItem<int>(
                        child: Text(
                          priority,
                          style: TextStyle(color: Colors.deepOrange),
                        ),
                        value: priorityList.indexOf(priority),
                      );
                    }).toList(),
                    hint: Text("Bu notun önceliği"),
                    value: _choosenPriority,
                    onChanged: (value) {
                      setState(() {
                        _choosenPriority =
                            value; //integer olarak State içerisinde tutuluyor
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildTittleFormWidget() {
    return Theme(
      data: ThemeData(primarySwatch: Colors.deepOrange),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: TextFormField(
          key: _tittleFormWidgetKey,
          initialValue: widget.defaultNote == null ? null : _noteTittleInState,
          decoration: InputDecoration(
            labelText: "Notunuzun başlığı : ",
            border: UnderlineInputBorder(),
            hintText: "Başlık giriniz",
          ),
          onSaved: (value) {
            _noteTittleInState = value;
          },
        ),
      ),
    );
  }

  buildContentFormWidget() {
    return Theme(
      data: ThemeData(primarySwatch: Colors.deepOrange),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: TextFormField(
          smartQuotesType: SmartQuotesType.enabled,
          maxLines: 20,
          minLines: 20,
          initialValue: _noteContent,
          decoration: InputDecoration(
            labelText: "Notunuz",
            border: OutlineInputBorder(),
            hintText: "Notunuzu giriniz",
            alignLabelWithHint: true,
          ),
          onSaved: (value) {
            _noteContent = value;
          },
        ),
      ),
    );
  }

  buildFormButtons() {
    return ButtonBar(
      alignment: MainAxisAlignment.spaceEvenly,
      children: [
        RaisedButton(
          child: Text("Vazgeç", style: TextStyle(fontSize: 24)),
          padding: EdgeInsets.all(10),
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.blueGrey.shade400,
          textColor: Colors.white,
        ),
        RaisedButton(
          child: Text("Kaydet", style: TextStyle(fontSize: 24)),
          padding: EdgeInsets.all(10),
          onPressed: () {
            _formKey.currentState.save();
            Note note = widget.defaultNote != null
                ? Note.withId(
                    noteId: widget.defaultNote.noteId,
                    categoryId: _choosenCategoryId,
                    noteTittle: _noteTittleInState,
                    noteContent: _noteContent,
                    notePriority: _choosenPriority,
                    noteDate: DateTime.now())
                : Note(
                    categoryId: _choosenCategoryId,
                    noteTittle: _noteTittleInState,
                    noteContent: _noteContent,
                    notePriority: _choosenPriority,
                    noteDate: DateTime.now());
            Navigator.of(context).pop(note);
          },
          color: Colors.deepOrange,
          textColor: Colors.black,
        ),
      ],
    );
  }
}
