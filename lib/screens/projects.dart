import "package:flutter/material.dart";
import "../data/database.dart";
import "../models/models.dart";

const pStatuses=["Brief","Editing","Review","Delivered"];
class ProjectsScreen extends StatefulWidget{const ProjectsScreen({super.key});@override State<ProjectsScreen> createState()=>_ProjectsScreenState();}
class _ProjectsScreenState extends State<ProjectsScreen>{
 final db=AppDb.instance;List<Project> items=[];List<Lead> leads=[];
 @override void initState(){super.initState();load();}
 Future<void> load() async {final x=await db.projects();final l=await db.leads();if(!mounted)return;setState((){items=x;leads=l;});}
 Future<void> form([Project? old]) async {
  final title=TextEditingController(text:old?.projectTitle);final deadline=TextEditingController(text:old?.deadline);final rev=TextEditingController(text:"${old?.revisions??0}");
  int? leadId=old?.leadId;String client=old?.clientName??"";String status=old?.status??pStatuses.first;
  await showDialog<void>(context:context,builder:(ctx)=>AlertDialog(title:Text(old==null?"Add project":"Edit project"),content:SingleChildScrollView(child:Column(children:[
    DropdownButtonFormField<int?>(initialValue:leadId,items:[const DropdownMenuItem<int?>(value:null,child:Text("No linked lead")),...leads.map((l)=>DropdownMenuItem<int?>(value:l.id,child:Text(l.name)))],onChanged:(v){leadId=v;final m=leads.where((l)=>l.id==v);if(m.isNotEmpty)client=m.first.name;},decoration:const InputDecoration(labelText:"Client / Outreach lead")),
    TextField(controller:title,decoration:const InputDecoration(labelText:"Project title")),
    TextField(controller:deadline,decoration:const InputDecoration(labelText:"Deadline")),
    DropdownButtonFormField<String>(initialValue:status,items:pStatuses.map((e)=>DropdownMenuItem<String>(value:e,child:Text(e))).toList(),onChanged:(v){if(v!=null)status=v;},decoration:const InputDecoration(labelText:"Status")),
    TextField(controller:rev,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:"Revision count")),
  ])),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text("Cancel")),FilledButton(onPressed:()async{
    final x=Project(id:old?.id,leadId:leadId,clientName:client,projectTitle:title.text.trim(),deadline:deadline.text.trim(),status:status,revisions:int.tryParse(rev.text)??0);
    if(old==null){await db.saveProject(x);}else{await db.deleteProject(old.id!);await db.saveProject(x);}if(ctx.mounted)Navigator.pop(ctx);await load();
  },child:const Text("Save"))]));
  title.dispose();deadline.dispose();rev.dispose();
 }
 @override Widget build(BuildContext context){
  return Scaffold(appBar:AppBar(title:const Text("Projects"),actions:[IconButton(onPressed:()=>form(),icon:const Icon(Icons.add))]),body:items.isEmpty?const Center(child:Text("No projects. Tap + to add one.")):ListView.builder(padding:const EdgeInsets.all(12),itemCount:items.length,itemBuilder:(context,i){
    final x=items[i];
    return Card(child:ListTile(title:Text(x.projectTitle),subtitle:Text("${x.clientName}\n${x.status} • Due ${x.deadline} • ${x.revisions} revisions"),isThreeLine:true,onTap:()=>form(x),trailing:PopupMenuButton<String>(itemBuilder:(context)=>const [PopupMenuItem<String>(value:"delete",child:Text("Delete"))],onSelected:(v)async{if(v=="delete"){await db.deleteProject(x.id!);await load();}})));
  }));
 }
}