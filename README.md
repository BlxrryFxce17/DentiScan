# 🦷 DentiScan — AI Dental Document Intelligence & Clinical Management

<div align="center">

[![Live Demo](https://img.shields.io/badge/Live_App-Open_DentiScan-0D9488?style=flat&logo=google-chrome&logoColor=white)](https://blxrryfxce17.github.io/DentiScan/)
[![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-334155?style=flat)](LICENSE)

[![Gemini](https://img.shields.io/badge/AI-Gemini_Vision-7C3AED?style=flat&logo=google&logoColor=white)](https://ai.google.dev)
[![Mistral](https://img.shields.io/badge/AI-Mistral_Pixtral-FF6B35?style=flat&logo=mistral&logoColor=white)](https://mistral.ai)
[![Storage](https://img.shields.io/badge/Offline_DB-Hive_NoSQL-EA580C?style=flat)](https://pub.dev/packages/hive)
[![Tests](https://img.shields.io/badge/Tests-Passing-059669?style=flat&logo=checkmarx&logoColor=white)](https://flutter.dev)
[![Release](https://img.shields.io/badge/APK-v1.0.0-22C55E?style=flat&logo=android&logoColor=white)](https://github.com/BlxrryFxce17/DentiScan/releases)

<br/>

**An intelligent, clinical-grade dental document intelligence system that transforms physical dental records, handwritten prescriptions, and printed examination charts into structured clinical intelligence.**

> 🌐 **Live Web App**: Try instantly at **[https://blxrryfxce17.github.io/DentiScan/](https://blxrryfxce17.github.io/DentiScan/)**

</div>

---

## 🌟 Overview

In dental clinics worldwide, patient charts, treatment plans, and prescriptions are predominantly on paper. Deciphering rushed handwriting, tracking tooth histories, and calculating costs manually creates operational friction and clinical risk.

**DentiScan** bridges the physical-digital divide with a privacy-first, dual-AI consensus intelligence system:

1. **Instant Intake** — Camera capture, gallery upload, or preloaded benchmark datasets
2. **Dual-AI Consensus** — Gemini Vision + Mistral Pixtral run in parallel and cross-validate findings
3. **9-Domain Clinical Structuring** — Automatically organizes messy notes into structured SOAP domains
4. **Anatomical Odontogram** — Bezier-rendered 32-tooth FDI chart with 5-surface diagrams
5. **Live Financial Recalculator** — Real-time INR (`₹`) billing synchronization
6. **Electronic Dental Record (EDR)** — Unified patient profiles with lifetime spending and allergy alerts
7. **Clinical PDF Export** — One-tap clinic-branded report with tooth charts and signature blocks
8. **Mobile-First Gestures** — Swipe to archive, pull-to-refresh, pinch-to-zoom, long-press shortcuts

---

## 🏗️ System Architecture

```
[Camera / Gallery / File]
          │
          ▼
 [Image Preprocessor] ──> Contrast Normalization, Auto-Deskew & 90° Rotation
          │
          ▼
 ┌─────────────────────────────────────────────────────┐
 │              Dual-AI Consensus Engine               │
 │                                                     │
 │  ┌──────────────────────┐  ┌──────────────────────┐ │
 │  │  Gemini Vision API   │  │ Mistral Pixtral API  │ │
 │  │ (Handwriting Expert  │  │ (Clinical Structure  │ │
 │  │  & Dental Abbrevs)   │  │  Cross-Validator)    │ │
 │  └──────────┬───────────┘  └──────────┬───────────┘ │
 │             └──────────┬──────────────┘             │
 │                        ▼                            │
 │              [Consensus Reconciler]                 │
 │           Merges & Cross-Verifies Findings          │
 └────────────────────────┬────────────────────────────┘
                          │   (Falls back to ML Kit offline)
                          ▼
              [Clinical Semantic Parser]
     Extracts & Normalizes 9 Clinical Domains (SOAP)
                          │
                          ▼
          [Side-by-Side Review & Edit Screen]
          Interactive Zoomable Scan + Odontogram
                          │
                          ▼
         [Local-First Hive NoSQL Persistence]
        Multi-Visit Patient Profiles & Ledgers
                          │
                          ▼
              [Clinical PDF Generator]
         Clinic Letterhead, Charts & Print/Share
```

---

## ✨ Key Features

### 🤖 Dual-AI Consensus Scanning
- **Gemini Vision** + **Mistral Pixtral** run **in parallel** on every scan
- A consensus reconciler merges both outputs, resolving conflicts by majority confidence
- If only one AI succeeds, it gracefully falls back to single-model extraction
- **On-device Google ML Kit** serves as an offline fallback (no internet required)
- Intelligent model fallback chain — if one Gemini model hits rate limits, auto-tries the next

### 🦷 Anatomical FDI Odontogram
- Bezier-rendered morphologically accurate 32-tooth arch (Incisors, Canines, Premolars, Molars)
- **Pathology Visuals**: 🔴 RCT (red gutta-percha), 🟠 Restorations (amber inlay), 🔵 Scaling (cyan band), ❌ Extraction (red cross)
- Toggle between **Anatomical** (crown + root) and **5-Surface** (Occlusal, Buccal, Lingual, Mesial, Distal) views
- Tap any tooth to inspect quadrant, procedure, surface, and cost

### 💰 Live Financial Recalculator
$$\text{Total} = \sum \text{Procedure Costs}$$
$$\text{Balance Due} = \text{Total} - \text{Insurance} - \text{Advance Paid}$$
- Edit any procedure's cost, description, or surface — Category 9 recalculates on every keystroke

### 👥 Patient Directory (EDR)
- Unified patient profiles grouping all visits under one identity
- Lifetime billing summary, balance due, and visit timeline
- **Critical Allergy Shield** — drug allergies prominently flagged across all records
- Status chips: *All, Pending Review, Needs Follow-up, Settled*

### 📱 Mobile Gesture Controls
- **Swipe left** on any record to archive/delete
- **Long-press** for quick-action shortcuts (View, Edit, Export PDF)
- **Pull-to-refresh** on home tabs and detail screens
- **Pinch-to-zoom** + **double-tap to reset** on scan preview
- **Drag-to-pan** with boundary clamping on zoomed scans

### 📄 Clinical PDF Export
- Clinic letterhead, doctor credentials, patient demographics
- Allergy warnings, 9-domain SOAP notes, tooth procedure table
- Financial receipt with INR breakdown and doctor signature block

---

## 📂 9-Category Clinical Domain Model

| Domain | Extracted Fields |
| :--- | :--- |
| **1. Patient Details** | Name, age, gender, phone, visit date |
| **2. Doctor Details** | Dentist name, clinic, registration number, qualifications |
| **3. Chief Complaint** | Symptoms, pain characteristics, duration, triggers |
| **4. Medical History** | Systemic conditions (HTN, DM) and active medications |
| **5. Dental History** | Prior restorations, extractions, orthodontic history |
| **6. Allergies & Habits** | Drug allergies (Penicillin, Latex) and lifestyle habits |
| **7. Treatment Plan** | Clinical diagnosis and proposed interventions |
| **8. Procedures & Teeth** | FDI tooth numbers, procedure type, surface, status, fees |
| **9. Payment & Financials** | Procedure costs, insurance, advance paid, balance due, Rx |

---

## 📸 Benchmark Test Samples

3 preloaded real-world clinical benchmarks in `assets/samples/`:

1. **Sample 1 — Handwritten OPD Prescription**: Cursive doctor script, RCT #46, Cefuroxime Rx
2. **Sample 2 — Printed Examination Chart**: Clean form, scaling on #23, composite on #14, insurance billing
3. **Sample 3 — Skewed Smartphone Photo**: Real-life angled desk photo, trauma case #11 composite bonding

---

## 🛠️ Project Structure

```
foxwell.ai/
├── assets/
│   ├── icon/                         # DentiScan app launcher icon
│   └── samples/                      # Bundled benchmark clinical records
├── lib/
│   ├── main.dart                     # App entry point & Hive initialization
│   ├── core/
│   │   ├── constants/dental_constants.dart  # FDI numbering, procedure names
│   │   ├── theme/app_theme.dart             # Typography & clinical color system
│   │   └── utils/
│   │       ├── image_processor.dart         # Contrast boost, deskew & rotation
│   │       ├── pdf_exporter.dart            # Clinical PDF generator
│   │       └── document_scanner_helper.dart # Camera & file picking helpers
│   ├── models/
│   │   ├── patient_record.dart       # 9-category record model + Hive adapter (0)
│   │   ├── tooth_procedure.dart      # Tooth procedure model + Hive adapter (1)
│   │   └── prescription_item.dart    # Rx item model + Hive adapter (2)
│   ├── services/
│   │   ├── hive_storage_service.dart       # CRUD, search, duplicate detection, settings
│   │   ├── gemini_vision_service.dart      # Gemini Vision multimodal transcription
│   │   ├── mistral_vision_service.dart     # Mistral Pixtral vision transcription
│   │   ├── clinical_consensus_engine.dart  # Dual-AI reconciler & conflict resolver
│   │   ├── ocr_engine.dart                 # Dual-engine orchestration & fallback logic
│   │   ├── clinical_parser.dart            # 9-domain regex & NLP semantic parser
│   │   └── ml_kit_ocr_service.dart         # On-device Google ML Kit (offline)
│   └── presentation/
│       ├── providers/dental_records_provider.dart  # State management & patient grouping
│       ├── screens/
│       │   ├── home_screen.dart             # Dashboard, swipe gestures, visit tabs
│       │   ├── scan_upload_screen.dart      # Viewfinder, laser scanner, zoom gestures
│       │   ├── review_edit_screen.dart      # Side-by-side verification & procedure editor
│       │   ├── patient_detail_screen.dart   # Full chart, odontogram & pull-to-refresh
│       │   └── pdf_preview_screen.dart      # PDF viewer, print & share
│       └── widgets/
│           ├── category_card.dart           # Structured card with warning indicators
│           ├── odontogram_widget.dart       # Interactive FDI dental arch chart
│           ├── real_tooth_painter.dart      # Bezier anatomical teeth renderer
│           ├── ai_settings_dialog.dart      # AI engine & masked key manager
│           └── sample_picker_sheet.dart     # Camera, gallery & sample picker sheet
└── test/
    ├── clinical_parser_test.dart     # Unit tests: 9 categories, INR billing, FDI logic
    ├── clinical_consensus_test.dart  # Dual-AI consensus reconciliation tests
    └── widget_test.dart              # Smoke tests: Odontogram & CategoryCard
```

---

## 🚀 Setup & Run

### Prerequisites
- [Flutter SDK](https://flutter.dev) 3.13.0 or later
- Android Studio / VS Code with Flutter extension
- Android 6.0+ (API 23) or a Chrome browser for web

### 1. Clone & Install
```bash
git clone https://github.com/BlxrryFxce17/DentiScan.git
cd DentiScan
flutter pub get
```

### 2. Run
```bash
# Web (Chrome)
flutter run -d chrome

# Android device / emulator
flutter run
```

> **AI Keys**: The app includes built-in fallback API keys for demo use. You can override them anytime via the **🧠 AI Settings** icon in the top-right header.

### 3. Build Release APK
```bash
flutter build apk --release --shrink --obfuscate --split-debug-info=./debug_info
```
APK output: `build/app/outputs/flutter-apk/app-release.apk`

> Download the latest prebuilt APK from [**Releases**](https://github.com/BlxrryFxce17/DentiScan/releases).

### 4. Run Tests
```bash
flutter test
```

### 5. Static Analysis
```bash
flutter analyze
```

---

## 💡 Testing the App

1. **Sample Benchmarks** — Tap **✨** → pick Sample 1/2/3 → watch the laser OCR scanner
2. **Dual-AI Consensus** — Set engine to **"Consensus"** in AI Settings → scan any document → both AIs run in parallel
3. **Odontogram** — Scroll to Category 7/8 → toggle Teeth/Surfaces → tap `#46` → edit cost → watch billing recalculate live
4. **Mobile Gestures** — Swipe a record left to delete; long-press for quick actions; pull down to refresh
5. **PDF Export** — Open any record → tap **Export PDF** → share or print the clinical report

---

## 🔒 Privacy & Security

- **Local-first**: All patient records are stored on-device in Hive (no cloud sync, no telemetry)
- **Offline mode**: Google ML Kit runs 100% on-device with zero network requests
- **Key masking**: API keys are permanently masked (`••••••••`) in the UI
- **Obfuscated builds**: Release APKs are built with `--obfuscate` to harden against reverse engineering
- **No analytics**: Zero tracking, crash reporting, or user data collection
