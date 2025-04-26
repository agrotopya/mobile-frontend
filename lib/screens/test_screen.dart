import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrotopya_app/theme/app_theme.dart';
import 'package:agrotopya_app/providers/auth_provider.dart';
import 'package:agrotopya_app/providers/field_provider.dart';
import 'package:agrotopya_app/providers/sensor_provider.dart';
import 'package:agrotopya_app/providers/irrigation_schedule_provider.dart';
import 'package:agrotopya_app/utils/test_data_generator.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool _isLoading = false;
  String _testResults = '';
  int _passedTests = 0;
  int _failedTests = 0;
  int _totalTests = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Testler çalıştırılıyor...\n\n';
      _passedTests = 0;
      _failedTests = 0;
      _totalTests = 0;
    });

    await _testAuthentication();
    await _testFieldOperations();
    await _testSensorOperations();
    await _testIrrigationOperations();

    setState(() {
      _testResults += '\n\nTest Sonuçları: $_passedTests başarılı, $_failedTests başarısız, toplam $_totalTests test';
      _isLoading = false;
    });
  }

  Future<void> _testAuthentication() async {
    _addTestHeader('Kimlik Doğrulama Testleri');
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Test 1: Başarılı giriş
    try {
      final success = await authProvider.login(
        TestDataGenerator.testUserCredentials['username']!,
        TestDataGenerator.testUserCredentials['password']!,
      );
      
      if (success && authProvider.isAuthenticated && authProvider.userId == 1) {
        _addTestResult('Başarılı giriş testi', true);
      } else {
        _addTestResult('Başarılı giriş testi', false, 'Giriş başarılı olmalıydı');
      }
    } catch (e) {
      _addTestResult('Başarılı giriş testi', false, 'Hata: $e');
    }
    
    // Test 2: Başarısız giriş
    try {
      await authProvider.logout(); // Önce çıkış yap
      
      final success = await authProvider.login(
        'wrong_username',
        'wrong_password',
      );
      
      if (!success && !authProvider.isAuthenticated) {
        _addTestResult('Başarısız giriş testi', true);
      } else {
        _addTestResult('Başarısız giriş testi', false, 'Giriş başarısız olmalıydı');
      }
    } catch (e) {
      _addTestResult('Başarısız giriş testi', false, 'Hata: $e');
    }
    
    // Test 3: Çıkış yapma
    try {
      // Önce giriş yap
      await authProvider.login(
        TestDataGenerator.testUserCredentials['username']!,
        TestDataGenerator.testUserCredentials['password']!,
      );
      
      await authProvider.logout();
      
      if (!authProvider.isAuthenticated && authProvider.userId == null) {
        _addTestResult('Çıkış yapma testi', true);
      } else {
        _addTestResult('Çıkış yapma testi', false, 'Çıkış başarılı olmalıydı');
      }
    } catch (e) {
      _addTestResult('Çıkış yapma testi', false, 'Hata: $e');
    }
    
    // Testler için tekrar giriş yap
    await authProvider.login(
      TestDataGenerator.testUserCredentials['username']!,
      TestDataGenerator.testUserCredentials['password']!,
    );
  }

  Future<void> _testFieldOperations() async {
    _addTestHeader('Tarla İşlemleri Testleri');
    
    final fieldProvider = Provider.of<FieldProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Test 1: Tarlaları getirme
    try {
      await fieldProvider.fetchFieldsByUserId(authProvider.userId!);
      
      if (fieldProvider.fields.isNotEmpty) {
        _addTestResult('Tarlaları getirme testi', true);
      } else {
        _addTestResult('Tarlaları getirme testi', false, 'Tarlalar alınmalıydı');
      }
    } catch (e) {
      _addTestResult('Tarlaları getirme testi', false, 'Hata: $e');
    }
    
    // Test 2: Tarla oluşturma
    try {
      final initialCount = fieldProvider.fields.length;
      
      final success = await fieldProvider.createField(
        Field(
          name: 'Test Tarlası',
          location: 'Test Konumu',
          area: 5.0,
          cropType: 'Test Ürünü',
          userId: authProvider.userId!,
        ),
      );
      
      if (success && fieldProvider.fields.length == initialCount + 1) {
        _addTestResult('Tarla oluşturma testi', true);
      } else {
        _addTestResult('Tarla oluşturma testi', false, 'Tarla oluşturulmalıydı');
      }
    } catch (e) {
      _addTestResult('Tarla oluşturma testi', false, 'Hata: $e');
    }
  }

  Future<void> _testSensorOperations() async {
    _addTestHeader('Sensör İşlemleri Testleri');
    
    final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
    final fieldProvider = Provider.of<FieldProvider>(context, listen: false);
    
    if (fieldProvider.fields.isEmpty) {
      _addTestResult('Sensör testleri', false, 'Tarla bulunamadı, önce tarla testlerini çalıştırın');
      return;
    }
    
    final fieldId = fieldProvider.fields.first.id!;
    
    // Test 1: Sensörleri getirme
    try {
      await sensorProvider.fetchSensorsByFieldId(fieldId);
      
      if (sensorProvider.sensors.isNotEmpty) {
        _addTestResult('Sensörleri getirme testi', true);
      } else {
        _addTestResult('Sensörleri getirme testi', false, 'Sensörler alınmalıydı');
      }
    } catch (e) {
      _addTestResult('Sensörleri getirme testi', false, 'Hata: $e');
    }
    
    // Test 2: Sensör oluşturma
    try {
      final initialCount = sensorProvider.sensors.length;
      
      final success = await sensorProvider.createSensor(
        Sensor(
          name: 'Test Sensörü',
          type: 'SOIL_MOISTURE',
          location: 'Test Konumu',
          isActive: true,
          fieldId: fieldId,
        ),
      );
      
      if (success && sensorProvider.sensors.length == initialCount + 1) {
        _addTestResult('Sensör oluşturma testi', true);
      } else {
        _addTestResult('Sensör oluşturma testi', false, 'Sensör oluşturulmalıydı');
      }
    } catch (e) {
      _addTestResult('Sensör oluşturma testi', false, 'Hata: $e');
    }
    
    // Test 3: Son sensör okumalarını getirme
    try {
      if (sensorProvider.sensors.isNotEmpty) {
        final sensorId = sensorProvider.sensors.first.id!;
        await sensorProvider.fetchLatestReading(sensorId);
        
        if (sensorProvider.latestReadings.containsKey(sensorId)) {
          _addTestResult('Son sensör okuması getirme testi', true);
        } else {
          _addTestResult('Son sensör okuması getirme testi', false, 'Sensör okuması alınmalıydı');
        }
      } else {
        _addTestResult('Son sensör okuması getirme testi', false, 'Sensör bulunamadı');
      }
    } catch (e) {
      _addTestResult('Son sensör okuması getirme testi', false, 'Hata: $e');
    }
  }

  Future<void> _testIrrigationOperations() async {
    _addTestHeader('Sulama İşlemleri Testleri');
    
    final irrigationProvider = Provider.of<IrrigationScheduleProvider>(context, listen: false);
    final fieldProvider = Provider.of<FieldProvider>(context, listen: false);
    
    if (fieldProvider.fields.isEmpty) {
      _addTestResult('Sulama testleri', false, 'Tarla bulunamadı, önce tarla testlerini çalıştırın');
      return;
    }
    
    final fieldId = fieldProvider.fields.first.id!;
    
    // Test 1: Sulama programlarını getirme
    try {
      await irrigationProvider.fetchSchedulesByFieldId(fieldId);
      
      _addTestResult('Sulama programlarını getirme testi', true);
    } catch (e) {
      _addTestResult('Sulama programlarını getirme testi', false, 'Hata: $e');
    }
    
    // Test 2: Sulama programı oluşturma
    try {
      final initialCount = irrigationProvider.schedules.length;
      
      final now = DateTime.now();
      final startTime = DateTime(now.year, now.month, now.day, 10, 0);
      
      final success = await irrigationProvider.createSchedule(
        IrrigationSchedule(
          name: 'Test Sulaması',
          startTime: startTime,
          durationMinutes: 20,
          isActive: true,
          isAutomatic: false,
          fieldId: fieldId,
        ),
      );
      
      if (success && irrigationProvider.schedules.length == initialCount + 1) {
        _addTestResult('Sulama programı oluşturma testi', true);
      } else {
        _addTestResult('Sulama programı oluşturma testi', false, 'Sulama programı oluşturulmalıydı');
      }
    } catch (e) {
      _addTestResult('Sulama programı oluşturma testi', false, 'Hata: $e');
    }
    
    // Test 3: Sulama programı durumunu değiştirme
    try {
      if (irrigationProvider.schedules.isNotEmpty) {
        final schedule = irrigationProvider.schedules.first;
        final initialStatus = schedule.isActive;
        
        final success = await irrigationProvider.toggleScheduleActive(schedule);
        
        if (success && irrigationProvider.schedules.first.isActive != initialStatus) {
          _addTestResult('Sulama programı durumu değiştirme testi', true);
        } else {
          _addTestResult('Sulama programı durumu değiştirme testi', false, 'Sulama programı durumu değiştirilmeliydi');
        }
      } else {
        _addTestResult('Sulama programı durumu değiştirme testi', false, 'Sulama programı bulunamadı');
      }
    } catch (e) {
      _addTestResult('Sulama programı durumu değiştirme testi', false, 'Hata: $e');
    }
  }

  void _addTestHeader(String header) {
    setState(() {
      _testResults += '\n$header\n${'-' * header.length}\n';
    });
  }

  void _addTestResult(String testName, bool passed, [String? errorMessage]) {
    setState(() {
      _totalTests++;
      if (passed) {
        _passedTests++;
        _testResults += '✅ $testName: Başarılı\n';
      } else {
        _failedTests++;
        _testResults += '❌ $testName: Başarısız${errorMessage != null ? ' - $errorMessage' : ''}\n';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agrotopya Test Ekranı'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uygulama Test Aracı',
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(height: 8),
            Text(
              'Bu ekran, uygulamanın temel işlevlerini test etmek için kullanılır.',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 24),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runAllTests,
              icon: Icon(Icons.play_arrow),
              label: Text('Tüm Testleri Çalıştır'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            
            SizedBox(height: 24),
            
            Text(
              'Test Sonuçları',
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: 8),
            
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Text(
                          _testResults.isEmpty ? 'Henüz test çalıştırılmadı.' : _testResults,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
