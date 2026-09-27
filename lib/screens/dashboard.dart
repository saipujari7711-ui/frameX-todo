import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "../data/database.dart";
import "../models/models.dart";

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}
class _DashboardScreenState extends State<DashboardScreen> {
  final db=AppDb.instance; List<Task> tasks=[]; int dms=0,projects=0,streak=0; double revenue=0; String goal="50000",focus="";
  String get today=>DateFormat("yyyy-MM-dd").format(DateTime.now());
  @override void initState(){super.initState();load();}
  Future<void> load() async {
    await db.ensureTasks(today); final t=await db.tasks(today); final l=await db.leads(); final p=await db.projects();
    final r=await db.monthRevenue(today.substring(0,7)); final g=await db.setting("income_goal","50000"); final f=await db.setting("focus",""); final s=await db.streak(today);
    if(!mounted)return; setState((){tasks=t;dms=l.where((x)=>x.dateContacted==today).length;projects=p.where((x)=>x.status!="Delivered").length;revenue=r;goal=g;focus=f;streak=s;});
  }
  Future<void> editFocus() async {
    final c=TextEditingController(text:focus);
    await showDialog<void>(context:context,builder:(ctx)=>AlertDialog(title:const Text("Today Focus"),content:TextField(controller:c,maxLines:3),actions:[
      TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text("Cancel")),
      FilledButton(onPressed:() async {await db.setSetting("focus",c.text.trim());if(ctx.mounted)Navigator.pop(ctx);await load();},child:const Text("Save")),
    ])); c.dispose();
  }
  @override Widget build(BuildContext context){
    final target=double.tryParse(goal)??0; final progress=target<=0?0.0:(revenue/target).clamp(0.0,1.0);
    final taskWidgets=tasks.map<Widget>((t)=>CheckboxListTile(value:t.completed,onChanged:(_)async{await db.toggleTask(t);await load();},title:Text(t.title),subtitle:Text(t.category),contentPadding:EdgeInsets.zero)).toList();
    return Scaffold(appBar:AppBar(title:const Text("Freelance Ops"),actions:[IconButton(onPressed:editFocus,icon:const Icon(Icons.edit_note))]),body:RefreshIndicator(onRefresh:load,child:ListView(padding:const EdgeInsets.all(16),children:[
      Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text("TODAY FOCUS",style:TextStyle(fontWeight:FontWeight.bold)),const SizedBox(height:8),Text(focus.isEmpty?"Tap edit to set your priority.":focus,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w600))]))),
      const SizedBox(height:12), Row(children:[_metric("DMs","$dms","today"),_metric("Projects","$projects","active")]),
      const SizedBox(height:12), Card(child:ListTile(leading:const Icon(Icons.payments),title:Text("This month: ₹${revenue.toStringAsFixed(0)}"),subtitle:LinearProgressIndicator(value:progress),trailing:Text("${(progress*100).toStringAsFixed(0)}%"))),
      const SizedBox(height:12), Card(child:ListTile(leading:const Icon(Icons.local_fire_department),title:Text("$streak day streak"),subtitle:Text("${tasks.where((x)=>x.completed).length}/${tasks.length} tasks complete"))),
      const SizedBox(height:12),const Text("TODAY TASKS",style:TextStyle(fontWeight:FontWeight.bold)),...taskWidgets,
    ])));
  }
  Widget _metric(String a,String b,String sub)=>Expanded(child:Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(a),Text(b,style:const TextStyle(fontSize:28,fontWeight:FontWeight.bold)),Text(sub)]))));
}