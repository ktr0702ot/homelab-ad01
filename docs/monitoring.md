# 監視サーバー構築

## 目的

MON01を監視サーバーとして構築し、サーバーの死活監視を行う。

障害発生時に利用者からの問い合わせを待つのではなく、監視システムによって異常を早期に検知できる環境を構築することを目的とする。

---

## MON01構築

### サーバー情報

| 項目       | 設定値           |
| -------- | ------------- |
| サーバー名    | MON01         |
| IPアドレス   | 192.168.10.50 |
| サブネットマスク | 255.255.255.0 |
| DNSサーバー  | 192.168.10.10 |
| ドメイン     | corp.local    |

### ネットワーク

* アダプター1：NAT
* アダプター2：内部ネットワーク（mob-lan）

### ドメイン参加

MON01をcorp.localへ参加させた。

監視サーバーをドメインへ参加させることで、将来的にドメイン認証やイベントログ監視などを行いやすくなる。

---

## Ping疎通確認

監視対象として以下のサーバーを登録した。

* AD01
* FILE01
* BK01
* CLIENT01

MON01から各サーバーへPingを実施し、疎通確認を行った。

---

## 発生したトラブル

### 症状

MON01からCLIENT01へのPingが失敗した。

AD01、FILE01、BK01へのPingは成功したが、CLIENT01のみタイムアウトした。

### 切り分け

名前解決確認

```powershell
nslookup CLIENT01
```

Ping確認

```powershell
ping CLIENT01
```

疎通確認

```powershell
Test-NetConnection CLIENT01
```

その結果、DNSによる名前解決は成功していた。

そのためDNS障害ではなく、CLIENT01側の設定に問題があると判断した。

### 原因

CLIENT01側のファイアウォールおよびGPO設定が原因で、ICMP応答が許可されていなかった。

### 対応

GPOを修正し、MON01からCLIENT01へのPingが成功することを確認した。

### 学んだこと

Ping失敗時はすぐにDNSを疑うのではなく、

* 名前解決
* ネットワーク疎通
* ファイアウォール

を切り分けながら調査することが重要である。

---

## Ping監視スクリプト作成

PowerShellを使用して死活監視スクリプトを作成した。

監視対象

* AD01
* FILE01
* BK01
* CLIENT01

監視対象をIPアドレスではなくサーバー名で管理することで、IPアドレス変更時にもスクリプト修正が不要となる。

---

## ログ出力

監視結果をログファイルへ出力するように設定した。

ログ保存先

```text
C:\Monitor\ping-monitor.log
```

ログには実行日時と監視結果を記録する。

例

```text
2026-06-18 18:00:00 : FILE01 OK
```

---

## 障害検知テスト

FILE01を停止し、監視スクリプトを実行した。

結果

```text
FILE01 NG
```

と表示され、監視システムが異常を検知できることを確認した。

---

## アラート表示

異常発生時にコンソールへアラートを表示するようにした。

例

```text
ALERT : FILE01 is DOWN
```

正常時はログのみ記録し、異常時のみ通知する設計とした。

---

## 復旧確認

FILE01を起動し、再度監視スクリプトを実行した。

結果

```text
FILE01 OK
```

となり、復旧を正常に検知できることを確認した。

---

## 学んだこと

監視の目的は単にサーバーの状態を確認することではなく、利用者から問い合わせを受ける前に障害を検知することである。

また、正常状態を大量に通知すると重要なアラートが埋もれてしまうため、異常時のみ通知することが重要である。

今回のハンズオンを通して、前職で監視オペレーターとして見ていたアラートが、どのような仕組みで生成されているのかを理解することができた。

さらに、Ping監視だけでなく、障害発生時の切り分けや原因調査の考え方についても学ぶことができた。

---

## ディスク容量監視

### 目的
Ping監視ではサーバーの生存確認しかできないため、ディスク容量不足による障害を事前に検知できるようにする。
サーバーは稼働していても、ディスク容量が枯渇するとログ出力やアプリケーション動作に影響が発生するため、容量監視は重要な監視項目。

### 監視対象
- AD01
- FILE01
- BK01
- MON01
監視対象サーバーのCドライブ使用率を取得。

### 情報取得方法
MON01からPowerShellのCIMを利用し、各サーバーのディスク情報を取得した。
取得コマンド：Get-CimInstance Win32_LogicalDisk -ComputerName FILE01 -Filter "DeviceID='C:'"
取得項目：Size(総容量)、Freespace(空き容量)
使用率計算：（総容量 - 空き容量） / 総容量 * 100
  $usedPercent = (($disk.Size - $disl.FreeSpace) / $disk.Size) * 100
  $usedPercent = [math]::Round($usedPercent,0)

### 閾値判定
使用率80％以上を異常と判定
if ($usedPercent -ge 80) {
  "ALERT"
}
else *
  "OK"
}

### ログ出力
監視結果をログファイルへ出力
C:\Monitor\Logs\disk.log
出力例：2026-06-19 11:30:00 OK FILE01 C: Used 25%

### 複数サーバー対応
配列とforeachを使用し複数サーバーをまとめて監視
$server = @("AD01","FILE01","BK01","MON01")
サーバー追加時は配列へ追記するだけで監視対象を増やせる

## サービス監視

### 目的
ping監視ではサーバーの生存確認しかできないため、重要サービスの停止を検知できるようにする。

### 監視対象
| サーバー | サービス |
|---|---|
| AD01 | DNS |
| AD01 | DHCPServer |
| FILE01 | LanmanServer |

### 情報取得
PowerShellでリモートサービス状態を取得
Get-Service -ComputerName AD01 -Name DNS

### 判定処理
サービス状態がRunning以外の場合は異常と判定
if ($service.Status -eq "Running") { 
  "OK" } 
else { 
  "ALERT" 
}

### ログ出力
C:\Monitor\Logs\service.log
出力例
2026-06-19 20:00:00 OK AD01 DNS Running
2026-06-19 20:00:00 ALERT FILE01 LanmanServer Stopped

### 障害検知テスト
FILE01のLanmanServerサービスを停止し、監視スクリプトで異常検知を確認
Stop-Service LanmanServer
結果：ALERT FILE01 LanmanServer Stopped

### 復旧確認
サービス展開後に正常判定へ戻ることを確認
Start-Service LanmanServer
結果：OK FILE01 LanmanServer Running

### 学んだこと
- Ping監視だけではサービス障害を検知できない
- サービス監視により利用者影響のある障害を早期検知できる
- 停止検知だけでなく復旧確認も重要

---

## イベントログ監視

### 目的
イベントログから警告・エラーを検知し、障害の兆候や発生履歴を確認できるようにする。

### 監視対象
- Systemログ
- 警告  （Level3）
- エラー（Level2）

### 情報取得
PowerShellでSystemログを取得する。
Get-WinEvent -LogName System -MaxEvents 50
取得項目
- EventID
- Level
- ProviderName
- TimeCreated

### ログ出力
ログ保存先
C:\Monitor\Logs\eventlog.log
正常時：2026-06-19 16:05:42 OK No warning or error events
異常時：2026-06-19 16:10:00 ALERT EventID:7036 Level:2 Provider:Service Control Manager

### 動作確認
直近50件のイベントログから警告・エラーを抽出するスクリプトを作成した。
警告・エラーが存在しない場合は正常メッセージを出力するようにした。

### 学んだこと
- サービス監視は「現在の状態」を確認する監視
- イベントログ監視は「過去に発生した事象」を確認する監視
- EventIDやProviderNameを利用することで障害内容を特定できる
- 警告・エラーのみを監視対象とすることで不要な通知を減らせる

# 監視サーバー構築・監視自動化

## 目的
MON01を監視サーバーとして構築し、PowerShellによる死活監視と日次レポート生成を自動化する

## サーバー構成
| サーバー | IPアドレス | 役割 |
| ---- | ---- | ---- |
| AD01 | 192.168.10.10 | Active Direcotry/DNS/DHCP |
| FILE01 | 192.168.10.30 | ファイルサーバー |
| CLIENT01 | 192.168.10.150 | クライアントPC |
| BK01 | 192.168.10.40 | バックアップサーバー |
| MON01 | 192.168.10.50 | 監視サーバー |

## 監視対象
PowerShellスクリプトで以下のサーバーを対象とした
- AD01.corp.local
- FILE01.corp.local
- CLIENT01.corp.local
- BK01.corp.local
監視方法はICMP(Ping)による死活監視を採用した。

## PowerShellスクリプト
作成ファイル
C:\Scripts\daily-server-report.ps1
主な処理
1.監視対象サーバー一覧を定義
2.Tes-Connectionで疎通確認
3.結果をログファイルへ出力
4.NGサーバー数を集計
5.日次レポートを生成

## Test-Connectionについて
使用コマンド
Test-Connection -ComputerName $Server -Count 1 -Quiet
### パラメータ
- ComputerName
  - 監視対象サーバー名
- Count
  - Ping送信回数
  - 今回は一回
- Quiet
  - True/Falseのみ返却
  - if文との相性がいい

## ログ出力
出力先：C:\Logs\daily-server-report.log
出力例
===== Daily Server Report =====
Date : 2026-06-23 17:50:24 
AD01.corp.local : OK
FILE01.corp.local : OK
CLIENT01.corp.local : OK 
BK01.corp.local : OK 
NG Count : 0

## 障害試験

### FILE01停止試験
実施内容
- FILE01をシャットダウン
- スクリプト実行

結果
FILE01.corp.local : NG
NG Count : 1

正常に異常検知できることを確認。

## 発生したトラブルと対応

1.CLIENT01がNGになる
症状
CLIENT01 : NG
調査
- ping CLIENT01 失敗
- nslookup CLIENT01 失敗
- nslookup CLIENT01.corp.local 成功

原因：BK01でDNSサフィックスが補完されておらず、短縮名で名前解決できなかった
対応：監視対象をFQDNへ変更
CLIENT01 → CLIENT01.corp.local

2.BK01がNGになる
症状
BK01 : NG
調査
nslookup BK01.corp.local  失敗
原因：BK01はドメイン悲参加の為、DNSへ自動登録されていなかった
対応：AD01のDNSへ手動でAレコードを追加。
BK01
192.168.10.40
追加後に正常化

3.タスクスケジューラが実行されない
症状
ログが出力されない
履歴
ユーザーがログオンしていなかったため実行されませんでした
原因：タスク設定が、ユーザーがログオンしているときのみ実行、になっていた
対応：ユーザーがログオンしているかどうかにかかわらず実行、へ変更
正常に自動実行されることを確認

## タスクスケジューラ設定
タスク名：Daily Server Report
実行プログラム：powershell.exe
引数：-ExecutionPolicy Bypass -File "C]\Scripts\daily-server-report.ps1"
設定
- 最上位の特権で実行
- ログオン有無に関係なく実行

## 学習内容
- PowerShellによる死活監視
- Test-Connectionの利用
- ログ出力
- FQDNとDNSの名前解決
- DNSレコード管理
- タスクスケジューラによる自動実行
- 障害試験の実施
- トラブルシュート手順
- 監視レポート作成
  

























