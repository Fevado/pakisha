# Pakisha

**Pakisha** is a community-powered food redistribution platform built to tackle food waste and hunger by connecting those with surplus food to those in need. Whether you're a donor with excess food or a recipient looking for support, Pakisha provides a simple and accessible platform to help. 
The app's live domain is : https://pakisha-app.web.app

---

## Features

-  **Authentication**: Secure login and registration using Firebase Auth.
-  **Home Dashboard**: Browse available food donations in your area.
-  **Add Food Post**: Share surplus food with others via a simple form and optional images.
-  **Image Uploads**: Upload and store food images using Firebase Storage.
-  **Food Details View**: View detailed info about donations.
-  **Persistent Sessions**: Automatically keeps users logged in until they log out.

---

## Tech Stack

| Layer       | Technology                             |
|-------------|-----------------------------------------|
| Frontend    | [Flutter]         |
| Backend     | [Firebase]|
| Language    | [Dart]               |
| Services    | Firebase Auth, Firestore, Firebase Storage |

---

## App Structure & Screens

###  `main.dart`
- Initializes Firebase.
- Sets global app theme.
- Defines routing and entry point to `LoginScreen`.

---

### `LoginScreen` (`/screens/login_screen.dart`)
- **Purpose**: Authenticate returning users.

### `SignUpScreen`
- **Purpose**: Register new users.
- **Validation**:
  - Valid email format
  - Minimum password length (8+ characters)
- **Firebase**:
  - Uses Firebase Auth to create a new user

### `HomeScreen` 
- **Purpose**: Display food posts & navigate.

### `AddFoodScreen` 
- **Purpose**: Let users donate food.

### `FoodDetailsScreen`
- **Purpose**: View details of a selected food post.

## Navigation Flow
- LoginScreen → HomeScreen
- SignUpScreen → HomeScreen
- HomeScreen → AddFoodScreen / FoodDetailsScreen / Logout

## Setup Instructions

### Prerequisites

- Flutter SDK installed 
- Firebase CLI configured
- Dart SDK (included with Flutter)
- A Firebase project with:
  - Email/password authentication enabled
  - Firestore and Firebase Storage setup

### Future Improvements
Role-based dashboards (separate donor and recipient views)

Claim/Reserve functionality for food posts

Map integration for location-based matching

Push notifications

User profile management

### Clone & Run

```bash
git clone https://github.com/your-username/pakisha.git
cd pakisha
flutter pub get
flutterfire configure  # Select Firebase project and platforms
flutter run 
'''


#### Contact me

For questions or feedback:

Email: mwangefavoured@gmail.com





