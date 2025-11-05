# VegBill - Navigation Guide

## 🧭 Application Navigation Structure

```
┌─────────────────────────────────────────────────────────────────┐
│  VegBill - Farmer Account System                    [_][□][X]  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐                                               │
│  │              │                                               │
│  │  🏠 Dashboard │  ← Home screen with business overview       │
│  │              │                                               │
│  ├──────────────┤                                               │
│  │              │                                               │
│  │  📄 New Bill  │  ← Create new bills for farmers             │
│  │              │                                               │
│  ├──────────────┤                                               │
│  │              │                                               │
│  │  📦 Stock     │  ← Manage inventory items                   │
│  │              │                                               │
│  ├──────────────┤                                               │
│  │              │                                               │
│  │  👥 Farmers   │  ← Manage farmer accounts                   │
│  │              │                                               │
│  ├──────────────┤                                               │
│  │              │                                               │
│  │  📊 Reports   │  ← View all bills and transactions          │
│  │              │                                               │
│  ├──────────────┤                                               │
│  │              │                                               │
│  │  📈 Analytics │  ← NEW! Comprehensive analytics dashboard   │
│  │              │                                               │
│  ├──────────────┤                                               │
│  │              │                                               │
│  │  ⚙️  Settings │  ← NEW! App settings and preferences        │
│  │              │                                               │
│  ├──────────────┤                                               │
│  │              │                                               │
│  │  🔑 PIN Set.. │  ← Change or reset PIN                      │
│  │              │                                               │
│  ├──────────────┤                                               │
│  │              │                                               │
│  │  🔒 Lock App  │  ← Manually lock the application            │
│  │              │                                               │
│  └──────────────┘                                               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📱 Main Navigation Items

### 1. 🏠 Dashboard (`/dashboard`)
**Purpose**: Business overview and quick insights

**Features**:
- Business metrics (Total Farmers, Stock Items, Balance)
- Recent activity feed
- Quick stats at a glance

**When to use**: 
- Starting point when opening the app
- Quick overview of business status
- Check recent transactions

---

### 2. 📄 New Bill (`/billing`)
**Purpose**: Create new bills for farmers

**Features**:
- Select farmer
- Add multiple items
- Calculate totals
- Generate bill

**When to use**:
- Recording new purchases from farmers
- Creating invoices
- Processing transactions

---

### 3. 📦 Stock (`/stock`)
**Purpose**: Manage inventory

**Features**:
- Add new stock items
- Update quantities
- View current stock levels
- Track inventory

**When to use**:
- Adding new products
- Updating stock after purchases
- Checking inventory levels

---

### 4. 👥 Farmers (`/farmers`)
**Purpose**: Manage farmer accounts

**Features**:
- Add new farmers
- Edit farmer details
- View farmer ledger
- Track balances

**When to use**:
- Registering new farmers
- Updating farmer information
- Checking farmer account status

---

### 5. 📊 Reports (`/reports`)
**Purpose**: View all bills and transactions

**Features**:
- List all bills
- Search and filter
- View bill details
- Print/Export

**When to use**:
- Reviewing past transactions
- Searching for specific bills
- Generating reports

---

### 6. 📈 Analytics (`/analytics`) **NEW!**
**Purpose**: Comprehensive business analytics

**Features**:
- **Overview Tab**: Key metrics and summaries
- **Sales Tab**: Detailed sales analytics
- **Farmers Tab**: Farmer performance insights
- **Stock Tab**: Inventory analytics and alerts

**When to use**:
- Analyzing business performance
- Identifying top farmers
- Monitoring stock levels
- Making data-driven decisions

**Sub-sections**:
```
Analytics
├── Overview
│   ├── Key Metrics (Sales, Bills, Avg Value)
│   ├── Top 5 Farmers
│   └── Stock Summary
│
├── Sales
│   ├── Sales Metrics
│   └── Sales Breakdown
│
├── Farmers
│   ├── Farmer Statistics
│   └── Top Farmers List
│
└── Stock
    ├── Stock Metrics
    └── Low Stock Alerts
```

---

## ⚙️ Footer Navigation Items

### 7. ⚙️ Settings (`/settings`) **NEW!**
**Purpose**: Configure app preferences and manage data

**Features**:
- **Security**: Change PIN, Lock App, Reset PIN
- **Preferences**: Dark Mode, Notifications, Currency
- **Data Management**: Backup, Restore, Auto Backup, Clear Data
- **About**: Version info, Feedback

**When to use**:
- Changing app settings
- Managing security
- Backing up data
- Customizing preferences

**Sub-sections**:
```
Settings
├── Security
│   ├── Change PIN
│   ├── Lock App Now
│   └── Reset PIN
│
├── Preferences
│   ├── Dark Mode
│   ├── Notifications
│   └── Currency
│
├── Data Management
│   ├── Backup Data
│   ├── Restore Data
│   ├── Auto Backup
│   └── Clear All Data
│
└── About
    ├── Version
    ├── Build
    └── Send Feedback
```

---

### 8. 🔑 PIN Settings (`/pin-settings`)
**Purpose**: Change security PIN

**Features**:
- Verify old PIN
- Set new PIN
- Confirm new PIN
- Secure PIN change flow

**When to use**:
- Updating security PIN
- Changing forgotten PIN
- Enhancing security

---

### 9. 🔒 Lock App (`/pin-lock`)
**Purpose**: Manually lock the application

**Features**:
- Immediate app lock
- Requires PIN to unlock
- Security protection

**When to use**:
- Leaving workstation
- Protecting sensitive data
- Quick security lock

---

## 🔄 Navigation Flow Examples

### Example 1: Creating a Bill
```
Dashboard → New Bill → Select Farmer → Add Items → Generate Bill → Dashboard
```

### Example 2: Checking Analytics
```
Dashboard → Analytics → Overview Tab → View Metrics → Sales Tab → Analyze Trends
```

### Example 3: Managing Settings
```
Dashboard → Settings → Security → Change PIN → Verify → Success
```

### Example 4: Farmer Management
```
Dashboard → Farmers → Select Farmer → View Details → Check Ledger → Back
```

### Example 5: Stock Management
```
Dashboard → Stock → Add Item → Save → View Stock List → Analytics → Stock Tab
```

---

## 🎯 Quick Access Guide

### Most Used Features
1. **New Bill** - Daily transactions
2. **Dashboard** - Quick overview
3. **Farmers** - Account management
4. **Analytics** - Business insights

### Security Features
1. **Lock App** - Quick lock
2. **PIN Settings** - Change PIN
3. **Settings → Security** - Advanced security

### Data Management
1. **Settings → Backup** - Save data
2. **Settings → Restore** - Load data
3. **Settings → Clear** - Reset app

### Business Intelligence
1. **Analytics → Overview** - Quick insights
2. **Analytics → Sales** - Revenue analysis
3. **Analytics → Farmers** - Customer insights
4. **Analytics → Stock** - Inventory status

---

## 🔐 Security Navigation

### PIN Authentication Flow
```
App Launch
    ↓
Is PIN Set?
    ├── No → PIN Setup Screen → Dashboard
    └── Yes → PIN Lock Screen
                ↓
            Enter PIN
                ├── Correct → Dashboard
                └── Incorrect → Retry (Max 5 attempts)
                                    ↓
                                Lockout (30 min)
```

### Lock/Unlock Flow
```
Working in App
    ↓
Click "Lock App"
    ↓
PIN Lock Screen
    ↓
Enter PIN
    ↓
Unlock → Return to Previous Screen
```

---

## 📊 Analytics Navigation

### Tab Structure
```
Analytics Screen
├── [Period Selector: Week | Month | Year]
│
└── Tabs
    ├── Overview (Default)
    │   └── Summary of all metrics
    │
    ├── Sales
    │   └── Detailed sales data
    │
    ├── Farmers
    │   └── Farmer performance
    │
    └── Stock
        └── Inventory analytics
```

### Navigation Tips
- Use **Period Selector** to change time range
- Switch between **Tabs** for different insights
- Click **Refresh** to update data
- All data updates in real-time

---

## ⚙️ Settings Navigation

### Section Structure
```
Settings Screen
├── Security
│   └── PIN management and app lock
│
├── Preferences
│   └── UI and app preferences
│
├── Data Management
│   └── Backup, restore, and data operations
│
└── About
    └── App information and feedback
```

### Navigation Tips
- Scroll to see all sections
- Click items to open dialogs/screens
- Toggle switches for quick changes
- Confirmations for destructive actions

---

## 🎨 Visual Navigation Cues

### Color Coding
- **Blue** - Information and neutral items
- **Green** - Positive values (credit, success)
- **Red** - Negative values (debt, warnings)
- **Orange** - Calculations and averages
- **Yellow/Gold** - Top rank/important

### Icons
- 🏠 Home/Dashboard
- 📄 Bills/Documents
- 📦 Stock/Inventory
- 👥 People/Farmers
- 📊 Reports/Lists
- 📈 Analytics/Charts
- ⚙️ Settings/Configuration
- 🔑 Security/PIN
- 🔒 Lock/Security

### Badges
- 🥇 Gold - #1 Rank
- 🥈 Silver - #2 Rank
- 🥉 Bronze - #3 Rank
- 🔵 Blue - Other ranks

---

## 🚀 Keyboard Shortcuts (Future)

### Planned Shortcuts
- `Ctrl+D` - Dashboard
- `Ctrl+B` - New Bill
- `Ctrl+S` - Stock
- `Ctrl+F` - Farmers
- `Ctrl+R` - Reports
- `Ctrl+A` - Analytics
- `Ctrl+,` - Settings
- `Ctrl+L` - Lock App

---

## 📱 Mobile Navigation (Future)

### Bottom Navigation Bar
```
┌─────────────────────────────────┐
│                                 │
│        Main Content             │
│                                 │
└─────────────────────────────────┘
┌─────┬─────┬─────┬─────┬─────┐
│  🏠 │  📄 │  📦 │  👥 │  ⋮  │
│ Home│ Bill│Stock│Farm │More │
└─────┴─────┴─────┴─────┴─────┘
```

### Drawer Menu
```
☰ Menu
├── Dashboard
├── New Bill
├── Stock
├── Farmers
├── Reports
├── Analytics
├── Settings
└── Lock App
```

---

**Navigation Tip**: Use the navigation pane on the left for quick access to all features. Footer items (Settings, PIN Settings, Lock App) are always accessible for security and configuration needs.
