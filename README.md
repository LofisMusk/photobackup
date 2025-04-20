# PhotoBackup iOS (Xcodegen)

Ten zip zawiera:
* katalog `PhotoBackup/` – pliki źródłowe Swift + Info.plist
* `project.yml` – konfigurację **Xcodegen** (generuje PhotoBackup.xcodeproj)

Jak wygenerować projekt:

```bash
brew install xcodegen
xcodegen generate   # wygeneruje PhotoBackup.xcodeproj
```

W CI użyj akcji:
```yaml
- uses: yonaskolb/xcodegen-action@v2
```

Po wygenerowaniu możesz budować:

```bash
xcodebuild -workspace PhotoBackup.xcworkspace            -scheme PhotoBackup            -configuration Release archive
```
