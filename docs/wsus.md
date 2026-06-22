## 発生したトラブル

### 症状

WSUS初回同期が完了せず、Synchronizationsで
"Running..." のまま進捗0%となった。

### 切り分け

- Microsoft Updateへの通信確認
- DNS名前解決確認
- WSUSサービス起動確認
- イベントログ確認

### 結果

WSUSサービスは正常起動しており、
製品一覧も取得できていることを確認した。

同期処理自体は開始されているが、
初回同期が長時間完了しないため、
原因調査は保留とした。

### 学んだこと

WSUSは

- Products
- Classifications
- Synchronizations
- Options

の設定が重要である。

また、同期トラブル発生時は
Synchronizationsとイベントログを確認する。
