#!/bin/bash

# Скрипт для вычисления версии (только для release)
# Использование: ./calculate-version.sh [branch_name] [repository_name]

set -e

BRANCH_NAME="$1"
REPOSITORY_NAME="$2"

echo "🔍 Calculating version for branch: $BRANCH_NAME"

# Проверяем, что repository_name передан и не пустой
if [ -z "$REPOSITORY_NAME" ]; then
  echo "❌ Error: Repository name is required but was not provided"
  echo "Usage: $0 [branch_name] [repository_name]"
  echo "Example: $0 develop my-awesome-app"
  exit 1
fi

echo "✅ Using repository: $REPOSITORY_NAME"

# Получаем последний тег на текущем коммите
CURRENT_COMMIT=$(git rev-parse HEAD)
TAG_ON_CURRENT_COMMIT=$(git tag --points-at HEAD)

if [ -n "$TAG_ON_CURRENT_COMMIT" ]; then
  # Если тег на текущем коммите, используем его (для всех веток)
  VERSION="$TAG_ON_CURRENT_COMMIT"
  echo "🎯 Using tag on current commit: $VERSION"
else
  if [ "$BRANCH_NAME" = "develop" ]; then
    # Логика для develop ветки
    LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
    echo "📌 Last tag: $LAST_TAG"
    
    # Увеличиваем patch версию
    IFS='.' read -ra VERSION_PARTS <<< "${LAST_TAG#v}"
    MAJOR=${VERSION_PARTS[0]:-0}
    MINOR=${VERSION_PARTS[1]:-0}
    PATCH=${VERSION_PARTS[2]:-0}
    
    NEW_PATCH=$((PATCH + 1))
    VERSION="v${MAJOR}.${MINOR}.${NEW_PATCH}"
    echo "🔢 Increased patch version: $VERSION"
    
  elif [ "$BRANCH_NAME" = "main" ]; then
    # Логика для main ветки
    echo "🔍 Looking for latest tag on develop branch..."
    
    # Получаем последний тег из ветки develop
    DEVELOP_TAG=$(git ls-remote --tags origin | grep -v "{}" | grep -E "v[0-9]+\.[0-9]+\.[0-9]+$" | sort -V | tail -n1 | sed 's|.*refs/tags/||')
    
    if [ -z "$DEVELOP_TAG" ]; then
      DEVELOP_TAG="v0.0.0"
      echo "⚠️  No develop tags found, using default: $DEVELOP_TAG"
    else
      echo "📌 Latest develop tag: $DEVELOP_TAG"
    fi
    
    # Увеличиваем minor версию
    IFS='.' read -ra VERSION_PARTS <<< "${DEVELOP_TAG#v}"
    MAJOR=${VERSION_PARTS[0]:-0}
    MINOR=${VERSION_PARTS[1]:-0}
    PATCH=${VERSION_PARTS[2]:-0}
    
    NEW_MINOR=$((MINOR + 1))
    VERSION="v${MAJOR}.${NEW_MINOR}.0"
    echo "🔢 Increased minor version: $VERSION"
    
  else
    # Для других веток используем логику develop
    LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
    echo "📌 Last tag: $LAST_TAG"
    
    IFS='.' read -ra VERSION_PARTS <<< "${LAST_TAG#v}"
    MAJOR=${VERSION_PARTS[0]:-0}
    MINOR=${VERSION_PARTS[1]:-0}
    PATCH=${VERSION_PARTS[2]:-0}
    
    NEW_PATCH=$((PATCH + 1))
    VERSION="v${MAJOR}.${MINOR}.${NEW_PATCH}"
    echo "🔢 Increased patch version for branch $BRANCH_NAME: $VERSION"
  fi
fi

echo "version=$VERSION" >> $GITHUB_OUTPUT
echo "✅ Final version: $VERSION for repository: $REPOSITORY_NAME"