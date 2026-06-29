# Alert Notification System Version 3.1

## 概要

Version2.0で構築した監視ダッシュボードを拡張し、
監視結果から異常(ALERT)のみを抽出して通知履歴として管理する
Alert Notification Systemを実装した。

通知履歴はHTMLダッシュボードへ統合し、
運用担当者が異常を一覧で確認できる構成とした。

# システム構成

```text
disk.log
service-monitor.log
eventlog.log
        │
        ▼
alert-notification.ps1
        │
        ▼
alert-notification.log
        │
        ▼
publish-report.ps1
        │
        ▼
server-status.html
        │
        ▼
IIS01
        │
        ▼
CLIENT01
```

# 実装内容

## Alert Notification Script

新規作成：alert-notification.ps1
役割
- Diskログ取得
- Serviceログ取得
- Eventログ取得
- ALERTのみ抽出
- 通知ログ生成

対象：disk.log
取得条件：ALERT
通知内容：2026-06-19 11:40:43 | Disk | AD01 | C: Used 25%

## Service Alert

対象：service-monitor.log
取得条件：ALERT
通知内容：2026-06-27 10:00:00 | Service | FILE01 | LanmanServer Stopped
Server名はFILE01.corp.localからFILE01へ変換して表示するよう改善した。

## Event Alert
対象：eventlog.log
取得条件：ALERT
通知内容：2026-06-19 16:06:29 | Event | - | EventID:7036 Level:4 Provider:Service
EventLogにはServer情報が存在しないため、Server = "-"として表示した。

# 通知ログ
生成ファイル： C:\Logs\alert-notification.log
フォーマット：DateTime | Type | Server | Detail
例
2026-06-19 11:40:43 | Disk | AD01 | C: Used 25%
2026-06-27 10:00:00 | Service | FILE01 | LanmanServer Stopped
2026-06-19 16:06:29 | Event | - | EventID:7036 Level:4 Provider:Service

# Monitoring Dashboard改善
監視ダッシュボードへAlert Historyを追加。
表示項目
- Date Time
- Type
- Server
- Detail
これにより監視結果だけではなく、
異常通知履歴もWeb画面で確認できるようになった。

# Version3.1 改善

## 最新20件のみ表示
Alert HistoryはSelect-Object -Last 20
を利用し、最新20件のみ表示するよう変更した。
大量の通知が蓄積しても、ダッシュボードの可読性を維持できる構成とした。

## 重複通知の削除
ログ取得時にSort-Object -Uniqueを利用し、同一通知を重複表示しないよう改善した。
対象
- Disk
- Service
- Event

# alert-notification.ps1構成

設定
↓
Disk ALERT取得
↓
Service ALERT取得
↓
Event ALERT取得
↓
通知ログ生成

# Version3.1 完成イメージ

HomeLab Monitoring Dashboard
Last Update
Server Status
Disk Usage
Service Status
Event Status
Alert History

# 学んだこと

- ログから異常のみ抽出する方法
- 複数ログを統合して共通フォーマットへ変換する方法
- 通知ログの設計
- HTMLダッシュボードへの通知履歴表示
- Sort-Object -Uniqueによる重複通知削除
- Select-Object -Lastによる履歴表示件数の制御
- 監視システムから通知システムへ発展させる設計


