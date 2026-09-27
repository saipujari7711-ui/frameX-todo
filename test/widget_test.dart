import 'package:flutter_test/flutter_test.dart';
import 'package:freelance_ops/models/models.dart';

void main() {
  test('Lead model round-trips through map serialization', () {
    final lead = Lead(
      name: 'Test Client',
      platform: 'Instagram',
      niche: 'Creator',
      status: 'DMed',
      dateContacted: '2026-09-27',
      followUpDate: '2026-09-28',
      notes: 'Test note',
    );

    final restored = Lead.fromMap(lead.toMap());

    expect(restored.name, lead.name);
    expect(restored.platform, lead.platform);
    expect(restored.niche, lead.niche);
    expect(restored.status, lead.status);
    expect(restored.dateContacted, lead.dateContacted);
    expect(restored.followUpDate, lead.followUpDate);
    expect(restored.notes, lead.notes);
  });
}
