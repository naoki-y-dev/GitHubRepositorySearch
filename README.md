# GitHubRepositorySearch

GitHub REST API を利用したリポジトリ検索 iOS アプリ。

## 要件

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9

## セットアップ

```bash
git clone https://github.com/naoki-y-dev/GitHubRepositorySearch.git
cd GitHubRepositorySearch
open GitHubRepositorySearch.xcodeproj
```

シミュレーターまたは実機でビルド・実行してください。外部ライブラリは使用していません。

## 機能

- リポジトリ検索（GitHub Search API）
- 検索結果の一覧表示・無限スクロール
- リポジトリ詳細画面（スター数・Subscribers数・GitHub リンク）
- いいね機能（ハートアイコン、永続化）
- Favorites タブ

## アーキテクチャ

MVVM + async/await + SwiftUI

```
Models/         データモデル (Codable)
Services/       API・永続化レイヤー
ViewModels/     ビジネスロジック (@MainActor)
Views/          SwiftUI View
```

## テスト

```bash
xcodebuild test \
  -scheme GitHubRepositorySearch \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

33件のユニットテスト（ViewModel・Service・Model・ネットワーク層）
