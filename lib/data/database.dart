import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/models.dart';
class AppDb {
  AppDb._(); static final AppDb instance=AppDb._(); Database? _db;
  Future<Database> get db async { _db ??= await _open(); return _db!; }
  Future<Database> _open() async { final p=join(await getDatabasesPath(),'freelance_ops.db'); return openDatabase(p,version:1,onCreate:(d,v)async{
    await d.execute('CREATE TABLE leads(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,platform TEXT NOT NULL,niche TEXT NOT NULL,status TEXT NOT NULL,date_contacted TEXT NOT NULL,follow_up_date TEXT NOT NULL,notes TEXT NOT NULL)');
    await d.execute('CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT,title TEXT NOT NULL,category TEXT NOT NULL,date TEXT NOT NULL,completed INTEGER NOT NULL DEFAULT 0)');
    await d.execute('CREATE TABLE projects(id INTEGER PRIMARY KEY AUTOINCREMENT,lead_id INTEGER,client_name TEXT NOT NULL,project_title TEXT NOT NULL,deadline TEXT NOT NULL,status TEXT NOT NULL,revisions INTEGER NOT NULL DEFAULT 0)');
    await d.execute('CREATE TABLE payments(id INTEGER PRIMARY KEY AUTOINCREMENT,client TEXT NOT NULL,amount REAL NOT NULL,currency TEXT NOT NULL,date TEXT NOT NULL,platform TEXT NOT NULL)');
    await d.execute('CREATE TABLE library(id INTEGER PRIMARY KEY AUTOINCREMENT,title TEXT NOT NULL,section TEXT NOT NULL,content TEXT NOT NULL)');
    await d.execute('CREATE TABLE settings(key TEXT PRIMARY KEY,value TEXT NOT NULL)');
    await d.insert('settings',{'key':'dm_target','value':'20'}); await d.insert('settings',{'key':'income_goal','value':'50000'}); await d.insert('settings',{'key':'focus','value':''});
  }); }
  Future<List<Lead>> leads() async=>(await (await db).query('leads',orderBy:'id DESC')).map(Lead.fromMap).toList();
  Future<int> saveLead(Lead x) async=> (await db).insert('leads',x.toMap()..remove('id'));
  Future<int> updateLead(Lead x) async { final database=await db; final map=x.toMap()..remove('id'); return database.update('leads',map,where:'id=?',whereArgs:[x.id]); }
  Future<void> deleteLead(int id) async=>(await db).delete('leads',where:'id=?',whereArgs:[id]);
  Future<int> todayDms(String date) async{final r=await (await db).rawQuery('SELECT COUNT(*) c FROM leads WHERE date_contacted=?',[date]);return Sqflite.firstIntValue(r)??0;}
  Future<List<Task>> tasks(String date) async=>(await (await db).query('tasks',where:'date=?',whereArgs:[date],orderBy:'id')).map(Task.fromMap).toList();
  Future<void> ensureTasks(String date) async { final d=await db; final existing=await d.query('tasks',where:'date=?',whereArgs:[date]); if(existing.isNotEmpty)return; for(final t in [['Send 20 outreach messages','Outreach'],['Edit client deliverables','Editing'],['Study BCA topic','Study'],['Work on course/product','Course Building']]) await d.insert('tasks',{'title':t[0],'category':t[1],'date':date,'completed':0}); }
  Future<void> toggleTask(Task x) async=>(await db).update('tasks',{'completed':x.completed?0:1},where:'id=?',whereArgs:[x.id]);
  Future<int> streak(String today) async { int n=0; DateTime d=DateTime.parse(today); while(true){final s=d.toIso8601String().substring(0,10); final rows=await (await db).rawQuery('SELECT COUNT(*) total, SUM(completed) done FROM tasks WHERE date=?',[s]); if(rows.first['total']==null || (rows.first['total'] as int)==0 || (rows.first['done']??0)!=(rows.first['total'])) break; n++; d=d.subtract(const Duration(days:1));} return n; }
  Future<List<Project>> projects() async=>(await (await db).query('projects',orderBy:'deadline')).map(Project.fromMap).toList();
  Future<int> saveProject(Project x) async=>(await db).insert('projects',x.toMap()..remove('id'));
  Future<void> deleteProject(int id) async=>(await db).delete('projects',where:'id=?',whereArgs:[id]);
  Future<List<Payment>> payments() async=>(await (await db).query('payments',orderBy:'date DESC,id DESC')).map(Payment.fromMap).toList();
  Future<int> savePayment(Payment x) async=>(await db).insert('payments',x.toMap()..remove('id'));
  Future<void> deletePayment(int id) async=>(await db).delete('payments',where:'id=?',whereArgs:[id]);
  Future<double> monthRevenue(String ym,{String currency='₹'}) async {final r=await (await db).rawQuery("SELECT COALESCE(SUM(amount),0) total FROM payments WHERE substr(date,1,7)=? AND currency=?",[ym,currency]);return (r.first['total'] as num).toDouble();}
  Future<List<LibraryItem>> library() async=>(await (await db).query('library',orderBy:'section,title')).map(LibraryItem.fromMap).toList();
  Future<int> saveLibrary(LibraryItem x) async=>x.id==null?(await db).insert('library',x.toMap()..remove('id')):(await db.update('library',x.toMap()..remove('id'),where:'id=?',whereArgs:[x.id]));
  Future<void> deleteLibrary(int id) async=>(await db).delete('library',where:'id=?',whereArgs:[id]);
  Future<String> setting(String key,String fallback) async {final r=await (await db).query('settings',where:'key=?',whereArgs:[key]);return r.isEmpty?fallback:r.first['value'] as String;}
  Future<void> setSetting(String key,String value) async=>(await db).insert('settings',{'key':key,'value':value},conflictAlgorithm:ConflictAlgorithm.replace);
}
