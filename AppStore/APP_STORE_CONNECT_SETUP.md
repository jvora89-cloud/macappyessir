# App Store Connect Setup Guide

## Overview

Complete guide for setting up QuoteHub in App Store Connect, from initial app creation to final submission preparation.

---

## Prerequisites

Before starting, ensure you have:
- [ ] Apple Developer Account ($99/year)
- [ ] Two-factor authentication enabled
- [ ] App-specific password created
- [ ] Xcode 15.0+ installed
- [ ] Valid Developer certificates
- [ ] App built and tested locally

---

## Phase 1: Apple Developer Account Setup

### 1.1 Enroll in Apple Developer Program

**If not already enrolled:**

1. Visit https://developer.apple.com/programs/enroll/
2. Click "Start Your Enrollment"
3. Sign in with Apple ID
4. Complete enrollment form:
   - Entity Type: Individual or Organization
   - Contact Information
   - Agree to terms
5. Pay $99 annual fee
6. Wait for approval (usually 24-48 hours)

### 1.2 Enable Two-Factor Authentication

**Required for App Store Connect:**

1. Go to https://appleid.apple.com
2. Sign in
3. Security section → Two-Factor Authentication
4. Follow setup instructions
5. Save recovery key safely

### 1.3 Create App-Specific Password

**For automated tools (Xcode Cloud, fastlane):**

1. Visit https://appleid.apple.com
2. Security → App-Specific Passwords
3. Generate password: "QuoteHub-Xcode"
4. Save password securely
5. Use when Xcode requests password

---

## Phase 2: Certificates & Identifiers

### 2.1 Create App ID

1. Visit https://developer.apple.com/account
2. Navigate to Certificates, Identifiers & Profiles
3. Click Identifiers → "+" button
4. Select "App IDs" → Continue

**App ID Configuration:**
```
Description: QuoteHub
Bundle ID: com.yourcompany.quotehub (Explicit)
Capabilities:
  ☑ iCloud (if using)
  ☐ Push Notifications
  ☐ Sign in with Apple
  ☐ Apple Pay
  ☑ Associated Domains (optional)
```

5. Click Continue → Register

### 2.2 Create Distribution Certificate

**For App Store submission:**

1. Certificates → "+" button
2. Select "Apple Distribution"
3. Create Certificate Signing Request (CSR):
   - Open Keychain Access on Mac
   - Keychain Access → Certificate Assistant → Request Certificate from CA
   - Email: your@email.com
   - Common Name: QuoteHub Distribution
   - Save to disk
4. Upload CSR file
5. Download certificate (.cer)
6. Double-click to install in Keychain

### 2.3 Create Provisioning Profile

**Distribution profile for App Store:**

1. Profiles → "+" button
2. Select "App Store" under Distribution
3. Select App ID: com.yourcompany.quotehub
4. Select Distribution Certificate
5. Profile Name: "QuoteHub App Store"
6. Download profile
7. Double-click to install in Xcode

---

## Phase 3: App Store Connect Setup

### 3.1 Access App Store Connect

1. Visit https://appstoreconnect.apple.com
2. Sign in with Apple ID
3. Complete two-factor authentication
4. Accept agreements (if first time)

### 3.2 Create New App

1. Click "My Apps"
2. Click "+" → "New App"

**App Information:**
```
Platform: macOS ✓

Name: QuoteHub
  (Must be unique across App Store)
  (25 characters max)

Primary Language: English (U.S.)

Bundle ID: com.yourcompany.quotehub
  (Select from dropdown - created earlier)

SKU: quotehub-mac-2026
  (Your unique identifier, not visible to users)

User Access: Full Access
  (All team members can edit)
```

3. Click "Create"

### 3.3 Configure App Information

**Navigate to: App Information (left sidebar)**

#### Localizable Information

**Name:** QuoteHub (25 chars max)
- Appears under icon on App Store
- Should match app name exactly

**Subtitle:** Professional Contractor Management (30 chars max)
- Appears below name on App Store
- Keywords: "Professional", "Contractor", "Management"

**Privacy Policy URL:**
```
https://quotehub.app/privacy
(Must be publicly accessible)
(Must be HTTPS)
```

**Category:**
- Primary Category: Business
- Secondary Category: Productivity

**Content Rights:**
```
☐ Contains Third-Party Content
☐ Uses Cryptography
```

#### Non-Localizable Information

**Bundle ID:** com.yourcompany.quotehub (auto-filled)

**License Agreement:**
- Standard Apple License (default)
- Or upload custom EULA (optional)

---

## Phase 4: Pricing and Availability

### 4.1 Set Pricing

**Navigate to: Pricing and Availability**

**Base Price:**
```
Price: Free (Tier 0)
(App is free to download)
(In-app purchases for Pro/Team tiers)
```

**Price Schedule:**
- Start Date: Immediate (or schedule future date)
- End Date: No End Date

### 4.2 Configure Availability

**Territories:**
```
☑ United States
☑ Canada
☑ United Kingdom
☑ Australia
☐ Other territories (select as needed)
```

**Pre-Order:**
```
☐ Enable Pre-Order
(Uncheck for initial release)
(Enable later for major updates)
```

---

## Phase 5: App Privacy

### 5.1 Configure Privacy Practices

**Navigate to: App Privacy**

Apple requires detailed privacy information for App Store.

**Data Collection:**

1. Click "Get Started"
2. Answer questions:

**Q: Does this app collect data from users?**
```
☑ Yes (if using analytics)
☐ No (if no data collection)
```

**If Yes, specify data types:**

**Contact Info:**
- Email Address (for support)
  - Used for: App Functionality
  - Linked to User: No
  - Used for Tracking: No

**Identifiers:**
- Device ID (for analytics)
  - Used for: Analytics
  - Linked to User: No
  - Used for Tracking: No

**Usage Data:**
- Product Interaction (analytics events)
  - Used for: Analytics
  - Linked to User: No
  - Used for Tracking: No

**Financial Info:**
- Purchase History (job costs)
  - Used for: App Functionality
  - Linked to User: Yes
  - Used for Tracking: No

3. Save privacy practices

### 5.2 Privacy Policy Link

Ensure privacy policy URL is accessible:
- https://quotehub.app/privacy
- Must be live before submission
- Must comply with GDPR, CCPA
- Already created in Phase 1 (PRIVACY_POLICY.md)

---

## Phase 6: Version Information

### 6.1 Create First Version

**Navigate to: macOS → 1.0 Prepare for Submission**

#### What's New in This Version

**Version 1.0 Release Notes:**
```
Welcome to QuoteHub 1.0! 🎉

Professional contractor management for macOS:

• AI-powered estimates from photos
• 8 professional job templates
• Comprehensive payment tracking
• Beautiful PDF generation
• Job progress monitoring
• Bulk operations for efficiency
• Business analytics dashboard
• Email integration

Download free and transform your contracting business today!
```

(4000 characters max, use ~170 chars for concise description)

#### Promotional Text (Optional)

**Featured text on App Store:**
```
NEW: AI camera estimates in seconds. Create professional estimates 10x faster with QuoteHub's revolutionary photo-to-estimate technology.
```

(170 characters max, appears above description)

---

## Phase 7: App Description & Keywords

### 7.1 Write App Description

**Description field (4000 chars max):**

```
QuoteHub is the professional contractor management app built exclusively for macOS. Create estimates 10x faster, track jobs effortlessly, and get paid without the hassle.

🚀 KEY FEATURES

AI-POWERED ESTIMATES
Take photos of the project site and let AI generate accurate estimates instantly. No more manual measurements or hours of calculation—just point, shoot, and done.

PROFESSIONAL TEMPLATES
Start fast with 8 pre-built templates:
• Kitchen Remodels
• Bathroom Renovations
• Roofing Projects
• Interior Painting
• Flooring Installation
• Fence Construction
• HVAC Systems
• Landscaping & Decks

Each template is fully customizable for your specific needs.

PAYMENT TRACKING
Never lose track of payments again:
• Accept cash, check, credit card, Venmo, Zelle
• Automatic balance calculations
• Complete payment history
• Real-time payment status

PROFESSIONAL OUTPUT
Impress clients with beautiful, branded PDFs:
• Professional estimate layouts
• Detailed invoice generation
• Email directly to clients
• Export for offline records

JOB MANAGEMENT
Track every detail in one place:
• Visual progress indicators
• Project photo galleries
• Client information management
• Custom notes and fields
• Job status at a glance

BULK OPERATIONS
Save hours every week:
• Mark multiple jobs complete at once
• Export data for several projects
• Bulk delete old estimates
• Manage 10+ jobs simultaneously

BUSINESS ANALYTICS
Make data-driven decisions:
• Total revenue tracking
• Active job value monitoring
• Completion rate analysis
• Payment status dashboard
• Performance insights

🎯 BUILT FOR MAC

QuoteHub is a native macOS app optimized for Apple Silicon:
• Lightning-fast performance
• Beautiful, intuitive interface
• Follows Apple Human Interface Guidelines
• Full light and dark mode support
• VoiceOver accessibility
• Works completely offline

💰 FLEXIBLE PRICING

Free Tier: Up to 10 active jobs
Pro: $29/month - Unlimited jobs + AI features
Team: $99/month - Collaboration + advanced features

Download QuoteHub free today and transform your contracting business!

📧 SUPPORT

Questions? Feedback? Contact us at support@quotehub.app
We respond within 24 hours.

🔒 PRIVACY

Your data stays on your Mac. No cloud sync required. Full data ownership and export anytime.

---

Built by contractors, for contractors. QuoteHub eliminates the administrative burden so you can focus on what you do best—building.
```

### 7.2 Optimize Keywords

**Keywords field (100 chars max, comma-separated):**

```
contractor,estimate,invoice,job,payment,project,remodel,renovation,construction,business
```

**Keyword Strategy:**

**High Priority (included above):**
- contractor (high volume, highly relevant)
- estimate (primary use case)
- invoice (core feature)
- job (common search term)
- payment (key feature)
- project (alternative term)

**Secondary (space permitting):**
- remodel, renovation, construction
- business, management

**Avoid:**
- Generic: app, software, tool
- Brand names: QuoteHub (auto-indexed)
- Duplicates: "contractor software" (both indexed separately)

**Keyword Research Tools:**
- App Store Connect Keyword Insights
- AppTweak
- Sensor Tower
- Mobile Action

---

## Phase 8: Screenshots & Previews

### 8.1 Upload Screenshots

**Navigate to: App Previews and Screenshots**

**Required Sizes for macOS:**
- 1280 x 800 pixels (minimum)
- 2880 x 1800 pixels (Retina, recommended)

**Upload Process:**

1. Click "macOS 11.0 and later"
2. Drag and drop screenshots (up to 10)
3. Reorder screenshots (drag to reposition)
4. Add captions (optional, 30 chars)

**Screenshot Order (from SCREENSHOT_GUIDE.md):**
1. Dashboard Hero
2. AI Camera
3. Job Detail
4. Templates
5. Payments
6. PDF Export
7. Bulk Operations
8. Analytics

### 8.2 Upload App Preview Video (Optional)

**Video Specifications:**
- Duration: 15-30 seconds
- Resolution: 1920 x 1080 pixels
- Format: MOV or MP4
- Codec: H.264, High Profile
- Frame Rate: 30 fps

**Upload Process:**
1. Click "+ App Preview"
2. Upload video file
3. Select poster frame
4. Preview video playback
5. Save

(Use APP_STORE_VIDEO_SCRIPT.md for production)

---

## Phase 9: Build Upload

### 9.1 Prepare Xcode Project

**Version & Build Number:**

1. Open Xcode project
2. Select target → General
3. Set version: `1.0`
4. Set build: `1` (increment for each upload)

**Deployment Target:**
```
Minimum macOS Version: 14.0 (Sonoma)
```

**Code Signing:**
```
Team: Your Team Name
Signing Certificate: Apple Distribution
Provisioning Profile: QuoteHub App Store
```

**Capabilities:**
- Review Info.plist for required permissions
- Remove unused capabilities
- Test all features work

### 9.2 Create Archive

1. Select "Any Mac" as destination
2. Product → Archive (or Cmd+Shift+B)
3. Wait for archive to complete (5-10 minutes)
4. Archive appears in Organizer

### 9.3 Validate Archive

**Before uploading:**

1. In Organizer, select archive
2. Click "Validate App"
3. Choose options:
   ```
   ☑ Upload your app's symbols (for crash logs)
   ☑ Include bitcode for iOS App Store
   ☐ Strip Swift symbols (keep for debugging)
   ```
4. Click "Validate"
5. Wait for validation (2-5 minutes)
6. Review any errors or warnings

**Common Issues:**
- Missing required icons
- Invalid provisioning profile
- Code signing errors
- Missing entitlements

Fix all issues before proceeding.

### 9.4 Upload to App Store Connect

1. Click "Distribute App"
2. Select "App Store Connect"
3. Choose upload options (same as validation)
4. Click "Upload"
5. Wait for upload (5-15 minutes depending on size)
6. Success message appears

**Note:** Build processing takes 15-60 minutes after upload.

---

## Phase 10: Test Flight (Optional but Recommended)

### 10.1 Enable TestFlight

**Internal Testing (before public release):**

1. Navigate to TestFlight tab
2. Add internal testers:
   - Team members with App Store Connect access
   - Up to 100 internal testers
   - No review required
3. Upload build (already done in Phase 9)
4. Wait for processing
5. Testers receive email notification

### 10.2 External Testing (Optional)

**Public beta testing:**

1. Create external test group
2. Set build for testing
3. Add beta information (What to Test)
4. Submit for Beta App Review (1-2 days)
5. Invite up to 10,000 external testers
6. Collect feedback

**What to Test:**
```
Please test the following:

1. Create a new estimate (try AI camera if possible)
2. Add payments to a job
3. Export a PDF
4. Use bulk operations (select multiple jobs)
5. Report any crashes or bugs

Your feedback is crucial for improving QuoteHub!
```

---

## Phase 11: App Review Information

### 11.1 Contact Information

**Navigate to: App Review Information**

```
First Name: [Your First Name]
Last Name: [Your Last Name]
Phone Number: +1 (555) 123-4567
Email: review@quotehub.app
```

(Must be available during review process)

### 11.2 Demo Account

**For app review team to test the app:**

**If app requires login:**
```
Username: reviewer@quotehub.com
Password: ReviewPass123!

Sign-in required: No
(QuoteHub works without account)
```

**If features need special access:**
- Provide instructions
- Pre-populate demo data
- Explain how to access all features

### 11.3 Review Notes

**Additional information for reviewers:**

```
DEMO DATA:
The app comes pre-loaded with 5 sample jobs to demonstrate functionality. Reviewers can also create new jobs using the "+" button in the top toolbar.

AI CAMERA FEATURE:
The AI camera estimation feature requires actual project photos to demonstrate. We've included sample images in the Help menu → "Sample Project Photos" for testing purposes.

PAYMENT METHODS:
Payment tracking is for record-keeping only. The app does NOT process actual payments—it simply logs payment information entered by the contractor.

PRIVACY:
All data is stored locally on the user's Mac. No cloud sync or data transmission occurs. Users have full control over their data.

TESTING INSTRUCTIONS:
1. Create a new estimate using templates
2. Add payment information to existing jobs
3. Export a job as PDF
4. Use bulk operations on multiple jobs
5. View analytics dashboard

Please contact us at review@quotehub.app if you have questions.
```

### 11.4 Attachments

**Optional supporting documents:**
- Demo video showing key features
- Explanation of IAP if applicable
- Screenshots with annotations
- Beta test results

---

## Phase 12: Age Rating

### 12.1 Complete Rating Questionnaire

**Navigate to: Age Rating**

**Questions for QuoteHub:**

```
Cartoon or Fantasy Violence: None
Realistic Violence: None
Prolonged Graphic or Sadistic Realistic Violence: None
Profanity or Crude Humor: None
Mature/Suggestive Themes: None
Horror: None
Medical/Treatment Information: None
Alcohol, Tobacco, or Drug Use or References: None
Simulated Gambling: None
Sexual Content or Nudity: None
Graphic Sexual Content and Nudity: None

Unrestricted Web Access: No
Gambling and Contests: No
```

**Result:** Age 4+

Save rating.

---

## Phase 13: Rights & Pricing

### 13.1 Export Compliance

**Navigate to: App Store → Version → Export Compliance**

**Is your app designed to use cryptography or does it contain encryption?**

```
☑ Yes (uses HTTPS for web requests)

Select the type of encryption:
☑ Uses encryption exempt under ECCN 5D992
(Standard encryption for HTTPS, not subject to export rules)
```

### 13.2 Content Rights

**Third-party content:**

```
☐ App contains, displays, or accesses third-party content
(QuoteHub generates content from user input only)
```

### 13.3 Advertising Identifier

```
☐ This app uses the Advertising Identifier (IDFA)
(QuoteHub does not use IDFA)
```

---

## Phase 14: Version Release

### 14.1 Release Options

**Navigate to: Version Release**

**Choose release method:**

```
○ Automatically release this version
  (Released immediately after approval)

● Manually release this version
  (You control release date after approval)
  [RECOMMENDED for initial launch]

○ Schedule for release
  (Released on specific date after approval)
```

**Recommendation:** Choose manual release for:
- Coordinating with marketing campaign
- Fixing critical bugs found during review
- Ensuring support is ready

---

## Phase 15: Submit for Review

### 15.1 Final Checklist

Before submitting, verify:

- [ ] Build uploaded and processed
- [ ] All screenshots uploaded (8 minimum)
- [ ] Description complete (no Lorem Ipsum)
- [ ] Keywords optimized (100 chars)
- [ ] Contact information correct
- [ ] Demo account working (if applicable)
- [ ] Review notes comprehensive
- [ ] Privacy policy accessible
- [ ] Age rating completed
- [ ] Export compliance answered
- [ ] Version release option selected
- [ ] All localizations complete (if applicable)

### 15.2 Submit

1. Click "Submit for Review"
2. Confirm all information is correct
3. Wait for confirmation email

**Status Changes:**
```
Waiting for Review → In Review → Processing → Ready for Sale
```

**Typical Timeline:**
- Waiting for Review: 1-3 days
- In Review: 1-24 hours
- Processing: 15-60 minutes
- Ready for Sale: Immediate (or scheduled)

---

## Phase 16: Post-Submission

### 16.1 Monitor Status

**App Store Connect:**
- Check status daily
- Respond to reviewer questions promptly
- Have email notifications enabled

**Rejection Reasons:**
- Missing required metadata
- Crash on launch
- Features not working as described
- Privacy policy issues
- Guideline violations

### 16.2 Communication with App Review

**If reviewers have questions:**

1. Check email for App Store Connect notifications
2. Respond in Resolution Center within 24 hours
3. Provide clear, helpful answers
4. Include screenshots/videos if helpful

**If rejected:**

1. Read rejection reason carefully
2. Fix all issues mentioned
3. Test thoroughly
4. Upload new build
5. Resubmit with explanation in Review Notes

---

## Troubleshooting Common Issues

### Build Not Appearing in App Store Connect

**Solutions:**
- Wait 15-60 minutes for processing
- Check for email about processing errors
- Verify bundle ID matches exactly
- Ensure build number is unique
- Upload again if needed

### Missing Compliance Information

**Solutions:**
- Complete Export Compliance section
- Answer all encryption questions
- Save and resubmit

### Invalid Binary

**Solutions:**
- Check Xcode version (use latest)
- Verify provisioning profile
- Remove unused frameworks
- Check for invalid architectures
- Re-archive and upload

### Screenshot Issues

**Solutions:**
- Verify exact dimensions required
- Use PNG format (not JPEG)
- Ensure screenshots show actual app UI
- Remove copyrighted content
- Re-capture if blurry or pixelated

---

## Best Practices

### DO:
✅ Test app thoroughly before submission
✅ Provide comprehensive review notes
✅ Use clear, professional screenshots
✅ Write detailed, accurate description
✅ Respond quickly to reviewer questions
✅ Keep contact information current
✅ Review Apple's App Store Guidelines

### DON'T:
❌ Submit untested builds
❌ Use placeholder text or images
❌ Exaggerate features in description
❌ Ignore reviewer questions
❌ Submit frequent updates during review
❌ Include competitor names in keywords
❌ Promise features not yet implemented

---

## Resources

### Apple Documentation
- App Store Connect Help: https://help.apple.com/app-store-connect/
- App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- macOS App Distribution: https://developer.apple.com/distribute/

### Tools
- Xcode (required): https://developer.apple.com/xcode/
- Transporter (alternative upload): https://apps.apple.com/app/transporter/id1450874784
- App Store Connect API: https://developer.apple.com/app-store-connect/api/

### Support
- Developer Forums: https://developer.apple.com/forums/
- App Review: https://developer.apple.com/contact/app-store/
- Technical Support: https://developer.apple.com/support/

---

## Timeline Summary

**Total Time to App Store Connect Setup:**
- Account setup: 2-3 days (includes approval wait)
- Certificates & profiles: 1-2 hours
- App creation & metadata: 3-4 hours
- Screenshots & video: 8-10 hours (from SCREENSHOT_GUIDE)
- Build upload: 1-2 hours
- Review submission: 30 minutes

**Total: 2-3 days + 15-20 hours of work**

**Review Process:**
- Waiting for Review: 1-3 days
- In Review: 1-24 hours
- **Total: 1-4 days from submission to approval**

---

**Document Version:** 1.0
**Last Updated:** February 2026
**Status:** Ready for Implementation
