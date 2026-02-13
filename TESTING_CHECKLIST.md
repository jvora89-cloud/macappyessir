# Lakshami Contractors - Testing Checklist

## ✅ First Launch Experience
- [ ] Onboarding tour appears on first launch
- [ ] Can navigate through all 7 onboarding steps
- [ ] "Get Started" button works and dismisses tour
- [ ] Can skip onboarding

## ✅ Navigation & UI
- [ ] All 5 sidebar items are visible (Dashboard, New Estimate, Jobs, Completed, Settings)
- [ ] Can click each sidebar item to navigate
- [ ] Keyboard shortcuts work:
  - [ ] ⌘1 - Dashboard
  - [ ] ⌘2 - New Estimate
  - [ ] ⌘3 - Jobs
  - [ ] ⌘4 - Completed
  - [ ] ⌘5 - Settings
  - [ ] ⌘K - Command Palette
  - [ ] ⌘N - New Estimate

## ✅ Dashboard
- [ ] Revenue chart displays correctly
- [ ] Stats cards show: Total Revenue, Active Jobs, Avg. Job Cost
- [ ] Recent jobs list appears
- [ ] "Quick Actions" section works
- [ ] Animations are smooth

## ✅ New Estimate Wizard
- [ ] Can open wizard with "New Estimate" button or ⌘N
- [ ] Step 1 (Method): All 3 options selectable (AI Camera, Use Template, Start Fresh)
- [ ] Step 2 (Client): Can enter client name, address, phone, email
  - [ ] Auto-complete suggests existing clients
  - [ ] Can save drafts
- [ ] Step 3 (Job Details): Can select job type, add description, set dates
- [ ] Step 4 (Pricing): Can enter cost, select pricing type, add line items
- [ ] Step 5 (Review): All entered info displays correctly
- [ ] "Create Estimate" button creates job successfully
- [ ] Can navigate back/forward through steps
- [ ] Progress indicator shows current step

## ✅ Jobs List & Filtering
- [ ] Jobs display in list/grid view (toggle button)
- [ ] Can search jobs by name
- [ ] Filter by job type works (All, Plumbing, Electrical, HVAC, etc.)
- [ ] Filter by cost range works (min/max sliders)
- [ ] Filter by status works (All, Active, Completed, On Hold)
- [ ] Filter by date range works
- [ ] Sort options work (Date: Newest, Date: Oldest, Cost: High to Low, etc.)
- [ ] Can save filter presets
- [ ] "Clear Filters" button works

## ✅ Job Details
- [ ] Can click a job to see details
- [ ] All job info displays correctly
- [ ] Photos section shows thumbnails
- [ ] Can add new photos
- [ ] Payment section displays
- [ ] Can add payments

## ✅ Payment System
- [ ] Can set up payment schedule (percentage-based or milestone-based)
- [ ] Milestones generate correctly (33% deposit, 33% midpoint, 34% final)
- [ ] Can mark milestones as paid
- [ ] Can record a payment with all details (amount, method, date, reference)
- [ ] Can generate receipt (preview and export)
- [ ] Payment analytics show:
  - [ ] Total received
  - [ ] Outstanding balance
  - [ ] Payment method breakdown (pie chart)
  - [ ] Payment timeline (line chart)

## ✅ PDF Export
- [ ] Can access PDF export from job details
- [ ] Can preview PDF before export
- [ ] All 3 template styles work:
  - [ ] Modern (blue accent)
  - [ ] Classic (green accent)
  - [ ] Minimal (black accent)
- [ ] Can customize branding:
  - [ ] Company name
  - [ ] Address
  - [ ] Phone
  - [ ] Email
  - [ ] Website
- [ ] Can save as PDF successfully
- [ ] PDF looks professional and correct

## ✅ Camera Features
- [ ] Camera opens successfully (⌘⇧C)
- [ ] Can capture photos
- [ ] Photo Review appears after capture:
  - [ ] Can edit brightness, contrast, saturation
  - [ ] Can rotate photos
  - [ ] Can crop photos
  - [ ] Can add annotations (draw, text)
  - [ ] Can accept or retake photo
- [ ] Batch capture mode works:
  - [ ] Set target photo count
  - [ ] Progress indicator updates
  - [ ] Can capture multiple photos quickly
- [ ] Photos save to correct job

## ✅ Command Palette (⌘K)
- [ ] Opens with ⌘K keyboard shortcut
- [ ] Can search for jobs by name
- [ ] Can search for clients
- [ ] Shows recent items
- [ ] Can navigate with arrow keys
- [ ] Enter key selects item
- [ ] Escape closes palette

## ✅ Settings
- [ ] All settings tabs accessible:
  - [ ] General
  - [ ] Appearance
  - [ ] PDF Templates
  - [ ] Keyboard Shortcuts
  - [ ] About
- [ ] Can customize appearance (light/dark mode if implemented)
- [ ] PDF branding settings save correctly
- [ ] Keyboard shortcuts list is visible
- [ ] About section shows app version

## ✅ Animations & Polish
- [ ] All transitions are smooth
- [ ] Hover effects work on cards and buttons
- [ ] Loading states show for long operations
- [ ] No janky animations or lag
- [ ] Micro-interactions feel polished

## ✅ Data Persistence
- [ ] Close and reopen app - data persists
- [ ] Jobs, estimates, payments all saved
- [ ] Settings preferences saved
- [ ] Photos remain associated with jobs

## ✅ Edge Cases & Errors
- [ ] Can handle empty states (no jobs, no photos, etc.)
- [ ] Form validation works (required fields)
- [ ] Error messages are clear and helpful
- [ ] Can't create invalid data (negative costs, past dates, etc.)
- [ ] App doesn't crash with unexpected input

## 🐛 Bugs Found
(List any issues discovered during testing)

---

## 📊 Testing Summary
- Total Tests: 90+
- Passed: ___
- Failed: ___
- Blocked: ___
- Notes: ___
