import 'package:health/health.dart';
import '../models/step_data.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();
  
  // Tipos de dados que queremos acessar
  static const List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
  ];

  // Permissões necessárias
  static const List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
  ];

  /// Verifica se o Health Connect está disponível
  Future<bool> isHealthConnectAvailable() async {
    // A biblioteca 'health' não tem um método direto para verificar o Health Connect.
    // Uma abordagem é verificar a disponibilidade de um tipo de dado.
    return await _health.isDataTypeAvailable(HealthDataType.STEPS);
  }

  /// Solicita permissões para acessar dados de saúde
  Future<bool> requestPermissions() async {
    try {
      // Solicita permissões do Health Connect
      bool requested = await _health.requestAuthorization(
        _dataTypes,
        permissions: _permissions,
      );

      if (requested) {
        // Verifica se as permissões foram concedidas
        bool? hasPermissions = await _health.hasPermissions(_dataTypes);
        return hasPermissions ?? false;
      }
      
      return false;
    } catch (e) {
      print('Erro ao solicitar permissões: $e');
      return false;
    }
  }

  /// Obtém os dados de passos das últimas 24 horas
  Future<StepData?> getStepsLast24Hours() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      // Busca dados de passos
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [HealthDataType.STEPS],
      );

      if (healthData.isEmpty) {
        return StepData(
          totalSteps: 0,
          date: now,
          source: 'Nenhum dado encontrado',
        );
      }

      // Filtra dados apenas do smartwatch (exclui dados do telefone)
      List<HealthDataPoint> watchData = healthData.where((dataPoint) {
        // Verifica se a fonte é um smartwatch
        String sourceName = dataPoint.sourceName.toLowerCase();
        return sourceName.contains('watch') || 
               sourceName.contains('wear') ||
               sourceName.contains('galaxy watch') ||
               sourceName.contains('pixel watch') ||
               sourceName.contains('fitbit');
      }).toList();

      // Se não encontrar dados do smartwatch, usa todos os dados disponíveis
      List<HealthDataPoint> dataToProcess = watchData.isNotEmpty ? watchData : healthData;

      if (dataToProcess.isEmpty) {
        return StepData(
          totalSteps: 0,
          date: now,
          source: 'Nenhum dado de passos',
        );
      }

      // Calcula o total de passos
      int totalSteps = 0;
      String source = 'Health Connect';
      
      for (var dataPoint in dataToProcess) {
        if (dataPoint.value is NumericHealthValue) {
          totalSteps += (dataPoint.value as NumericHealthValue).numericValue.toInt();
          source = dataPoint.sourceName;
        }
      }

      return StepData(
        totalSteps: totalSteps,
        date: now,
        source: source,
      );
      
    } catch (e) {
      print('Erro ao obter dados de passos: $e');
      return null;
    }
  }

  /// Verifica se o usuário tem permissões concedidas
  Future<bool> hasPermissions() async {
    // O método hasPermissions pode retornar nulo, então tratamos isso
    return await _health.hasPermissions(_dataTypes) ?? false;
  }
}
