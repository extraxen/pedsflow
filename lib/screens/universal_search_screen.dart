// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/bilirubin/bilirubin_screen.dart';
import '../features/dka/dka_calculator_screen.dart';
import '../features/electrolytes/electrolyte_engine_screen.dart';
import '../features/electrolytes/hypokalemia_engine_screen.dart';
import '../features/endocrine/endocrine_hub_screen.dart';
import '../features/growth/growth_suite_screen.dart';
import '../features/neonatal/neonatal_hub_screen.dart';
import '../models/admission_plan.dart';
import '../models/medication_monograph.dart';
import '../services/app_store.dart';
import '../services/global_search.dart';
import 'antibiotic_guide_screen.dart';
import 'calculators_screen.dart';
import 'clinical_sources_screen.dart';
import 'escalation_screen.dart';
import 'integrated_clinical_support_screen.dart';
import 'library_screen.dart';
import 'medication_quality_screen.dart';
import 'medication_reference_screen.dart';
import 'medications_screen.dart';
import 'more_screen.dart';
import 'pain_management_screen.dart';
import 'pccu_screen.dart';
import 'pediatric_reference_screen.dart';
import 'plan_screen.dart';

class UniversalSearchScreen extends StatefulWidget {
  final AppStore store;
  const UniversalSearchScreen({super.key, required this.store});
  @override State<UniversalSearchScreen> createState() => _UniversalSearchScreenState();
}

class _UniversalSearchScreenState extends State<UniversalSearchScreen> {
  static const String _recentKey = 'pedsflow_search_recent_v2';
  static const String _favoriteKey = 'pedsflow_search_favorites_v2';
  final TextEditingController _controller = TextEditingController();
  GlobalSearchIndex? _index;
  List<SearchHit> _hits = const <SearchHit>[];
  String _filter = 'all';
  Timer? _debounce;
  String _query = '';
  List<String> _recent = <String>[];
  Set<String> _favoriteIds = <String>{};

  static const List<(String, String)> _filters = <(String, String)>[
    ('all','All'), ('pccu','PCCU'), ('medication','Medications'), ('plan','Plans'),
    ('calculators','Calculators'), ('electrolytes','Electrolytes'), ('neonatal','Neonatal'),
    ('endocrine','Endocrine'), ('growth','Growth'), ('antibiotic','Antibiotics'), ('pain','Pain'),
  ];

  @override void initState(){super.initState();_load();}
  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final GlobalSearchIndex index = await GlobalSearchIndex.build(widget.store);
    if(!mounted)return;
    setState((){
      _recent = prefs.getStringList(_recentKey) ?? <String>[];
      _favoriteIds = (prefs.getStringList(_favoriteKey) ?? <String>[]).toSet();
      _index=index;
      _runSearch();
    });
  }
  @override void dispose(){_debounce?.cancel();_controller.dispose();super.dispose();}

  void _onChanged(String value){
    _query=value;
    _debounce?.cancel();
    _debounce=Timer(const Duration(milliseconds:90),(){if(mounted)setState(_runSearch);});
  }
  void _runSearch(){
    final String? engineKind = switch(_filter){
      'electrolytes' => 'electrolytes',
      'neonatal' => 'neonatal',
      'endocrine' => 'endocrine',
      'growth' => 'growth',
      _ => _filter,
    };
    _hits=_index?.search(_query,kind:engineKind)??const<SearchHit>[];
  }

  Future<void> _remember(String q) async {
    final String clean=q.trim(); if(clean.length<2)return;
    _recent.removeWhere((x)=>x.toLowerCase()==clean.toLowerCase());
    _recent.insert(0,clean); if(_recent.length>10)_recent=_recent.take(10).toList();
    final p=await SharedPreferences.getInstance();await p.setStringList(_recentKey,_recent);if(mounted)setState((){});
  }
  Future<void> _toggleFavorite(SearchDocument d) async {
    if(_favoriteIds.contains(d.id)){_favoriteIds.remove(d.id);}else{_favoriteIds.add(d.id);}
    final p=await SharedPreferences.getInstance();await p.setStringList(_favoriteKey,_favoriteIds.toList());if(mounted)setState((){});
  }
  void _applyQuery(String q){_controller.text=q;_controller.selection=TextSelection.collapsed(offset:q.length);setState((){_query=q;_runSearch();});}

  double? get _commandWeight {
    final m=RegExp(r'(\d+(?:\.\d+)?)\s*kg\b',caseSensitive:false).firstMatch(_query);
    return m==null?null:double.tryParse(m.group(1)!);
  }
  String get _semanticQuery => _query.replaceAll(RegExp(r'\d+(?:\.\d+)?\s*kg\b',caseSensitive:false),'').trim();

  @override Widget build(BuildContext context){
    final double? weight=_commandWeight;
    final List<SearchHit> favoriteHits = _index==null?const<SearchHit>[]:_index!.documents.where((d)=>_favoriteIds.contains(d.id)).map((d)=>SearchHit(d,0,'favorite')).toList();
    return Scaffold(
      appBar:AppBar(title:const Text('Search PedsFlow',style:TextStyle(fontWeight:FontWeight.w900))),
      body:SafeArea(child:ListView(
        keyboardDismissBehavior:ScrollViewKeyboardDismissBehavior.onDrag,
        padding:const EdgeInsets.fromLTRB(16,8,16,28),
        children:<Widget>[
          TextField(controller:_controller,autofocus:true,textInputAction:TextInputAction.search,autocorrect:false,enableSuggestions:false,onChanged:_onChanged,onSubmitted:(q)=>_remember(q),decoration:InputDecoration(
            hintText:'Search anything â€” or type â€œketamine dose 25 kgâ€â€¦',prefixIcon:const Icon(Icons.search),
            suffixIcon:_query.isEmpty?null:IconButton(tooltip:'Clear',onPressed:(){_controller.clear();setState((){_query='';_hits=const[];});},icon:const Icon(Icons.clear)),
          )),
          if(weight!=null) Padding(padding:const EdgeInsets.only(top:8),child:Card(color:Theme.of(context).colorScheme.primaryContainer,child:Padding(padding:const EdgeInsets.all(10),child:Row(children:[const Icon(Icons.scale_outlined),const SizedBox(width:8),Expanded(child:Text('Command parser detected ${weight.toStringAsFixed(weight%1==0?0:1)} kg â€¢ clinical query: â€œ$_semanticQueryâ€. Dose results still require opening the verified medication/pathway; PedsFlow will not infer a dose from free text.'))])))),
          const SizedBox(height:10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters
                  .map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: ChoiceChip(
                        label: Text(f.$2),
                        selected: _filter == f.$1,
                        onSelected: (_) {
                          setState(() {
                            _filter = f.$1;
                          });
                          _runSearch();
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          if(_index==null)const Padding(padding:EdgeInsets.only(top:28),child:Center(child:CircularProgressIndicator()))
          else if(_query.trim().isEmpty)...[
            const SizedBox(height:18),
            const Text('Quick clinical commands',style:TextStyle(fontSize:17,fontWeight:FontWeight.w900)),const SizedBox(height:8),
            Wrap(spacing:7,runSpacing:7,children:['ketamine dose 25 kg','ceftriaxone meningitis','LP sedation','hyperK','nimbex infusion','CPS bilirubin','DKA cerebral edema','hypophos IV'].map((q)=>ActionChip(label:Text(q),onPressed:()=>_applyQuery(q))).toList()),
            if(_recent.isNotEmpty)...[
              const SizedBox(height:18),Row(children:[const Expanded(child:Text('Recent searches',style:TextStyle(fontSize:17,fontWeight:FontWeight.w900))),TextButton(onPressed:()async{_recent.clear();final p=await SharedPreferences.getInstance();await p.remove(_recentKey);if(mounted)setState((){});},child:const Text('Clear'))]),
              Wrap(spacing:7,runSpacing:7,children:_recent.map((q)=>ActionChip(avatar:const Icon(Icons.history,size:18),label:Text(q),onPressed:()=>_applyQuery(q))).toList()),
            ],
            if(favoriteHits.isNotEmpty)...[
              const SizedBox(height:18),const Text('Favorite results',style:TextStyle(fontSize:17,fontWeight:FontWeight.w900)),const SizedBox(height:6),...favoriteHits.take(12).map((h)=>_resultTile(context,h)),
            ],
            const SizedBox(height:18),const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('Search v2 indexes full admission-plan text, medication dose sections/warnings, PCCU pathways, neonatal/endocrine/electrolyte modules, calculators, pain, antibiotics/organisms, references and saved algorithm notes. Results are ranked globally, so the best clinical destination appears first.'))),
          ]else if(_hits.isEmpty)...[
            const SizedBox(height:24),const Card(child:Padding(padding:EdgeInsets.all(20),child:Text('No match found. Try a shorter clinical term, abbreviation, brand name, indication, or spelling variation.',textAlign:TextAlign.center))),
          ]else...[
            const SizedBox(height:16),
            Text('Best match',style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w900)),
            _bestMatch(context,_hits.first),
            if(_hits.length>1)...[
              const SizedBox(height:14),Text('${_hits.length-1} more results',style:const TextStyle(fontSize:16,fontWeight:FontWeight.w900)),
              ..._hits.skip(1).map((h)=>_resultTile(context,h)),
            ],
          ],
        ],
      )),
    );
  }

  Widget _bestMatch(BuildContext context,SearchHit hit){final d=hit.document;return Card(color:Theme.of(context).colorScheme.primaryContainer,child:ListTile(contentPadding:const EdgeInsets.all(12),leading:CircleAvatar(child:Icon(_iconFor(d.kind))),title:Text(d.title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),subtitle:Text('${d.category} â€¢ matched ${hit.matchedOn}'),trailing:IconButton(tooltip:'Favorite',icon:Icon(_favoriteIds.contains(d.id)?Icons.star:Icons.star_border),onPressed:()=>_toggleFavorite(d)),onTap:(){_remember(_query);_open(context,d);}));}
  Widget _resultTile(BuildContext context,SearchHit hit){final d=hit.document;return Card(child:ListTile(leading:CircleAvatar(child:Icon(_iconFor(d.kind))),title:Text(d.title,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${d.category}${hit.matchedOn=='content'?'':' â€¢ matched ${hit.matchedOn}'}',maxLines:2),trailing:IconButton(tooltip:'Favorite',icon:Icon(_favoriteIds.contains(d.id)?Icons.star:Icons.star_border),onPressed:()=>_toggleFavorite(d)),onTap:(){_remember(_query);_open(context,d);}));}

  IconData _iconFor(String kind)=>switch(kind){
    'medication'=>Icons.medication_outlined,'plan'=>Icons.assignment_outlined,'pccu'=>Icons.monitor_heart_outlined,
    'calculators'||'bilirubin'||'dka'=>Icons.calculate_outlined,'antibiotic'=>Icons.biotech_outlined,'pain'=>Icons.healing_outlined,
    'algorithm'=>Icons.photo_library_outlined,'growth'=>Icons.show_chart,'neonatal'=>Icons.child_care_outlined,'endocrine'=>Icons.hub_outlined,
    'electrolytes'||'hypokalemia_engine'=>Icons.science_outlined,_=>Icons.search_outlined,
  };

  void _open(BuildContext context,SearchDocument d){Widget? screen;switch(d.kind){
    case'plan':final AdmissionPlan? plan=widget.store.planById(d.objectId!);if(plan!=null)screen=PlanScreen(plan:plan,store:widget.store);break;
    case'medication':final MedicationMonograph? med=widget.store.medicationById(d.objectId!);if(med!=null)screen=MedicationDetailScreen(medication:med,store:widget.store);break;
    case'pccu':screen=PccuTopicScreen(title:d.target);break;
    case'calculators':screen=const CalculatorsScreen();break;
    case'hypokalemia_engine':screen=const HypokalemiaEngineScreen();break;
    case'electrolytes':screen=const ElectrolyteEngineScreen();break;
    case'neonatal':screen=const NeonatalHubScreen();break;
    case'endocrine':screen=const EndocrineHubScreen();break;
    case'growth':screen=const GrowthSuiteScreen();break;
    case'pain':screen=const PainManagementScreen();break;
    case'antibiotic':screen=AntibioticGuideScreen(store:widget.store);break;
    case'integrated':screen=const IntegratedClinicalSupportScreen();break;
    case'bilirubin':screen=const BilirubinScreen();break;
    case'dka':screen=const DkaCalculatorScreen();break;
    case'reference':screen=const PediatricReferenceScreen();break;
    case'sources':screen=const ClinicalSourcesScreen();break;
    case'escalation':screen=const EscalationScreen();break;
    case'algorithm':screen=LibraryScreen(store:widget.store);break;
    case'med_quality':screen=MedicationQualityScreen(store:widget.store);break;
    case'med_reference':screen=MedicationReferenceScreen(store:widget.store);break;
    case'more':screen=MoreScreen(store:widget.store);break;
  }if(screen!=null)Navigator.of(context).push(MaterialPageRoute<void>(builder:(_)=>screen!));}
}

