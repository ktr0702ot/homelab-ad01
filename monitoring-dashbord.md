# Monitoring Dashbord(統合監視レポート)

## 概要

MON01上で作成した監視スクリプトの結果を集約し、日次レポートとして出力する仕組みを構築。
監視対象
- 死活監視
- サービス監視
- イベントログ監視
各監視スクリプトは個別にログ出力を行い、最終的にdaily-infra-report.ps1で統合レポートを生成する

## 構成

### 死活監視
スクリプト：daily-server-report.ps1
監視内容
- AD01
- FILE01
監視方法：Test-Connection
出力ログ：C:\Logs\daily-server-report.log

### サービス監視
スクリプト：service-monitor.ps1
監視内容
| Server | Service |
| --- | --- |
| AD01 | DNS |
| AD01 | DHCPServer |
| FILE01 | LanmanServer |
監視方法：Get-Service
出力ログ：C:\Logs\service-monitor.ps1
出力例
==== Service Monitor Report ====
Date : 2026-06-24 16:05:34
NG Count : 0

### イベントログ監視
スクリプト：eventlog-monitor.ps1
監視内容
- Systemログ
- Warning
- Error
取得期間：過去24時間
監視方法：Get-WinEvent
出力ログ：C:\Logs\eventlog-monitor.log
出力例
==== Event Log Report ====
Date : 2026-06-24 16:05:04
Warning Count : 20
Error Count : 6
Event Count : 26

### 統合レポート
スクリプト：daily-infra-report.ps1
出力先：C:\Logs\daily-infra-report.log
機能
- 死活監視結果を取得
- サービス監視結果を取得
- イベントログ監視結果を取得
- 1つのレポートへ集約
出力例
==== Daily Infrastructure Report ====
[Server Status]
NG Count : 0
[Service Status]
NG Count : 0
[Event Log Status]
Warning Count : 20
Error Count : 6
Event Count : 26

## 学習した内容
PowerShell
- Test-Connection
- Get-Service
- Get-WinEvent
- Where-object
- Select-Object
- 配列
- ハッシュテーブル
- foreach
- if
- Out-File
- Out-File -Append
運用保守
- 死活監視
- サービス監視
- イベントログ監視
- ログ出力
- レポート集約


- 





















