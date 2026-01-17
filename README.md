![CC BY-NC 4.0](https://licensebuttons.net/l/by-nc/4.0/88x31.png)

This work is licensed under a  
[Creative Commons Attribution-NonCommercial 4.0 International License](https://creativecommons.org/licenses/by-nc/4.0/).

![CC BY-NC 4.0](https://licensebuttons.net/l/by-nc/4.0/88x31.png)

本作品は  
[Creative Commons 表示-非営利 4.0 国際 (CC BY-NC 4.0)](https://creativecommons.org/licenses/by-nc/4.0/deed.ja)  
の下で提供されています。

# websh

---

## 🇯🇵 日本語（概要）

**websh** は、1つのシェルスクリプトだけで起動できる  
Linux / Termux 向けの **Webベースシェルサーバー**です。

`web.sh` を実行するだけで、必要なサーバーコード・フロントエンド・設定ファイルを自動生成し、
ブラウザから Linux のシェルを操作できます。

> ⚠ 本ツールはリモートコマンド実行機能を含みます。  
> 信頼できるネットワーク内でのみ使用してください。

---

### 主な特徴

- 1ファイル構成（`web.sh` のみ）
- WebSocket ベースの Web シェル
- Basic 認証対応
- HTTPS 対応（自己署名証明書）
- Linux / Termux 両対応
- データベース不要
- 最小セットアップ

---

### 必要環境

- Node.js
- npm
- OpenSSL
- Linux または Termux

---

### セットアップ

```sh
chmod +x web.sh
./web.sh config
````

このコマンドで以下が自動生成されます：

* サーバーコード
* フロントエンド（Web UI）
* `config.conf`
* 必要なディレクトリ
* npm 依存関係

---

### 使い方

起動：

```sh
./web.sh start
```

停止：

```sh
./web.sh stop
```

状態確認：

```sh
./web.sh status
```

ブラウザからアクセス：

```
http://<サーバーのIP>:8080
```

---

### 認証設定

`config.conf` を編集してください：

```conf
auth-enable=true
auth-id=root
auth-pass=pass
```

認証がキャンセル・失敗した場合、
**コマンド実行は完全に拒否されます。**

---

### HTTPS（任意）

自己署名証明書の生成：

```sh
openssl req -x509 -newkey rsa:2048 \
  -keyout cert/privkey.pem \
  -out cert/fullchain.pem \
  -days 365 -nodes
```

設定例：

```conf
https-enable=true
https-cert-path=cert/fullchain.pem
https-key-path=cert/privkey.pem
```

---

### ライセンス

本プロジェクトは
**Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)**
で配布されています。

* クレジット表記必須
* 非商用利用のみ許可

[https://creativecommons.org/licenses/by-nc/4.0/](https://creativecommons.org/licenses/by-nc/4.0/)

---

---

## 🇺🇸 English (Overview)

**websh** is a web-based shell server for Linux / Termux
that can be launched using a single shell script.

Running `web.sh` automatically generates all required files
(server, frontend, configuration) and allows you to control
a Linux shell from your browser.

> ⚠ This software allows remote command execution.
> Use only in trusted networks.

---

### Features

* Single-file launcher (`web.sh`)
* Web-based shell via WebSocket
* Basic Authentication support
* HTTPS support (self-signed)
* Works on Linux and Termux
* No database required
* Minimal setup

---

### Requirements

* Node.js
* npm
* OpenSSL
* Linux or Termux environment

---

### Setup

```sh
chmod +x web.sh
./web.sh config
```

This command automatically generates:

* Server code
* Frontend (Web UI)
* `config.conf`
* Required directories
* npm dependencies

---

### Usage

Start the server:

```sh
./web.sh start
```

Stop the server:

```sh
./web.sh stop
```

Check status:

```sh
./web.sh status
```

Access from browser:

```
http://<server-ip>:8080
```

---

### Authentication

Edit `config.conf`:

```conf
auth-enable=true
auth-id=root
auth-pass=pass
```

If authentication is cancelled or invalid,
**command execution is completely blocked.**

---

### HTTPS (Optional)

Generate a self-signed certificate:

```sh
openssl req -x509 -newkey rsa:2048 \
  -keyout cert/privkey.pem \
  -out cert/fullchain.pem \
  -days 365 -nodes
```

Enable HTTPS in `config.conf`:

```conf
https-enable=true
https-cert-path=cert/fullchain.pem
https-key-path=cert/privkey.pem
```

---

### License

This project is licensed under
**Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)**.

* Attribution required
* Commercial use is not allowed

[https://creativecommons.org/licenses/by-nc/4.0/](https://creativecommons.org/licenses/by-nc/4.0/)

---

### Author

わたあめえ

