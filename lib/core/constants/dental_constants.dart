class DentalToothInfo {
  final String fdiNumber;
  final int universalNumber;
  final String quadrant; // "UR", "UL", "LL", "LR"
  final String name;

  const DentalToothInfo({
    required this.fdiNumber,
    required this.universalNumber,
    required this.quadrant,
    required this.name,
  });
}

class DentalConstants {
  static const String currencySymbol = '₹';
  static const String currencyCode = 'INR';
  static const String pdfCurrencyPrefix = 'Rs. ';

  static const Map<String, DentalToothInfo> teeth = {
    // Upper Right (Quadrant 1)
    '18': DentalToothInfo(fdiNumber: '18', universalNumber: 1, quadrant: 'UR', name: 'Upper Right Third Molar (Wisdom)'),
    '17': DentalToothInfo(fdiNumber: '17', universalNumber: 2, quadrant: 'UR', name: 'Upper Right Second Molar'),
    '16': DentalToothInfo(fdiNumber: '16', universalNumber: 3, quadrant: 'UR', name: 'Upper Right First Molar'),
    '15': DentalToothInfo(fdiNumber: '15', universalNumber: 4, quadrant: 'UR', name: 'Upper Right Second Premolar'),
    '14': DentalToothInfo(fdiNumber: '14', universalNumber: 5, quadrant: 'UR', name: 'Upper Right First Premolar'),
    '13': DentalToothInfo(fdiNumber: '13', universalNumber: 6, quadrant: 'UR', name: 'Upper Right Canine'),
    '12': DentalToothInfo(fdiNumber: '12', universalNumber: 7, quadrant: 'UR', name: 'Upper Right Lateral Incisor'),
    '11': DentalToothInfo(fdiNumber: '11', universalNumber: 8, quadrant: 'UR', name: 'Upper Right Central Incisor'),

    // Upper Left (Quadrant 2)
    '21': DentalToothInfo(fdiNumber: '21', universalNumber: 9, quadrant: 'UL', name: 'Upper Left Central Incisor'),
    '22': DentalToothInfo(fdiNumber: '22', universalNumber: 10, quadrant: 'UL', name: 'Upper Left Lateral Incisor'),
    '23': DentalToothInfo(fdiNumber: '23', universalNumber: 11, quadrant: 'UL', name: 'Upper Left Canine'),
    '24': DentalToothInfo(fdiNumber: '24', universalNumber: 12, quadrant: 'UL', name: 'Upper Left First Premolar'),
    '25': DentalToothInfo(fdiNumber: '25', universalNumber: 13, quadrant: 'UL', name: 'Upper Left Second Premolar'),
    '26': DentalToothInfo(fdiNumber: '26', universalNumber: 14, quadrant: 'UL', name: 'Upper Left First Molar'),
    '27': DentalToothInfo(fdiNumber: '27', universalNumber: 15, quadrant: 'UL', name: 'Upper Left Second Molar'),
    '28': DentalToothInfo(fdiNumber: '28', universalNumber: 16, quadrant: 'UL', name: 'Upper Left Third Molar (Wisdom)'),

    // Lower Left (Quadrant 3)
    '38': DentalToothInfo(fdiNumber: '38', universalNumber: 17, quadrant: 'LL', name: 'Lower Left Third Molar (Wisdom)'),
    '37': DentalToothInfo(fdiNumber: '37', universalNumber: 18, quadrant: 'LL', name: 'Lower Left Second Molar'),
    '36': DentalToothInfo(fdiNumber: '36', universalNumber: 19, quadrant: 'LL', name: 'Lower Left First Molar'),
    '35': DentalToothInfo(fdiNumber: '35', universalNumber: 20, quadrant: 'LL', name: 'Lower Left Second Premolar'),
    '34': DentalToothInfo(fdiNumber: '34', universalNumber: 21, quadrant: 'LL', name: 'Lower Left First Premolar'),
    '33': DentalToothInfo(fdiNumber: '33', universalNumber: 22, quadrant: 'LL', name: 'Lower Left Canine'),
    '32': DentalToothInfo(fdiNumber: '32', universalNumber: 23, quadrant: 'LL', name: 'Lower Left Lateral Incisor'),
    '31': DentalToothInfo(fdiNumber: '31', universalNumber: 24, quadrant: 'LL', name: 'Lower Left Central Incisor'),

    // Lower Right (Quadrant 4)
    '41': DentalToothInfo(fdiNumber: '41', universalNumber: 25, quadrant: 'LR', name: 'Lower Right Central Incisor'),
    '42': DentalToothInfo(fdiNumber: '42', universalNumber: 26, quadrant: 'LR', name: 'Lower Right Lateral Incisor'),
    '43': DentalToothInfo(fdiNumber: '43', universalNumber: 27, quadrant: 'LR', name: 'Lower Right Canine'),
    '44': DentalToothInfo(fdiNumber: '44', universalNumber: 28, quadrant: 'LR', name: 'Lower Right First Premolar'),
    '45': DentalToothInfo(fdiNumber: '45', universalNumber: 29, quadrant: 'LR', name: 'Lower Right Second Premolar'),
    '46': DentalToothInfo(fdiNumber: '46', universalNumber: 30, quadrant: 'LR', name: 'Lower Right First Molar'),
    '47': DentalToothInfo(fdiNumber: '47', universalNumber: 31, quadrant: 'LR', name: 'Lower Right Second Molar'),
    '48': DentalToothInfo(fdiNumber: '48', universalNumber: 32, quadrant: 'LR', name: 'Lower Right Third Molar (Wisdom)'),
  };

  static const List<DentalTreatmentOption> treatmentCatalog = [
    DentalTreatmentOption(
      name: 'Root Canal Treatment (RCT)',
      defaultSurface: 'Occlusal',
      defaultCost: 3500.0,
      category: 'Endodontics',
    ),
    DentalTreatmentOption(
      name: 'Composite Resin Restoration',
      defaultSurface: 'Occlusal (O)',
      defaultCost: 1200.0,
      category: 'Restorative',
    ),
    DentalTreatmentOption(
      name: 'Composite Build-up (Class II MOD)',
      defaultSurface: 'Mesio-Occluso-Distal (MOD)',
      defaultCost: 1800.0,
      category: 'Restorative',
    ),
    DentalTreatmentOption(
      name: 'Zirconia Crown',
      defaultSurface: 'Full Crown',
      defaultCost: 6500.0,
      category: 'Prosthodontics',
    ),
    DentalTreatmentOption(
      name: 'PFM (Porcelain-Fused-to-Metal) Crown',
      defaultSurface: 'Full Crown',
      defaultCost: 3500.0,
      category: 'Prosthodontics',
    ),
    DentalTreatmentOption(
      name: 'Ultrasonic Scaling & Polishing',
      defaultSurface: 'Cervical / Full Mouth',
      defaultCost: 1500.0,
      category: 'Periodontics',
    ),
    DentalTreatmentOption(
      name: 'Subgingival Curettage & Deep Scaling',
      defaultSurface: 'Subgingival',
      defaultCost: 2000.0,
      category: 'Periodontics',
    ),
    DentalTreatmentOption(
      name: 'Simple Tooth Extraction',
      defaultSurface: 'Socket',
      defaultCost: 1000.0,
      category: 'Oral Surgery',
    ),
    DentalTreatmentOption(
      name: 'Surgical Disimpaction (Wisdom Tooth)',
      defaultSurface: 'Surgical Impaction',
      defaultCost: 5000.0,
      category: 'Oral Surgery',
    ),
    DentalTreatmentOption(
      name: 'Dental Implant & Abutment',
      defaultSurface: 'Endosteal',
      defaultCost: 25000.0,
      category: 'Implantology',
    ),
    DentalTreatmentOption(
      name: 'Porcelain Veneer / Laminate',
      defaultSurface: 'Labial / Facial',
      defaultCost: 7500.0,
      category: 'Cosmetic',
    ),
    DentalTreatmentOption(
      name: 'Incisal Composite Edge Bonding',
      defaultSurface: 'Incisal (I)',
      defaultCost: 2200.0,
      category: 'Cosmetic',
    ),
    DentalTreatmentOption(
      name: 'Pit & Fissure Sealant',
      defaultSurface: 'Occlusal (O)',
      defaultCost: 800.0,
      category: 'Preventive',
    ),
    DentalTreatmentOption(
      name: 'Fluoride Varnish Application',
      defaultSurface: 'Full Arch',
      defaultCost: 600.0,
      category: 'Preventive',
    ),
    DentalTreatmentOption(
      name: 'Inlay / Onlay (Ceramic)',
      defaultSurface: 'Mesio-Occluso-Distal (MOD)',
      defaultCost: 4500.0,
      category: 'Prosthodontics',
    ),
    DentalTreatmentOption(
      name: 'Fixed Dental Bridge (per unit)',
      defaultSurface: 'Full Bridge',
      defaultCost: 4000.0,
      category: 'Prosthodontics',
    ),
    DentalTreatmentOption(
      name: 'Custom / Other Procedure',
      defaultSurface: 'General',
      defaultCost: 1000.0,
      category: 'Other',
    ),
  ];

  static const List<String> commonProcedures = [
    'Root Canal Treatment (RCT)',
    'Zirconia Crown',
    'PFM Crown',
    'Composite Resin Restoration',
    'Ultrasonic Scaling & Polishing',
    'Subgingival Curettage',
    'Tooth Extraction (Simple)',
    'Surgical Disimpaction',
    'Dental Implant',
    'Porcelain Veneer',
    'Gingival Flap Surgery',
    'Fluoride Application',
  ];

  static const List<String> surfaces = [
    'Occlusal (O)',
    'Mesial (M)',
    'Distal (D)',
    'Buccal (B)',
    'Lingual (L)',
    'Mesio-Occlusal (MO)',
    'Disto-Occlusal (DO)',
    'Mesio-Occluso-Distal (MOD)',
    'Incisal (I)',
    'Cervical / Subgingival',
    'Full Crown',
  ];

  static const List<DentalPrescriptionOption> prescriptionCatalog = [
    DentalPrescriptionOption(
      medicineName: 'Amoxicillin 500mg',
      defaultDosage: 'TDS (3 times/day)',
      defaultDuration: '5 Days',
      defaultInstructions: 'After food',
    ),
    DentalPrescriptionOption(
      medicineName: 'Augmentin 625mg (Amox + Clav)',
      defaultDosage: 'BD (2 times/day)',
      defaultDuration: '5 Days',
      defaultInstructions: 'After food',
    ),
    DentalPrescriptionOption(
      medicineName: 'Zerodol-P (Aceclofenac + Paracetamol)',
      defaultDosage: 'BD (2 times/day)',
      defaultDuration: '3 Days',
      defaultInstructions: 'After food for pain relief',
    ),
    DentalPrescriptionOption(
      medicineName: 'Ketorol-DT 10mg (Ketorolac)',
      defaultDosage: 'SOS (When in pain)',
      defaultDuration: '3 Days',
      defaultInstructions: 'Disperse in water after food',
    ),
    DentalPrescriptionOption(
      medicineName: 'Flagyl 400mg (Metronidazole)',
      defaultDosage: 'TDS (3 times/day)',
      defaultDuration: '5 Days',
      defaultInstructions: 'After food for anaerobic coverage',
    ),
    DentalPrescriptionOption(
      medicineName: 'Pan-40 (Pantoprazole 40mg)',
      defaultDosage: 'OD (Once daily)',
      defaultDuration: '5 Days',
      defaultInstructions: '30 mins before breakfast',
    ),
    DentalPrescriptionOption(
      medicineName: 'Chlorhexidine 0.2% Mouthwash',
      defaultDosage: 'BD (2 times/day)',
      defaultDuration: '7 Days',
      defaultInstructions: 'Swish 10ml undiluted for 30s after brushing',
    ),
    DentalPrescriptionOption(
      medicineName: 'Custom / Other Medicine',
      defaultDosage: 'BD (2 times/day)',
      defaultDuration: '5 Days',
      defaultInstructions: 'After food',
    ),
  ];

  static String getToothDescription(String toothNum) {
    return teeth[toothNum]?.name ?? 'Tooth #$toothNum';
  }
}

class DentalTreatmentOption {
  final String name;
  final String defaultSurface;
  final double defaultCost;
  final String category;

  const DentalTreatmentOption({
    required this.name,
    required this.defaultSurface,
    required this.defaultCost,
    this.category = 'General',
  });
}

class DentalPrescriptionOption {
  final String medicineName;
  final String defaultDosage;
  final String defaultDuration;
  final String defaultInstructions;

  const DentalPrescriptionOption({
    required this.medicineName,
    required this.defaultDosage,
    required this.defaultDuration,
    required this.defaultInstructions,
  });
}
