# 🥬 Vegetable Trading & Farmer Account Management System

A comprehensive Windows desktop application built with **Flutter** for managing vegetable trading businesses, farmer accounts, billing, and instant WhatsApp notifications.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)

## 🌟 Features

### 📊 **Dashboard**
- Real-time business overview
- Total farmers count tracking
- Stock quantity monitoring
- Outstanding balance summary
- Recent transaction activity feed

### 🧾 **Billing System**
- Create professional bills/invoices
- Multi-item billing with quantity and pricing
- Automatic total calculation
- Real-time farmer balance updates
- Transaction ledger integration
- PDF bill generation with company logo

### 📦 **Stock Management**
- Add/Edit/Delete stock items
- Track quantities in different units (KG, Bundle, Piece)
- Increase/Decrease stock levels
- Low stock warnings
- Item-wise inventory tracking

### 👥 **Farmer Account Management**
- Complete farmer database
- Mobile number with WhatsApp integration
- Address and contact details
- Current balance tracking
- Credit/Debit ledger system
- Transaction history view

### 💰 **Payment Recording**
- Record farmer payments
- Automatic balance adjustment
- Payment history tracking
- Notes and reference numbers

### 📑 **Reports & Analytics**
- View all bills/invoices
- Download bills as PDF
- Send notifications via WhatsApp
- Date-wise transaction filtering
- Export functionality

### 💬 **WhatsApp Integration**
- Instant bill notifications
- Payment confirmation messages
- Custom message templates
- One-click WhatsApp messaging

## 🛠️ Tech Stack

- **Framework**: Flutter 3.9.2+
- **UI Library**: Fluent UI (Windows 11 style)
- **Database**: SQLite with Drift ORM
- **State Management**: Riverpod
- **Navigation**: Go Router
- **PDF Generation**: pdf & printing packages
- **Window Management**: bitsdojo_window
- **Messaging**: url_launcher (WhatsApp)

## 📥 Installation

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Windows 10/11
- Visual Studio 2019 or later (for Windows builds)

### Steps

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd Veg_Billing_Software-main
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate database files**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application**
   ```bash
   flutter run -d windows
   ```

## 📖 Usage Guide

### First-Time Setup

1. **Add Stock Items**
   - Navigate to Stock section
   - Click "Add New Item"
   - Enter vegetable name and unit
   - Start tracking inventory

2. **Add Farmers**
   - Go to Farmers section
   - Click "Add New Farmer"
   - Enter name, mobile (with country code), and address
   - Save to database

3. **Create First Bill**
   - Open New Bill section
   - Select farmer
   - Add items with quantities and prices
   - Save bill (auto-updates ledger)

4. **Record Payments**
   - View farmer details
   - Click "Add Payment"
   - Enter amount and notes
   - Balance updates automatically

### Daily Operations

- **Dashboard**: Monitor business at a glance
- **Billing**: Create bills for daily purchases
- **Stock**: Update quantities as items are sold/received
- **Reports**: Download PDFs and send WhatsApp notifications

## 🗂️ Project Structure

```
lib/
├── core/
│   ├── app_shell.dart           # Main app navigation shell
│   ├── db/
│   │   ├── app_db.dart          # Database configuration
│   │   ├── db_provider.dart     # Riverpod providers
│   │   └── tables.dart          # Database tables
│   ├── navigation/
│   │   └── router.dart          # App routing
│   └── services/
│       ├── pdf_service.dart     # PDF generation
│       └── whatsapp_service.dart # WhatsApp integration
├── features/
│   ├── dashboard/
│   │   └── home_screen.dart     # Dashboard UI
│   ├── billing/
│   │   ├── billing_screen.dart  # Bill creation
│   │   └── billing_provider.dart # Bill state
│   ├── stock/
│   │   └── stock_screen.dart    # Stock management
│   ├── farmers/
│   │   ├── farmers_screen.dart  # Farmers list
│   │   └── farmer_detail_screen.dart # Ledger view
│   └── reports/
│       └── bills_screen.dart    # All bills report
└── main.dart                    # App entry point
```

## 💾 Database Schema

### Tables

1. **Farmers**: Store farmer information
   - id, name, mobile_number, address, current_balance, created_at

2. **Stock Items**: Inventory management
   - id, name, unit, current_stock, avg_purchase_price, created_at

3. **Bills**: Invoice records
   - id, farmer_id, total_amount, status, created_at

4. **Bill Items**: Line items in bills
   - id, bill_id, stock_item_id, item_name, quantity, price_per_unit, total

5. **Ledger Entries**: Transaction log
   - id, farmer_id, type, amount, new_balance, notes, created_at

## 🎨 Screenshots

*(Add screenshots of your application here)*

- Dashboard with statistics
- Bill creation interface
- Stock management screen
- Farmer ledger view
- PDF bill sample

## ⚙️ Configuration

### Company Details
Edit `lib/core/services/pdf_service.dart` to customize:
- Company name
- Logo
- Contact information
- Invoice format

### WhatsApp Messages
Modify templates in `lib/core/services/whatsapp_service.dart`

### Theme Colors
Adjust in `lib/main.dart`:
```dart
theme: FluentThemeData(
  accentColor: Colors.blue, // Change this
)
```

## 🔒 Security & Backup

- Database stored locally at: `C:\Users\<Username>\Documents\vegbill.sqlite`
- Backup this file regularly
- No cloud storage (privacy-first)
- Future: Firebase backup option

## 🐛 Troubleshooting

**Database errors?**
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

**WhatsApp not opening?**
- Check phone number format (919876543210)
- Ensure WhatsApp Desktop is installed

**Build errors?**
```bash
flutter clean
flutter pub get
flutter run -d windows
```

## 🚀 Future Roadmap

- [ ] Cloud backup with Firebase
- [ ] Multi-user authentication
- [ ] Advanced analytics dashboard
- [ ] Direct thermal printer support
- [ ] Mobile app version (Android/iOS)
- [ ] Multi-language support (Tamil, Hindi)
- [ ] Barcode scanning for items
- [ ] SMS notifications
- [ ] Email reports

## 📄 License

This project is proprietary software designed for vegetable trading businesses.

## 🤝 Contributing

This is a custom business application. For feature requests or bug reports, please create an issue.

## 📞 Support

For setup help, see [SETUP_GUIDE.md](SETUP_GUIDE.md)

---

**Built with ❤️ using Flutter for Windows Desktop**

*Empowering vegetable traders with modern technology* 🥬📊
