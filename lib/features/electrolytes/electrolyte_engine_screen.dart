import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'hypokalemia_engine_screen.dart';

class ElectrolyteEngineScreen extends StatelessWidget {
  const ElectrolyteEngineScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final items = <_ElectrolyteItem>[
      _ElectrolyteItem('Hypokalemia / KCl engine','Oral and IV KCl, background-fluid K, total delivery, access, fluid burden and monitoring',Icons.bolt_outlined,const HypokalemiaEngineScreen()),
      _ElectrolyteItem('Sodium correction safety','Hyponatremia correction ceiling, sodium deficit and hypernatremia safety framework',Icons.water_drop_outlined,const SodiumReplacementScreen()),
      _ElectrolyteItem('Hypomagnesemia','Oral and IV magnesium dose, max dose, duration and renal cautions',Icons.science_outlined,const MagnesiumReplacementScreen()),
      _ElectrolyteItem('Hypophosphatemia','Enteral/IV phosphate dose, concentration, infusion rate and Na/K content cautions',Icons.biotech_outlined,const PhosphateReplacementScreen()),
      _ElectrolyteItem('Calcium replacement','Ionized calcium-first assessment, ECG/line safety and local-protocol dosing gate',Icons.monitor_heart_outlined,const CalciumReplacementScreen()),
    ];
    String query='';
    return StatefulBuilder(builder:(context,setLocal){final visible=items.where((x)=>'${x.title} ${x.subtitle}'.toLowerCase().contains(query.toLowerCase())).toList();return Scaffold(
      appBar:AppBar(title:const Text('Electrolyte Replacement Engine',style:TextStyle(fontWeight:FontWeight.w900))),
      body:ListView.separated(padding:const EdgeInsets.fromLTRB(16,8,16,28),itemCount:visible.length+1,separatorBuilder:(_,__)=>const SizedBox(height:10),itemBuilder:(context,i){if(i==0)return TextField(decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Search within Electrolyte Engine…',border:OutlineInputBorder()),onChanged:(v)=>setLocal(()=>query=v));final x=visible[i-1];return Card(child:ListTile(leading:CircleAvatar(child:Icon(x.icon)),title:Text(x.title,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text(x.subtitle),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.of(context).push(MaterialPageRoute<void>(builder:(_)=>x.screen))));}),
    );});
  }
}
class _ElectrolyteItem{final String title,subtitle;final IconData icon;final Widget screen;const _ElectrolyteItem(this.title,this.subtitle,this.icon,this.screen);}

class SodiumReplacementScreen extends StatefulWidget{const SodiumReplacementScreen({super.key});@override State<SodiumReplacementScreen> createState()=>_SodiumReplacementScreenState();}
class _SodiumReplacementScreenState extends State<SodiumReplacementScreen>{final weight=TextEditingController(text:'20'),current=TextEditingController(text:'126'),target=TextEditingController(text:'132');double tbw=.6;@override void dispose(){weight.dispose();current.dispose();target.dispose();super.dispose();}double? n(c)=>double.tryParse(c.text.trim());@override Widget build(BuildContext context){final W=n(weight),C=n(current),T=n(target);final deficit=W!=null&&C!=null&&T!=null?(T-C)*W*tbw:null;final delta=C!=null&&T!=null?T-C:null;final over=delta!=null&&delta>8;return _ePage(context,'Sodium correction safety',[
 _eNotice(context,'For a non-seizing child with hyponatremia, RCH targets correction of about 6–8 mmol/L over 24 h. Neurologic symptoms/seizures require an emergency hypertonic-saline protocol and senior/PICU input; this screen does not substitute for that order set.'),
 Row(children:[Expanded(child:_eField(weight,'Weight','kg',()=>setState((){}))),const SizedBox(width:8),Expanded(child:_eField(current,'Current Na','mmol/L',()=>setState((){}))),const SizedBox(width:8),Expanded(child:_eField(target,'24-h target','mmol/L',()=>setState((){})))]),
 Text('TBW factor ${tbw.toStringAsFixed(2)}'),Slider(value:tbw,min:.45,max:.8,divisions:35,onChanged:(v)=>setState(()=>tbw=v)),
 if(delta!=null)_eResult('Planned Na change','${delta.toStringAsFixed(1)} mmol/L / 24 h'),if(deficit!=null)_eResult('Calculated Na deficit to target','${deficit.toStringAsFixed(0)} mmol (planning estimate, not an infusion order)'),
 if(over)const Card(color:Color(0xFFFFE4E4),child:Padding(padding:EdgeInsets.all(12),child:Text('⚠ Planned correction exceeds 8 mmol/L in 24 h. Re-enter a safer target unless a specialist emergency indication requires a different strategy.'))),
 const Text('Check fluid balance, glucose, serum/urine osmolality, urine sodium, medications and volume status. Chronicity and etiology matter. Transfer/urgent specialist input is appropriate for Na <125 mmol/L with CNS symptoms or severe/complex abnormalities.'),
 const Text('Source: RCH Hyponatraemia CPG. Use local hypertonic saline concentration/rate protocol for symptomatic emergencies.'),
 ]);}}

class MagnesiumReplacementScreen extends StatefulWidget{const MagnesiumReplacementScreen({super.key});@override State<MagnesiumReplacementScreen> createState()=>_MagnesiumReplacementScreenState();}
class _MagnesiumReplacementScreenState extends State<MagnesiumReplacementScreen>{final weight=TextEditingController(text:'20');double oral=.2,iv=.2,hours=3;bool renal=false;@override void dispose(){weight.dispose();super.dispose();}double? get w=>double.tryParse(weight.text.trim());@override Widget build(BuildContext context){final W=w;final oralDose=W==null?null:W*oral;final ivDose=W==null?null:math.min(W*iv,8);final rate=ivDose==null?null:ivDose/hours;return _ePage(context,'Hypomagnesemia replacement',[
 _eNotice(context,'Oral/enteral magnesium is preferred for mild asymptomatic deficiency; IV replacement is used for severe symptoms or significant GI intolerance. Symptomatic or severe deficiency needs specialist involvement.'),
 _eField(weight,'Weight','kg',()=>setState((){})),SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('Moderate–severe renal impairment'),value:renal,onChanged:(v)=>setState(()=>renal=v)),
 const Text('Oral dose'),Slider(value:oral,min:.1,max:.8,divisions:7,label:'${oral.toStringAsFixed(1)} mmol/kg/dose',onChanged:(v)=>setState(()=>oral=v)),if(oralDose!=null)_eResult('Oral/enteral amount','${oralDose.toStringAsFixed(1)} mmol/dose • RCH usual 0.1–0.2 mmol/kg TID; higher 0.4–0.8 mmol/kg up to QID if required/tolerated'),
 const Divider(),const Text('IV dose'),Slider(value:iv,min:.1,max:.4,divisions:3,label:'${iv.toStringAsFixed(1)} mmol/kg',onChanged:(v)=>setState(()=>iv=v)),Text('Infusion duration ${hours.toStringAsFixed(0)} h'),Slider(value:hours,min:2,max:4,divisions:2,onChanged:(v)=>setState(()=>hours=v)),if(ivDose!=null)_eResult('IV magnesium amount','${ivDose.toStringAsFixed(1)} mmol (8 mmol maximum in RCH reference)'),if(rate!=null)_eResult('Approx infusion rate','${rate.toStringAsFixed(2)} mmol/hr over ${hours.toStringAsFixed(0)} h'),
 if(renal)const Card(color:Color(0xFFFFE4E4),child:Padding(padding:EdgeInsets.all(12),child:Text('⚠ Renal impairment increases risk of hypermagnesemia. Seek renal/pharmacy/specialist advice before replacement.'))),
 const Text('Monitor Mg according to severity and symptoms. IV magnesium 0.1–0.2 mmol/kg, up to 0.4 mmol/kg, max 8 mmol, is generally administered over 2–4 h in the RCH guideline; faster administration is reserved for severe symptoms with expert monitoring.'),
 const Text('Source: RCH Hypomagnesaemia CPG. Verify local product concentration and pump library.'),
 ]);}}

class PhosphateReplacementScreen extends StatefulWidget{const PhosphateReplacementScreen({super.key});@override State<PhosphateReplacementScreen> createState()=>_PhosphateReplacementScreenState();}
class _PhosphateReplacementScreenState extends State<PhosphateReplacementScreen>{final weight=TextEditingController(text:'20');double iv=.36;double hours=6;bool neonate=false,renal=false,central=false;@override void dispose(){weight.dispose();super.dispose();}double? get w=>double.tryParse(weight.text.trim());@override Widget build(BuildContext context){final W=w;final dose=W==null?null:W*iv;final rate=dose==null?null:dose/hours;final double maxConc = central ? 0.12 : 0.05;final minVol=dose==null?null:dose/maxConc;final maxRateW=W==null?null:.2*W;return _ePage(context,'Hypophosphatemia replacement',[
 _eNotice(context,'Severe acute phosphate <0.5 mmol/L may cause weakness/respiratory or cardiac dysfunction; <0.3 mmol/L is a life-threatening emergency. Treat the cause and account for potassium/sodium contained in the selected phosphate product.'),
 _eField(weight,'Weight','kg',()=>setState((){})),SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('Neonate'),value:neonate,onChanged:(v)=>setState(()=>neonate=v)),SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('Renal impairment'),value:renal,onChanged:(v)=>setState(()=>renal=v)),
 _eResult('Enteral reference',neonate?'1 mmol/kg/day in 2–4 doses; up to 3 mmol/kg/day may be used for osteopenia of prematurity under neonatal guidance':'2–3 mmol/kg/day in 2–4 divided doses for children (product-specific maximums apply)'),
 const Divider(),Text('IV dose ${iv.toStringAsFixed(2)} mmol/kg'),Slider(value:iv,min:.1,max:.5,divisions:8,onChanged:(v)=>setState(()=>iv=v)),Text('Duration ${hours.toStringAsFixed(0)} h'),Slider(value:hours,min:4,max:8,divisions:4,onChanged:(v)=>setState(()=>hours=v)),SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('Central line'),value:central,onChanged:(v)=>setState(()=>central=v)),
 if(dose!=null)_eResult('IV phosphate amount','${dose.toStringAsFixed(2)} mmol'),if(rate!=null)_eResult('Infusion rate','${rate.toStringAsFixed(2)} mmol/hr${maxRateW==null?'':' • weight-based ceiling ${maxRateW.toStringAsFixed(1)} mmol/hr'}'),if(minVol!=null)_eResult('Minimum final volume at RCH concentration ceiling','${minVol.toStringAsFixed(0)} mL at ≤${maxConc.toStringAsFixed(2)} mmol/mL (${central?'central':'peripheral'})'),
 if(dose!=null&&dose>10)const Card(color:Color(0xFFFFF0D2),child:Padding(padding:EdgeInsets.all(12),child:Text('⚠ IV phosphate dose >10 mmol: RCH recommends senior clinician discussion.'))),if(renal)const Card(color:Color(0xFFFFE4E4),child:Padding(padding:EdgeInsets.all(12),child:Text('⚠ Reduce dose and obtain specialist advice in renal impairment.'))),
 const Text('RCH IV reference: 0.36 mmol/kg slow infusion; peripheral concentration ≤0.05 mmol/mL, central ≤0.12 mmol/mL; usually over 6 h; maximum rate 0.2 mmol/kg/h or 10 mmol/h. Check phosphate and potassium before and ~2 h after completion. Do not share a lumen with calcium- or magnesium-containing solutions.'),
 const Text('Source: RCH Hypophosphataemia CPG. Verify whether the local product is potassium phosphate, sodium phosphate, or mixed salt before calculating total K/Na exposure.'),
 ]);}}

class CalciumReplacementScreen extends StatelessWidget{const CalciumReplacementScreen({super.key});@override Widget build(BuildContext context)=>_ePage(context,'Calcium replacement safety',const[
 Card(child:Padding(padding:EdgeInsets.all(14),child:Text('Calcium replacement is intentionally gated to local protocol because pediatric calcium gluconate/chloride concentration, elemental calcium content, line requirements and infusion rates vary. PedsFlow will calculate only after a validated local monograph is configured.'))),
 ListTile(leading:Icon(Icons.science_outlined),title:Text('Confirm the abnormality',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Prefer ionized calcium in the acutely ill child. Review pH and albumin if interpreting total calcium.')),
 ListTile(leading:Icon(Icons.monitor_heart_outlined),title:Text('Symptomatic hypocalcemia',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Tetany, seizure, laryngospasm/stridor, hypotension or prolonged QT → monitored urgent treatment; check Mg and phosphate and involve senior/PICU/endocrine as appropriate.')),
 ListTile(leading:Icon(Icons.medication_outlined),title:Text('Formulation matters',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Calcium chloride and calcium gluconate are NOT interchangeable by mL. Central/peripheral access and extravasation risks differ.')),
 ListTile(leading:Icon(Icons.warning_amber_outlined),title:Text('Compatibility',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Avoid incompatible co-infusion with phosphate/bicarbonate and verify line compatibility with pharmacy.')),
 Text('Add your LHSC/PCCU/NICU calcium monograph before enabling dose buttons. This is safer than embedding an unsupported generic concentration.'),
]);}

Widget _ePage(BuildContext context,String title,List<Widget> children)=>Scaffold(appBar:AppBar(title:Text(title,style:const TextStyle(fontWeight:FontWeight.w900))),body:ListView(padding:const EdgeInsets.fromLTRB(16,8,16,28),children:children.map((w)=>Padding(padding:const EdgeInsets.only(bottom:10),child:w)).toList()));
Widget _eNotice(BuildContext context,String text)=>Card(color:Theme.of(context).colorScheme.primaryContainer,child:Padding(padding:const EdgeInsets.all(14),child:Text(text)));
Widget _eField(TextEditingController c,String label,String suffix,VoidCallback changed)=>TextField(controller:c,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:label,suffixText:suffix,border:const OutlineInputBorder()),onChanged:(_)=>changed());
Widget _eResult(String label,String value)=>Card(child:Padding(padding:const EdgeInsets.all(12),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Text(label)),const SizedBox(width:10),Flexible(child:Text(value,textAlign:TextAlign.right,style:const TextStyle(fontWeight:FontWeight.w800)))])));
