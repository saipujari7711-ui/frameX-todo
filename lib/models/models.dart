class Lead {
  final int? id; final String name, platform, niche, status, dateContacted, followUpDate, notes;
  Lead({this.id, required this.name, required this.platform, required this.niche, required this.status, required this.dateContacted, required this.followUpDate, required this.notes});
  Map<String,Object?> toMap()=>{'id':id,'name':name,'platform':platform,'niche':niche,'status':status,'date_contacted':dateContacted,'follow_up_date':followUpDate,'notes':notes};
  factory Lead.fromMap(Map<String,Object?> m)=>Lead(id:m['id'] as int?,name:m['name'] as String,platform:m['platform'] as String,niche:m['niche'] as String,status:m['status'] as String,dateContacted:m['date_contacted'] as String,followUpDate:m['follow_up_date'] as String,notes:m['notes'] as String);
}
class Task { final int? id; final String title, category, date; final bool completed;
  Task({this.id,required this.title,required this.category,required this.date,required this.completed});
  Map<String,Object?> toMap()=>{'id':id,'title':title,'category':category,'date':date,'completed':completed?1:0};
  factory Task.fromMap(Map<String,Object?> m)=>Task(id:m['id'] as int?,title:m['title'] as String,category:m['category'] as String,date:m['date'] as String,completed:(m['completed'] as int)==1);
}
class Project { final int? id, leadId; final String clientName, projectTitle, deadline, status; final int revisions;
  Project({this.id,this.leadId,required this.clientName,required this.projectTitle,required this.deadline,required this.status,required this.revisions});
  Map<String,Object?> toMap()=>{'id':id,'lead_id':leadId,'client_name':clientName,'project_title':projectTitle,'deadline':deadline,'status':status,'revisions':revisions};
  factory Project.fromMap(Map<String,Object?> m)=>Project(id:m['id'] as int?,leadId:m['lead_id'] as int?,clientName:m['client_name'] as String,projectTitle:m['project_title'] as String,deadline:m['deadline'] as String,status:m['status'] as String,revisions:m['revisions'] as int);
}
class Payment { final int? id; final String client, currency, date, platform; final double amount;
  Payment({this.id,required this.client,required this.amount,required this.currency,required this.date,required this.platform});
  Map<String,Object?> toMap()=>{'id':id,'client':client,'amount':amount,'currency':currency,'date':date,'platform':platform};
  factory Payment.fromMap(Map<String,Object?> m)=>Payment(id:m['id'] as int?,client:m['client'] as String,amount:(m['amount'] as num).toDouble(),currency:m['currency'] as String,date:m['date'] as String,platform:m['platform'] as String);
}
class LibraryItem { final int? id; final String title, section, content;
  LibraryItem({this.id,required this.title,required this.section,required this.content});
  Map<String,Object?> toMap()=>{'id':id,'title':title,'section':section,'content':content};
  factory LibraryItem.fromMap(Map<String,Object?> m)=>LibraryItem(id:m['id'] as int?,title:m['title'] as String,section:m['section'] as String,content:m['content'] as String);
}
