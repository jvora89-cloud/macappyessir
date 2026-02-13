# Screenshot Guide for Landing Page

## Quick Instructions

Use macOS screenshot tool: **⌘⇧4** then press **Spacebar** to capture clean windows.

## Screenshots Needed (5 total)

### 1. Dashboard View (Primary Hero Image)
- **Navigate**: Press ⌘1 or click "Dashboard"
- **Setup**: Make sure you have:
  - Revenue chart visible with data
  - At least 2-3 job cards showing
  - Stats cards at top filled in
- **Capture**: ⌘⇧4 → Spacebar → Click window
- **Save as**: `docs/screenshots/dashboard.png`

### 2. Estimate Wizard (Show Innovation)
- **Navigate**: Press ⌘N for "New Estimate"
- **Setup**: Go to Step 3 or 4 (middle of wizard)
  - Fill in some sample data
  - Make it look "in use"
  - Show the progress indicator at top
- **Capture**: ⌘⇧4 → Spacebar → Click window
- **Save as**: `docs/screenshots/wizard.png`

### 3. Jobs List with Filters (Show Power)
- **Navigate**: Press ⌘3 for "Jobs"
- **Setup**: 
  - Have 4-5 jobs visible
  - Open filter panel/options
  - Maybe show search with results
- **Capture**: ⌘⇧4 → Spacebar → Click window
- **Save as**: `docs/screenshots/jobs.png`

### 4. Payment Tracking (Show Professional)
- **Navigate**: Click on a job to see details
- **Setup**:
  - Show payment milestones section
  - OR show payment analytics with charts
  - Make sure some payments are marked as paid
- **Capture**: ⌘⇧4 → Spacebar → Click window
- **Save as**: `docs/screenshots/payments.png`

### 5. Command Palette (Show Speed)
- **Navigate**: Press ⌘K anywhere in app
- **Setup**:
  - Type a search query (e.g., "kitchen")
  - Show search results
  - Make sure palette is centered and prominent
- **Capture**: ⌘⇧4 → Spacebar → Click window
- **Save as**: `docs/screenshots/command-palette.png`

## Pro Tips

1. **Clean Window**: Make sure window is full-screen or large enough to show details
2. **Sample Data**: Add realistic sample data first (jobs, clients, payments)
3. **Lighting**: Use light mode for clearer screenshots
4. **Resolution**: macOS captures Retina resolution automatically (perfect!)
5. **File Size**: We'll optimize after capture

## After Capture

Run this to optimize for web:
```bash
cd docs/screenshots
for img in *.png; do
    sips -Z 1600 "$img" --out "optimized-$img"
done
```

## Verification Checklist

- [ ] All 5 screenshots captured
- [ ] Files are in `docs/screenshots/` folder
- [ ] Images are clear and professional
- [ ] No sensitive/test data visible
- [ ] Window chrome (title bar) looks good

