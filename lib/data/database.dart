import "package:path/path.dart";
import "package:sqflite/sqflite.dart";
import "../models/models.dart";

class AppDb {
  AppDb._();
  static final AppDb instance = AppDb._();
  Database? _db;

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final p = join(await getDatabasesPath(), "freelance_ops.db");
    return openDatabase(p, version: 1, onCreate: (d, v) async {
      await d.execute("CREATE TABLE leads(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,platform TEXT NOT NULL,niche TEXT NOT NULL,status TEXT NOT NULL,date_contacted TEXT NOT NULL,follow_up_date TEXT NOT NULL,notes TEXT NOT NULL)");
      await d.execute("CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT,title TEXT NOT NULL,category TEXT NOT NULL,date TEXT NOT NULL,completed INTEGER NOT NULL DEFAULT 0)");
      await d.execute("CREATE TABLE projects(id INTEGER PRIMARY KEY AUTOINCREMENT,lead_id INTEGER,client_name TEXT NOT NULL,project_title TEXT NOT NULL,deadline TEXT NOT NULL,status TEXT NOT NULL,revisions INTEGER NOT NULL DEFAULT 0)");
      await d.execute("CREATE TABLE payments(id INTEGER PRIMARY KEY AUTOINCREMENT,client TEXT NOT NULL,amount REAL NOT NULL,currency TEXT NOT NULL,date TEXT NOT NULL,platform TEXT NOT NULL)");
      await d.execute("CREATE TABLE library(id INTEGER PRIMARY KEY AUTOINCREMENT,title TEXT NOT NULL,section TEXT NOT NULL,content TEXT NOT NULL)");
      await d.execute("CREATE TABLE settings(key TEXT PRIMARY KEY,value TEXT NOT NULL)");
      await d.insert("settings", {"key":"dm_target", "value":"20"});
      await d.insert("settings", {"key":"income_goal", "value":"50000"});
      await d.insert("settings", {"key":"focus", "value":""});
    });
  }

  Future<List<Lead>> leads() async { final d = await db; final r = await d.query("leads", orderBy:"id DESC"); return r.map(Lead.fromMap).toList(); }
  Future<int> saveLead(Lead x) async { final d = await db; final m = x.toMap()..remove("id"); return d.insert("leads", m); }
  Future<int> updateLead(Lead x) async { final d = await db; final m = x.toMap()..remove("id"); return d.update("leads", m, where:"id=?", whereArgs:[x.id]); }
  Future<void> deleteLead(int id) async { final d = await db; await d.delete("leads", where:"id=?", whereArgs:[id]); }

  Future<List<Task>> tasks(String date) async { final d = await db; final r = await d.query("tasks", where:"date=?", whereArgs:[date], orderBy:"id"); return r.map(Task.fromMap).toList(); }
  Future<void> ensureTasks(String date) async {
    final d = await db;
    final existing = await d.query("tasks", where:"date=?", whereArgs:[date]);
    if (existing.isNotEmpty) return;
    final defaults = <List<String>>[["Send 20 outreach messages","Outreach"],["Edit client deliverables","Editing"],["Study BCA topic","Study"],["Work on course/product","Course Building"]];
    for (final t in defaults) { await d.insert("tasks", {"title":t[0],"category":t[1],"date":date,"completed":0}); }
  }
  Future<void> toggleTask(Task x) async { final d = await db; await d.update("tasks", {"completed":x.completed ? 0 : 1}, where:"id=?", whereArgs:[x.id]); }
  Future<int> streak(String today) async {
    int n = 0; DateTime date = DateTime.parse(today);
    while (true) {
      final key = date.toIso8601String().substring(0,10);
      final rows = await (await db).rawQuery("SELECT COUNT(*) total, COALESCE(SUM(completed),0) done FROM tasks WHERE date=?", [key]);
      final total = (rows.first["total"] as num?)?.toInt() ?? 0;
      final done = (rows.first["done"] as num?)?.toInt() ?? 0;
      if (total == 0 || done != total) break;
      n++; date = date.subtract(const Duration(days:1));
    }
    return n;
  }

  Future<List<Project>> projects() async { final d = await db; final r = await d.query("projects", orderBy:"deadline"); return r.map(Project.fromMap).toList(); }
  Future<int> saveProject(Project x) async { final d = await db; final m = x.toMap()..remove("id"); return d.insert("projects",m); }
  Future<void> deleteProject(int id) async { final d = await db; await d.delete("projects",where:"id=?",whereArgs:[id]); }
  Future<List<Payment>> payments() async { final d = await db; final r = await d.query("payments",orderBy:"date DESC,id DESC"); return r.map(Payment.fromMap).toList(); }
  Future<int> savePayment(Payment x) async { final d = await db; final m = x.toMap()..remove("id"); return d.insert("payments",m); }
  Future<void> deletePayment(int id) async { final d = await db; await d.delete("payments",where:"id=?",whereArgs:[id]); }
  Future<double> monthRevenue(String ym,{String currency="₹"}) async { final d=await db; final r=await d.rawQuery("SELECT COALESCE(SUM(amount),0) total FROM payments WHERE substr(date,1,7)=? AND currency=?",[ym,currency]); return (r.first["total"] as num).toDouble(); }
  Future<List<LibraryItem>> library() async { final d=await db; final r=await d.query("library",orderBy:"section,title"); return r.map(LibraryItem.fromMap).toList(); }
  Future<int> saveLibrary(LibraryItem x) async { final d=await db; final m=x.toMap()..remove("id"); if(x.id==null) return d.insert("library",m); return d.update("library",m,where:"id=?",whereArgs:[x.id]); }
  Future<void> deleteLibrary(int id) async { final d=await db; await d.delete("library",where:"id=?",whereArgs:[id]); }
  Future<String> setting(String key,String fallback) async { final d=await db; final r=await d.query("settings",where:"key=?",whereArgs:[key]); return r.isEmpty ? fallback : r.first["value"] as String; }
  Future<void> setSetting(String key,String value) async { final d=await db; await d.insert("settings",{"key":key,"value":value},conflictAlgorithm:ConflictAlgorithm.replace); }
}