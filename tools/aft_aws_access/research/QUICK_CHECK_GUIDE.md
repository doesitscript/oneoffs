# Quick Check Guide: Can I Fix This Myself?

**Target:** `App-AWS-AA-database-sandbox-941677815499-admin` (empty group)  
**Goal:** Determine if you can populate it without contacting SailPoint admins

---

## ⚡ 5-Minute Self-Assessment

### Test 1: Okta Admin Access (2 minutes)

```
1. Open Okta: https://breadfinancial.okta.com
2. Look for "Admin" button in top-right
3. If you see it, click Admin
4. Navigate to: Directory → Groups
5. Search for: App-AWS-AA-database-sandbox-941677815499-admin
```

**✅ If you can see and edit the group:**
- You CAN do this yourself via Okta
- ⚠️ BUT bypasses governance (see warnings below)
- 📖 See: `SELF_SERVICE_OPTIONS.md` → Option 1

**❌ If you don't see Admin button or can't edit:**
- Continue to Test 2

---

### Test 2: SailPoint Admin Access (2 minutes)

```
1. Open Okta apps, find "SailPoint Identity Security Cloud"
2. Click to launch SailPoint
3. Look for "Admin" menu in navigation
4. Try to navigate to: Admin → Access Profiles
5. Check if you can click "Create Access Profile"
```

**✅ If you can create Access Profiles:**
- You CAN do this yourself via SailPoint (recommended way!)
- ✅ This is the proper governance method
- 📖 See: `SELF_SERVICE_OPTIONS.md` → Option 2

**❌ If you can't access Admin or create profiles:**
- You need SailPoint admin help
- Continue to Test 3

---

### Test 3: What CAN You Do? (1 minute)

Even without admin access, you might be able to:

**In SailPoint (as regular user):**
- Request access for YOURSELF
- View available access profiles
- Check status of pending requests

**In Okta (as regular user):**
- See your assigned groups
- View assigned applications
- Nothing administrative

**In AWS (with IAM Identity Center access):**
- View groups (read-only)
- See current members
- Nothing you SHOULD change manually

---

## 🎯 Quick Decision Tree

```
Do you have Okta Admin access?
├─ YES ──→ Can you tolerate governance bypass?
│          ├─ YES ──→ Use Option 1 (15 min, document it!)
│          └─ NO  ──→ Check SailPoint access
│
└─ NO  ──→ Do you have SailPoint Admin access?
           ├─ YES ──→ Use Option 2 (1 hour, proper way!)
           └─ NO  ──→ Contact SailPoint admins
```

---

## ⚠️ Critical Warning: Okta Direct Access

**If you CAN add users in Okta directly:**

### ✅ Pros:
- Fast (15 minutes total)
- Uses existing SCIM sync
- No AWS changes needed

### ❌ Cons:
- **No approval workflow**
- **No audit trail in SailPoint**
- **Compliance risk** (SOX/PCI/audit issues)
- **Lifecycle issues** (user won't be auto-removed when they leave)

### 🚨 DO NOT USE if:
- You're in Finance, Security, or Compliance department
- Your company is regulated (SOX, PCI, HIPAA, etc.)
- You're not sure about governance policies
- This is for production access

### ✅ OK to use if:
- Non-production/sandbox access
- Emergency situation (document it!)
- You plan to create proper SailPoint profile later
- Company policy allows manual Okta management

---

## 📋 What to Check in Each System

### Okta Admin Console Checklist

```bash
□ Can access Admin Console?
□ Can navigate to Directory → Groups?
□ Can search for AWS groups?
□ Can see "Add Users" or "Manage People" button?
□ Can view Applications tab in group?
□ Can see AWS IAM Identity Center app assigned?
□ Can see Push Status or sync status?
```

**If ALL checked:** You have sufficient Okta access for Option 1

---

### SailPoint Checklist

```bash
□ Can access SailPoint platform?
□ Can see Admin menu?
□ Can navigate to Access Profiles?
□ Can click "Create Access Profile"?
□ Can see Okta as a source system?
□ Can add Okta group entitlements?
□ Can assign access to users manually?
```

**If ALL checked:** You have sufficient SailPoint access for Option 2

---

### AWS IAM Identity Center Checklist

```bash
□ Can access account 717279730613?
□ Can navigate to IAM Identity Center?
□ Can view Groups section?
□ Can see group: 711bf5c0-b071-70c1-06da-35d7fbcac52d?
□ Can see "Add users" button (even if grayed out)?
```

**If checked:** You can MONITOR but shouldn't CHANGE directly

---

## 🔧 Quick Verification Commands

### Check if Group Exists in AWS

```bash
aws identitystore describe-group \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2
```

### Check Current Members

```bash
aws identitystore list-group-memberships \
  --identity-store-id d-9a6763d7d3 \
  --group-id 711bf5c0-b071-70c1-06da-35d7fbcac52d \
  --region us-east-2
```

**Expected Result Right Now:** Empty list (0 members)

---

## 📞 Who to Contact Based on Your Access

### If You Have:

| Your Access | What You Can Do | Who to Contact |
|-------------|-----------------|----------------|
| **Okta Admin + SailPoint Admin** | ✅ Everything yourself (use SailPoint!) | No one needed |
| **Okta Admin only** | ⚠️ Manual add (with risks) | SailPoint team (for proper setup) |
| **SailPoint Admin only** | ✅ Proper governance setup | No one needed |
| **Neither admin access** | ❌ Nothing yourself | **SailPoint Admins** |
| **Only AWS access** | ❌ Can view only | **SailPoint Admins** |

---

## 🎯 Recommended Actions by Access Level

### Scenario 1: You Have Both Okta and SailPoint Admin

**DO THIS:**
1. ✅ Create proper SailPoint Access Profile (Option 2)
2. ✅ This takes 1 hour but is the RIGHT way
3. ✅ Creates reusable, compliant process

**DON'T DO:**
- ❌ Skip to Okta direct add (tempting but wrong)

---

### Scenario 2: You Have Only Okta Admin

**DECISION POINT:**

**Is this production/regulated/critical access?**
- **YES** → Stop, contact SailPoint admins
- **NO** → Consider Option 1 with caveats:
  - ✅ Add users in Okta
  - ✅ Document the manual change
  - ✅ Create Jira/ticket to build proper SailPoint profile
  - ✅ Plan to migrate to proper governance

---

### Scenario 3: You Have Only SailPoint Admin

**DO THIS:**
1. ✅ Use Option 2 (proper way)
2. ✅ Create Access Profile
3. ✅ Assign to users
4. ✅ Let SCIM handle the rest

---

### Scenario 4: You Have Neither Admin Access

**DO THIS:**
1. 📞 Contact SailPoint administrators
2. 📋 Provide them with:
   ```
   Group Name: App-AWS-AA-database-sandbox-941677815499-admin
   AWS Account: database-sandbox (941677815499)
   Access Level: Admin
   Users Needed: [list of user emails]
   Business Justification: [your reason]
   ```
3. ⏱️ Wait for them to create access profile
4. 🔄 Then users can self-service request access

---

## ⏱️ Time Estimates

| Method | Setup Time | Per-User Time | Sustainable? |
|--------|------------|---------------|--------------|
| **Option 1: Okta Direct** | 5 min | 2 min/user | ❌ No (manual each time) |
| **Option 2: SailPoint** | 30-60 min (one-time) | 5 min/user (self-service!) | ✅ Yes |
| **Option 3: AWS Direct** | 2 min | 1 min/user | ❌❌ NO (breaks SCIM) |
| **Contact Admin** | 0 min (for you) | Depends on ticket | ✅ Yes (once setup) |

---

## 🚦 Red Flags: When You MUST Use SailPoint

Stop and use proper governance (Option 2 or contact admins) if:

- 🚨 Production environment access
- 🚨 Admin-level permissions
- 🚨 Financial systems access
- 🚨 PII/sensitive data access
- 🚨 SOX-controlled systems
- 🚨 PCI/HIPAA/regulated environment
- 🚨 Your company has strict governance policies
- 🚨 You're not 100% sure about the risks

---

## ✅ Green Lights: When Okta Direct Might Be OK

Consider Okta direct (Option 1) only if ALL true:

- ✅ Sandbox/non-production environment
- ✅ Read-only or low-privilege access
- ✅ No regulatory requirements
- ✅ Company culture allows it
- ✅ You will document it
- ✅ You plan to create proper SailPoint profile later
- ✅ Emergency/time-sensitive need

**In our case:** `database-sandbox` suggests dev/test → might be OK

---

## 📝 Documentation Template

If you use Okta direct, document it:

```markdown
### Manual Okta Group Assignment - [Date]

**Group:** App-AWS-AA-database-sandbox-941677815499-admin
**Users Added:** 
- user1@breadfinancial.com
- user2@breadfinancial.com

**Reason:** [Emergency/testing/temporary access]
**Added By:** [Your name]
**Date:** [Today's date]
**Follow-up Action:** 
- [ ] Create SailPoint Access Profile
- [ ] Migrate users to governed access
- [ ] Remove manual assignment
- [ ] Target Date: [Within 30 days]

**Approval:** [Manager/Security approval if applicable]
**Ticket:** [Jira/ticket number]
```

---

## 🎓 Final Recommendations

### Best → Worst Options:

1. 🥇 **SailPoint Admin Access** → Use Option 2
   - Proper governance
   - Audit trail
   - Sustainable
   - Compliant

2. 🥈 **Contact SailPoint Admins** → Let them set it up
   - Professional setup
   - You don't need admin access
   - Done right the first time

3. 🥉 **Okta Admin Access** → Use Option 1 (with caution)
   - Only for non-production
   - Document everything
   - Plan to migrate to SailPoint

4. 🚫 **AWS Direct Manipulation** → Never do this
   - Breaks SCIM
   - Creates conflicts
   - Causes issues

---

## 📚 Related Documentation

- **Full Guide:** `SELF_SERVICE_OPTIONS.md` (detailed steps)
- **Architecture:** `RESEARCH_SUMMARY.md` (how it all works)
- **SCIM Details:** `identity-center-investigation/README.md`

---

**Bottom Line:**  
Check your access → Use SailPoint if you can → Okta only if necessary → Never AWS direct

**When in doubt:** Contact SailPoint admins - that's what they're there for! 🎯