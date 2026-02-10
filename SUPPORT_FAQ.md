# QuoteHub Support & FAQ

## Quick Start Guide

### Getting Started

**Q: How do I create my first estimate?**
A: Click the "New Estimate" button in the sidebar (or press ⌘N), fill in client details and project description, then click "Continue to Pricing" to set costs.

**Q: Where is my data stored?**
A: All data is stored locally on your Mac at:
- Jobs: `~/Library/Application Support/macappyessir/jobs.json`
- Photos: `~/Library/Application Support/macappyessir/JobPhotos/`

**Q: Does QuoteHub require internet?**
A: No! QuoteHub works 100% offline. Internet is only needed if you choose to use the optional AI estimation feature with your own Claude API key.

---

## Features

### AI Estimation

**Q: How does AI estimation work?**
A: When you create an estimate, QuoteHub can use AI to suggest costs based on your project description and type. You can use our smart fallback (no API key needed) or connect your own Claude API key for enhanced suggestions.

**Q: Do I need to pay for AI features?**
A: QuoteHub includes smart cost estimation out-of-the-box at no extra cost. If you want enhanced AI suggestions, you can optionally provide your own Claude API key from Anthropic.

**Q: How accurate are AI estimates?**
A: AI estimates are suggestions based on typical project costs. Always review and adjust estimates based on your local market, materials, and expertise. AI is a starting point, not a guarantee.

### PDF Export

**Q: How do I export an estimate as PDF?**
A: Open any job, click the "Export" menu at the top right, and choose "Export Estimate" or "Export Invoice". The PDF will open automatically in Preview.

**Q: Can I customize PDF branding?**
A: Currently, PDFs include the QuoteHub branding. Custom branding (your logo and company name) is planned for a future update.

**Q: Where are PDFs saved?**
A: PDFs are saved to your `~/Documents/` folder with automatic naming (e.g., "Estimate_ClientName_timestamp.pdf").

### Payment Tracking

**Q: How do I record a payment?**
A: Open a job, go to the Payments tab, click "Add Payment", enter the amount and payment method, then save.

**Q: Can I see payment history?**
A: Yes! The Payments tab shows all payments for a job with dates, amounts, and methods. Invoices also include payment history.

**Q: What payment methods are supported?**
A: QuoteHub tracks Cash, Check, Credit Card, Bank Transfer, PayPal, Venmo, Zelle, and Other. Choose the method that matches your transaction.

### Photo Management

**Q: How do I add photos to a job?**
A: Open a job, go to the Photos tab, click "Add Photos", and select images from your Mac. You can add multiple photos at once.

**Q: What image formats are supported?**
A: QuoteHub supports all common image formats: PNG, JPG, JPEG, HEIC, and more.

**Q: Can I delete photos?**
A: Yes! Hover over any photo in the gallery and click the red trash icon that appears.

**Q: Where are photos stored?**
A: Photos are stored locally in `~/Library/Application Support/macappyessir/JobPhotos/` and organized by job ID.

---

## Job Management

**Q: How do I mark a job as complete?**
A: Open the job, go to the Overview tab, and click "Mark as Complete". You can also enter the final actual cost if it differs from the estimate.

**Q: Can I edit a job after creating it?**
A: Absolutely! Click the "Edit Job" button in the Overview tab to modify any details.

**Q: How do I delete a job?**
A: Open the job, go to the Overview tab, scroll down, and click "Delete Job". This cannot be undone, so be careful!

**Q: Can I filter jobs by status or type?**
A: Yes! The Active Jobs and Completed Jobs views have search and filter options at the top.

---

## Settings & Customization

**Q: How do I change the app theme?**
A: Go to Settings (⌘,) → Appearance section → choose Light, Dark, or System theme.

**Q: What keyboard shortcuts are available?**
A:
- ⌘N - New Estimate
- ⌘1 - Dashboard
- ⌘2 - New Estimate
- ⌘3 - Active Jobs
- ⌘4 - Completed Jobs
- ⌘, - Settings
- ⌘F - Find Jobs
- ⌘S - Save
- ⌘↑/↓ - Scroll to top/bottom

**Q: Can I export my data?**
A: Yes! You can export individual jobs as PDFs. Your raw data is also accessible as JSON at `~/Library/Application Support/macappyessir/jobs.json`.

---

## Troubleshooting

**Q: The app won't launch. What should I do?**
A:
1. Restart your Mac
2. Check for macOS updates (QuoteHub requires macOS 15.7+)
3. Try reinstalling from the Mac App Store
4. Contact support@quotehub.app if the issue persists

**Q: My jobs aren't saving.**
A:
1. Check disk space (Settings → Storage)
2. Check file permissions: `~/Library/Application Support/macappyessir/`
3. Try creating a new estimate to test
4. Email support@quotehub.app with details

**Q: PDFs won't generate.**
A:
1. Check that you have write access to `~/Documents/`
2. Ensure the job has a valid estimate amount
3. Try generating a different job's PDF to isolate the issue
4. Contact support@quotehub.app if problems persist

**Q: Photos won't import.**
A:
1. Check that image files aren't corrupted (open them in Preview)
2. Ensure you have disk space available
3. Try importing one photo at a time to identify problematic files
4. Email support@quotehub.app if issues continue

**Q: AI estimation isn't working.**
A:
1. Check your internet connection (if using Claude API)
2. Verify your API key is entered correctly (if using Claude API)
3. The app will use smart fallback estimation if API is unavailable
4. Try again in a few minutes - API services may be temporarily down

---

## Data & Privacy

**Q: Is my data secure?**
A: Yes! All data is stored locally on your Mac. We never upload your data to our servers. Your data is as secure as your Mac's FileVault encryption and user account.

**Q: Can I backup my data?**
A: Yes! Use Time Machine or manually copy:
- `~/Library/Application Support/macappyessir/`
To restore, simply copy these files back to the same location.

**Q: What happens if I uninstall QuoteHub?**
A: Your data remains on your Mac in `~/Library/Application Support/macappyessir/`. To completely remove all data, manually delete this folder.

**Q: Does QuoteHub collect analytics?**
A: We collect minimal anonymous usage data to improve the app (if you opt-in). We NEVER collect your client data, job details, or personal information. See our Privacy Policy for details.

---

## Billing & Licensing

**Q: Is QuoteHub free?**
A: QuoteHub is available for purchase on the Mac App Store. Pricing is displayed in the App Store.

**Q: Is there a subscription?**
A: [Your pricing model here - one-time purchase, subscription, or freemium]

**Q: Can I use QuoteHub on multiple Macs?**
A: Yes! Your Mac App Store purchase covers all Macs signed in with your Apple ID.

**Q: Do you offer refunds?**
A: Refund requests must be submitted through the Mac App Store. Apple handles all refunds according to their standard policy.

---

## Feature Requests

**Q: Can you add [feature]?**
A: We love hearing from users! Email your feature requests to support@quotehub.app. We're actively developing QuoteHub and your feedback shapes our roadmap.

**Q: What's coming next?**
A: Our roadmap includes:
- Email integration (send estimates directly)
- Job templates
- Calendar view
- Custom PDF branding
- Material cost database
- Time tracking
- And more!

---

## Contact Support

**Email:** support@quotehub.app
**Website:** https://quotehub.app/support
**Response Time:** Within 24-48 hours

**When contacting support, please include:**
- QuoteHub version (Settings → About)
- macOS version
- Description of the issue
- Steps to reproduce (if applicable)
- Screenshots (if helpful)

---

## System Requirements

**Minimum:**
- macOS 15.7 or later
- 50 MB free disk space
- 4 GB RAM

**Recommended:**
- macOS 15.7 or later
- 500 MB free disk space (for photos)
- 8 GB RAM
- Apple Silicon Mac (M1/M2/M3) for best performance

---

## Tips & Tricks

💡 **Tip 1:** Use keyboard shortcuts to navigate quickly. Press ⌘1-4 to jump between views.

💡 **Tip 2:** The AI estimate is a starting point. Always adjust based on your expertise and local market.

💡 **Tip 3:** Add progress notes as you work. They'll help you remember details when creating the final invoice.

💡 **Tip 4:** Take photos before starting work, during key milestones, and after completion. Visual proof protects everyone.

💡 **Tip 5:** Export PDFs regularly as backups of your estimates and invoices.

💡 **Tip 6:** Use the search feature (⌘F) to quickly find jobs by client name or address.

💡 **Tip 7:** Mark jobs complete only after final payment to keep your outstanding balance accurate.

💡 **Tip 8:** Check the Dashboard regularly to see your active workload and financial health at a glance.

---

**Thank you for using QuoteHub!**
*Your Quote Command Center*
