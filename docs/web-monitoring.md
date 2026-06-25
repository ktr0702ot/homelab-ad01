# Web Monitoring System（監視レポート公開システム）

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



















