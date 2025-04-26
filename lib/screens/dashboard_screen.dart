import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrotopya_app/theme/app_theme.dart';
import 'package:agrotopya_app/providers/auth_provider.dart';
import 'package:agrotopya_app/providers/field_provider.dart';
import 'package:agrotopya_app/providers/sensor_provider.dart';
import 'package:agrotopya_app/providers/irrigation_schedule_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final fieldProvider = Provider.of<FieldProvider>(context, listen: false);
    
    if (authProvider.userId != null) {
      await fieldProvider.fetchFieldsByUserId(authProvider.userId!);
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agrotopya'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Bildirimler yakında eklenecek'),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Text('Profil'),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Text('Ayarlar'),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Çıkış Yap'),
                ),
              ];
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Özet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.landscape),
            label: 'Tarlalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sensors),
            label: 'Sensörler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop),
            label: 'Sulama',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new item based on selected tab
          switch (_selectedIndex) {
            case 1:
              _showAddFieldDialog();
              break;
            case 2:
              _showAddSensorDialog();
              break;
            case 3:
              _showAddIrrigationDialog();
              break;
            default:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Bu sekmede yeni öğe eklenemez'),
                ),
              );
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Ekle',
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildFieldsList();
      case 2:
        return _buildSensorsList();
      case 3:
        return _buildIrrigationList();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    final authProvider = Provider.of<AuthProvider>(context);
    final fieldProvider = Provider.of<FieldProvider>(context);
    final sensorProvider = Provider.of<SensorProvider>(context);
    final irrigationProvider = Provider.of<IrrigationScheduleProvider>(context);
    
    final fields = fieldProvider.fields;
    final sensors = sensorProvider.sensors;
    final schedules = irrigationProvider.schedules;
    
    // Calculate stats
    final activeSchedules = schedules.where((s) => s.isActive).length;
    
    // Get average soil moisture and temperature
    double avgMoisture = 0;
    int moistureCount = 0;
    double avgTemperature = 0;
    int temperatureCount = 0;
    
    sensorProvider.latestReadings.forEach((sensorId, reading) {
      if (reading != null) {
        final sensor = sensors.firstWhere(
          (s) => s.id == sensorId,
          orElse: () => null as Sensor,
        );
        
        if (sensor != null) {
          if (sensor.type == 'SOIL_MOISTURE') {
            avgMoisture += reading.value;
            moistureCount++;
          } else if (sensor.type == 'TEMPERATURE') {
            avgTemperature += reading.value;
            temperatureCount++;
          }
        }
      }
    });
    
    if (moistureCount > 0) avgMoisture /= moistureCount;
    if (temperatureCount > 0) avgTemperature /= temperatureCount;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoş Geldiniz, ${authProvider.currentUser?.fullName ?? 'Çiftçi'}',
            style: Theme.of(context).textTheme.headline4,
          ),
          SizedBox(height: 8),
          Text(
            'İşte tarlanızın durumu',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          SizedBox(height: 24),
          
          // Stats Cards
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard('Toplam Tarla', fields.length.toString(), Icons.landscape, AppColors.primary),
              _buildStatCard('Aktif Sensör', sensors.where((s) => s.isActive).length.toString(), Icons.sensors, AppColors.accent),
              _buildStatCard('Ortalama Nem', moistureCount > 0 ? '%${avgMoisture.toStringAsFixed(1)}' : 'Veri yok', Icons.water, AppColors.info),
              _buildStatCard('Sıcaklık', temperatureCount > 0 ? '${avgTemperature.toStringAsFixed(1)}°C' : 'Veri yok', Icons.thermostat, AppColors.warning),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Recent Readings
          Text(
            'Son Sensör Okumaları',
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: 16),
          _buildRecentReadings(sensorProvider),
          
          SizedBox(height: 24),
          
          // Upcoming Irrigations
          Text(
            'Yaklaşan Sulamalar',
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: 16),
          _buildUpcomingIrrigations(irrigationProvider),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReadings(SensorProvider sensorProvider) {
    final readings = sensorProvider.latestReadings.entries.toList();
    
    if (readings.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('Henüz sensör okuması bulunmuyor'),
          ),
        ),
      );
    }
    
    return Container(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: readings.length,
        itemBuilder: (context, index) {
          final sensorId = readings[index].key;
          final reading = readings[index].value;
          
          if (reading == null) return Container();
          
          final sensor = sensorProvider.sensors.firstWhere(
            (s) => s.id == sensorId,
            orElse: () => null as Sensor,
          );
          
          if (sensor == null) return Container();
          
          final isMoisture = sensor.type == 'SOIL_MOISTURE';
          
          return Container(
            width: 160,
            margin: EdgeInsets.only(right: 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          isMoisture ? Icons.water : Icons.thermostat,
                          color: isMoisture ? AppColors.info : AppColors.warning,
                        ),
                        Text(
                          reading.timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      '${reading.value.toStringAsFixed(1)}${reading.unit}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      isMoisture ? 'Toprak Nemi' : 'Sıcaklık',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      sensor.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingIrrigations(IrrigationScheduleProvider irrigationProvider) {
    final schedules = irrigationProvider.schedules
        .where((s) => s.isActive && s.nextRun != null)
        .toList()
      ..sort((a, b) => a.nextRun!.compareTo(b.nextRun!));
    
    if (schedules.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('Yaklaşan sulama programı bulunmuyor'),
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: schedules.length > 3 ? 3 : schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.water_drop, color: AppColors.primary),
            ),
            title: Text(schedule.name),
            subtitle: Text('${schedule.fieldName ?? 'Tarla'} - ${schedule.statusText}'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to irrigation details
            },
          ),
        );
      },
    );
  }

  Widget _buildFieldsList() {
    final fieldProvider = Provider.of<FieldProvider>(context);
    final fields = fieldProvider.fields;
    
    if (fields.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.landscape,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              'Henüz tarla eklenmemiş',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Yeni tarla eklemek için + butonuna tıklayın',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: fields.length,
      itemBuilder: (context, index) {
        final field = fields[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.landscape,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (field.location != null) ...[
                      Text(
                        'Konum: ${field.location}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                    if (field.cropType != null) ...[
                      Text(
                        'Ürün: ${field.cropType}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                    if (field.area != null) ...[
                      Text(
                        'Alan: ${field.area} dönüm',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.sensors),
                            label: Text('Sensörler'),
                            onPressed: () {
                              // Load sensors for this field
                              final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
                              sensorProvider.fetchSensorsByFieldId(field.id!);
                              
                              // Switch to sensors tab
                              _onItemTapped(2);
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.water_drop),
                            label: Text('Sulama'),
                            onPressed: () {
                              // Load irrigation schedules for this field
                              final irrigationProvider = Provider.of<IrrigationScheduleProvider>(context, listen: false);
                              irrigationProvider.fetchSchedulesByFieldId(field.id!);
                              
                              // Switch to irrigation tab
                              _onItemTapped(3);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSensorsList() {
    final sensorProvider = Provider.of<SensorProvider>(context);
    final sensors = sensorProvider.sensors;
    
    if (sensors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sensors,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              'Henüz sensör eklenmemiş',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Yeni sensör eklemek için + butonuna tıklayın',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: sensors.length,
      itemBuilder: (context, index) {
        final sensor = sensors[index];
        final reading = sensorProvider.latestReadings[sensor.id];
        final isMoisture = sensor.type == 'SOIL_MOISTURE';
        
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isMoisture ? AppColors.primaryLight : AppColors.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isMoisture ? Icons.water : Icons.thermostat,
                color: isMoisture ? AppColors.primary : AppColors.accent,
              ),
            ),
            title: Text(sensor.name),
            subtitle: Text('${sensor.type == 'SOIL_MOISTURE' ? 'Toprak Nemi' : 'Sıcaklık'} - ${sensor.isActive ? 'Aktif' : 'Pasif'}'),
            trailing: reading != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${reading.value.toStringAsFixed(1)}${reading.unit}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        reading.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : Text('Veri yok'),
            onTap: () {
              // Navigate to sensor details
            },
          ),
        );
      },
    );
  }

  Widget _buildIrrigationList() {
    final irrigationProvider = Provider.of<IrrigationScheduleProvider>(context);
    final schedules = irrigationProvider.schedules;
    
    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.water_drop,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              'Henüz sulama programı eklenmemiş',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Yeni sulama programı eklemek için + butonuna tıklayın',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: schedule.isActive ? AppColors.primaryLight : AppColors.divider.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.water_drop,
                    color: schedule.isActive ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                title: Text(schedule.name),
                subtitle: Text('${schedule.fieldName ?? 'Tarla'} - ${schedule.isActive ? 'Aktif' : 'Pasif'}'),
                trailing: Switch(
                  value: schedule.isActive,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    irrigationProvider.toggleScheduleActive(schedule);
                  },
                ),
              ),
              Divider(height: 1),
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Başlangıç',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            schedule.formattedStartTime,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Süre',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${schedule.durationMinutes} dakika',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tür',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            schedule.isAutomatic ? 'Otomatik' : 'Manuel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddFieldDialog() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final areaController = TextEditingController();
    final cropTypeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Yeni Tarla Ekle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tarla Adı *',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Konum',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: areaController,
                decoration: InputDecoration(
                  labelText: 'Alan (dönüm)',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                controller: cropTypeController,
                decoration: InputDecoration(
                  labelText: 'Ürün Tipi',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tarla adı zorunludur'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final fieldProvider = Provider.of<FieldProvider>(context, listen: false);
              
              if (authProvider.userId != null) {
                final field = Field(
                  name: nameController.text,
                  location: locationController.text.isEmpty ? null : locationController.text,
                  area: areaController.text.isEmpty ? null : double.tryParse(areaController.text),
                  cropType: cropTypeController.text.isEmpty ? null : cropTypeController.text,
                  userId: authProvider.userId!,
                );
                
                fieldProvider.createField(field);
                Navigator.pop(context);
              }
            },
            child: Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showAddSensorDialog() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    String? selectedType;
    int? selectedFieldId;
    
    final fieldProvider = Provider.of<FieldProvider>(context, listen: false);
    final fields = fieldProvider.fields;
    
    if (fields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Önce bir tarla eklemelisiniz'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Yeni Sensör Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Sensör Adı *',
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Sensör Tipi *',
                  ),
                  value: selectedType,
                  items: [
                    DropdownMenuItem(
                      value: 'SOIL_MOISTURE',
                      child: Text('Toprak Nemi'),
                    ),
                    DropdownMenuItem(
                      value: 'TEMPERATURE',
                      child: Text('Sıcaklık'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Tarla *',
                  ),
                  value: selectedFieldId,
                  items: fields.map((field) => DropdownMenuItem(
                    value: field.id,
                    child: Text(field.name),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFieldId = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Konum',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty || selectedType == null || selectedFieldId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sensör adı, tipi ve tarla zorunludur'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                
                final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
                
                final sensor = Sensor(
                  name: nameController.text,
                  type: selectedType!,
                  location: locationController.text.isEmpty ? null : locationController.text,
                  isActive: true,
                  fieldId: selectedFieldId!,
                );
                
                sensorProvider.createSensor(sensor);
                Navigator.pop(context);
              },
              child: Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddIrrigationDialog() {
    final nameController = TextEditingController();
    final durationController = TextEditingController();
    TimeOfDay? selectedTime;
    int? selectedFieldId;
    bool isAutomatic = false;
    final moistureThresholdController = TextEditingController();
    
    final fieldProvider = Provider.of<FieldProvider>(context, listen: false);
    final fields = fieldProvider.fields;
    
    if (fields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Önce bir tarla eklemelisiniz'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Yeni Sulama Programı Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Program Adı *',
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Tarla *',
                  ),
                  value: selectedFieldId,
                  items: fields.map((field) => DropdownMenuItem(
                    value: field.id,
                    child: Text(field.name),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFieldId = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Başlangıç Saati *',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    child: Text(
                      selectedTime != null
                          ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                          : 'Seçiniz',
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: durationController,
                  decoration: InputDecoration(
                    labelText: 'Süre (dakika) *',
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                SwitchListTile(
                  title: Text('Otomatik Sulama'),
                  subtitle: Text('Nem sensörü değerine göre otomatik sulama'),
                  value: isAutomatic,
                  onChanged: (value) {
                    setState(() {
                      isAutomatic = value;
                    });
                  },
                ),
                if (isAutomatic) ...[
                  SizedBox(height: 16),
                  TextField(
                    controller: moistureThresholdController,
                    decoration: InputDecoration(
                      labelText: 'Nem Eşiği (%) *',
                      hintText: 'Nem bu değerin altına düştüğünde sulama başlar',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty || selectedFieldId == null || 
                    selectedTime == null || durationController.text.isEmpty ||
                    (isAutomatic && moistureThresholdController.text.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tüm zorunlu alanları doldurun'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                
                final irrigationProvider = Provider.of<IrrigationScheduleProvider>(context, listen: false);
                
                // Create DateTime from TimeOfDay
                final now = DateTime.now();
                final startTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                );
                
                final schedule = IrrigationSchedule(
                  name: nameController.text,
                  startTime: startTime,
                  durationMinutes: int.parse(durationController.text),
                  isActive: true,
                  isAutomatic: isAutomatic,
                  moistureThreshold: isAutomatic ? double.parse(moistureThresholdController.text) : null,
                  fieldId: selectedFieldId!,
                );
                
                irrigationProvider.createSchedule(schedule);
                Navigator.pop(context);
              },
              child: Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
