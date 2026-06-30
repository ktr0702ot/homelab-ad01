# HTTPS Configuration（HTTPS対応）

## 概要

Monitoring DashboardをHTTPSで公開するため、IISへ自己署名証明書を導入し、SSL/TLS通信を構成した。

また、HTTPからHTTPSへのリダイレクトを設定し、すべてのアクセスを暗号化通信へ統一した。

---

# システム構成

```text
CLIENT01
      │
http://iis01
      │
301 Redirect
      ▼
https://iis01
      │
TLS暗号化通信
      ▼
IIS01
      │
server-status.html
```

---

# 実装内容

## 1. 自己署名証明書の作成

IISの「Server Certificates」機能を利用し、自己署名証明書を作成した。

証明書名

```
IIS01-HTTPS
```

証明書ストア

```
Personal
```

---

## 2. HTTPSバインド設定

Default Web SiteへHTTPSバインドを追加した。

設定内容

|項目|設定|
|---|---|
|Type|https|
|Port|443|
|IP Address|All Unassigned|
|Host Name|空欄|
|SSL Certificate|IIS01-HTTPS|

設定後のバインド

|Type|Port|
|---|---|
|http|80|
|https|443|

---

## 3. HTTPS接続確認

CLIENT01から

```
https://iis01/server-status.html
```

へアクセスし、Monitoring Dashboardが表示されることを確認した。

自己署名証明書のためブラウザに証明書警告は表示されるが、HTTPS通信自体は正常に行われていることを確認した。

---

## 4. HTTP Redirect追加

IISの役割サービス

```
HTTP Redirect
```

を追加した。

その後、Default Web SiteでHTTP Redirectを設定した。

リダイレクト先

```
https://iis01
```

HTTP Status Code

```
301 (Permanent)
```

---

## 動作確認

HTTPでアクセス

```
http://iis01/server-status.html
```

↓

自動的に

```
https://iis01/server-status.html
```

へリダイレクトされることを確認した。

---

# HTTPS化後の構成

```text
CLIENT01

      │

HTTP (80)
      │
301 Redirect
      ▼
HTTPS (443)
      │
TLS暗号化
      ▼
IIS01
      │
Monitoring Dashboard
```

---

# 学んだこと

- HTTPとHTTPSの違い
- SSL/TLSによる暗号化通信
- 自己署名証明書の作成方法
- IISへの証明書バインド
- HTTPS(443)によるWeb公開
- HTTP RedirectによるHTTPSへの自動転送
- 301リダイレクトの役割
- ブラウザの証明書警告が表示される理由

---

# 実務との違い

今回は自己署名証明書を利用したため、ブラウザには証明書警告が表示される。

実務では以下のような認証局が発行した証明書を利用することで、ブラウザの警告は表示されない。

- Active Directory Certificate Services（AD CS）
- DigiCert
- GlobalSign
- Let's Encrypt

---

# Azureとの関連

HTTPS化はAzureでも基本となる技術であり、以下のサービスでも同様の考え方を利用する。

- Azure Application Gateway
- Azure App Service
- Azure Front Door
- Azure Load Balancer（TLS終端構成）

オンプレミス環境でHTTPSの基本構成を理解したことで、Azure環境でも証明書設定やHTTPS公開の仕組みを理解しやすくなる。
