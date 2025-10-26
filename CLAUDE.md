# CLAUDE.md

このファイルは、このリポジトリで作業する際にClaude Code (claude.ai/code) へのガイダンスを提供します。

## プロジェクト概要

このプロジェクトは、AWSを使用して静的ウェブサイトをデプロイするTerraformインフラストラクチャです：
- S3バケット（静的サイトホスティング用）
- CloudFront CDN（Origin Access Identity (OAI)によるコンテンツ配信）
- CloudFrontのみがS3コンテンツにアクセスできるセキュアなアクセスパターン

インフラストラクチャはデフォルトで`ap-northeast-1`（東京）リージョン向けに設計されています。

## アーキテクチャ

インフラストラクチャは以下のアクセスパターンに従います：
```
ユーザー → CloudFrontディストリビューション → OAI → S3バケット（プライベート）
```

主要なアーキテクチャの決定事項：
- S3バケットは公開アクセス不可。CloudFrontのみがOAI経由でアクセス可能
- CloudFrontはHTTPSを強制（redirect-to-httpsポリシー）
- バケットポリシーはCloudFront OAIのcanonical user IDにのみGetObject権限を付与
- ステートバックエンドは現在ローカル（main.tf:8に将来のGitHub Actions用S3バックエンド設定の記載あり）

## 主要コマンド

### Terraformの初期化
```bash
terraform init
```

### 設定の検証
```bash
terraform validate
```

### インフラストラクチャ変更の計画
```bash
terraform plan
```

### プランをファイルに保存
```bash
terraform plan -out=plan.tfplan
```

### 変更の適用
```bash
terraform apply
```

### 保存したプランの適用
```bash
terraform apply plan.tfplan
```

### インフラストラクチャの破棄
```bash
terraform destroy
```

### コードのフォーマット
```bash
terraform fmt
```

### 現在の状態を表示
```bash
terraform show
```

### 出力値の表示
```bash
terraform output
```

## 設定

### 必須変数
- `bucket_name`: S3バケット名（グローバルで一意である必要あり）。`terraform.tfvars`に設定
- `region`: AWSリージョン（デフォルトは`ap-northeast-1`）

### 重要な出力値
- `cloudfront_domain_name`: 静的サイトにアクセスするための公開URL
- `aws_cloudfront_distribution_id`: コンテンツ更新後のキャッシュ無効化に使用
- `s3_bucket_name`: サイトをホスティングするバケット
- `s3_website_endpoint`: S3リージョナルドメイン（OAIのため直接アクセス不可）

## ファイル構成

- `main.tf`: コアインフラストラクチャリソース（S3、CloudFront、OAI、ポリシー）
- `variables.tf`: 入力変数の定義
- `outputs.tf`: 出力値の定義
- `terraform.tfvars`: 変数値（バケット名設定を含む）
- `.terraform.lock.hcl`: プロバイダーバージョンロックファイル

## 開発メモ

- 将来の機能拡張予定：リモートステート用のS3バックエンド設定（main.tf:8参照）
- CloudFrontディストリビューションのデプロイ・更新には15〜20分かかります
- S3へのコンテンツアップロード後、即座に更新を反映させるにはCloudFrontのキャッシュ無効化が必要な場合があります
