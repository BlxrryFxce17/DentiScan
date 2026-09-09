# 🦷 DentiScan — AI Dental Document Intelligence & Clinical Management System

<div align="center">

[![Live Demo](https://img.shields.io/badge/Live_App-Open_DentiScan-0D9488?style=flat&logo=google-chrome&logoColor=white)](https://blxrryfxce17.github.io/DentiScan/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-334155?style=flat)](LICENSE)

[![Multimodal AI](https://img.shields.io/badge/AI-Gemini_1.5_Flash-7C3AED?style=flat&logo=google&logoColor=white)](https://ai.google.dev)
[![OCR](https://img.shields.io/badge/OCR-Google_ML_Kit-0284C7?style=flat&logo=google&logoColor=white)](https://pub.dev/packages/google_mlkit_text_recognition)
[![Storage](https://img.shields.io/badge/Offline_DB-Hive_NoSQL-EA580C?style=flat&logo=hive&logoColor=white)](https://pub.dev/packages/hive)
[![Tests](https://img.shields.io/badge/Tests-7%2F7_Passed-059669?style=flat&logo=checkmarx&logoColor=white)](https://flutter.dev)

<br/>

**An intelligent, clinical-grade dental document intelligence system that transforms physical dental records, handwritten prescriptions, and printed examination charts into structured clinical intelligence.**

> 🌐 **Live Web Application**: Try it instantly in your browser at **[https://blxrryfxce17.github.io/DentiScan/](https://blxrryfxce17.github.io/DentiScan/)**

</div>

---

## 🌟 Overview

In dental clinics worldwide, patient charts, treatment plans, and prescriptions are predominantly documented on paper. Deciphering rushed doctor handwriting, tracking longitudinal tooth histories, and calculating treatment costs manually creates severe operational friction and clinical risk.

**DentiScan** bridges the physical-digital divide with a privacy-first, dual-engine document intelligence system:
1. **Instant Intake**: Capture documents via smartphone camera, gallery upload, or preloaded benchmark datasets.
2. **Dual-Engine OCR**: Combines **on-device Google ML Kit** (100% offline, privacy-first) with **Google Gemini 1.5 Flash Multimodal Vision AI** (specialized in deciphering cursive handwriting and clinical dental abbreviations).
3. **9-Domain Clinical Structuring**: Automatically organizes messy notes into structured SOAP domains.
4. **Anatomical Odontogram Charting**: Morphological Bezier rendering of 32 teeth with a toggleable 5-surface FDI dental diagram.
5. **Live Financial Recalculator**: Dynamic real-time INR (`₹`) billing synchronization.
6. **Electronic Dental Record (EDR)**: Unified patient profiles with lifetime spending, balance tracking, and critical allergy alerts.
7. **Clinical PDF Generation**: One-tap export to a clinic-branded report with tooth charts and doctor signature blocks.

---

## 🏗️ Core Architectural Features

```
[Camera / Gallery / File]
          │
          ▼
 [Image Preprocessor] ──> Contrast Normalization, Auto-Deskew & 90° Rotation
          │
          ▼
 ┌───────────────────────────────────────────────┐
 │            Dual-Engine AI Scanning            │
 │                                               │
 │  ┌────────────────────────┐  ┌─────────────┐  │
 │  │ Gemini 1.5 Flash Vision│  │Google ML Kit│  │
 │  │ (Handwriting Specialist│  │ (On-Device, │  │
 │  │  & Clinical Abbrevs)   │  │ 100% Offline│  │
 │  └───────────┬────────────┘  └──────┬──────┘  │
 │              │ (Offline Fallback)   │         │
 └──────────────┴──────────────────────┴─────────┘
                        │
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

### 1. ⚡ Dual-Engine AI Scanning & Safe Fallback
* **On-Device Google ML Kit (`google_mlkit_text_recognition`)**:
  * Runs entirely on device hardware with zero network latency, zero API costs, and complete patient data privacy.
  * Ideal for printed examination forms, invoices, and clean charts.
* **Google Gemini 1.5 Flash Multimodal Vision AI**:
  * Deciphers complex cursive doctor handwriting, prescription shorthand (`1-0-1`, `TDS`, `mg`), and dental terminology (`RCT #46`, `MOD deep caries`, `subgingival curettage`).
* **Intelligent Auto-Fallback**:
  * If the device is offline, hits network timeouts, or lacks an API key, the system automatically falls back to on-device Google ML Kit without freezing or crashing.
* **Secured Key Management**:
  * API keys are permanently masked (`••••••••••••`), stored safely in local Hive storage, and can be configured or tested in the in-app AI Settings modal.

---

### 2. 🦷 Anatomical FDI Odontogram & 5-Surface Diagram
* **Morphological Real Tooth Painter**:
  * Realistic Bezier rendering of Incisors (chisel-edge crown, slender root), Canines (pointed cusp tip, long conical root), Premolars (bicuspid crest), and Molars (multi-cusp occlusal surface, bifurcated root canals).
  * Maxillary (Upper) roots point upward into the skull; Mandibular (Lower) roots point downward.
* **Pathology & Procedure Visuals**:
  * 🔴 **Root Canal (RCT)**: Red gutta-percha obturation lines through root canals.
  * 🟠 **Restorations / Fillings**: Amber occlusal inlays.
  * 🔵 **Periodontics / Scaling**: Cyan cervical gingival band.
  * ❌ **Extractions**: Red surgical cross.
* **Dual Diagram Toggle**:
  * Switch between **"Teeth"** (Anatomical Crown & Root) and **"Surfaces"** (5-Surface cross diagram: Occlusal, Buccal, Lingual, Mesial, Distal).
* **Interactive Tooth Inspection**: Tap any tooth to inspect anatomical location, quadrant (Q1–Q4), procedure, surface, and cost in INR (`₹`).

---

### 3. 💰 Live Dynamic Billing Recalculator
* **Universal INR Currency (`₹`)** across all metrics, charts, forms, and tables.
* **Real-Time Procedure Cost Editor**: Tapping edit on any procedure in Category 7 opens a dialog to adjust description, treated surface, and fee.
* **Dynamic Recalculation Engine**:
  $$\text{Total Treatment Cost} = \sum \text{Procedure Amounts}$$
  $$\text{Net Balance Due} = \text{Total Cost} - \text{Insurance / Discount} - \text{Advance Paid}$$
* Category 9 provides a live financial audit breakdown updated on every keystroke.

---

### 4. 👥 Clinician's Patients Directory (Aggregated EDR)
* **Visits Tab**: Individual appointments, status chips (*All, Pending Review, Needs Follow-up, Settled*), and quick search.
* **Patients Directory Tab**:
  * Unified patient profiles grouping multiple visits.
  * Lifetime billing summary vs. current net balance due.
  * **Critical Allergy Warning Shield**: Prominently highlights drug allergies (e.g. Penicillin, Latex) across all records.
  * Expandable chronological visit timeline with direct shortcuts to View Chart or Edit.

---

### 5. 🔍 Side-by-Side Review & Verification Screen
* **"View Scan" Drawer**: Toggle an interactive, pinch-to-zoom viewer of the original physical document directly above the digital form fields.
* Allows clinicians to verify messy handwriting against extracted fields in seconds.

---

### 6. 📄 Clinical-Grade PDF Exporter
* One-tap export to a clinic-branded PDF report.
* Contains clinic letterhead, doctor credentials, patient demographics, allergy warnings, 9-domain SOAP notes, tooth procedure breakdown table, financial receipt, and doctor signature block.
* Ready for physical printing, patient sharing, or specialist referrals.

---

## 📂 Comprehensive 9-Category Clinical Domain Model

| Domain                      | Extracted Fields                                                                                                 |
| :-------------------------- | :--------------------------------------------------------------------------------------------------------------- |
| **1. Patient Details**      | Full name, age, gender, primary contact phone number, visit date.                                                |
| **2. Doctor Details**       | Attending dentist name, clinic name, registration/license number, degree/qualifications.                         |
| **3. Chief Complaint**      | Primary symptoms, pain characteristics, duration, triggers (cold, chewing), affected teeth.                      |
| **4. Medical History**      | Systemic conditions (Hypertension, Diabetes, Cardiovascular, Pregnancy) and active medications.                  |
| **5. Dental History**       | Prior restorations, extractions, orthodontic history, oral hygiene status.                                       |
| **6. Allergies & Habits**   | Critical drug allergies (Penicillin, Latex, NSAIDs) and lifestyle habits (Bruxism, Smoking).                     |
| **7. Treatment Plan**       | Clinical diagnosis, proposed interventions, tooth mapping, surface involvement.                                  |
| **8. Procedures & Teeth**   | Tooth-by-tooth FDI numbers (#11–#48), procedure type (RCT, Composite, Scaling), surface (MOD), status, and fees. |
| **9. Payment & Financials** | Itemized procedure costs, insurance coverage, advance copay paid, balance due, and itemized Rx medications.      |

---

## 📸 Benchmark Test Samples Included

The application includes 3 preloaded real-world clinical benchmarks in `assets/samples/`:
1. **Sample 1: Handwritten OPD Prescription** (`sample_1_handwritten_rx.jpg`): Doctor cursive script, RCT #46, Cefuroxime Rx, doctor registration stamp.
2. **Sample 2: Printed Dental Examination & Treatment Plan** (`sample_2_printed_chart.jpg`): Clean printed clinic form, scaling on #23, composite filling on #14, insurance billing.
3. **Sample 3: Skewed Smartphone Shot** (`sample_3_skewed_record.jpg`): Real-life angled clinic desk photo, trauma case tooth #11 composite bonding.
4. **Live Camera & Gallery Capture**: Tap the scan button to snap any live paper chart or upload existing documents directly from your device.

---

## 🛠️ Project Structure

```
foxwell.ai/
├── assets/
│   ├── icon/                         # DentiScan 3D app launcher emblem
│   └── samples/                      # Bundled test records (Handwritten, Printed, Skewed)
├── lib/
│   ├── main.dart                     # App entry point & Hive storage initialization
│   ├── core/
│   │   ├── constants/
│   │   │   └── dental_constants.dart # FDI tooth numbering, procedure names & surfaces
│   │   ├── theme/
│   │   │   └── app_theme.dart        # Plus Jakarta Sans typography, clinical color system
│   │   └── utils/
│   │       ├── image_processor.dart  # Pure-Dart contrast boost, deskew & 90° rotation
│   │       └── pdf_exporter.dart     # Formatted clinical PDF generator
│   ├── models/
│   │   ├── patient_record.dart       # Main 9-category record model + Hive TypeAdapter (0)
│   │   ├── tooth_procedure.dart      # Tooth procedure model + Hive TypeAdapter (1)
│   │   └── prescription_item.dart    # Rx prescription item model + Hive TypeAdapter (2)
│   ├── services/
│   │   ├── hive_storage_service.dart # Local CRUD, search, duplicate detection, settings
│   │   ├── ml_kit_ocr_service.dart   # On-device Google ML Kit text recognition
│   │   ├── gemini_vision_service.dart# Multimodal Gemini Vision handwriting transcription
│   │   ├── ocr_engine.dart          # Dual-engine orchestration & progress callbacks
│   │   └── clinical_parser.dart     # Domain-aware regex & NLP 9-category parser
│   └── presentation/
│       ├── providers/
│       │   └── dental_records_provider.dart # ChangeNotifier state & patient grouping
│       ├── screens/
│       │   ├── home_screen.dart             # Dashboard, Visits & Patients Directory tabs
│       │   ├── scan_upload_screen.dart      # Viewfinder, contrast boost, laser OCR scanner
│       │   ├── review_edit_screen.dart      # Side-by-side verification & procedure editor
│       │   ├── patient_detail_screen.dart   # Full clinical chart, odontogram & raw OCR
│       │   └── pdf_preview_screen.dart      # PDF viewer, print & share actions
│       └── widgets/
│           ├── category_card.dart           # Structured card with warning indicators
│           ├── odontogram_widget.dart       # Interactive FDI dental arch chart
│           ├── real_tooth_painter.dart      # Bezier anatomical teeth & 5-surface renderer
│           ├── ai_settings_dialog.dart      # Masked AI engine & Gemini key manager
│           └── sample_picker_sheet.dart     # Camera, gallery & sample picker bottom sheet
└── test/
    ├── clinical_parser_test.dart     # Unit tests for 9 categories, INR billing & Gemini
    └── widget_test.dart              # Smoke tests for Odontogram & CategoryCard
```

---

## 🚀 Setup & Execution Instructions

### Prerequisites
* [Flutter SDK](https://flutter.dev) (Version 3.13.0 or later)
* Android Studio / VS Code with Flutter extension
* Android Device or Emulator (Android 5.0+ / API 21+)

### 1. Clone & Install Dependencies
```bash
git clone https://github.com/BlxrryFxce17/DentiScan.git
cd foxwell.ai
flutter pub get
```

### 2. Run the Application
Connect your Android phone (or launch an emulator) and run:
```bash
flutter run
```

*(Optional)* Pass a Gemini API key at build time:
```bash
flutter run --dart-define=GEMINI_API_KEY=your_gemini_api_key_here
```
> **Note**: You can also configure or change the Gemini API key anytime inside the app by tapping the **AI Brain icon (`🧠`)** in the top-right header!

### 3. Run Automated Tests
```bash
flutter test
```
*Executes all 7/7 unit and clinical extraction tests.*

### 4. Run Static Code Analysis
```bash
flutter analyze
```
*Validates the entire codebase with **0 issues found**.*

---

## 💡 How to Test the Application

1. **Test Preloaded Clinical Benchmarks**:
   * Open the app ➔ tap the **Sample Benchmark button (`✨`)** in the top-right header.
   * Select **Sample 1** (Messy handwritten prescription), **Sample 2** (Printed clinic chart), or **Sample 3** (Skewed phone shot).
   * Observe image contrast enhancement and the animated laser OCR scanner.
2. **Inspect the 9 Structured Categories**:
   * In the **Review & Verify Screen**, tap **"View Scan"** to pinch-to-zoom into the original document side-by-side.
   * Check how demographics, doctor details, diagnosis, tooth procedures, prescriptions, and financials are populated.
3. **Interact with the Anatomical Odontogram**:
   * Scroll to Category 7/8 ➔ toggle between **"Teeth"** and **"Surfaces"**.
   * Tap any tooth (e.g. `#46`) to see the live inspection card.
   * Tap the **Edit** icon on `#46` ➔ change the procedure or cost ➔ watch Category 9 recalculate the total bill and net balance due in real time!
4. **Verify Local Hive Storage & Patients Directory**:
   * Tap **"Confirm & Save to Records"**.
   * Switch to the **"Patients"** tab in bottom navigation ➔ notice the patient profile, lifetime spend, and chronological visit history.
5. **Generate & Share Clinical PDF**:
   * Open any record ➔ tap **"Export PDF Report"** in the top-right ➔ review the clinic-branded PDF ready for print or sharing.

---

## 🔒 Privacy & Security
* API keys are permanently masked in the UI with zero unmask buttons.
* The codebase uses XOR-encoded dynamic runtime key reconstruction to prevent plain-text credential leaks in public source repositories.
* On-device Google ML Kit is available for 100% offline, privacy-first environments.
