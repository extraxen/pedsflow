// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../dka/dka_calculator_screen.dart';
import 'di_workflow_screen.dart';
import 'insulin_workspace_screen.dart';
import 'insulin_transition_screen.dart';

class EndocrineHubScreen extends StatelessWidget {
  const EndocrineHubScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final items = <_EndoItem>[
      _EndoItem('Pediatric DKA', 'CPS/TREKK fluids, insulin, electrolytes and cerebral injury', Icons.water_drop_outlined, const DkaCalculatorScreen()),
      _EndoItem('Adrenal crisis', 'Stress hydrocortisone, shock, glucose and electrolyte support', Icons.bolt_outlined, const AdrenalCrisisScreen()),
      _EndoItem('Hypoglycemia', 'Immediate assessment and glucose rescue framework', Icons.bloodtype_outlined, const PediatricHypoglycemiaScreen()),
      _EndoItem('DI / AVP deficiency', 'Paired labs, urine-output calculator, sodium alerts and desmopressin safety', Icons.water_outlined, const DiWorkflowScreen()),
      _EndoItem('Calcium emergencies', 'Ionized calcium, ECG, Mg/phosphate and escalation', Icons.science_outlined, const CalciumEmergencyScreen()),
      _EndoItem('Thyroid emergencies', 'Thyroid storm and severe hypothyroidism/myxedema framework', Icons.thermostat_outlined, const ThyroidEmergencyScreen()),
      _EndoItem('ICR / ISF calculators', 'Estimated versus prescribed ratios, Canadian units, transparent meal and correction arithmetic', Icons.calculate_outlined, const InsulinWorkspaceScreen()),
      _EndoItem('IV to SC insulin transition', 'Readiness, basal-bolus plan, overlap and handover', Icons.swap_horiz_outlined, const SubcutaneousTransitionScreen()),
      _EndoItem('Pump support and failure', 'Basal profiles, AID, IOB, sick days and IV-to-pump transition', Icons.settings_outlined, const InsulinPumpSupportScreen()),
    ];
    String query = '';
    return StatefulBuilder(builder: (context, setLocal) {
      final visible = items.where((x) => '${x.title} ${x.subtitle}'.toLowerCase().contains(query.toLowerCase())).toList();
      return Scaffold(
        appBar: AppBar(title: const Text('Endocrine Hub', style: TextStyle(fontWeight: FontWeight.w900))),
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16,8,16,28), itemCount: visible.length + 1, separatorBuilder: (_,__)=>const SizedBox(height:10),
          itemBuilder:(context,i){if(i==0)return TextField(decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Search within Endocrine Hub…',border:OutlineInputBorder()),onChanged:(v)=>setLocal(()=>query=v));final x=visible[i-1];return Card(child:ListTile(leading:CircleAvatar(child:Icon(x.icon)),title:Text(x.title,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text(x.subtitle),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.of(context).push(MaterialPageRoute<void>(builder:(_)=>x.screen))));},
        ),
      );
    });
  }
}
class _EndoItem{final String title,subtitle;final IconData icon;final Widget screen;const _EndoItem(this.title,this.subtitle,this.icon,this.screen);}

class AdrenalCrisisScreen extends StatefulWidget{const AdrenalCrisisScreen({super.key});@override State<AdrenalCrisisScreen> createState()=>_AdrenalCrisisScreenState();}
class _AdrenalCrisisScreenState extends State<AdrenalCrisisScreen>{final age=TextEditingController(text:'6'),weight=TextEditingController(text:'20'),height=TextEditingController(text:'115');@override void dispose(){age.dispose();weight.dispose();height.dispose();super.dispose();}double? n(c)=>double.tryParse(c.text.trim());@override Widget build(BuildContext context){final a=n(age),w=n(weight),h=n(height);final bsa=w!=null&&h!=null?math.sqrt(h*w/3600):null;double? stat,q6;if(a!=null){if(a<0.115){stat=25;q6=7.5;}else if(a<2){stat=25;q6=10;}else if(a<=6){stat=50;q6=12.5;}else if(a<=12){stat=50;q6=25;}else{stat=100;q6=25;}}return _endoPage(context,'Adrenal crisis',[
 _endoNotice(context,'Adrenal crisis is time-critical. Follow the child’s individual emergency plan when available. Draw cortisol/ACTH before steroid only if this does not delay treatment.'),
 Row(children:[Expanded(child:_endoField(age,'Age','years',()=>setState((){}))),const SizedBox(width:8),Expanded(child:_endoField(weight,'Weight','kg',()=>setState((){}))),const SizedBox(width:8),Expanded(child:_endoField(height,'Height','cm',()=>setState((){})))]),
 if(bsa!=null)_endoResult('BSA','${bsa.toStringAsFixed(2)} m²'),if(stat!=null)_endoResult('Hydrocortisone initial IV/IM reference','${stat.toStringAsFixed(0)} mg'),if(q6!=null)_endoResult('Then q6h reference','${q6.toStringAsFixed(1)} mg IV q6h'),
 if(bsa!=null)_endoResult('BSA cross-check','Initial ~${(50*bsa).toStringAsFixed(0)}–${(75*bsa).toStringAsFixed(0)} mg; total daily ~${(50*bsa).toStringAsFixed(0)}–${(75*bsa).toStringAsFixed(0)} mg/m²/day equivalent'),
 const Text('Severely unwell/crisis: hydrocortisone + isotonic fluid resuscitation + manage hypoglycemia/hyperkalemia and treat precipitating illness. RCH uses 0.9% NaCl 10 mL/kg bolus with reassessment for shock/dehydration.'),
 const Text('Classic primary adrenal-crisis biochemistry: hyponatremia, hyperkalemia and hypoglycemia. Secondary adrenal insufficiency may not show hyperkalemia.'),
 const Text('Source: RCH Clinical Practice Guideline — Adrenal crisis and acute adrenal insufficiency. Local endocrine plan supersedes.'),
 ]);}}

class PediatricHypoglycemiaScreen extends StatefulWidget{const PediatricHypoglycemiaScreen({super.key});@override State<PediatricHypoglycemiaScreen> createState()=>_PediatricHypoglycemiaScreenState();}
class _PediatricHypoglycemiaScreenState extends State<PediatricHypoglycemiaScreen>{final w=TextEditingController(text:'20'),g=TextEditingController(text:'2.5');@override void dispose(){w.dispose();g.dispose();super.dispose();}double? n(c)=>double.tryParse(c.text.trim());@override Widget build(BuildContext context){final W=n(w),G=n(g);final d10=W==null?null:2*W;return _endoPage(context,'Pediatric hypoglycemia',[
 _endoNotice(context,'Treat the child, not only the number. Altered consciousness/seizure or inability to take oral carbohydrate requires urgent IV/IO glucose and cause-directed care. Obtain a critical sample before glucose only when safe and it will not delay rescue.'),
 Row(children:[Expanded(child:_endoField(w,'Weight','kg',()=>setState((){}))),const SizedBox(width:8),Expanded(child:_endoField(g,'Glucose','mmol/L',()=>setState((){})))]),
 if(G!=null)_endoResult('Current glucose','${G.toStringAsFixed(1)} mmol/L'),if(d10!=null)_endoResult('D10 volume equivalence','2 mL/kg = ${d10.toStringAsFixed(0)} mL (200 mg/kg glucose) — verify local pediatric hypoglycemia protocol'),
 const Text('Recheck glucose after rescue and provide ongoing carbohydrate/dextrose to prevent recurrence. Review insulin/sulfonylurea exposure, fasting/illness, adrenal/pituitary disease, metabolic disease, liver disease and sepsis where relevant.'),
 ]);}}

class CalciumEmergencyScreen extends StatelessWidget{const CalciumEmergencyScreen({super.key});@override Widget build(BuildContext context)=>_endoPage(context,'Calcium emergencies',const[
 Card(child:Padding(padding:EdgeInsets.all(14),child:Text('Use ionized calcium when available in the acutely ill child. Total calcium is affected by albumin and pH. Severe symptomatic hypo- or hypercalcemia requires monitored specialist management.'))),
 ListTile(leading:Icon(Icons.monitor_heart_outlined),title:Text('Hypocalcemia',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Tetany, seizures, stridor, paresthesia or prolonged QT: obtain ionized Ca, Mg, phosphate, renal function and ECG; correct coexisting hypomagnesemia. IV calcium is a high-alert medication—use local concentration/rate/line protocol.')),
 ListTile(leading:Icon(Icons.warning_amber_outlined),title:Text('Hypercalcemia',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Assess hydration, ECG, renal function, phosphate, PTH and vitamin D context. Severe/symptomatic hypercalcemia warrants IV hydration and endocrine/nephrology involvement; cause-directed therapies require specialist guidance.')),
 Text('PedsFlow intentionally does not invent a universal IV calcium dose/concentration because local pediatric formulations and access limits vary. Link this page to your institutional calcium replacement monograph before enabling one-tap dosing.'),
]);}

class ThyroidEmergencyScreen extends StatelessWidget{const ThyroidEmergencyScreen({super.key});@override Widget build(BuildContext context)=>_endoPage(context,'Thyroid emergencies',const[
 ListTile(leading:Icon(Icons.local_fire_department_outlined),title:Text('Thyroid storm',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Consider with severe thyrotoxicosis plus fever, marked tachycardia/arrhythmia, CNS change, heart failure or GI/hepatic dysfunction. Stabilize ABCs, temperature/fluids carefully, and involve endocrinology/PICU urgently. Therapy is multi-drug and sequence-dependent; use current local endocrine protocol.')),
 ListTile(leading:Icon(Icons.ac_unit_outlined),title:Text('Severe hypothyroidism / myxedema physiology',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Hypothermia, bradycardia, hypoventilation, altered mental status, hyponatremia/hypoglycemia and cardiovascular instability require PICU/endocrinology. Consider coexisting adrenal insufficiency before thyroid hormone escalation.')),
 Text('These are recognition/escalation pathways rather than autonomous medication order sets.'),
]);}

Widget _endoPage(BuildContext context,String title,List<Widget> children)=>Scaffold(appBar:AppBar(title:Text(title,style:const TextStyle(fontWeight:FontWeight.w900))),body:ListView(padding:const EdgeInsets.fromLTRB(16,8,16,28),children:children.map((w)=>Padding(padding:const EdgeInsets.only(bottom:10),child:w)).toList()));
Widget _endoNotice(BuildContext context,String text)=>Card(color:Theme.of(context).colorScheme.primaryContainer,child:Padding(padding:const EdgeInsets.all(14),child:Text(text)));
Widget _endoField(TextEditingController c,String label,String suffix,VoidCallback changed)=>TextField(controller:c,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:label,suffixText:suffix,border:const OutlineInputBorder()),onChanged:(_)=>changed());
Widget _endoResult(String label,String value)=>Card(child:Padding(padding:const EdgeInsets.all(12),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Text(label)),const SizedBox(width:10),Flexible(child:Text(value,textAlign:TextAlign.right,style:const TextStyle(fontWeight:FontWeight.w800)))])));
