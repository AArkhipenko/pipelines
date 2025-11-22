#!/bin/bash

# Скрипт для создания Git тега
# Использование: ./create-git-tag.sh [version] [github_token]

set -e

VERSION="$1"
GITHUB_TOKEN="$2"

echo "🔖 Creating Git tag: $VERSION"

# Проверяем, что version передан
if [ -z "$VERSION" ]; then
  echo "❌ Error: Version is required"
  exit 1
fi

# Проверяем, существует ли уже тег
CURRENT_COMMIT=$(git rev-parse HEAD)
EXISTING_TAG=$(git tag --points-at HEAD | grep "^$VERSION$" || true)

if [ -z "$EXISTING_TAG" ]; then
  echo "🆕 Creating new tag: $VERSION"
  
  # Настраиваем git
  git config --local user.email "action@github.com"
  git config --local user.name "GitHub Action"
  
  # Создаем тег
  git tag "$VERSION"
  
  # Пушим тег
  if [ -n "$GITHUB_TOKEN" ]; then
    git push origin "$VERSION"
  else
    echo "⚠️  GITHUB_TOKEN not provided, tag created locally only"
  fi
  
  echo "✅ Tag $VERSION created and pushed"
else
  echo "✅ Tag $VERSION already exists on current commit"
fi