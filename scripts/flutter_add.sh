#!/bin/bash

# Kitabxana adı ötürülməyibsə
if [ -z "$1" ]; then
  echo "❌ Istifadə: ./flutter_add.sh <package_name>"
  exit 1
fi

PACKAGE_NAME=$1

echo "📦 $PACKAGE_NAME kitabxanasi elave edilir..."

flutter pub add $PACKAGE_NAME

if [ $? -eq 0 ]; then
  echo "✅ $PACKAGE_NAME ugurla elave olundu"
else
  echo "❌ Xəta baş verdi"
fi
