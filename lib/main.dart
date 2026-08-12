name: Flutter Build

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: stable

      - name: Get dependencies
        run: flutter pub get

      - name: Build APK
        run: flutter build apk --release
