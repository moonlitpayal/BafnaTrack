# 🏗️ BafnaTrack

> **Independently architected and built during my internship at the D. Bafna Group.**

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

**BafnaTrack** is an enterprise-grade Real Estate Management System (ERP) designed to digitize the entire sales and inventory lifecycle of a construction firm. It serves as the "Single Source of Truth," replacing fragmented spreadsheets with a centralized, logic-driven cloud ecosystem.

---

## 📸 Application Showcase

### 📱 Mobile View (Android)
*Optimized for Sales Agents on-site to view live inventory and calculate costs.*

| **1. The Dashboard** | **2. Live Inventory Grid** | **3. Flat Details** |
|:---:|:---:|:---:|
| <img src="PASTE_MOBILE_DASHBOARD_URL_HERE" width="250" alt="Mobile Dashboard"> | <img src="PASTE_MOBILE_GRID_URL_HERE" width="250" alt="Inventory Grid"> | <img src="PASTE_MOBILE_DETAILS_URL_HERE" width="250" alt="Flat Details"> |
| *Global Project Stats* | *Color-Coded Status* | *Unit Information* |

| **4. Financial Engine** | **5. Edit & Manage** | **6. Archives** |
|:---:|:---:|:---:|
| <img src="PASTE_MOBILE_FINANCE_URL_HERE" width="250" alt="Financial Calculator"> | <img src="PASTE_MOBILE_EDIT_URL_HERE" width="250" alt="Edit Screen"> | <img src="PASTE_MOBILE_ARCHIVE_URL_HERE" width="250" alt="Archives"> |
| *Auto-Loan Calculator* | *Admin Controls* | *Completed Projects* |

<br>

### 💻 Desktop / Web View
*Optimized for the Head Office to manage assets and analyze financial health.*

#### 🖥️ The "God-Level" Admin Command Center
*A real-time dashboard aggregating total inventory value, unit availability, and sales performance across all active sites.*
<img width="100%" alt="Admin Dashboard Desktop" src="PASTE_DESKTOP_DASHBOARD_URL_HERE">

<br>

#### 📑 Project Document Manager
*Centralized hub for managing architectural plans and legal quotations linked to specific projects.*
<img width="100%" alt="Document Manager Desktop" src="PASTE_DESKTOP_DOCS_URL_HERE">

---

## 💡 The Problem & Solution

**The Challenge:**
Managing inventory for a construction company involves tracking hundreds of units, fluctuating financial data, and complex loan calculations.
* **The Bottleneck:** The team relied on manual paper trails and Excel sheets, leading to data discrepancies and calculation errors.
* **The Risk:** Without a centralized system, double-booking units and miscalculating "Due Amounts" were frequent risks.

**My Solution:**
I engineered **BafnaTrack**, a logic-heavy ERP system.
* **Automated Logic:** The app absorbs the mathematical complexity. It auto-calculates loan disbursements based on project completion percentages.
* **Real-Time Sync:** If a flat is sold by an agent, the status updates instantly for the admin, eliminating double-bookings.
* **Scalable Database:** Built on a relational PostgreSQL schema to handle complex Project-Flat-Document relationships.

---

## ✨ Key Features & Logic

### 🧠 1. The Financial Logic Engine
This is the core "brain" of the application. It eliminates human error by automating complex real estate math.
* **Smart Loan Logic:** It detects if a customer has a loan and calculates the *Amount Due from Bank* dynamically:
    > `Due From Bank = Loan Amount × (Project Completion % ÷ 100)`
* **Live Balance Calculator:** As admins type payment entries, the *Remaining Balance* updates instantly in the UI.

### 🏢 2. "God-Level" Admin Panel
* **Dynamic Dashboard:** Aggregates live data to calculate Total Inventory Value (₹) and Sales Ratios.
* **Bulk Generation:** A custom algorithm that generates hundreds of unit entries (e.g., A101–A104, B101–B104) in a single click, saving hours of data entry.
* **Cascade Deletion:** Safely handles the removal of projects by cleaning up all associated flats and storage buckets automatically.

### 🎨 3. Advanced UI/UX
* **Visual Status Tracking:** Units are color-coded (Green/Orange/Red) for instant visual scanning of inventory health.
* **Stacked Parking Logic:** Custom 3-way toggle UI to handle specific parking allocation (None / A / B).

---

## 🛠️ Tech Stack & Architecture

* **Frontend:** Flutter (Dart)
    * *Architecture:* Modular widget design for reusability across Mobile and Web.
* **Backend:** Supabase (PostgreSQL)
    * *Database:* Relational SQL schema for complex data modeling.
    * *Real-time:* High-performance data fetching.
    * *Storage:* Secure buckets for architectural blueprints and quotations.
* **State Management:** `setState` & Async/Await patterns for reactive UI updates.

---

## 🚀 Installation (For Developers)

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/moonlitpayal/BafnaTrack.git](https://github.com/moonlitpayal/BafnaTrack.git)
    ```
2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the App:**
    ```bash
    flutter run
    ```

---

## 👨‍💻 Internship Context
This project was developed as a solo initiative during my internship at **DBafna Developers**. It demonstrates the ability to translate complex business requirements into a production-grade software solution involving heavy logic and database management.

*Designed and Architected by **Payal Dharma Mehta**.*
