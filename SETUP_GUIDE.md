# 🥬 Vegetable Trading & Farmer Account Management System - Setup Guide

## 📋 Prerequisites

- **Flutter SDK**: Version 3.9.2 or higher
- **Windows OS**: This is a Windows desktop application
- **Git**: For version control (optional)

## 🚀 Installation Steps

### 1. Install Dependencies

Open your terminal/command prompt in the project directory and run:

```bash
flutter pub get
```

This will download all required packages including:
- `fluent_ui` - Modern Windows UI
- `drift` - SQLite database
- `pdf` & `printing` - PDF generation
- `url_launcher` - WhatsApp integration
- `riverpod` - State management

### 2. Generate Database Files

The app uses Drift for database management. Generate the required files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This command generates `app_db.g.dart` file which contains database code.

### 3. Run the Application

Start the application:

```bash
flutter run -d windows
```

Or use your IDE:
- **VS Code**: Press `F5` or click "Run > Start Debugging"
- **Android Studio**: Click the green play button and select Windows

## 📱 Features Overview

### 1. **Dashboard** 📊
- View total farmers count
- Monitor total stock items
- Track total balance (receivables/payables)
- See recent activity/transactions

### 2. **New Bill** 🧾
- Select farmer from dropdown
- Add multiple items with quantity and price
- Automatic total calculation
- Save bill and update farmer ledger
- Instant balance update

### 3. **Stock Management** 📦
- Add new stock items (vegetables)
- Edit item name and unit
- Increase/decrease stock quantities
- Delete items
- Low stock warnings (red color for < 10 items)

### 4. **Farmers Management** 👥
- Add new farmers with name, mobile, address
- View all farmers with their current balance
- Click "View Details" to see:
  - Complete transaction history
  - Ledger entries (debit/credit)
  - Add payment functionality
  - Balance tracking

### 5. **Reports** 📑
- View all bills/invoices
- Download bills as PDF
- Send bill notification via WhatsApp
- Filter and search bills

## 🎯 How to Use

### Adding Your First Farmer

1. Go to **Farmers** section
2. Click **"Add New Farmer"**
3. Enter:
   - Name (required)
   - Mobile number with country code (e.g., 919876543210)
   - Address (optional)
4. Click **Save**

### Adding Stock Items

1. Go to **Stock** section
2. Click **"Add New Item"**
3. Enter:
   - Item name (e.g., Tomato)
   - Unit (e.g., KG, Bundle, Piece)
4. Click **Save**

### Creating a Bill

1. Go to **New Bill** section
2. Select a farmer from the dropdown
3. On the right side:
   - Select stock item
   - Enter quantity
   - Enter price per unit
   - Click **"Add Item"**
4. Repeat for multiple items
5. Review the total
6. Click **"💾 Save Bill"**

### Recording a Payment

1. Go to **Farmers** section
2. Click **"View Details"** on any farmer
3. Click **"💰 Add Payment"**
4. Enter payment amount
5. Add notes (optional)
6. Click **Save**

### Generating PDF Bills

1. Go to **Reports** section
2. Find the bill you want
3. Click the **PDF icon** (📄)
4. PDF will be generated and saved
5. Click **"Open Folder"** to view the file

### Sending WhatsApp Notifications

1. Go to **Reports** section
2. Find the bill you want
3. Click the **WhatsApp icon** (💬)
4. WhatsApp will open with pre-filled message
5. Click send in WhatsApp

## 💾 Database Location

The SQLite database is stored in:
```
C:\Users\<YourUsername>\Documents\vegbill.sqlite
```

You can back up this file to preserve your data.

## 🔧 Troubleshooting

### Database Generation Errors

If you get database errors, run:
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### WhatsApp Not Opening

- Ensure WhatsApp Desktop or WhatsApp Web is installed
- Check that the phone number includes country code (no + sign)
- Format: 919876543210 (91 is India code)

### PDF Not Generating

- Check write permissions in Documents folder
- Ensure `pdf` and `printing` packages are installed
- Run `flutter pub get` again

### Application Won't Start

1. Clean build files:
   ```bash
   flutter clean
   flutter pub get
   ```

2. Rebuild:
   ```bash
   flutter run -d windows
   ```

## 📊 Data Format

### Currency
- All amounts are stored in **paisa** (1 rupee = 100 paisa)
- This prevents floating-point rounding errors
- Display automatically converts to rupees

### Balance Logic
- **Positive balance** = Farmer has credit (we owe them)
- **Negative balance** = Farmer owes us (receivable)
- New bill = Debit (negative amount)
- Payment = Credit (positive amount)

## 🎨 Customization

### Company Name
Edit `lib/core/services/pdf_service.dart`:
```dart
'Vegetable Trading Company'  // Change this line
```

### WhatsApp Messages
Edit `lib/core/services/whatsapp_service.dart` to customize message templates.

### Colors and Theme
Edit `lib/main.dart` to change the accent color and theme.

## 🔐 Security Notes

- Database is stored locally (not cloud)
- No passwords or encryption yet
- Keep database file backup secure
- WhatsApp messages sent via your WhatsApp account

## 🚀 Future Enhancements

Ready for implementation:
- ☁️ Cloud backup (Firebase)
- 🔒 Login system with encryption
- 📈 Advanced reports and analytics
- 🖨️ Direct printing without PDF
- 📧 Email notifications
- 🌐 Multi-language support (Tamil/Hindi)

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review error messages carefully
3. Ensure all dependencies are installed
4. Try cleaning and rebuilding

## 📝 License

This is a custom application for vegetable trading businesses.

---

**Made with ❤️ using Flutter**
