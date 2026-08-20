import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class AccessibilityService extends ChangeNotifier {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  late Box _box;

  bool _agrandarTexto = false;
  bool _altoContraste = false;
  bool _espaciadoTexto = false;
  bool _alturaLinea = false;
  bool _reducirAnimaciones = false;
  bool _dislexia = false;
  bool _escalaGrises = false;

  bool get agrandarTexto => _agrandarTexto;
  bool get altoContraste => _altoContraste;
  bool get espaciadoTexto => _espaciadoTexto;
  bool get alturaLinea => _alturaLinea;
  bool get reducirAnimaciones => _reducirAnimaciones;
  bool get dislexia => _dislexia;
  bool get escalaGrises => _escalaGrises;

  static Future<void> init() async {
    _instance._box = await Hive.openBox('accessibility_box');
    _instance._cargarDatos();
  }

  void _cargarDatos() {
    _agrandarTexto = _box.get('agrandarTexto', defaultValue: false);
    _altoContraste = _box.get('altoContraste', defaultValue: false);
    _espaciadoTexto = _box.get('espaciadoTexto', defaultValue: false);
    _alturaLinea = _box.get('alturaLinea', defaultValue: false);
    _reducirAnimaciones = _box.get('reducirAnimaciones', defaultValue: false);
    _dislexia = _box.get('dislexia', defaultValue: false);
    _escalaGrises = _box.get('escalaGrises', defaultValue: false);
  }

  void toggleAgrandarTexto(bool value) {
    _agrandarTexto = value;
    _box.put('agrandarTexto', value);
    notifyListeners();
  }

  void toggleAltoContraste(bool value) {
    _altoContraste = value;
    _box.put('altoContraste', value);
    notifyListeners();
  }

  void toggleEspaciadoTexto(bool value) {
    _espaciadoTexto = value;
    _box.put('espaciadoTexto', value);
    notifyListeners();
  }

  void toggleAlturaLinea(bool value) {
    _alturaLinea = value;
    _box.put('alturaLinea', value);
    notifyListeners();
  }

  void toggleReducirAnimaciones(bool value) {
    _reducirAnimaciones = value;
    _box.put('reducirAnimaciones', value);
    notifyListeners();
  }

  void toggleDislexia(bool value) {
    _dislexia = value;
    _box.put('dislexia', value);
    notifyListeners();
  }

  void toggleEscalaGrises(bool value) {
    _escalaGrises = value;
    _box.put('escalaGrises', value);
    notifyListeners();
  }

  void restablecer() {
    _agrandarTexto = false;
    _altoContraste = false;
    _espaciadoTexto = false;
    _alturaLinea = false;
    _reducirAnimaciones = false;
    _dislexia = false;
    _escalaGrises = false;
    _box.clear();
    notifyListeners();
  }
}
