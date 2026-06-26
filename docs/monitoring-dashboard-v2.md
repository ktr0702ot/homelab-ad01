# Monitoring Dashboard Version 2.0

## 概要
Version1.1で作成したserver status画面を拡張し、
複数の監視情報を1つのダッシュボードへ統合。

HTMLテンプレートへ各監視結果を反映し、IIS経由でCLIENT01から閲覧できる監視ポータルの構築。

## 追加した機能

### Last Update
画面上部に最終更新日時を表示。
↓
Last Update : yyyy-MM-dd HH:mm:ss

監視停止や同期失敗を判別しやすくした。

### Disk Usage
disk.logを解析し、
- Server
- Drive
- Usage
- Status
- Checked At
を表示する機能を追加。

### 新規スクリプト
- Get-DiskStatus.ps1

publish-report.ps1
追加
- Convert-DiskStatusToHtmlRows()

### Service Status
service-monitor.logの出力形式を見直し
Data
NG Count
↓
yyyy-MM-dd HH:mm:ss OK AD01 DNS Running
形式へ変更、HTMLへ詳細表示できるようになった。

表示項目
- Server
- Service
- Status
- Checked At
  
### 新規スクリプト
- Get-ServiceStatus.ps1
publish-report.ps1
追加
- Convert-ServiceStatusToHtmlRows()

### Event Status
eventlog.logを解析し、
- Status
- Event ID
- Level
- provider
- Checked At
  表示する機能を追加。

  ### 新規スクリプト
  - Get-EventStatus.ps1
 
  publish-report.ps1
  追加
  - Convert-EventStatusToHtmlRows()

  ## publish-report.ps1改善
  New-HtmlContent()を拡張し、HTMLテンプレートへ
  - Server
  - Disk
  - Service
  - Event
  - Last Update
  を差し込めるよう改善。

## HTMLテンプレート改善
追加
- HomeLab Monitoring Dashbord
- Last Update
- Disk Usage
- Service Status
- Event Status

テンプレートのプレースホルダー
- {{SERVER_ROWS}}
- {{DISK_ROWS}}
- {{SERVICE_ROWS}}
- {{EVENT_ROWS}}
- {{LAST_UPDATE}}

## ディレクトリ構成
Scripts
|
|- Get-DiskStatus.ps1
|- Get-ServiceStatus.ps1
|- Get-EventStatus.ps1
|- publish-report.ps1
|
Template
|- server-status-template.html

## 学んだこと
- ログを解析してHTMLへ変換する流れ
- PSCustomObjectによるデータ管理
- HTMLテンプレートへのデータ埋め込み
- 関数を追加して機能を横展開する方法
- 監視ダッシュボード設計
- ログ形式の重要性
- 保守しやすいPowerShell構成
- 
