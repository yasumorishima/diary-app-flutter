# アプリアイコン画像 配置場所

このディレクトリにアプリアイコン画像を配置してください。

## 📋 必要なファイル

### 1. app_icon.png（必須）
- **サイズ**: 1024x1024px
- **フォーマット**: PNG（透過背景可）
- **用途**: iOS、Android（非Adaptive）のアプリアイコン

**デザイン案**:
- 📖 本のアイコン
- グラデーション背景: #667eea（左上） → #764ba2（右下）
- シンプルで認識しやすいデザイン

### 2. app_icon_foreground.png（Android Adaptive Icon用）
- **サイズ**: 1024x1024px
- **フォーマット**: PNG（透過背景**必須**）
- **用途**: Android Adaptive Iconの前景レイヤー
- **注意**: 背景は透過にして、アイコン本体のみを配置

**デザイン**:
- 📖 本のアイコンのみ（背景なし）
- 中央に配置（セーフエリア考慮）

## 🎨 AI画像生成時のプロンプト例

### app_icon.png 用
```
Create an app icon for a diary app, 1024x1024px.
- Theme: Simple book icon (📖) in the center
- Background: Gradient from #667eea (top-left) to #764ba2 (bottom-right)
- Style: Modern, minimalist, flat design
- Colors: Purple gradient with white book icon
- No text, icon only
```

### app_icon_foreground.png 用
```
Create a transparent PNG icon, 1024x1024px.
- A simple white book icon (📖) in the center
- Transparent background
- Icon should be centered with safe margins
- Style: Modern, minimalist, flat design
- White color (#FFFFFF)
```

## 🚀 アイコン生成コマンド（画像配置後）

画像を配置したら、以下のコマンドを実行：

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

これで、Android/iOSの全サイズのアイコンが自動生成されます。
