import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../dka/dka_calculator_screen.dart';

class EndocrineHubScreen extends StatelessWidget {
  const EndocrineHubScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final items = <_EndoItem>[
      _EndoItem('Pediatric DKA', 'CPS/TREKK fluids, insulin, electrolytes and cerebral injury', Icons.water_drop_outlined, const DkaCalculatorScreen()),
      _EndoItem('Adrenal crisis', 'Stress hydrocortisone, shock, glucose and electrolyte support', Icons.bolt_outlined, const AdrenalCrisisScreen()),
      _EndoItem('Hypoglycemia', 'Immediate assessment and glucose rescue framework', Icons.bloodtype_outlined, const PediatricHypoglycemiaScreen()),
      _EndoItem('DI / SIADH', 'Polyuria-hypernatremia and water-retention-hyponatremia framework', Icons.water_outlined, const DiSiadhScreen()),
      _EndoItem('Calcium emergencies', 'Ionized calcium, ECG, Mg/phosphate and escalation', Icons.science_outlined, const CalciumEmergencyScreen()),
      _EndoItem('Thyroid emergencies', 'Thyroid storm and severe hypothyroidism/myxedema framework', Icons.thermostat_outlined, const ThyroidEmergencyScreen()),
      _EndoItem('Insulin calculators', 'TDD, basal split, carb ratio, correction factor and dose estimate', Icons.calculate_outlined, const InsulinCalculatorScreen()),
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

class DiSiadhScreen extends StatelessWidget{const DiSiadhScreen({super.key});@override Widget build(BuildContext context)=>_endoPage(context,'DI / SIADH',const[
 Card(child:Padding(padding:EdgeInsets.all(14),child:Text('DI and SIADH can both produce dangerous sodium disorders but require opposite fluid strategies. Confirm serum sodium/osmolality, urine output, urine osmolality/specific gravity and clinical volume status before acting.'))),
 ListTile(leading:Icon(Icons.water_outlined),title:Text('Central / nephrogenic DI',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Polyuria + dilute urine with high/raising serum sodium/osmolality. Never restrict free access to water in suspected/known DI. Inpatients require strict fluid balance and close sodium monitoring. Discuss all desmopressin starts/changes with endocrinology.')),
 ListTile(leading:Icon(Icons.opacity),title:Text('Desmopressin safety',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('RCH: verify serum Na ≥135 mmol/L (or higher specialist target) within 1–2 h before dose, document dilute urine, and allow a period of diuresis before further doses. Dose routes are not equivalent.')),
 ListTile(leading:Icon(Icons.water_drop_outlined),title:Text('SIADH pattern',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Hyponatremia with inappropriately concentrated urine and low serum osmolality in a clinically euvolemic patient after excluding adrenal, thyroid, renal and medication causes. Fluid restriction and treatment of cause are common principles; symptomatic hyponatremia is an emergency.')),
 Text('Source: RCH Diabetes insipidus guideline and local hyponatremia/SIADH pathway.'),
]);}

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

class InsulinCalculatorScreen extends StatefulWidget{const InsulinCalculatorScreen({super.key});@override State<InsulinCalculatorScreen> createState()=>_InsulinCalculatorScreenState();}
class _InsulinCalculatorScreenState extends State<InsulinCalculatorScreen>{final weight=TextEditingController(text:'40'),tdd=TextEditingController(text:'30'),carbs=TextEditingController(text:'60'),bg=TextEditingController(text:'12'),target=TextEditingController(text:'6');double basalPct=.45;@override void dispose(){weight.dispose();tdd.dispose();carbs.dispose();bg.dispose();target.dispose();super.dispose();}double? n(c)=>double.tryParse(c.text.trim());@override Widget build(BuildContext context){final T=n(tdd),C=n(carbs),B=n(bg),Tg=n(target);final basal=T==null?null:T*basalPct;final icr=T==null||T<=0?null:500/T;final isf=T==null||T<=0?null:100/T;final carbDose=icr==null||C==null?null:C/icr;final corr=isf==null||B==null||Tg==null?null:math.max(0,(B-Tg)/isf);return _endoPage(context,'Insulin calculators',[
 _endoNotice(context,'Educational dose-estimation workspace. Existing individualized diabetes plans, pump settings and endocrinology orders supersede formula estimates. Do not use these rules to create a new insulin regimen without clinical review.'),
 Row(children:[Expanded(child:_endoField(weight,'Weight','kg',()=>setState((){}))),const SizedBox(width:8),Expanded(child:_endoField(tdd,'Known TDD','units/day',()=>setState((){})))]),
 Text('Basal fraction ${(basalPct*100).round()}%'),Slider(value:basalPct,min:.3,max:.6,divisions:30,onChanged:(v)=>setState(()=>basalPct=v)),
 if(basal!=null)_endoResult('Basal estimate','${basal.toStringAsFixed(1)} units/day'),if(icr!=null)_endoResult('500-rule carb-ratio estimate','1 unit per ${icr.toStringAsFixed(1)} g carbohydrate'),if(isf!=null)_endoResult('100-rule ISF estimate','1 unit lowers glucose by ~${isf.toStringAsFixed(1)} mmol/L'),
 const Divider(),Row(children:[Expanded(child:_endoField(carbs,'Carbohydrate','g',()=>setState((){}))),const SizedBox(width:8),Expanded(child:_endoField(bg,'Current BG','mmol/L',()=>setState((){}))),const SizedBox(width:8),Expanded(child:_endoField(target,'Target BG','mmol/L',()=>setState((){})))]),
 if(carbDose!=null)_endoResult('Carbohydrate dose estimate','${carbDose.toStringAsFixed(2)} units'),if(corr!=null)_endoResult('Correction estimate','${corr.toStringAsFixed(2)} units'),if(carbDose!=null&&corr!=null)_endoResult('Combined estimate','${(carbDose+corr).toStringAsFixed(2)} units BEFORE individualized rounding/IOB review'),
 const Text('Before dosing: check active insulin/insulin-on-board, exercise, illness/ketones, meal timing, pump status, hypoglycemia risk and the patient-specific correction/carb ratios.'),
 ]);}}

Widget _endoPage(BuildContext context,String title,List<Widget> children)=>Scaffold(appBar:AppBar(title:Text(title,style:const TextStyle(fontWeight:FontWeight.w900))),body:ListView(padding:const EdgeInsets.fromLTRB(16,8,16,28),children:children.map((w)=>Padding(padding:const EdgeInsets.only(bottom:10),child:w)).toList()));
Widget _endoNotice(BuildContext context,String text)=>Card(color:Theme.of(context).colorScheme.primaryContainer,child:Padding(padding:const EdgeInsets.all(14),child:Text(text)));
Widget _endoField(TextEditingController c,String label,String suffix,VoidCallback changed)=>TextField(controller:c,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:label,suffixText:suffix,border:const OutlineInputBorder()),onChanged:(_)=>changed());
Widget _endoResult(String label,String value)=>Card(child:Padding(padding:const EdgeInsets.all(12),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Text(label)),const SizedBox(width:10),Flexible(child:Text(value,textAlign:TextAlign.right,style:const TextStyle(fontWeight:FontWeight.w800)))])));
