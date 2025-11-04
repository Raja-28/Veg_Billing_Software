# ⚡ Quick Start Guide

## 🚀 Run the Application

The application is now **fully functional** and ready to use!

### Start the App

```bash
flutter run -d windows
```

Or press **F5** in VS Code / Click **Run** in your IDE.

## ✅ What's Been Implemented

### ✨ All Features Are Now Working:

#### 1. **Dashboard** 📊
- ✅ Shows total farmers count
- ✅ Displays total stock quantity
- ✅ Shows total outstanding balance
- ✅ Lists recent transactions in real-time

#### 2. **New Bill** 🧾
- ✅ Select farmer from dropdown
- ✅ Add multiple items with quantity & price
- ✅ Automatic total calculation
- ✅ Save bill with ledger updates
- ✅ Real-time balance adjustment

#### 3. **Stock Management** 📦
- ✅ Add new stock items (name, unit)
- ✅ Edit existing items
- ✅ Delete items with confirmation
- ✅ **Increase stock** (+ button)
- ✅ **Decrease stock** (- button)
- ✅ Low stock warnings (red for < 10)
- ✅ Real-time updates

#### 4. **Farmers** 👥
- ✅ Add new farmers (name, mobile, address)
- ✅ View all farmers with balances
- ✅ Click "View Details" to see:
  - Complete transaction ledger
  - Debit/Credit history
  - Current balance
- ✅ **Add Payment** functionality
  - Records payment received
  - Updates balance automatically
  - Shows in ledger

#### 5. **Reports** 📑
- ✅ View all bills/invoices
- ✅ **Download PDF** bills
  - Professional invoice format
  - Company branding
  - Itemized details
- ✅ **Send via WhatsApp**
  - One-click messaging
  - Pre-filled bill details
  - Opens WhatsApp Web/Desktop

## 🎯 First Steps After Running

### 1. Add Stock Items (2 minutes)
```
Go to Stock → Add New Item
Examples:
- Name: Tomato, Unit: KG
- Name: Onion, Unit: KG  
- Name: Coriander, Unit: Bundle
```

### 2. Add Farmers (2 minutes)
```
Go to Farmers → Add New Farmer
Example:
- Name: Rajesh Kumar
- Mobile: 919876543210 (with country code)
- Address: Village Road, District
```

### 3. Create Your First Bill (3 minutes)
```
Go to New Bill →
1. Select farmer from dropdown
2. Right side: Select item, enter quantity & price
3. Click "Add Item"
4. Repeat for more items
5. Click "💾 Save Bill"
```

### 4. Record a Payment (1 minute)
```
Go to Farmers → View Details (on any farmer) →
1. Click "💰 Add Payment"
2. Enter amount (e.g., 5000)
3. Add notes (optional)
4. Save
```

### 5. Download Bill PDF (1 minute)
```
Go to Reports →
1. Click PDF icon (📄) on any bill
2. PDF generates automatically
3. Click "Open Folder" to view
```

### 6. Send WhatsApp Message (1 minute)
```
Go to Reports →
1. Click WhatsApp icon (💬) on any bill
2. WhatsApp opens with message
3. Click Send in WhatsApp
```

## 🎨 What You'll See

### Navigation Sidebar (Left)
- 🏠 Dashboard
- 🧾 New Bill
- 📦 Stock
- 👥 Farmers
- 📑 Reports

### Modern Windows 11 UI
- Fluent Design
- Smooth animations
- Dark/Light mode support
- Professional look

## 💡 Key Concepts

### Balance System
- **Negative balance** = Farmer owes you money (red)
- **Positive balance** = You owe farmer money (green)
- Creating a bill = Debit (negative)
- Recording payment = Credit (positive)

### Currency
All amounts stored in paisa (1 rupee = 100 paisa) to prevent rounding errors. Display automatically shows rupees.

### Stock Tracking
- Add items when receiving new stock
- Decrease when selling
- Warning shown when low (< 10 units)

## 📁 Data Location

Your database is stored at:
```
C:\Users\YourUsername\Documents\vegbill.sqlite
```

**Backup this file regularly!**

## 🔧 Common Actions

### Update Stock Quantity
```
Stock → Click + or - button on any item
```

### View Farmer Ledger
```
Farmers → View Details button
```

### Generate PDF
```
Reports → PDF icon on any bill
```

### Send WhatsApp
```
Reports → WhatsApp icon on any bill
```

## ⚠️ Important Notes

1. **Phone Number Format**: Use full number with country code
   - India: 919876543210 (no + or spaces)
   - Will open WhatsApp Web on desktop

2. **PDF Files**: Saved in Documents folder with timestamp

3. **Database**: All data stored locally (offline)

4. **Backup**: Copy the .sqlite file to backup your data

## 🐛 If Something Goes Wrong

**App won't start?**
```bash
flutter clean
flutter pub get
flutter run -d windows
```

**Database error?**
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

**WhatsApp not opening?**
- Install WhatsApp Desktop
- Check phone number format (no spaces, include country code)

## 📊 Sample Data

Want to test with sample data? Add:

**Farmers:**
- Rajesh Kumar - 919876543210
- Priya Devi - 919876543211
- Suresh Patel - 919876543212

**Stock Items:**
- Tomato - KG
- Onion - KG
- Potato - KG
- Coriander - Bundle
- Mint - Bundle

**Then create bills and payments to see the system in action!**

## 🎉 You're All Set!

The application is **100% functional** with all features working:
- ✅ Complete CRUD operations
- ✅ Real-time updates
- ✅ PDF generation
- ✅ WhatsApp integration
- ✅ Professional UI
- ✅ SQLite database
- ✅ Transaction ledger
- ✅ Balance tracking

**Start the app and begin managing your vegetable trading business!** 🥬📊

---

For detailed documentation, see:
- [README.md](README.md) - Full project documentation
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Complete setup instructions

**Need help?** Check the troubleshooting sections in the guides above.
