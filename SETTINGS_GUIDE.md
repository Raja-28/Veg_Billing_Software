# Settings Guide - VegBill

## 📋 Overview
The Settings screen provides comprehensive control over your VegBill application with essential business features, data management, and customization options.

---

## 🏪 Shop Details

Manage your shop information that appears on bills and reports.

### Available Fields:
- **Shop Name**: Your business name (default: "VegBill Store")
- **Address**: Complete shop address
- **Phone Number**: Contact number for customers
- **Email**: Business email address
- **GST Number**: Tax registration number

### How to Edit:
1. Click on any shop detail item
2. Enter the new information in the dialog
3. Click "Save" to update
4. Information is saved permanently

### Usage:
- Shop details appear on printed bills
- Used in PDF/Excel exports
- Displayed in reports

---

## 🎨 Theme Settings

Customize the appearance of your application.

### Dark Mode
- **Toggle**: Enable/disable dark theme
- **Instant Switch**: Changes apply immediately
- **Persistent**: Remembers your choice
- **Benefits**:
  - Reduces eye strain in low light
  - Saves battery on OLED screens
  - Modern, professional look

### Currency
- **Options**: INR, USD, EUR, GBP
- **Default**: INR (Indian Rupee)
- **Usage**: Affects all monetary displays
- **Symbol Display**: Automatically updates currency symbols

---

## 📤 Data Export

Export your business data in multiple formats.

### Export to Excel
- **What it exports**:
  - All bills and transactions
  - Farmer account details
  - Stock information
  - Payment records
  - Ledger entries

- **Format**: .xlsx (Excel 2007+)
- **Use Cases**:
  - Accounting purposes
  - Data analysis
  - Sharing with accountants
  - Creating custom reports

### Export to PDF
- **What it exports**:
  - Formatted expenditure reports
  - Bill summaries
  - Farmer statements
  - Stock reports

- **Format**: .pdf (Portable Document Format)
- **Use Cases**:
  - Professional reports
  - Printing
  - Email sharing
  - Record keeping

### Export All Data
- **What it exports**:
  - Complete database backup
  - All tables and relationships
  - Settings and preferences

- **Format**: Database backup file
- **Use Cases**:
  - Full backup before updates
  - Transferring to new device
  - Disaster recovery
  - Data migration

---

## 🔔 Notifications

Control how VegBill notifies you about important events.

### Enable Notifications
- **Toggle**: Turn all notifications on/off
- **Default**: Enabled
- **Types**:
  - System notifications
  - In-app alerts
  - Status updates

### Low Stock Alerts
- **Purpose**: Get notified when inventory is low
- **Trigger**: When stock falls below threshold (10 kg)
- **Benefits**:
  - Prevent stockouts
  - Timely reordering
  - Better inventory management

### Payment Reminders
- **Purpose**: Track pending farmer payments
- **Trigger**: Based on payment due dates
- **Benefits**:
  - Improve cash flow
  - Reduce outstanding balances
  - Better financial tracking

---

## 🔐 Security

Manage app security and access control.

### Change PIN
- **Purpose**: Update your 4-digit security PIN
- **Process**:
  1. Enter current PIN
  2. Enter new PIN
  3. Confirm new PIN
- **Security**: Old PIN required for verification

### Lock App Now
- **Purpose**: Immediately lock the application
- **Usage**: When leaving workstation
- **Unlock**: Requires PIN to access again

### Reset PIN
- **Purpose**: Remove current PIN completely
- **Warning**: Requires confirmation
- **Result**: Must set up new PIN on next launch
- **Use Case**: Forgotten PIN recovery

---

## ℹ️ About

View application information and details.

### Version Information
- **Current Version**: 1.1.0
- **Build Number**: 110
- **Release Date**: November 2025
- **Purpose**: Track app version for support

### Developer
- **Team**: VegBill Team
- **Purpose**: Know who built the app

### License
- **Type**: Proprietary
- **View**: Click to see full license text
- **Copyright**: © 2025 VegBill Team

---

## 🆘 Help & Support

Get assistance and provide feedback.

### User Guide
- **Content**: Quick start guide
- **Topics**:
  - Dashboard overview
  - Creating bills
  - Managing stock
  - Farmer accounts
  - Reports and analytics
- **Access**: Click to view in-app guide

### Send Feedback
- **Purpose**: Share your thoughts and suggestions
- **Process**:
  1. Click "Send Feedback"
  2. Type your feedback
  3. Submit
- **Response**: Team reviews all feedback

### Report a Bug
- **Purpose**: Help us fix issues
- **Process**:
  1. Describe the problem
  2. Include steps to reproduce
  3. Submit report
- **Follow-up**: Team investigates and fixes

### Contact Support
- **Methods**:
  - 📧 Email: support@vegbill.com
  - 📞 Phone: +91 1234567890
  - 🌐 Website: www.vegbill.com
- **Response Time**: Within 24 hours
- **Support Hours**: 9 AM - 6 PM IST

---

## 🎯 Quick Actions

### Common Tasks

**Update Shop Name**:
1. Settings → Shop Details
2. Click "Shop Name"
3. Enter new name
4. Save

**Enable Dark Mode**:
1. Settings → Theme Settings
2. Toggle "Dark Mode"
3. Theme changes instantly

**Export Data**:
1. Settings → Data Export
2. Choose format (Excel/PDF)
3. Select location
4. Export

**Change PIN**:
1. Settings → Security
2. Click "Change PIN"
3. Follow prompts

**Get Help**:
1. Settings → Help & Support
2. Choose help option
3. Follow instructions

---

## 💡 Tips & Best Practices

### Shop Details
- ✅ Keep information up-to-date
- ✅ Include complete address
- ✅ Verify GST number accuracy
- ✅ Use professional email

### Data Export
- ✅ Export regularly (weekly/monthly)
- ✅ Store backups securely
- ✅ Test restore process
- ✅ Keep multiple backup copies

### Security
- ✅ Use unique PIN
- ✅ Change PIN periodically
- ✅ Lock app when away
- ✅ Don't share PIN

### Notifications
- ✅ Enable important alerts
- ✅ Set appropriate thresholds
- ✅ Review notifications regularly
- ✅ Act on alerts promptly

---

## 🔄 Settings Persistence

### What is Saved:
- ✅ Shop details
- ✅ Theme preference
- ✅ Currency selection
- ✅ Notification settings
- ✅ PIN configuration

### What is NOT Saved:
- ❌ Temporary session data
- ❌ Cache data
- ❌ Temporary files

### Storage Location:
- **Preferences**: SharedPreferences (encrypted)
- **PIN**: Secure Storage (encrypted)
- **Database**: Local SQLite database

---

## 🚨 Important Notes

### Data Export
- 📌 Excel/PDF export features are in development
- 📌 Database backup is functional
- 📌 Choose secure location for exports
- 📌 Verify exported data

### Security
- ⚠️ PIN reset requires confirmation
- ⚠️ Lost PIN requires app reinstall
- ⚠️ Keep backup of important data
- ⚠️ Don't share sensitive information

### Support
- 📞 Contact support for critical issues
- 💬 Use feedback for suggestions
- 🐛 Report bugs with details
- 📧 Email for detailed queries

---

## 📱 Keyboard Shortcuts

### Settings Navigation
| Action | Shortcut |
|--------|----------|
| Open Settings | Click footer icon |
| Lock App | Ctrl+L (planned) |
| Save Changes | Enter (in dialogs) |
| Cancel | Esc (in dialogs) |

---

## 🔮 Future Features

### Planned Additions
1. **Cloud Sync**
   - Automatic backup to cloud
   - Multi-device sync
   - Real-time updates

2. **Advanced Export**
   - Custom date ranges
   - Filtered exports
   - Scheduled exports
   - Email delivery

3. **Enhanced Notifications**
   - SMS alerts
   - Email notifications
   - Custom alert rules
   - Priority levels

4. **Multi-Language**
   - Hindi support
   - Regional languages
   - Custom translations

5. **Advanced Security**
   - Biometric authentication
   - Two-factor authentication
   - Session management
   - Activity logs

---

## 📊 Settings Overview

```
Settings
├── Shop Details (5 fields)
│   ├── Shop Name
│   ├── Address
│   ├── Phone
│   ├── Email
│   └── GST Number
│
├── Theme Settings (2 options)
│   ├── Dark Mode
│   └── Currency
│
├── Data Export (3 formats)
│   ├── Excel
│   ├── PDF
│   └── Full Backup
│
├── Notifications (3 types)
│   ├── Enable/Disable
│   ├── Low Stock
│   └── Payment Reminders
│
├── Security (3 actions)
│   ├── Change PIN
│   ├── Lock App
│   └── Reset PIN
│
├── About (4 items)
│   ├── Version
│   ├── Release Date
│   ├── Developer
│   └── License
│
└── Help & Support (4 options)
    ├── User Guide
    ├── Send Feedback
    ├── Report Bug
    └── Contact Support
```

---

## ✅ Checklist

### Initial Setup
- [ ] Update shop name
- [ ] Add shop address
- [ ] Enter phone number
- [ ] Add email address
- [ ] Enter GST number (if applicable)
- [ ] Set preferred currency
- [ ] Configure theme preference

### Regular Maintenance
- [ ] Export data weekly
- [ ] Review notifications
- [ ] Update shop details as needed
- [ ] Change PIN periodically
- [ ] Check for updates

### Before Important Events
- [ ] Backup all data
- [ ] Verify shop details
- [ ] Test export functionality
- [ ] Review security settings

---

## 🎓 Training Resources

### Video Tutorials (Coming Soon)
- Settings overview
- Data export guide
- Security best practices
- Troubleshooting common issues

### Documentation
- User manual (this guide)
- Quick start guide
- FAQ section
- Troubleshooting guide

---

## 📞 Support Channels

### Priority Levels
1. **Critical**: App crashes, data loss
2. **High**: Feature not working
3. **Medium**: Minor bugs
4. **Low**: Feature requests

### Response Times
- Critical: 2-4 hours
- High: 24 hours
- Medium: 2-3 days
- Low: 1 week

---

**Last Updated**: November 5, 2025  
**Version**: 1.1.0  
**Status**: ✅ Production Ready
