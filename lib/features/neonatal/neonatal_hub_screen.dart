// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../bilirubin/bilirubin_screen.dart';

class NeonatalHubScreen extends StatelessWidget {
  const NeonatalHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_NeoItem>[
      _NeoItem('CPS neonatal bilirubin', 'Phototherapy, ΔTSB, pre-exchange/exchange support', Icons.wb_sunny_outlined, const BilirubinScreen()),
      _NeoItem('Neonatal hypoglycemia', 'CPS screening, dextrose gel, IV dextrose and GIR support', Icons.bloodtype_outlined, const NeonatalHypoglycemiaScreen()),
      _NeoItem('EOS / sepsis assessment', 'Clinical illness and maternal risk-factor framework', Icons.coronavirus_outlined, const NeonatalEosScreen()),
      _NeoItem('Neonatal fluids & GIR', 'mL/kg/day, hourly rate, glucose infusion rate and total glucose', Icons.water_drop_outlined, const NeonatalFluidsScreen()),
      _NeoItem('Corrected gestational age', 'PMA / corrected age from GA at birth and chronological age', Icons.calendar_month_outlined, const NeonatalCorrectedAgeScreen()),
      _NeoItem('Feeding calculator', 'mL/kg/day → mL/day, mL/feed and kcal/kg/day', Icons.local_drink_outlined, const NeonatalFeedingScreen()),
      _NeoItem('Neonatal medication reference', 'GA/PMA-aware safety framework and high-alert reminders', Icons.medication_outlined, const NeonatalMedicationReferenceScreen()),
      _NeoItem('Newborn resuscitation quick reference', '2025 ventilation-first newborn resuscitation sequence', Icons.emergency_outlined, const NeonatalResuscitationScreen()),
    ];
    String query = '';
    return StatefulBuilder(builder: (context, setLocal) {
      final visible = items.where((x) => '${x.title} ${x.subtitle}'.toLowerCase().contains(query.toLowerCase())).toList();
      return Scaffold(
        appBar: AppBar(title: const Text('Neonatal Hub', style: TextStyle(fontWeight: FontWeight.w900))),
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          itemCount: visible.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            if (i == 0) return TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search within Neonatal Hub…', border: OutlineInputBorder()), onChanged: (v) => setLocal(() => query = v));
            final item = visible[i - 1];
            return Card(child: ListTile(
              leading: CircleAvatar(child: Icon(item.icon)), title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(item.subtitle), trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => item.screen)),
            ));
          },
        ),
      );
    });
  }
}

class _NeoItem {
  final String title, subtitle;
  final IconData icon;
  final Widget screen;
  const _NeoItem(this.title, this.subtitle, this.icon, this.screen);
}

class NeonatalHypoglycemiaScreen extends StatefulWidget {
  const NeonatalHypoglycemiaScreen({super.key});
  @override State<NeonatalHypoglycemiaScreen> createState() => _NeonatalHypoglycemiaScreenState();
}

class _NeonatalHypoglycemiaScreenState extends State<NeonatalHypoglycemiaScreen> {
  final _weight = TextEditingController(text: '3.2');
  final _glucose = TextEditingController(text: '2.1');
  int _hours = 6;
  bool _symptomatic = false;
  @override void dispose(){_weight.dispose();_glucose.dispose();super.dispose();}
  double? _n(TextEditingController c)=>double.tryParse(c.text.trim());
  @override Widget build(BuildContext context){
    final w=_n(_weight), g=_n(_glucose);
    final gelMl=w==null?null:0.5*w;
    final d10Bolus=w==null?null:2*w;
    final persistent=_hours>72;
    String band='Enter glucose';
    if(g!=null){
      if(persistent) band=g<2.8?'Below persistent-hypoglycemia investigation threshold':'At/above investigation threshold';
      else if(g<1.8) band='Very low — expedite treatment';
      else if(g<2.6) band='Below transitional intervention threshold';
      else band='At/above 2.6 mmol/L';
    }
    return _page(context,'Neonatal hypoglycemia',[
      _notice(context,'CPS framework: transitional hypoglycemia is <2.6 mmol/L during the first 72 h; persistent hypoglycemia after 72 h uses higher investigation/therapeutic targets. Always interpret a bedside result with symptoms, feeding, risk factors and confirmatory testing when indicated.'),
      Row(children:[Expanded(child:_field(_weight,'Weight','kg',()=>setState((){}))),const SizedBox(width:8),Expanded(child:_field(_glucose,'Glucose','mmol/L',()=>setState((){})))]),
      const SizedBox(height:10),
      DropdownButtonFormField<int>(initialValue:_hours,decoration:const InputDecoration(labelText:'Age',border:OutlineInputBorder()),items:const [2,6,12,24,48,72,96,120].map((h)=>DropdownMenuItem(value:h,child:Text('$h hours'))).toList(),onChanged:(v)=>setState(()=>_hours=v??_hours)),
      SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('Symptoms / clinical concern'),subtitle:const Text('Jitteriness, lethargy, apnea, seizures, poor feeding or other concerning signs'),value:_symptomatic,onChanged:(v)=>setState(()=>_symptomatic=v)),
      _result('Assessment',band),
      if(gelMl!=null)_result('40% dextrose gel reference','0.5 mL/kg = ${gelMl.toStringAsFixed(1)} mL (200 mg/kg), give with a feed when appropriate'),
      if(d10Bolus!=null)_result('D10W rescue reference','2 mL/kg = ${d10Bolus.toStringAsFixed(1)} mL may be used for very low/symptomatic glucose per local neonatal protocol'),
      const Divider(),
      const Text('CPS bedside sequence',style:TextStyle(fontWeight:FontWeight.w900)),
      const SizedBox(height:6),
      const Text('• Screen at-risk infants starting at ~2 h and then every 3–6 h with feeds.\n• Asymptomatic 1.8–2.5 mmol/L: enteral supplementation and recheck in ~30 min.\n• Symptomatic hypoglycemia, very low values, or failure of enteral measures: IV dextrose.\n• D10W at 80 mL/kg/day provides GIR ≈5.5 mg/kg/min.\n• Persistent/recurrent hypoglycemia beyond the transitional period needs diagnostic evaluation and a critical sample when indicated.'),
      if(_symptomatic) const Card(child:Padding(padding:EdgeInsets.all(12),child:Text('⚠ Symptoms + low glucose require prompt treatment and monitored reassessment; do not delay for repeated screening.'))),
      const Text('Source: Canadian Paediatric Society, The screening and management of newborns at risk for low blood glucose, updated March 2025.'),
    ]);
  }
}

class NeonatalEosScreen extends StatefulWidget {const NeonatalEosScreen({super.key});@override State<NeonatalEosScreen> createState()=>_NeonatalEosScreenState();}
class _NeonatalEosScreenState extends State<NeonatalEosScreen>{
  bool unwell=false,gbs=false,bacteriuria=false,prior=false,rom=false,fever=false,adequateIap=false;int ga=39;
  @override Widget build(BuildContext context){final n=[gbs,bacteriuria,prior,rom,fever].where((x)=>x).length;String plan;if(unwell){plan='UNWELL: prompt cultures/investigation and empiric IV antibiotics after cultures; do not rely on a normal CBC to rule out EOS.';}else if(ga<37){plan='Preterm infant: this term-infant CPS framework is not sufficient. Use neonatal/local preterm sepsis pathway.';}else if(n==0){plan='No listed maternal EOS risk factor selected. Continue routine clinical surveillance.';}else if(n==1&&adequateIap){plan='Well term infant with one risk factor and adequate IAP: close clinical assessment/observation; routine labs/antibiotics are often not required in the CPS framework.';}else{plan='Multiple risk factors and/or inadequate IAP: individualized assessment with close observation; investigation/treatment may be warranted depending on risk severity and local pathway.';}
    return _page(context,'EOS / sepsis assessment',[
      _notice(context,'This is a risk-factor framework, not a probability calculator. The CPS term-infant statement is older (2017) and applies primarily to ≥37-week newborns. Local neonatal EOS pathways supersede.'),
      DropdownButtonFormField<int>(initialValue:ga,decoration:const InputDecoration(labelText:'Gestational age',border:OutlineInputBorder()),items:List.generate(23,(i)=>i+20).map((x)=>DropdownMenuItem(value:x,child:Text('$x weeks'))).toList(),onChanged:(v)=>setState(()=>ga=v??ga)),
      _check('Infant clinically unwell',unwell,(v)=>setState(()=>unwell=v)),
      _check('Maternal GBS colonization',gbs,(v)=>setState(()=>gbs=v)),
      _check('GBS bacteriuria this pregnancy',bacteriuria,(v)=>setState(()=>bacteriuria=v)),
      _check('Previous infant with invasive GBS',prior,(v)=>setState(()=>prior=v)),
      _check('Rupture of membranes ≥18 h',rom,(v)=>setState(()=>rom=v)),
      _check('Maternal temperature ≥38°C',fever,(v)=>setState(()=>fever=v)),
      _check('Adequate intrapartum GBS prophylaxis',adequateIap,(v)=>setState(()=>adequateIap=v)),
      _result('Selected maternal risk factors','$n'),_result('Framework output',plan),
      const Text('Clinical signs suggesting EOS include respiratory distress, temperature instability, tachycardia, seizures, hypotonia/lethargy, poor perfusion, hypotension and acidosis. Blood culture remains the diagnostic standard; screening WBC indices are not sufficiently sensitive to rule out EOS.'),
      const SizedBox(height:8),
      const Text('Empiric treatment for an unwell term infant should cover common EOS pathogens; CPS identifies ampicillin plus an aminoglycoside as a typical initial combination, adjusted for local susceptibility and meningitis concern.'),
      const Text('Source: Canadian Paediatric Society, Management of term infants at increased risk for early onset bacterial sepsis.'),
    ]);
  }
}

class NeonatalFluidsScreen extends StatefulWidget {const NeonatalFluidsScreen({super.key});@override State<NeonatalFluidsScreen> createState()=>_NeonatalFluidsScreenState();}
class _NeonatalFluidsScreenState extends State<NeonatalFluidsScreen>{
  final w=TextEditingController(text:'3.2'),mlkg=TextEditingController(text:'80'),dex=TextEditingController(text:'10');
  @override void dispose(){w.dispose();mlkg.dispose();dex.dispose();super.dispose();}
  double? n(TextEditingController c)=>double.tryParse(c.text.trim());
  @override Widget build(BuildContext context){final W=n(w),V=n(mlkg),D=n(dex);final day=W!=null&&V!=null?W*V:null;final rate=day==null?null:day/24;final gir=W!=null&&W>0&&rate!=null&&D!=null?D*rate/(6*W):null;return _page(context,'Neonatal fluids & GIR',[
    _notice(context,'Calculator only. Neonatal fluid prescriptions depend on gestational age, postnatal day, birth weight, humidity/incubator losses, urine output, sodium, glucose, enteral feeds and clinical condition.'),
    Row(children:[Expanded(child:_field(w,'Weight','kg',()=>setState((){}))),const SizedBox(width:8),Expanded(child:_field(mlkg,'Total fluid','mL/kg/day',()=>setState((){}))),const SizedBox(width:8),Expanded(child:_field(dex,'Dextrose','%',()=>setState((){})))]),
    if(day!=null)_result('Total volume','${day.toStringAsFixed(1)} mL/day'),if(rate!=null)_result('Hourly rate','${rate.toStringAsFixed(2)} mL/hr'),if(gir!=null)_result('GIR','${gir.toStringAsFixed(2)} mg/kg/min'),
    const Text('Formula: GIR (mg/kg/min) = dextrose % × mL/hr ÷ (6 × kg). For example, D10W at 80 mL/kg/day gives GIR ≈5.6 mg/kg/min.'),
  ]);}
}

class NeonatalCorrectedAgeScreen extends StatefulWidget {const NeonatalCorrectedAgeScreen({super.key});@override State<NeonatalCorrectedAgeScreen> createState()=>_NeonatalCorrectedAgeScreenState();}
class _NeonatalCorrectedAgeScreenState extends State<NeonatalCorrectedAgeScreen>{int gw=30,gd=0,chron=70;@override Widget build(BuildContext context){final birthDays=gw*7+gd;final pmaDays=birthDays+chron;final pw=pmaDays~/7,pd=pmaDays%7;final correction=math.max(0,280-birthDays);final corrected=math.max(0,chron-correction);return _page(context,'Corrected gestational age',[
  Row(children:[Expanded(child:DropdownButtonFormField<int>(initialValue:gw,decoration:const InputDecoration(labelText:'GA weeks',border:OutlineInputBorder()),items:List.generate(23,(i)=>i+20).map((x)=>DropdownMenuItem(value:x,child:Text('$x'))).toList(),onChanged:(v)=>setState(()=>gw=v??gw))),const SizedBox(width:8),Expanded(child:DropdownButtonFormField<int>(initialValue:gd,decoration:const InputDecoration(labelText:'+ days',border:OutlineInputBorder()),items:List.generate(7,(i)=>i).map((x)=>DropdownMenuItem(value:x,child:Text('$x'))).toList(),onChanged:(v)=>setState(()=>gd=v??gd)))]),
  const SizedBox(height:10),Slider(value:chron.toDouble(),min:0,max:730,divisions:146,label:'$chron d',onChanged:(v)=>setState(()=>chron=v.round())),_result('Chronological age','$chron days'),_result('Postmenstrual age','$pw weeks + $pd days'),_result('Prematurity correction','$correction days'),_result('Corrected age','$corrected days (${(corrected/30.4375).toStringAsFixed(1)} months)'),
  const Text('Corrected age = chronological age − weeks/days born before 40 weeks. Use local developmental/growth policy for how long to correct.'),
]);}}

class NeonatalFeedingScreen extends StatefulWidget {const NeonatalFeedingScreen({super.key});@override State<NeonatalFeedingScreen> createState()=>_NeonatalFeedingScreenState();}
class _NeonatalFeedingScreenState extends State<NeonatalFeedingScreen>{final w=TextEditingController(text:'3.2'),goal=TextEditingController(text:'150'),kcal=TextEditingController(text:'20');int feeds=8;@override void dispose(){w.dispose();goal.dispose();kcal.dispose();super.dispose();}double? n(c)=>double.tryParse(c.text.trim());@override Widget build(BuildContext context){final W=n(w),G=n(goal),K=n(kcal);final daily=W!=null&&G!=null?W*G:null,each=daily==null?null:daily/feeds,kcalKg=G!=null&&K!=null?G*K/30:null;return _page(context,'Neonatal feeding calculator',[
 Row(children:[Expanded(child:_field(w,'Weight','kg',()=>setState((){}))),const SizedBox(width:8),Expanded(child:_field(goal,'Feed goal','mL/kg/day',()=>setState((){}))),const SizedBox(width:8),Expanded(child:_field(kcal,'Energy density','kcal/oz',()=>setState((){})))]),
 const SizedBox(height:10),DropdownButtonFormField<int>(initialValue:feeds,decoration:const InputDecoration(labelText:'Feeds per day',border:OutlineInputBorder()),items:const [6,8,10,12,24].map((x)=>DropdownMenuItem(value:x,child:Text('$x'))).toList(),onChanged:(v)=>setState(()=>feeds=v??feeds)),if(daily!=null)_result('Daily enteral volume','${daily.toStringAsFixed(0)} mL/day'),if(each!=null)_result('Volume per feed','${each.toStringAsFixed(1)} mL/feed'),if(kcalKg!=null)_result('Approx energy','${kcalKg.toStringAsFixed(0)} kcal/kg/day'),
 const Text('Energy estimate assumes kcal/oz ÷ 30 ≈ kcal/mL. Feeding advancement, fortification and fluid restriction must follow neonatal/dietitian guidance.'),
]);}}

class NeonatalMedicationReferenceScreen extends StatelessWidget{const NeonatalMedicationReferenceScreen({super.key});@override Widget build(BuildContext context)=>_page(context,'Neonatal medication reference',const[
 Card(child:Padding(padding:EdgeInsets.all(14),child:Text('Neonatal dosing is strongly dependent on gestational age, postmenstrual age, postnatal age, weight, renal function, indication and local formulation. PedsFlow intentionally does not extrapolate a general pediatric mg/kg dose into a neonatal dose.'))),
 ListTile(leading:Icon(Icons.schedule_outlined),title:Text('Always capture GA / PMA / PNA',style:TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('Dose interval often changes as renal/hepatic clearance matures.')),
 ListTile(leading:Icon(Icons.scale_outlined),title:Text('Use current dosing weight',style:TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('Confirm birth weight versus current/adjusted dosing weight where relevant.')),
 ListTile(leading:Icon(Icons.water_drop_outlined),title:Text('Renal clearance matters',style:TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('Aminoglycosides, vancomycin and other renally cleared drugs need interval/level-based adjustment.')),
 ListTile(leading:Icon(Icons.warning_amber_outlined),title:Text('High-alert infusions',style:TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('Verify concentration, line, compatibility, smart-pump library and independent double-check.')),
 Text('Use the PedsFlow medication library for monographs, but verify neonatal-specific doses against the current local NICU formulary/pharmacy reference before prescribing.'),
]);}

class NeonatalResuscitationScreen extends StatelessWidget{const NeonatalResuscitationScreen({super.key});@override Widget build(BuildContext context)=>_page(context,'Newborn resuscitation quick reference',const[
 Card(child:Padding(padding:EdgeInsets.all(14),child:Text('2025 AHA/AAP newborn resuscitation: effective ventilation remains the priority. Use trained neonatal-resuscitation teams and your local NRP algorithm.'))),
 ListTile(leading:CircleAvatar(child:Text('1')),title:Text('Initial transition',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Warm, maintain temperature, position airway, dry/stimulate when appropriate; assess breathing and heart rate. Deferred cord clamping ≥60 s is appropriate for many newborns not requiring immediate resuscitation.')),
 ListTile(leading:CircleAvatar(child:Text('2')),title:Text('Ventilate when needed',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Apnea/gasping or persistent HR <100/min: provide assisted ventilation within the first 60 s. Recommended ventilation rate 30–60 inflations/min; initial PIP 20–30 cmH₂O is reasonable and titrated to chest movement/HR response.')),
 ListTile(leading:CircleAvatar(child:Text('3')),title:Text('Correct ineffective ventilation',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Reposition airway, improve mask seal/two-hand hold, suction if obstructed, increase pressure as needed, and place an alternative airway when ventilation remains ineffective. Rising HR is the key response.')),
 ListTile(leading:CircleAvatar(child:Text('4')),title:Text('HR <60 despite effective ventilation',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('After ~30 s of ventilation that moves the chest: chest compressions. Prefer ETT/alternative airway. Use synchronized 3:1 compression:ventilation ratio (90 compressions + 30 inflations/min) with two-thumb encircling technique.')),
 ListTile(leading:CircleAvatar(child:Text('5')),title:Text('HR remains <60 after compressions',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('After ~60 s of compressions + adequate ventilation: intravascular epinephrine 0.01–0.03 mg/kg; repeat every 3–5 min if HR remains <60. UVC is preferred vascular access; IO may be considered.')),
 ListTile(leading:Icon(Icons.monitor_heart_outlined),title:Text('Oxygen / monitoring',style:TextStyle(fontWeight:FontWeight.w900)),subtitle:Text('Pulse oximetry guides oxygen. Start term/late-preterm ventilation with 21% O₂; preterm oxygen strategy varies by GA. 100% O₂ may be used during compressions then titrated after ROSC. ECG is useful during advanced resuscitation.')),
 Text('Source: 2025 American Heart Association / American Academy of Pediatrics neonatal resuscitation guidelines. Local NRP training card and equipment remain authoritative.'),
]);}

Widget _page(BuildContext context,String title,List<Widget> children)=>Scaffold(appBar:AppBar(title:Text(title,style:const TextStyle(fontWeight:FontWeight.w900))),body:ListView(padding:const EdgeInsets.fromLTRB(16,8,16,28),children:children.map((w)=>Padding(padding:const EdgeInsets.only(bottom:10),child:w)).toList()));
Widget _notice(BuildContext context,String text)=>Card(color:Theme.of(context).colorScheme.primaryContainer,child:Padding(padding:const EdgeInsets.all(14),child:Text(text)));
Widget _field(TextEditingController c,String label,String suffix,VoidCallback changed)=>TextField(controller:c,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:label,suffixText:suffix,border:const OutlineInputBorder()),onChanged:(_)=>changed());
Widget _result(String label,String value)=>Card(child:Padding(padding:const EdgeInsets.all(12),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Text(label)),const SizedBox(width:10),Flexible(child:Text(value,textAlign:TextAlign.right,style:const TextStyle(fontWeight:FontWeight.w800)))])));
Widget _check(String title,bool value,ValueChanged<bool> onChanged)=>CheckboxListTile(contentPadding:EdgeInsets.zero,title:Text(title),value:value,onChanged:(v)=>onChanged(v??false));
