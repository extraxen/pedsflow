import 'package:flutter/material.dart';

import '../models/admission_plan.dart';
import '../models/medication_monograph.dart';
import '../services/app_store.dart';
import '../widgets/plan_tile.dart';
import 'calculators_screen.dart';
import 'pain_management_screen.dart';
import 'pccu_screen.dart';

class UniversalSearchScreen extends StatefulWidget {
  final AppStore store;
  const UniversalSearchScreen({super.key, required this.store});
  @override State<UniversalSearchScreen> createState() => _UniversalSearchScreenState();
}

class _UniversalSearchScreenState extends State<UniversalSearchScreen> {
  String query = '';
  static const Map<String,String> aliases = <String,String>{
    'vomitting':'vomiting','gravol':'dimenhydrinate','zofran':'ondansetron','hypok':'hypokalemia','bronch':'bronchiolitis','pna':'pneumonia','icp':'raised intracranial pressure','chs':'cannabis hyperemesis syndrome','tylenol':'acetaminophen','motrin':'ibuprofen','advil':'ibuprofen','dilaudid':'hydromorphone','epi':'epinephrine',
  };
  static const List<String> pccuTopics = <String>['Severe asthma','Status asthmaticus','Bronchiolitis requiring HFNC','Pediatric ARDS','Septic shock','Status epilepticus','Raised intracranial pressure','Cerebral edema in DKA','Pediatric rapid-sequence intubation','High-flow nasal cannula','CPAP and BiPAP basics','Non-invasive ventilation troubleshooting','Vasoactive selection','Continuous sedation','Neuromuscular blockade','Ketamine'];
  static const List<String> calculators = <String>['Pediatric DKA','PCCU & critical care','Maintenance fluids','Hypernatremic dehydration','Medication dose','Corrected sodium','Anion gap','Corrected calcium','Body surface area','QTc','Glucose infusion rate','Free-water deficit','P/F ratio'];
  static const List<String> emergencies = <String>['Status epilepticus','Sepsis','Anaphylaxis','DKA','Hyperkalemia','Raised intracranial pressure','Toxic ingestion'];
  String normalize(String value) { final raw=value.trim().toLowerCase(); return aliases[raw] ?? raw; }
  bool hit(String text,String q)=>text.toLowerCase().contains(q);

  @override Widget build(BuildContext context) {
    final q=normalize(query);
    final plans=q.isEmpty?<AdmissionPlan>[]:widget.store.plans.where((p)=>hit(<String>[p.title,p.category,...p.aliases].join(' '),q)).toList()..sort((a,b)=>_rank(a.title,q).compareTo(_rank(b.title,q)));
    final meds=q.isEmpty?<MedicationMonograph>[]:widget.store.medications.where((m)=>hit(<String>[m.name,m.category,...m.aliases,m.summary].join(' '),q)).take(30).toList()..sort((a,b)=>_rank(a.name,q).compareTo(_rank(b.name,q)));
    final pccu=q.isEmpty?<String>[]:pccuTopics.where((x)=>hit(x,q)).toList();
    final calcs=q.isEmpty?<String>[]:calculators.where((x)=>hit(x,q)).toList();
    final emergency=q.isEmpty?<String>[]:emergencies.where((x)=>hit(x,q)).toList();
    return Scaffold(appBar:AppBar(title:const Text('Search PedsFlow',style:TextStyle(fontWeight:FontWeight.w900))),body:ListView(padding:const EdgeInsets.fromLTRB(16,8,16,28),children:<Widget>[
      TextField(autofocus:true,onChanged:(v)=>setState(()=>query=v),decoration:const InputDecoration(hintText:'Search diagnoses, medications, calculators or PCCU...',prefixIcon:Icon(Icons.search))),
      if(q.isEmpty) const Padding(padding:EdgeInsets.only(top:24),child:Card(child:Padding(padding:EdgeInsets.all(22),child:Text('Try “vomitting”, “Gravol”, “Zofran”, “hypoK”, “PNA”, “ICP”, “CHS”, “DKA” or “status asthma”.',textAlign:TextAlign.center)))) else ...<Widget>[
        _heading('Admission plans',plans.length,Icons.assignment_outlined),...plans.take(20).map((p)=>PlanTile(plan:p,store:widget.store)),
        _heading('Medications',meds.length,Icons.medication_outlined),...meds.map((m)=>Card(child:ExpansionTile(title:Text(m.name,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text(m.category),childrenPadding:const EdgeInsets.fromLTRB(16,0,16,16),children:<Widget>[Align(alignment:Alignment.centerLeft,child:SelectableText(m.summary)),if(m.doseSections.isNotEmpty)...<Widget>[const SizedBox(height:8),Align(alignment:Alignment.centerLeft,child:SelectableText(m.doseSections.take(2).map((d)=>'${d.title}: ${d.text}').join('\n\n')))] ]))),
        _heading('PCCU topics',pccu.length,Icons.monitor_heart_outlined),...pccu.map((x)=>_navTile(context,x,Icons.monitor_heart_outlined,()=>Navigator.of(context).push(MaterialPageRoute<void>(builder:(_)=>PccuTopicScreen(title:x))))),
        _heading('Calculators',calcs.length,Icons.calculate_outlined),...calcs.map((x)=>_navTile(context,x,Icons.calculate_outlined,()=>Navigator.of(context).push(MaterialPageRoute<void>(builder:(_)=>const CalculatorsScreen())))),
        _heading('Emergency pathways',emergency.length,Icons.emergency_outlined),...emergency.map((x)=>_navTile(context,x,Icons.emergency_outlined,()=>Navigator.of(context).push(MaterialPageRoute<void>(builder:(_)=>PccuTopicScreen(title:x))))),
        if(hit('pain analgesia opioid naloxone sickle cell sjs ten neuropathic postoperative',q)) _navTile(context,'Pediatric pain management',Icons.healing_outlined,()=>Navigator.of(context).push(MaterialPageRoute<void>(builder:(_)=>const PainManagementScreen()))),
      ]
    ]));
  }
  int _rank(String title,String q){final t=title.toLowerCase();if(t==q)return 0;if(t.startsWith(q))return 1;return 2;}
  Widget _heading(String title,int count,IconData icon)=>Padding(padding:const EdgeInsets.only(top:20,bottom:8),child:Row(children:[Icon(icon),const SizedBox(width:8),Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),const Spacer(),Chip(label:Text('$count'))]));
  Widget _navTile(BuildContext c,String title,IconData icon,VoidCallback tap)=>Card(child:ListTile(leading:Icon(icon),title:Text(title,style:const TextStyle(fontWeight:FontWeight.w700)),trailing:const Icon(Icons.chevron_right),onTap:tap));
}
