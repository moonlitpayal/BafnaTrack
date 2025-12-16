# 🏗️ BafnaTrack: Enterprise ERP

> **Engineered & Architected exclusively for DBafna Developers.**

![Flutter](https://img.shields.io/badge/Flutter-Architect-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/SQL-Database-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![System](https://img.shields.io/badge/System-ERP_Core-FF5722?style=for-the-badge)

**BafnaTrack** is a high-performance Real Estate ERP (Enterprise Resource Planning) system. It serves as the digital "Central Nervous System" for **DBafna Developers**, replacing fragmented spreadsheet workflows with a logic-driven, relational cloud ecosystem.

---

## 📸 The System Interface

### 📱 Mobile Field Unit
*Engineered for Sales Agents to execute complex financial modeling on-site.*

#### 1. Overview & Navigation
*Real-time project tracking and inventory visualization.*

| **A. Operations Dashboard** | **B. Live Inventory Grid** | **C. The Archives** |
|:---:|:---:|:---:|
| <img src="PASTE_MOBILE_DASHBOARD_URL_HERE" width="250" alt="Operations Dashboard"> | <img src="PASTE_MOBILE_GRID_URL_HERE" width="250" alt="Inventory Grid"> | <img src="PASTE_MOBILE_ARCHIVE_URL_HERE" width="250" alt="Archives"> |
| *Global Stats & Projects* | *Color-Coded Status* | *Lifecycle Management* |

<br>

#### 2. Unit Analytics (View Mode)
*Comprehensive breakdown of unit details. (Showing full scroll view).*

| **A. Unit Details (Top)** | **B. Unit Details (Bottom)** | **C. Admin Settings** |
|:---:|:---:|:---:|
| <img src="PASTE_FLAT_VIEW_1_URL_HERE" width="250" alt="Flat View Top"> | <img src="PASTE_FLAT_VIEW_2_URL_HERE" width="250" alt="Flat View Bottom"> | <img src="PASTE_MOBILE_SETTINGS_URL_HERE" width="250" alt="Admin Settings"> |
| *Basic Info & Status* | *Financial Summary* | *App Configuration* |

<br>

#### 3. The Financial Logic Engine (Edit Mode)
*The complex form where financial logic, loans, and calculations happen.*

| **A. Configuration (Top)** | **B. Financial Math (Mid)** | **C. Finalization (End)** |
|:---:|:---:|:---:|
| <img src="PASTE_FLAT_EDIT_1_URL_HERE" width="250" alt="Edit Config"> | <img src="PASTE_FLAT_EDIT_2_URL_HERE" width="250" alt="Edit Finance"> | <img src="PASTE_FLAT_EDIT_3_URL_HERE" width="250" alt="Edit Save"> |
| *Pricing & Parking Logic* | *Loan & Bank Due Logic* | *Notes & Uploads* |

<br>

### 💻 The Executive Command Center (Desktop)
*A high-level dashboard for data aggregation and strategic decision making.*

#### 📊 Master Operations Dashboard
*Visualizes Total Asset Value (TAV), Sales Velocity, and Inventory Health across all sites in real-time.*
<img width="100%" alt="Master Operations Dashboard" src="https://github.com/user-attachments/assets/2e7923e2-02ac-4a6e-a188-7e78f6695252">

<br>

#### 🎛️ The Admin Control Panel
*The central configuration hub. This is where Admins execute "God-Level" commands: Creating new projects, running the Bulk-Generation algorithm, and managing Archives.*
<img width="100%" alt="Admin Control Panel" src="https://github.com/user-attachments/assets/dd328903-3d8c-4f3f-99ed-0e66fa42c9b5">

---

## 🧠 Engineering The "Logic Core"

Unlike standard apps that simply store data, **BafnaTrack** actively computes it. I designed three core algorithmic engines to power the business:

### 1. The Financial Computation Engine 💸
**The Problem:** Manual loan calculations were error-prone due to varying "Project Completion Percentages" affecting bank disbursements.
**My Algorithm:**
I implemented a reactive financial model. The moment an admin toggles *"Has Loan"*:
1.  The system queries the global `Project_Completion_Rate`.
2.  It dynamically computes: `Bank_Liability = Loan_Amount * (Completion_Rate / 100)`.
3.  It instantly derives the `Customer_Payable_Balance`.
**Result:** Eliminated financial calculation errors by 100%.

### 2. The Bulk-Generation Algorithm ⚡
**The Problem:** Manually creating database entries for a 100-flat building took hours.
**My Algorithm:**
I wrote a custom Dart loop injection script.
* **Input:** Building Name (e.g., "Orchid"), Wing Count, Floors, Units per Floor.
* **Process:** The system iterates through the parameters, generating unique IDs (A101, A102... B101...) and pushing a batched transaction to Supabase.
**Result:** Reduced data entry time from **4 hours to 4 seconds**.

### 3. Relational Cascade Integrity 🔗
**The Problem:** Deleting a project often left "orphan" data (stray flats or files) in the database.
**My Algorithm:**
I architected a **Cascade Delete Protocol**. If a Project is deleted by an Admin, the system recursively identifies and purges:
* All associated Flat records in PostgreSQL.
* All linked Quotation images in Supabase Storage buckets.
**Result:** Maintains a pristine, zero-waste database environment.

---

## 🛠️ Technical Architecture

* **Core Framework:** **Flutter (Dart)**
    * *Role:* Provides the "Pixel-Perfect" rendering engine required for the complex financial grids.
* **Backend Infrastructure:** **Supabase**
    * *Role:* Replaces traditional APIs with a direct-to-database connection.
* **Database Topology:** **PostgreSQL**
    * *Role:* Handles complex relational mapping (`Project` 1:N `Flats` 1:N `Documents`).
* **State Management:** **Reactive Streams**
    * *Role:* Ensures that if a flat is sold on Mobile, the Desktop dashboard updates instantly.

---

## 👨‍💻 Internship Impact
Developed independently at **DBafna Developers**, this system dismantled the operational complexity of manual tracking. It stands as a testament to my ability to engineer **logic-heavy, business-critical software** that solves tangible real-world problems.

*Architected & Developed by **Payal Dharma Mehta**.*
