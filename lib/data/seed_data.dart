import 'package:drift/drift.dart';
import 'database.dart';

/// Seeds the database with realistic sample documents for M1.
Future<void> seedDatabase(AppDatabase db) async {
  // Check if already seeded
  final existing = await db.getAllDocuments();
  if (existing.isNotEmpty) return;

  final now = DateTime.now().millisecondsSinceEpoch;
  final yesterday = now - 86400000;
  final lastWeek = now - 604800000;

  // Create sample folders
  await db.insertFolder(ScanFoldersCompanion(
    name: const Value('Receipts'),
    colorHex: const Value('#D43030'),
    sortOrder: const Value(0),
    createdAt: Value(lastWeek),
  ));

  await db.insertFolder(ScanFoldersCompanion(
    name: const Value('IDs'),
    colorHex: const Value('#1B8A4A'),
    sortOrder: const Value(1),
    createdAt: Value(lastWeek),
  ));

  await db.insertFolder(ScanFoldersCompanion(
    name: const Value('School'),
    colorHex: const Value('#C06800'),
    sortOrder: const Value(2),
    createdAt: Value(lastWeek),
  ));

  // Document 1: M-Pesa receipt
  final receiptId = await db.insertDocument(ScanDocumentsCompanion(
    title: const Value('M-Pesa Statement Nov'),
    folderId: const Value(1),
    pageCount: const Value(2),
    ocrStatus: const Value('complete'),
    createdAt: Value(yesterday),
    updatedAt: Value(yesterday),
  ));

  await db.insertPage(ScanPagesCompanion(
    documentId: Value(receiptId),
    sortOrder: const Value(0),
    originalImagePath: const Value('seed/receipt_p1.jpg'),
    filterType: const Value('enhanced'),
    recognizedText: const Value(
      'SAFARICOM M-PESA\n'
      'M-PESA Statement\n'
      'Transaction ID: RJK4F8HDMS\n'
      'Date: 07/11/2026 14:32\n'
      'Amount: KES 1,500.00\n'
      'To: John Kamau\n'
      'Balance: KES 4,250.00',
    ),
    createdAt: Value(yesterday),
  ));

  await db.insertPage(ScanPagesCompanion(
    documentId: Value(receiptId),
    sortOrder: const Value(1),
    originalImagePath: const Value('seed/receipt_p2.jpg'),
    filterType: const Value('enhanced'),
    recognizedText: const Value(
      'Transaction History\n'
      '05/11/2026 Buy Goods KES 350.00\n'
      '04/11/2026 Send Money KES 2,000.00\n'
      '03/11/2026 Airtime KES 100.00\n'
      '01/11/2026 Deposit KES 5,000.00',
    ),
    createdAt: Value(yesterday),
  ));

  // Document 2: National ID
  final idDocId = await db.insertDocument(ScanDocumentsCompanion(
    title: const Value('National ID Card'),
    folderId: const Value(2),
    pageCount: const Value(2),
    ocrStatus: const Value('complete'),
    createdAt: Value(lastWeek),
    updatedAt: Value(lastWeek),
  ));

  await db.insertPage(ScanPagesCompanion(
    documentId: Value(idDocId),
    sortOrder: const Value(0),
    originalImagePath: const Value('seed/id_front.jpg'),
    filterType: const Value('original'),
    recognizedText: const Value(
      'REPUBLIC OF KENYA\n'
      'NATIONAL IDENTITY CARD\n'
      'ID No: 12345678\n'
      'Full Names: JANE WANJIKU MWANGI\n'
      'Date of Birth: 15/03/1995\n'
      'Sex: F\n'
      'District of Birth: KIAMBU',
    ),
    createdAt: Value(lastWeek),
  ));

  await db.insertPage(ScanPagesCompanion(
    documentId: Value(idDocId),
    sortOrder: const Value(1),
    originalImagePath: const Value('seed/id_back.jpg'),
    filterType: const Value('original'),
    recognizedText: const Value(
      'Address: P.O. BOX 456\n'
      'THIKA\n'
      'Date of Issue: 20/06/2018\n'
      'District: KIAMBU',
    ),
    createdAt: Value(lastWeek),
  ));

  // Document 3: School certificate
  final certId = await db.insertDocument(ScanDocumentsCompanion(
    title: const Value('KCSE Certificate'),
    folderId: const Value(3),
    pageCount: const Value(1),
    ocrStatus: const Value('partial'),
    createdAt: Value(lastWeek - 86400000),
    updatedAt: Value(lastWeek),
  ));

  await db.insertPage(ScanPagesCompanion(
    documentId: Value(certId),
    sortOrder: const Value(0),
    originalImagePath: const Value('seed/certificate.jpg'),
    filterType: const Value('bw'),
    recognizedText: const Value(
      'KENYA NATIONAL EXAMINATIONS COUNCIL\n'
      'KENYA CERTIFICATE OF SECONDARY EDUCATION\n'
      'Name: JANE WANJIKU MWANGI\n'
      'Index No: 10123456/001\n'
      'Year: 2012\n'
      'Mean Grade: A-',
    ),
    createdAt: Value(lastWeek - 86400000),
  ));

  // Document 4: Fee receipt (no folder, no OCR yet)
  final feeId = await db.insertDocument(ScanDocumentsCompanion(
    title: const Value('Term 3 Fee Receipt'),
    pageCount: const Value(1),
    ocrStatus: const Value('none'),
    createdAt: Value(now),
    updatedAt: Value(now),
  ));

  await db.insertPage(ScanPagesCompanion(
    documentId: Value(feeId),
    sortOrder: const Value(0),
    originalImagePath: const Value('seed/fee_receipt.jpg'),
    filterType: const Value('enhanced'),
    createdAt: Value(now),
  ));

  // Document 5: KRA PIN Certificate
  final kraId = await db.insertDocument(ScanDocumentsCompanion(
    title: const Value('KRA PIN Certificate'),
    folderId: const Value(1),
    pageCount: const Value(1),
    ocrStatus: const Value('complete'),
    createdAt: Value(lastWeek - 172800000),
    updatedAt: Value(lastWeek - 86400000),
  ));

  await db.insertPage(ScanPagesCompanion(
    documentId: Value(kraId),
    sortOrder: const Value(0),
    originalImagePath: const Value('seed/kra_pin.jpg'),
    filterType: const Value('enhanced'),
    recognizedText: const Value(
      'KENYA REVENUE AUTHORITY\n'
      'TAX COMPLIANCE CERTIFICATE\n'
      'PIN: A012345678Z\n'
      'Name: JANE WANJIKU MWANGI\n'
      'Obligation: Income Tax - Resident Individual\n'
      'Effective From: 01/01/2026\n'
      'Valid Until: 31/12/2026',
    ),
    createdAt: Value(lastWeek - 172800000),
  ));
}
