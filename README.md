# UniForums — Flutter Discussion Board

A full-featured forums application built with Flutter, Firebase, and BLoC architecture. Users can register, sign in, create discussion topics, and reply to threads — all with real-time updates powered by Cloud Firestore.

---

## Features

- **Authentication** — Register and sign in with Email & Password via Firebase Auth
- **Forum Topics** — Create new topics with a title and content
- **Replies** — Add replies to any topic; reply count updates in real time
- **Author & Timestamps** — Every post and reply shows the author name and a human-readable timestamp
- **Real-time updates** — Firestore streams push new topics and replies instantly
- **Loaders** — Linear/circular progress indicators whenever data is being fetched or posted
- **Validation** — All forms validate input before submission with clear error messages
- **Green & Sea-Green theme** — Consistent Material 3 design throughout

---

## Architecture

```
lib/
├── main.dart                        # Entry point — Firebase init, DI setup
├── app.dart                         # Root widget — MultiBlocProvider + MaterialApp
├── core/
│   ├── theme/app_theme.dart         # Global Material 3 green/sea-green theme
│   └── di/injection.dart            # get_it service locator
└── features/
    ├── auth/
    │   ├── bloc/                    # AuthBloc — login, register, logout events/states
    │   └── screens/                 # LoginScreen, RegisterScreen
    └── forum/
        ├── bloc/                    # ForumBloc — topics & replies stream + CRUD
        ├── screens/                 # ForumListScreen, ForumDetailScreen, CreateTopicScreen
        └── widgets/                 # TopicCard, ReplyCard

packages/
└── firebase_service/                # Local Flutter package
    ├── lib/src/
    │   ├── models/                  # UserModel, TopicModel, ReplyModel
    │   ├── auth/                    # AuthService (abstract) + FirebaseAuthServiceImpl
    │   └── db/                     # FirestoreService (abstract) + FirebaseFirestoreServiceImpl
    └── test/                        # Mockito unit tests for auth & Firestore services
```

### State Management — BLoC

| BLoC | Events | Key States |
|---|---|---|
| `AuthBloc` | `LoginRequested`, `RegisterRequested`, `LogoutRequested` | `AuthLoading`, `AuthAuthenticated`, `AuthUnauthenticated`, `AuthError` |
| `ForumBloc` | `LoadTopics`, `CreateTopic`, `LoadReplies`, `AddReply` | `ForumLoading`, `TopicsLoaded`, `RepliesLoaded`, `ForumError` |

### Local Package — `firebase_service`

All Firebase logic lives in a separate local Flutter package (`packages/firebase_service`). The main app depends on abstract interfaces (`AuthService`, `FirestoreService`), keeping Firebase details isolated and testable.

---

## Firestore Data Model

```
topics/                          (collection)
  {topicId}/
    title        : String
    content      : String
    authorId     : String
    authorName   : String
    authorEmail  : String
    createdAt    : Timestamp
    replyCount   : int

    replies/                     (subcollection)
      {replyId}/
        topicId      : String
        content      : String
        authorId     : String
        authorName   : String
        authorEmail  : String
        createdAt    : Timestamp
```

---

## Setup

### 1. Prerequisites

- Flutter SDK >= 3.10
- A Firebase project with **Email/Password** authentication enabled
- A **Cloud Firestore** database created (start in test mode for development)

### 2. Add Firebase to the Android app

Place your project's `google-services.json` inside `android/app/`.

> You can download it from **Firebase Console → Project Settings → Your Apps → Android**.

### 3. Install dependencies

```bash
# Main app
flutter pub get

# Local firebase_service package
cd packages/firebase_service
flutter pub get
```

### 4. Generate Mockito mocks (for tests)

```bash
# From the packages/firebase_service directory
dart run build_runner build

# From the main app root (for widget tests)
dart run build_runner build
```

### 5. Run the app

```bash
flutter run
```

---

## Running Tests

```bash
# Widget tests (main app)
flutter test test/widget_test.dart

# Unit tests (firebase_service package)
cd packages/firebase_service
flutter test
```

The test suite covers:
- Login screen renders correctly when unauthenticated
- Form validation — empty fields, invalid email, short password
- `AuthLoading` state shows a progress indicator
- `AuthService.signIn` returns a `UserModel` on success
- `AuthService` throws `AuthException` on Firebase errors
- `AuthService.signOut` calls `FirebaseAuth.signOut`
- `authStateChanges` stream emits `null` / `UserModel` correctly
- `FirestoreService.createTopic` calls Firestore `add`
- `FirestoreService.getTopics` returns a stream of `TopicModel` list
- `FirestoreService.addReply` commits a batch write

---

## Dependencies

| Package | Purpose |
|---|---|
| `firebase_core` | Firebase initialisation |
| `firebase_auth` | Email/password authentication |
| `cloud_firestore` | Real-time database |
| `flutter_bloc` | BLoC state management |
| `equatable` | Value equality for BLoC states/events |
| `get_it` | Service locator / dependency injection |
| `intl` | Date formatting on posts |
| `mockito` + `build_runner` | Mock generation for unit tests |
