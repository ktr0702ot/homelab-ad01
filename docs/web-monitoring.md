# Version 1.1 Web Monitoring System（監視レポート公開システム）

## 概要
MON01で取得した監視結果をPowerShellでHTMLへ変換し、IIS01でWebページとして公開する監視レポートシステムを構築した。

---

## システム構成

```text
MON01(Monitoring Server)
|
|
daily-server-report.log
|
▼
publish-report.ps1
|
HTML自動生成
|
▼
\\IIS01\WebData
|
▼
Sync-WebData.ps1
|
▼
C:\inetpub\wwwroot
|
▼
IIS(Web Server)
|
▼
CLIENT01
```

---

##作成したPowerShell

### Publish-report.ps1

役割
- daily-server-report.logを読み込む
- サーバー情報のみ抽出
- HTMLテーブル生成
- server-status.html

処理の流れ
```text
daily-server-report.log
|
▼
Get-Content
|
▼
Where-Object
|
▼
foreach
|
|- split()
|- Replace()
|- Trim()
|- HTML生成
|
▼
server-status.html
```

---

### Sync-WebData.ps1
役割
WebData内のserver-status.htmlをIIS公開フォルダ（wwwroot）へコピーする。

```powershell
Copy-Item -Path "C:\WebData\server-status.html" -Destination "C:\inetpub\wwwroot\server-status.html" -Force
```

---

## HTMLで学習したこと

### 基本タグ
- html
- head
- body
- title
- h1
- h2
- p
- ul
- li
- hr
- table
- tr
- th
- td
- a

---

### CSS

```css
table{
  border-collapse: collapse;
}

table,th,td {
  border:1px solid black;
}

th{
  background-color: lightgray;
}

th.td{
  padding:10px;
}
```

学習内容
- border
- border-collapse
- padding
- background-color

---
## PowerShellで学習したこと

### Get-Content
ログファイル読み込み

### Where-Object
必要な行だけ抽出

### Split()
文字列分割

### Replace()
不要な文字を削除

### Trim()
前後の空白削除

### foreach
サーバーごとにHTML生成

## 運用設計
役割分担
MON01
- 監視
- HTML生成
IIS01
- HTML公開
責任を分離することで保守性を向上

---

## タスクスケジューラ
IIS01
Sync-WebData.ps1
5分ごとに実行
役割：WebDataからwwwrootへ自動反映

---

# Version 1.1 リファクタリング

## publish-report.ps1のリファクタリング
Version1.0では動作優先で実装したため、実務で保守しやすいコードを目標にリファクタリングを実施。

### Configuration
設定値をスクリプト先頭へ集約
$SourceLog
$PublishPath
$OutputHtml
$TemplatePath
変更時に修正箇所を最小限にできる構成とした。

### 関数化
Get-ServiceList()
↓
Convert-ToHtmlRows()
↓
New-HtmlContent()
↓
Publish-Html()
Main処理では「何をしているか」がわかる構成とした

### Main処理
リファクタリング後
Get-Content
↓
Get-ServerList
↓
Convert-ToHtmlRows
↓
New-HtmlContent
↓
Publish-Html
細かい実装を関数にし、Main処理をストーリとして読める構成へ改善

### 命名規則
可読性向上のため、変数名を見直し
変更例
Server   →  ServerLine
Data    →  ServerInfo
Rows    →  HtmlRows
戻り値  →  Result
変数名だけで役割がわかるように意識

### HTMLテンプレート化
HTMLをPowerShellから分離
Templates
  |-server-status-template.html
テンプレート内の{{SERCER_ROWS}}をPowerShellで置換する構成へ変更
HTML修正とPowerShell修正を独立して行えるようになった

### CSS分離
HTMLへ直接記述していたstyle属性を廃止
PowerShell
<span class="online">
CSS
.online{
  color:green;
}
.offline{
  color:red;
}
見た目をstyle.cssへ集約

### エラーハンドリング
Test-Pathを利用し、
- ログファイル存在確認
- テンプレート存在確認
を追加
ファイルが存在しない場合はエラーメッセージを表示して終了するよう改善した

### ログ出力改善
daily-server-report.ps1
ログ出力をAdd-ContentからSet-Contentを利用した上書き方式へ変更。
server-status.htmlには常に最新の監視結果のみ表示されるよう改善

  

















