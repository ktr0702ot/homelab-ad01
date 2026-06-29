# Monitoring Dashboard Version 2.1 Refactoring

## 概要

Version2.0で作成した監視ダッシュボードに対して、コードの保守性を高めるためのリファクタリングを実施した。

新機能の追加ではなく、既存機能を維持したまま、命名整理・共通処理の切り出しを行った。

---

## 対象

- publish-report.ps1

---

## 実施内容

### 1. 関数名の整理

Server Status用のHTML行生成関数名を変更した。

変更前

```powershell
Convert-ToHtmlRows
```

変更後

```powershell
Convert-ServerStatusToHtmlRows
```

### 変更理由

Version2.0では、Disk / Service / Event など複数のHTML行生成関数が追加された。

そのため、`Convert-ToHtmlRows` という汎用的な名前では、何のHTML行を生成する関数なのか分かりにくくなっていた。

Server Status専用の関数であることが分かるよう、関数名を明確化した。

---

### 2. Status表示処理の共通化

Disk / Service / Event / Server で重複していたStatus表示処理を共通関数へ切り出した。

追加した関数

```powershell
function Convert-StatusToHtml {
    param (
        [string]$Status
    )

    if ($Status -eq "OK") {
        return "<span class='online'>OK</span>"
    }

    return "<span class='offline'>ALERT</span>"
}
```

---

## 変更前の課題

Version2.0では、各HTML変換関数の中に以下のような処理が重複していた。

```powershell
if ($Status -eq "OK") {
    $StatusText = "<span class='online'>OK</span>"
}
else {
    $StatusText = "<span class='offline'>ALERT</span>"
}
```

この状態では、Status表示ルールを変更する場合に、複数箇所を修正する必要があった。

---

## 変更後

各HTML変換関数では、共通関数を呼び出す形に変更した。

例：Disk Status

```powershell
$StatusText = Convert-StatusToHtml -Status $Disk.Status
```

例：Server Status

```powershell
$StatusText = Convert-StatusToHtml -Status $Status
```

---

## 改善効果

### 保守性の向上

Statusの表示ルールを変更する場合、`Convert-StatusToHtml` のみ修正すればよくなった。

### 可読性の向上

各HTML変換関数からStatus判定処理が減り、テーブル行生成の処理に集中できるようになった。

### 変更範囲の縮小

今後、OK / ALERT以外に Warning などの状態を追加する場合も、共通関数側で対応しやすくなった。

---

## Version2.1時点の構成

```text
publish-report.ps1
|
├── Convert-StatusToHtml
├── Convert-ServerStatusToHtmlRows
├── Convert-DiskStatusToHtmlRows
├── Convert-ServiceStatusToHtmlRows
├── Convert-EventStatusToHtmlRows
├── New-HtmlContent
└── Publish-Html
```

---

## 学んだこと

- リファクタリングは新機能追加ではなく、既存機能を保ったままコード品質を上げる作業である
- 関数名は役割が分かる名前にする
- 重複処理は共通関数へ切り出す
- 変更箇所を1か所に集約すると保守しやすくなる
- 一気に全部直さず、小さく変更して動作確認することが重要

---
