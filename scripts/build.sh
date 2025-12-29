#!/bin/bash

echo "🧹 Flutter clean edilir..."
flutter clean

echo "📦 Paketler yuklenir..."
flutter pub get

echo "⚙️ build_runner ishe dusur..."
flutter pub run build_runner build --delete-conflicting-outputs

if [ $? -eq 0 ]; then
  echo "✅ build_runner ugurla bitdi"
else
  echo "❌ build_runner xetasi bas verdi"
  exit 1
fi
