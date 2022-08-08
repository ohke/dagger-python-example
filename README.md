# dagger-python-example

DockerでCI/CDパイプラインの実装を行うツール **[Dagger](https://dagger.io/)** をPythonで使ってみた非公式のexampleレポジトリです。

こちらで解説記事も書いています。

[DaggerでPythonのCIを実装してGitHub Actionsで動かしてみる - け日記](https://ohke.hateblo.jp/entry/2022/08/08/184500)

## 前提

自身の環境で実行する場合は、以下を予めインストールしてください。

- [dagger](https://docs.dagger.io/1200/local-dev)
- Docker
- direnv

## 使い方

```
git clone https://github.com/ohke/dagger-python-example
cd dagger-python-example

# 環境変数の設定
cp .env.example .env
vim .env
direnv allow

# セットアップ
dagger project update

# dagger doで使えるサブコマンドを確認
dagger do -h
```

dagger doでは、以下のサブコマンドを指定できます。

- lint flake8による静的チェック
- fmt blackによるフォーマット
- test pytestによるテスト
- check lint, fmt, testをまとめて実行
- buildImage イメージビルド
- pushLocal ローカルレポジトリへプッシュ
  - 予め `docker run -d -p 5042:5000 --restart=always --name localregistry registry:2` でローカルレポジトリを起動してください
- pushDockerhub docker.ioレポジトリへプッシュ
  - 予め .env の `DOCKERHUB_USERNAME` と `DOCKERHUB_TOKEN` をセットしてください
