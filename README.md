# Homelab #1 Active Directory

## 概要
VirtualBox上にWindows Server2022を構築し、ActiveDirectory環境を作成。

## 構成

### AD01
- Windows Server 2022
- Active Directory Domain Services
- DNS Server

### ドメイン
corp.local

### ネットワーク
| サーバー | IPアドレス |
| --- | --- |
| AD01 | 192.168.10.10 |

### 実施内容
- Windows Server 2022 インストール
- サーバー名変更
- 固定IPアドレス設定
- AD DSインストール
- DNSインストール
- corp.local作成
- OU作成
- ユーザー作成
- グループ作成

## 作成したOU
- UserAccounts
- Groups
- Servers

### 作成したユーザー
- tanaka

## 学んだこと
- ADは認証情報を一元管理する仕組み
- ADはDNSに依存する
- サーバーは固定IPが基本
- ユーザーではなくグループに権限を付与する
- OUはGPO適用の単位になる

## Next Steps
- [x] Active Directory構築
- [x] DNS構築
- [x] OU作成
- [x] ユーザー作成
- [x] グループ作成
- [ ] Windows11クライアント作成
- [ ] ドメイン参加
- [ ] ファイルサーバー構築
- [ ] GPO設定

## Documents
- [要件定義書](docs/requirements.md)
- [基本設計書](docs/basic_design.md)
