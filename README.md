# StatusMaker

StatusMaker is a Flutter application designed to generate stylized image and video statuses with quotes, personalized with the user's name and photo.

## Features
- **Personalized Content**: Upload your photo and enter your name to have it overlaid on every status.
- **Multi-Language Support**: Choose from 5 languages (Hindi, Tamil, Malayalam, Kannada, Marathi).
- **Category Based**: Select from Motivational, Festival Wishes, Love, Devotional, and Funny categories.
- **Reels-Style Interface**: Vertical scrolling feed of content.
- **Favorites**: Save your favorite quotes to a dedicated list.
- **Smart Design**: Modern UI with gradients and glassmorphism.

## Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK

### Installation
1. Clone the repository or download the source code.
2. Navigate to the project directory:
   ```bash
   cd status_maker
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure
- `lib/models`: Data models for User, Content, etc.
- `lib/screens`: UI Screens (Home, Selection, Content).
- `lib/services`: Logical services (Data, Query, Favorites).
- `lib/widgets`: Reusable widgets (ContentRenderWidget).
- `assets/`: Contains images and placeholder videos.

## tech Stack
- **Flutter**
- **Provider** (State Management)
- **Shared Preferences** (Local Storage)
- **Google Fonts** (Typography)
- **Video Player** (Media Playback)

## Developer
Developed by Antigravity.
