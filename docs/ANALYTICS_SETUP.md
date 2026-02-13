# Analytics Setup Guide

## Google Analytics Setup (5 minutes)

### Step 1: Create Google Analytics Account

1. Go to https://analytics.google.com
2. Click "Start measuring"
3. Enter account name: "Lakshami Contractors"
4. Configure data sharing settings (optional)
5. Click "Next"

### Step 2: Create Property

1. Property name: "Lakshami Contractors Website"
2. Timezone: Select your timezone
3. Currency: USD
4. Click "Next"

### Step 3: Add Data Stream

1. Select platform: "Web"
2. Website URL: `https://jvora89-cloud.github.io/macappyessir/`
3. Stream name: "Lakshami Contractors Landing Page"
4. Click "Create stream"

### Step 4: Get Your Tracking ID

After creating the stream, you'll see:
- **Measurement ID**: `G-XXXXXXXXXX` (looks like G-1A2B3C4D5E)

Copy this ID!

### Step 5: Update Landing Page

Open `docs/index.html` and replace both instances of `G-XXXXXXXXXX` with your actual tracking ID:

```html
<!-- Find line ~27 -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-YOUR-ID-HERE"></script>
<script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'G-YOUR-ID-HERE'); <!-- Update this too -->
</script>
```

### Step 6: Commit and Push

```bash
git add docs/index.html
git commit -m "Add Google Analytics tracking"
git push origin main
```

Wait 2 minutes for GitHub Pages to deploy, then visit your site to test!

---

## What's Being Tracked

Your landing page automatically tracks:

### Page Views
- Landing page visits
- Which pages users view
- Session duration
- Bounce rate

### Events
- ✓ Download button clicks (all download buttons)
- ✓ Navigation link clicks
- ✓ Button interactions

### User Data
- Geographic location (country/city)
- Device type (desktop/mobile)
- Browser and OS
- Traffic source (direct, search, social, referral)

---

## View Your Analytics

1. Go to https://analytics.google.com
2. Select "Lakshami Contractors Website" property
3. View reports:
   - **Realtime**: See current visitors
   - **Acquisition**: Where users come from
   - **Engagement**: What users do on your site
   - **Events**: Download clicks, navigation clicks

---

## Useful Reports

### Check if Analytics is Working
1. Visit your landing page
2. Go to Analytics → Realtime
3. You should see yourself as "1 user right now"

### Track Downloads
1. Analytics → Events
2. Look for "download_click" events
3. See which buttons get the most clicks

### See Traffic Sources
1. Analytics → Acquisition → Traffic acquisition
2. See if users come from:
   - Direct (typing URL)
   - Organic Search (Google)
   - Social (Twitter, LinkedIn)
   - Referral (other websites)

---

## Privacy Considerations

✓ Google Analytics is GDPR compliant
✓ No personally identifiable information (PII) is collected
✓ IP addresses are anonymized
✓ Users can opt-out with browser extensions

If you want to add a cookie consent banner, see:
https://www.cookiebot.com/en/

---

## Alternative: Plausible Analytics (Privacy-First)

If you prefer a privacy-focused alternative:

1. Sign up at https://plausible.io
2. Add your site: `jvora89-cloud.github.io/macappyessir`
3. Replace Google Analytics script with:

```html
<script defer data-domain="jvora89-cloud.github.io" src="https://plausible.io/js/script.js"></script>
```

Plausible is:
- ✓ Cookieless (no consent banner needed)
- ✓ Privacy-friendly (no personal data)
- ✓ Lightweight (< 1KB script)
- ✗ Paid ($9/month for 10k pageviews)

---

## Troubleshooting

### "No data in Analytics"
- Wait 24-48 hours for first data
- Check that tracking ID is correct
- Visit your site to generate test data
- Check browser console for errors

### "Seeing my own visits"
- Normal! Analytics tracks all visitors
- Install "Google Analytics Opt-out" browser extension to exclude yourself

### "Events not tracking"
- Check browser console for JavaScript errors
- Make sure script.js is loaded
- Test by clicking buttons and checking Realtime events

---

## Next Steps

After setup:
1. ✓ Verify analytics is working (check Realtime)
2. ✓ Share your landing page link
3. ✓ Monitor traffic sources
4. ✓ Track which download buttons get most clicks
5. ✓ Optimize based on data

---

**Analytics is now ready!** 🎉 Start tracking your landing page performance.
