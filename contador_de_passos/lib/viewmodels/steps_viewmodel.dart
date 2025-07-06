import 'package:flutter/material.dart';
import '../models/step_data.dart';
import '../services/health_service.dart';

class StepsViewModel extends ChangeNotifier {
  final HealthService _healthService = HealthService();
  
  StepData? _stepData;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasPermissions = false;

  // Getters
  StepData? get stepData => _stepData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasPermissions => _hasPermissions;

  /// Inicializa o ViewModel
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();
    
    try {
      // Verifica se o Health Connect está disponível
      bool isAvailable = await _healthService.isHealthConnectAvailable();
      if (!isAvailable) {
        _setError('Health Connect não está disponível neste dispositivo');
        return;
      }

      // Verifica se já tem permissões
      _hasPermissions = await _healthService.hasPermissions();
      
      if (_hasPermissions) {
        await _loadStepData();
      }
    } catch (e) {
      _setError('Erro ao inicializar: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Solicita permissões para acessar dados de saúde
  Future<bool> requestPermissions() async {
    _setLoading(true);
    _clearError();
    
    try {
      bool granted = await _healthService.requestPermissions();
      _hasPermissions = granted;
      
      if (granted) {
        await _loadStepData();
      } else {
        _setError('Permissões não concedidas');
      }
      
      return granted;
    } catch (e) {
      _setError('Erro ao solicitar permissões: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega os dados de passos
  Future<void> loadStepData() async {
    if (!_hasPermissions) {
      _setError('Permissões não concedidas');
      return;
    }
    
    await _loadStepData();
  }

  /// Atualiza os dados de passos
  Future<void> refreshStepData() async {
    await _loadStepData();
  }

  /// Método privado para carregar dados
  Future<void> _loadStepData() async {
    _setLoading(true);
    _clearError();
    
    try {
      StepData? data = await _healthService.getStepsLast24Hours();
      if (data != null) {
        _stepData = data;
      } else {
        _setError('Não foi possível carregar os dados de passos');
      }
    } catch (e) {
      _setError('Erro ao carregar dados: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Define o estado de carregamento
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Define uma mensagem de erro
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Limpa mensagens de erro
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}