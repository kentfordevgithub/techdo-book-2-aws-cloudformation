# インストール後のWordPressでの初期設定

## 管理画面のログイン情報の確認

```ssh -i EC2接続用のSSH鍵ファイル(pem) bitnami@EC2インスタンスのIP``` でサーバにSSH接続する。

1. ```cat bitnami_credentials``` を実行
2. ログインユーザ名とログインパスワードが表示される


## CSSやJSファイルのリンクのHTTPS化

ELBからEC2インスタンスへは80ポートで接続している都合上、WordPressがHTTPSで通信が来たと判別することができず、ブログページなどを表示してもCSSやJSへのリンクがHTTPで作成されてしまい、Mixed Contentのエラーがブラウザで発生します。それを防ぐために、外部リンクへのURLは全てHTTPSで作成するようにプラグインを追加します。

1. プラグイン "SSL Insecure Content Fixer" をインストールする
2. "SSL Insecure Content Fixer" の設定を開き、HTTPS の検出方法 の HTTPS を検出する方法がない にチェックを付ける
3. 変更を保存する


## 基本サイトのURL変更

```ssh -i EC2接続用のSSH鍵ファイル(pem) bitnami@EC2インスタンスのIP``` でサーバにSSH接続する。

1. WordPressのコンフィグファイルに書かれているドメインを変更する
    1. ```vi apps/wordpress/htdocs/wp-config.php```
    3. ```a``` キーを入力するなどで編集モードにする
    2. ```define( 'DOMAIN_CURRENT_SITE', '設定されているドメイン' );``` の項目を任意のドメインに変更する
    5. ```esc``` ->  ```wq``` -> ```return``` の順にキー入力し上書き保存する

2. WordPressのコンフィルファイルからMySQLの接続情報を調べ、データの更新を実行する。
    1. ```cat apps/wordpress/htdocs/wp-config.php```
    2. DB_NAME, DB_USER, DB_PASSWORD, DB_HOST, が使用する情報
    3. mysqlコマンドを発行し、MySQLに接続する
        1. ```mysql -u bn_wordpress -h localhost -D bitnami_wordpress -p```
        2. 上記で調べた DB_PASSWORD を入力
    4. 下記のSQLを発行し、変更箇所を確認
        1. ```select option_name,option_value from wp_options where option_name = 'siteurl' OR option_name = 'home';```
        1. ```select domain,blog_id from wp_blogs;```
    5. 下記のSQLを発行し、データを更新
        1. ```UPDATE wp_options SET option_value = '任意のURL(https://~~)' WHERE option_name = 'home';```
        2. ```UPDATE wp_options SET option_value = '任意のURL(https://~~)' WHERE option_name = 'siteurl';```
        3. ```UPDATE wp_blogs SET domain = '任意のドメイン' WHERE blog_id = 1;```
    6. ```\q``` で mysqlコマンド を終了する


## 複数ドメインの設定方法

マルチサイトの設定まではBitnamiのマルチサイトを使っていれば設定されているため、プラグインの導入から。

1. プラグイン "WordPress MU Domain Mapping" をインストールする
2. ```define( 'SUNRISE', 'on' );``` を ```wp-config.php``` に追記する
    1. SSHで接続し、viコマンドで追記をする
    2. ```ssh -i EC2接続用のSSH鍵ファイル(pem) bitnami@EC2インスタンスのIP```
    3. ```vi apps/wordpress/htdocs/wp-config.php```
    4. ```a``` キーを入力するなどで編集モードにする
    5. ```define( 'SUNRISE', 'on' );``` をファイルに追記する
    6. ```esc``` ->  ```wq``` -> ```return``` の順にキー入力し上書き保存する
3. サイト設定から、サイトを新規追加する
4. サイトネットワーク設定のDomainsを開き、サイトIDとドメインを入力し、更新
    1. サイト設定でサイトを新規追加した際に振出されたIDがサイトIDとなる
    2. ドメインは任意の独自ドメイン
5. 追加したサイトの編集画面をサイト一覧から開き、サイトアドレス(URL)を設定した任意のドメインに変更する


## Bitnamiのロゴを削除する

```ssh -i EC2接続用のSSH鍵ファイル(pem) bitnami@EC2インスタンスのIP``` でサーバにSSH接続する。

```
# ロゴを消すための設定
sudo /opt/bitnami/apps/wordpress/bnconfig --disable_banner 1

# Apacheを再起動
sudo /opt/bitnami/ctlscript.sh restart apache
```


## クラシックエディタ

WordPressバージョン5から導入されたエディタが嫌な方はインストールする。

1. プラグイン "Classic Editor" をインストールする


# AWSマネジメントコンソールから設定すること

## 作成したCloudFormationのスタックの削除保護

CloudFormationの画面から、該当のスタックを選択肢、削除保護の編集から、保護するを選択する。

また各種重要な設定も個別に削除保護する。EC2のインスタンスについては個別で削除保護する。


## 初期設定完了後のスナップショットの作成

EC2インスタンス一覧から、該当のインスタンスをチェックし、アクション -> イメージ -> イメージの作成。

- 再起動しない、にチェックを入れてイメージ作成をすること。　
- この作業によりAMIイメージが作成され、以降はそのイメージを元にEC2インスタンスを作成すると、初期設定後の状態から開始できる
- ただ、基本サイトのURL変更、だけは再起動の度に必要となるため、注意すること


ボリューム一覧から、該当のインスタンスをチェックし、アクション -> スナップショットの作成。


## CloudWatchのログ登録

EC2インスタンス一覧から、該当のインスタンスをチェックし、アクション -> CloudWatchのモニタリング、から有効にする。

アラームの作成も可能になるため、CPU使用率等の基準で、アラート発行するように設定する。

## ライフサイクルマネージャーの設定

定期的にEC2インスタンスのバックアップが作成されるようにする。EBSの画面からライフサイクルマネージャーを選択する


### インスタンスの設定

- 説明: 適宜入力
- Select resource type: Instance を選択する
- Target with these tags: CloudFormationからタグ設定された、EC2インスタンスの設定を記載する
- スケジュール名: 適宜入力
- ポリシーを次の時間ごとに実行する: 6時間
- 開始時刻: 適宜入力
- 保持ルール: 8つ (6時間おきに作成で、8つであれば、 24時間 / 6 = 4 が1日分で、要するに2日分)


### ボリュームの設定

インスタンスとの違いがあまりわかっていない。設定は、上記のインスタンスの設定の、 Select resource type をVolumeに設定して、後は同様。


# 運用開始後に適宜やること

## ストレージ容量の拡張

EBSのストレージ容量の拡張はサーバ無停止で実施できる。


## インスタンスタイプの変更

EC2のインスタンスタイプは、EC2インスタンスの停止 -> 変更、で実施できる。
(実際の検証はまだ)
