# Minimal Todo App

## Overview

A simple to-do app that helps you track tasks. Add, complete, and organize items with ease. The clean design keeps you focused.

## Demo

https://github.com/user-attachments/assets/c8463969-3768-4d0c-8759-773acc5243e0

## Features

- **Add Todos**: Quickly create new tasks
- **Delete Todos**: Remove completed or unwanted tasks
- **Reorder Todos**: Drag and drop to prioritize your tasks
- **Update Todos**: Edit existing tasks as needed
- **Night Mode**: Easy on the eyes during evening work
- **Sorting Options**: Organize tasks by priority, date, or completion status

## Tech Stack

- Flutter (2.10+)
- State Management: Riverpod
- Database: Sqflite

## Prerequisites

- Flutter SDK (3.4.0 or higher)
- Dart SDK (3.4.0 or higher)
- Android Studio / VS Code
- Git

## Installation

1. Clone the repository
   ```
   git clone https://github.com/adilazhar/minimal-todo-app.git
   ```
2. Navigate to the project directory
   ```
   cd minimal-todo-app
   ```
3. Get all dependencies
   ```
   flutter pub get
   ```
4. Run the app on your preferred device
   ```
   flutter run
   ```

## Challenges & Solutions

**Challenge**: Sqflite doesn't have a real-time stream-based API, making it difficult to keep the UI in sync with database changes.

**Solution**: Implemented a custom state management solution with Riverpod that manually updates the UI state whenever database operations occur. Created a repository pattern that handles all database interactions and notifies the UI of changes.


