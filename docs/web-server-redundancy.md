# Web Server Redundancy（Webサーバー冗長化）

## 概要

Monitoring Dashboardの可用性向上を目的として、Webサーバーを1台構成から2台構成へ拡張した。

IIS02を新規構築し、IIS01と同じWebコンテンツを公開できる環境を作成した。

また、ロードバランサー構成としてWindows Network Load Balancing（NLB）の検証を実施した。

---

# システム構成

```text
               CLIENT01
               /      \
              /        \
             ▼          ▼
         IIS01      IIS02
            │          │
     Monitoring   Monitoring
      Dashboard    Dashboard
```

---

# 実装内容

## 1. IIS02構築

新しいWebサーバーとしてIIS02を構築した。

構成

|項目|設定|
|---|---|
|OS|Windows Server 2022|
|IP Address|192.168.10.70|
|Domain|corp.local|
|Role|Web Server(IIS)|

---

## 2. IIS構成

IIS01と同じ役割サービスを追加した。

追加した機能

- Web Server (IIS)
- HTTP Redirect

---

## 3. Webコンテンツ配置

IIS01で公開しているコンテンツをIIS02へ配置した。

コピーしたファイル

- server-status.html
- style.css

公開確認

```
http://IIS02/server-status.html
```

Monitoring Dashboardが正常に表示されることを確認した。

---

## 4. HTTPS対応

IIS01と同様にHTTPS公開を構成した。

実施内容

- 自己署名証明書作成
- HTTPS(443)バインド追加
- HTTP Redirect設定

確認

```
https://IIS02/server-status.html
```

HTTPからHTTPSへ自動リダイレクトされることを確認した。

---

# NLB検証

Windows Network Load Balancing（NLB）の検証を実施した。

実施内容

- Network Load Balancing機能追加
- NLB Manager起動
- 新規クラスター作成
- Virtual IP設定

設定

|項目|値|
|---|---|
|VIP|192.168.10.80|
|Cluster Name|monitor.corp.local|

---

# 検証結果

NLBクラスターの作成自体は正常に完了した。

しかし、クラスター構成後に以下の通信異常を確認した。

- IIS01 → IIS02 のSMB通信失敗
- ping IIS02 がタイムアウト
- IIS02追加時に接続失敗

VirtualBox環境におけるWindows NLBのネットワーク制約が原因である可能性が高いと判断した。

---

# 今後の対応

Windows NLBによる負荷分散は一旦保留とし、HTTP/HTTPSロードバランサーであるApplication Request Routing（ARR）を利用した構成へ切り替えて検証を継続する。

予定構成

```text
             CLIENT01
                  │
        monitor.corp.local
                  │
             IIS01(ARR)
           Reverse Proxy
                  │
         ┌────────────┐
         ▼            ▼
      IIS01        IIS02
```

---

# 学んだこと

- Webサーバー増設の手順
- IIS環境の複製
- HTTPS設定の再現
- 複数Webサーバー構成
- Virtual IP（VIP）の考え方
- Windows NLBの基本構成
- 検証環境による制約を考慮した設計変更の重要性

