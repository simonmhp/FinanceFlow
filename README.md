## FinanceFlow
FinanceFlow is a personal finance tracking app built using Flutter. The app uses SQLite for local database storage and Firebase for cloud authentication. It has three main sections, accessible through bottom navigation:

 - Home View: Displays all transactions for the current month along with visual graphs.
 - Budget View: Shows summaries and graphs of transactions categorized by your predefined budgets.
 - Transaction Calendar: Displays transactions by day in a calendar format.
 - Settings: Contains minor details like username and app preferences.

# Key Features:
 - Add and delete transactions (editing transactions is not supported currently).
 - Firebase Email/Password authentication.
 - Local storage of transactions using SQLite.
 - Firebase Firestore for cloud-based transaction storage (currently disabled).

# Note:
 - Transaction data is stored locally using SQLite. Cloud storage via Firebase is planned but not yet active.
 - User details such as username are stored in Firebase.

# Screenshots:
<p align="center"> <img src="https://github.com/user-attachments/assets/2794b5b8-2326-41f9-953f-d34311955af6" width="30%" /> <img src="https://github.com/user-attachments/assets/2d9b77c6-a041-4e5e-8b42-fb337130a01f" width="30%" /> <img src="https://github.com/user-attachments/assets/0985d28d-1d23-4b54-9b62-af06c07f6f66" width="30%" /> </p> <p align="center"> <img src="https://github.com/user-attachments/assets/2bafbc00-40fc-4f06-b3d1-de8ecdb41776" width="30%" /> <img src="https://github.com/user-attachments/assets/2e821c28-ec86-460a-9b26-42d4fb3f0383" width="30%" /> <img src="https://github.com/user-attachments/assets/a2dd6c22-1b75-4160-ac1f-18c51edc15be" width="30%" /> </p>

# Getting Started
1. Clone the Project:
bash
Copy code
git clone https://github.com/your-repo/FinanceFlow.git
2. Connect Firebase:
Set up Firebase in the Firebase Console.
Configure Firebase Authentication (Email/Password) and Firestore.
3. Run the App:
Register a new user account.
Log in and start adding your transactions!
Enabling Firebase Cloud for Transactions
To enable Firebase Firestore for transaction storage:

# Uncomment the relevant parts in:
MainViewTab()
DatabaseHelper()
SettingView()
Cloud-based functions are located at the end of the DatabaseHelper() file.
After uncommenting, Firebase Firestore will be enabled for cloud-based transaction storage.


# Resources for Flutter Beginners
Lab: Write your first Flutter app
Cookbook: Useful Flutter samples
For further help with Flutter, view the official Flutter documentation, including tutorials and full API references.

This README includes all necessary sections, images arranged in rows of three, and is formatted for clear readability on GitHub.
