class Note {
  Note({
    this.categoryId,
    this.noteTittle,
    this.noteContent,
    this.noteDate,
    this.notePriority,
  });
  Note.withId({
    this.noteId,
    this.categoryId,
    this.categoryName,
    this.noteTittle,
    this.noteContent,
    this.noteDate,
    this.notePriority,
  });

  int noteId;
  int categoryId;
  String categoryName;
  String noteTittle;
  String noteContent;
  DateTime noteDate;
  int notePriority;

  factory Note.fromMap(Map<String, dynamic> json) => Note.withId(
    noteId: json["note_id"] == null ? null : json["note_id"],
    categoryId: json["cathegory_id"] == null ? null : json["cathegory_id"],
    categoryName: json["category_name"] == null ? null : json["category_name"],
    noteTittle: json["note_tittle"] == null ? null : json["note_tittle"],
    noteContent: json["note_content"] == null ? null : json["note_content"],
    noteDate: json["note_date"] == null ? null : DateTime.parse(json["note_date"]),
    notePriority: json["note_priority"] == null ? null : json["note_priority"],
  );

  Map<String, dynamic> toMap() => {
    "note_id" : noteId == null ? null : noteId,
    "cathegory_id": categoryId == null ? null : categoryId,
    "note_tittle": noteTittle == null ? null : noteTittle,
    "note_content": noteContent == null ? null : noteContent,
    "note_date": noteDate == null ? null : noteDate.toString(),
    "note_priority": notePriority == null ? null : notePriority,
  };

  @override
  String toString() {
    return 'Note{noteId: $noteId, cathegoryId: $categoryId, noteTittle: $noteTittle, noteContent: $noteContent, noteDate: $noteDate, notePriority: $notePriority}';
  }
}
