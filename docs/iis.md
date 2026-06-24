# IIS Web Server構築

## 概要

Windows Server 2022上にIIS（Internet Information Services）を構築し、クライアントPCからWebページへアクセスできる環境を作成した。

Active Directory、DNS、ネットワーク設定と連携し、名前解決からWeb表示までの一連の流れを確認した。

---

## 構成

### サーバー構成

| サーバー     | IPアドレス         | 役割                 |
| -------- | -------------- | ------------------ |
| AD01     | 192.168.10.10  | AD DS / DNS / DHCP |
| FILE01   | 192.168.10.30  | ファイルサーバー           |
| IIS01    | 192.168.10.60  | Webサーバー(IIS)       |
| CLIENT01 | 192.168.10.150 | クライアント             |

ドメイン

```text
corp.local
```

---

## IIS01構築

### 仮想マシン作成

VirtualBox

設定

```text
メモリ：2GB
CPU：1コア
ディスク：50GB
```

ネットワーク

```text
アダプター1：NAT
アダプター2：内部ネットワーク(mob-lan)
```

---

### OSインストール

OS

```text
Windows Server 2022 Standard Desktop Experience
```

---

### IP設定

```text
IPアドレス      192.168.10.60
サブネット      255.255.255.0
デフォルトGW    192.168.10.1
DNS             192.168.10.10
```

---

### ホスト名変更

変更前

```text
WIN-XXXXXXX
```

変更後

```text
IIS01
```

---

### ドメイン参加

参加ドメイン

```text
corp.local
```

確認

```powershell
(Get-WmiObject Win32_ComputerSystem).Domain
```

結果

```text
corp.local
```

---

## IISインストール

サーバーマネージャー

```text
役割と機能の追加
↓
Web Server (IIS)
```

をインストール。

---

## 動作確認①

IIS01上で

```text
http://localhost
```

へアクセス。

結果

```text
IIS初期ページ表示成功
```

確認。

---

## DNS登録

AD01 DNSへAレコード追加。

レコード

```text
iis01.corp.local
192.168.10.60
```

---

## 動作確認②

CLIENT01で確認。

```powershell
nslookup iis01.corp.local
```

結果

```text
Name    : iis01.corp.local
Address : 192.168.10.60
```

DNS名前解決成功。

---

## 動作確認③

CLIENT01ブラウザからアクセス。

```text
http://iis01.corp.local
```

結果

```text
IIS初期ページ表示成功
```

---

## 通信の流れ

```text
CLIENT01
    ↓
DNS問い合わせ
    ↓
AD01(DNS)
    ↓
iis01.corp.local
    ↓
192.168.10.60
    ↓
HTTP(TCP80)
    ↓
IIS01
    ↓
Webページ表示
```

---

## トラブルシュート

### ドメイン参加確認

確認コマンド

```powershell
(Get-WmiObject Win32_ComputerSystem).Domain
```

結果

```text
corp.local
```

---

### DNS確認

確認コマンド

```powershell
nslookup corp.local 192.168.10.10
```

結果

```text
corp.local
```

正常応答。

---

### DNS優先順位問題

現象

```text
nslookup corp.local
```

実行時に

```text
192.168.24.1
```

(NAT側DNS)が参照された。

切り分けにより、

```text
nslookup corp.local 192.168.10.10
```

でAD01 DNSは正常であることを確認した。

---

## 学習内容

### Windows Server

* サーバー構築
* IP設定
* ホスト名変更
* ドメイン参加

### DNS

* Aレコード登録
* 名前解決確認
* nslookup

### IIS

* Web Server役割
* localhost確認
* クライアントアクセス確認

### トラブルシュート

* DNS確認
* ドメイン参加確認
* 名前解決切り分け

---

## 成果

IIS01を新規構築し、

* Windows Server構築
* ドメイン参加
* DNS登録
* IIS構築
* クライアントアクセス確認

まで実施した。

監視・運用だけでなく、Webサーバーの構築から公開までを一通り経験できた。
