import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "../data/database.dart";
import "../models/models.dart";

const currencies=["₹","\$"];const payPlatforms=["Fiverr","Direct","PeoplePerHour"];
class RevenueScreen extends StatefulWidget{const RevenueScreen({super.key});@override State<RevenueScreen> createState()=>_RevenueScreenState();}
class _RevenueScreenState extends State<RevenueScreen>{
 final db=AppDb.instance;List<Payment> items=[];double total=0,dollarTotal=0;String goal="50000";String get month=>DateFormat("yyyy-MM").format(DateTime.now());
 @override void initState(){super.initState();load();}
 Future<void> load() async {final x=await db.payments();final r=await db.monthRevenue(month,currency:"₹");final u=await db.monthRevenue(month,currency:"\$");final g=await db.setting("income_goal","50000");if(!mounted)return;setState((){items=x;total=r;dollarTotal=u;goal=g;});}
 Future<void> settings() async {final c=TextEditingController(text:goal);await showDialog<void>(context:context,builder:(ctx)=>AlertDialog(title:const Text("Monthly income goal"),content:TextField(controller:c,keyboardType:TextInputType.number),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text("Cancel")),FilledButton(onPressed:()async{await db.setSetting("income_goal",c.text);if(ctx.mounted)Navigator.pop(ctx);await load();},child:const Text("Save"))]));c.dispose();}
 Future<void> form() async {
  final client=TextEditingController();final amount=TextEditingController();String currency="₹";String platform=payPlatforms.first;
  await showDialog<void>(context:context,builder:(ctx)=>AlertDialog(title:const Text("Log payment"),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
    TextField(controller:client,decoration:const InputDecoration(labelText:"Client")),TextField(controller:amount,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:"Amount")),
    DropdownButtonFormField<String>(initialValue:currency,items:currencies.map((e)=>DropdownMenuItem<String>(value:e,child:Text(e))).toList(),onChanged:(v){if(v!=null)currency=v;},decoration:const InputDecoration(labelText:"Currency")),
    DropdownButtonFormField<String>(initialValue:platform,items:payPlatforms.map((e)=>DropdownMenuItem<String>(value:e,child:Text(e))).toList(),onChanged:(v){if(v!=null)platform=v;},decoration:const InputDecoration(labelText:"Platform")),
  ])),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text("Cancel")),FilledButton(onPressed:()async{await db.savePayment(Payment(client:client.text.trim(),amount:double.tryParse(amount.text)??0,currency:currency,date:DateFormat("yyyy-MM-dd").format(DateTime.now()),platform:platform));if(ctx.mounted)Navigator.pop(ctx);await load();},child:const Text("Save"))]));
  client.dispose();amount.dispose();
 }
 @override Widget build(BuildContext context){
  final target=double.tryParse(goal)??0;final progress=target<=0?0.0:(total/target).clamp(0.0,1.0);
  final cards=items.map<Widget>((x)=>Card(child:ListTile(title:Text("${x.currency}${x.amount.toStringAsFixed(0)} • ${x.client}"),subtitle:Text("${x.platform} • ${x.date}"),trailing:IconButton(icon:const Icon(Icons.delete_outline),onPressed:()async{await db.deletePayment(x.id!);await load();})))).toList();
  return Scaffold(appBar:AppBar(title:const Text("Revenue"),actions:[IconButton(onPressed:settings,icon:const Icon(Icons.flag_outlined)),IconButton(onPressed:form,icon:const Icon(Icons.add))]),body:ListView(padding:const EdgeInsets.all(12),children:[
    Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text("This month",style:Theme.of(context).textTheme.titleMedium),Text("₹${total.toStringAsFixed(0)}",style:const TextStyle(fontSize:32,fontWeight:FontWeight.bold)),const SizedBox(height:8),LinearProgressIndicator(value:progress),const SizedBox(height:5),Text("Goal ₹${double.tryParse(goal)?.toStringAsFixed(0)??goal} • ${(progress*100).toStringAsFixed(0)}%"),Text("USD this month: \${dollarTotal.toStringAsFixed(2)}")]))),const SizedBox(height:12),...cards
  ]));
 }
}