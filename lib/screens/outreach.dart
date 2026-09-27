import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "../data/database.dart";
import "../models/models.dart";

const statuses=["DMed","Replied","Interested","Proposal Sent","Client","Closed"];
const platforms=["Instagram","Email","LinkedIn","X","Other"];

class OutreachScreen extends StatefulWidget{const OutreachScreen({super.key});@override State<OutreachScreen> createState()=>_OutreachScreenState();}
class _OutreachScreenState extends State<OutreachScreen>{
 final db=AppDb.instance; List<Lead> leads=[]; String target="20"; String get today=>DateFormat("yyyy-MM-dd").format(DateTime.now());
 @override void initState(){super.initState();load();}
 Future<void> load() async {final x=await db.leads();final t=await db.setting("dm_target","20");if(!mounted)return;setState((){leads=x;target=t;});}
 Future<void> form([Lead? old]) async {
  final name=TextEditingController(text:old?.name); final niche=TextEditingController(text:old?.niche); final notes=TextEditingController(text:old?.notes); final follow=TextEditingController(text:old?.followUpDate);
  String platform=old?.platform??platforms.first; String status=old?.status??statuses.first;
  await showDialog<void>(context:context,builder:(ctx)=>AlertDialog(title:Text(old==null?"Add lead":"Edit lead"),content:SingleChildScrollView(child:Column(children:[
    TextField(controller:name,decoration:const InputDecoration(labelText:"Name")),
    DropdownButtonFormField<String>(initialValue:platform,items:platforms.map((e)=>DropdownMenuItem<String>(value:e,child:Text(e))).toList(),onChanged:(v){if(v!=null)platform=v;},decoration:const InputDecoration(labelText:"Platform")),
    TextField(controller:niche,decoration:const InputDecoration(labelText:"Niche")),
    DropdownButtonFormField<String>(initialValue:status,items:statuses.map((e)=>DropdownMenuItem<String>(value:e,child:Text(e))).toList(),onChanged:(v){if(v!=null)status=v;},decoration:const InputDecoration(labelText:"Status")),
    TextField(controller:follow,decoration:const InputDecoration(labelText:"Follow-up date")),TextField(controller:notes,maxLines:3,decoration:const InputDecoration(labelText:"Notes")),
  ])),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text("Cancel")),FilledButton(onPressed:()async{
    if(name.text.trim().isEmpty)return; final x=Lead(id:old?.id,name:name.text.trim(),platform:platform,niche:niche.text.trim(),status:status,dateContacted:old?.dateContacted??today,followUpDate:follow.text.trim(),notes:notes.text.trim());
    if(old==null){await db.saveLead(x);}else{await db.updateLead(x);} if(ctx.mounted)Navigator.pop(ctx); await load();
  },child:const Text("Save"))]));
  name.dispose();niche.dispose();notes.dispose();follow.dispose();
 }
 Widget leadCard(Lead x,String columnStatus){
  return Card(child:ListTile(title:Text(x.name),subtitle:Text("${x.platform} • ${x.niche}\n${x.followUpDate.isEmpty?"No follow-up":"Follow-up ${x.followUpDate}"}"),isThreeLine:true,onTap:()=>form(x),trailing:PopupMenuButton<String>(
    itemBuilder:(context)=>[...statuses.map((s)=>PopupMenuItem<String>(value:s,child:Text("Move to $s"))),const PopupMenuDivider(),const PopupMenuItem<String>(value:"delete",child:Text("Delete"))],
    onSelected:(v)async{if(v=="delete"){await db.deleteLead(x.id!);}else if(v!=columnStatus){await db.updateLead(Lead(id:x.id,name:x.name,platform:x.platform,niche:x.niche,status:v,dateContacted:x.dateContacted,followUpDate:x.followUpDate,notes:x.notes));}await load();},
  )));
 }
 @override Widget build(BuildContext context){
  final dms=leads.where((x)=>x.dateContacted==today).length;
  return Scaffold(appBar:AppBar(title:Text("Outreach • $dms/$target today"),actions:[IconButton(onPressed:()=>form(),icon:const Icon(Icons.add))]),
   body:leads.isEmpty?const Center(child:Text("No leads yet. Tap + to add one.")):ListView.builder(scrollDirection:Axis.horizontal,padding:const EdgeInsets.all(10),itemCount:statuses.length,itemBuilder:(context,index){
    final status=statuses[index];final xs=leads.where((x)=>x.status==status).toList();
    return SizedBox(width:275,child:Card(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Padding(padding:const EdgeInsets.all(12),child:Row(children:[Expanded(child:Text(status,style:const TextStyle(fontWeight:FontWeight.bold))),CircleAvatar(radius:12,child:Text("${xs.length}"))])),const Divider(height:1),Expanded(child:ListView(padding:const EdgeInsets.all(8),children:xs.map((x)=>leadCard(x,status)).toList()))])));
   }));
 }
}