/// Draft legal text. MUST be reviewed by qualified legal counsel before release.
/// Bump the version when a material change requires renewed acknowledgement.
class LegalSection {
  const LegalSection(this.heading, this.body);
  final String heading;
  final String body;
}

class LegalDocuments {
  static const termsVersion = '1.0.0';
  static const privacyVersion = '1.0.0';

  static const terms = <LegalSection>[
    LegalSection('1. About MediVox',
        'MediVox helps you organise, identify and remember your medicines. It is an assistive tool and not a medical device.'),
    LegalSection('2. Not medical advice',
        'MediVox does not diagnose, prescribe, or change any dosage. All dosages and schedules come only from information you or your caregiver enter from a prescription or doctor\'s instruction. Always follow your doctor or pharmacist.'),
    LegalSection('3. Verify before you take',
        'Text recognition and image matching can be wrong. Results are suggestions, never proof of what a medicine is. Always check the name, strength and composition on the package before taking any medicine. If unsure, ask a pharmacist.'),
    LegalSection('4. Reminders',
        'Reminders depend on your device settings, battery optimisation, permissions and notification restrictions. A reminder may be delayed or not delivered. Do not rely on MediVox as your only safeguard.'),
    LegalSection('5. Accounts and storage',
        'You choose either Local Storage (data stays on this device) or Google account mode (data is also backed up to your cloud account). You may change this later. You are responsible for your device and account security.'),
    LegalSection('6. Caregivers',
        'You may share access with a caregiver only with the patient\'s explicit consent. Access can be revoked at any time.'),
    LegalSection('7. Changes',
        'If these Terms change materially, you will be asked to accept the new version before continuing.'),
  ];

  static const privacy = <LegalSection>[
    LegalSection('1. What we handle',
        'Medicine names, strengths, schedules, dose history, medicine photographs, language and accessibility preferences, and (in Google mode) your Google account identifier and display name.'),
    LegalSection('2. Local Storage mode',
        'Everything stays on your device. No account is needed. Nothing is uploaded and no cloud service is contacted.'),
    LegalSection('3. Google account mode',
        'Your records and photographs are synchronised to your own cloud space using Firebase Authentication, Cloud Firestore and Cloud Storage. Local data remains available offline.'),
    LegalSection('4. Images and recognition',
        'Photographs are stored as files. Text recognition and matching run on your device. Images are not sent to external AI services.'),
    LegalSection('5. Permissions',
        'Camera, microphone, notifications, photos and vibration are requested only when you first use a feature that needs them. The microphone is only used after you activate voice features; MediVox never records in the background.'),
    LegalSection('6. Caregiver access',
        'Caregivers can see only what you authorise. You can revoke access at any time.'),
    LegalSection('7. Deleting your data',
        'You can delete medicines, your local data, and (in Google mode) your cloud data and account from Settings. Switching storage mode never silently deletes data.'),
    LegalSection('8. No advertising',
        'MediVox contains no advertising and no unnecessary analytics.'),
  ];
}
