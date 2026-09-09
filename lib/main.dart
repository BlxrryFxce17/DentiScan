import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/hive_storage_service.dart';
import 'presentation/providers/dental_records_provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local Hive database with custom TypeAdapters
  await HiveStorageService.init();

  runApp(const DentalRecordOcrApp());
}

class DentalRecordOcrApp extends StatelessWidget {
  const DentalRecordOcrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DentalRecordsProvider()),
      ],
      child: MaterialApp(
        title: 'DentiScan - Dental OCR & Clinical Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
