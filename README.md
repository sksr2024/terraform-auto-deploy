# Terraform AWS 静的ウェブサイトインフラストラクチャ

Terraformを使用してAWS上に静的ウェブサイトをデプロイするためのInfrastructure as Code。

## アーキテクチャ

![CloudFront + S3 アーキテクチャ](./aws_architecture.png)

このプロジェクトは、セキュアなアクセスパターンを実装しています：

```
クライアント → CloudFront (HTTPS) → Origin Access Identity (OAI) → S3バケット（プライベート）
```

### 主要コンポーネント

- **S3バケット**: 静的サイトコンテンツをホスティング（プライベートアクセスのみ）
- **CloudFront CDN**: HTTPS強制によるコンテンツ配信
- **Origin Access Identity (OAI)**: S3へのアクセスをCloudFrontのみに制限

### セキュリティ機能

- S3バケットは公開アクセス不可
- CloudFrontはOAI経由でのみS3にアクセス
- HTTPS強制（redirect-to-httpsポリシー）
- バケットポリシーはOAIのcanonical user IDにのみGetObject権限を付与

## 必要要件

- Terraform >= 1.0
- AWS CLI（設定済み）
- AWSアカウント

## 使用方法

### 1. 初期セットアップ

```bash
# リポジトリをクローン
git clone https://github.com/sksr2024/terraform-auto-deploy.git
cd terraform-auto-deploy

# terraform.tfvarsを作成してバケット名を設定
echo 'bucket_name = "your-unique-bucket-name"' > terraform.tfvars
```

### 2. Terraformでデプロイ

```bash
# Terraformを初期化
terraform init

# 変更内容をプレビュー
terraform plan

# インフラストラクチャをデプロイ
terraform apply
```

### 3. 出力値を確認

```bash
terraform output
```

重要な出力値：
- `cloudfront_domain_name`: サイトにアクセスするための公開URL
- `aws_cloudfront_distribution_id`: キャッシュ無効化に使用するディストリビューションID
- `s3_bucket_name`: サイトをホスティングするバケット名

## GitHub Actions CI/CD

このプロジェクトはGitHub Actionsを使用した自動デプロイをサポートしています。

### セットアップ手順

1. GitHubリポジトリの `Settings` → `Secrets and variables` → `Actions` に移動
2. 以下のシークレットを追加：
   - `AWS_ACCESS_KEY_ID`: AWSアクセスキーID
   - `AWS_SECRET_ACCESS_KEY`: AWSシークレットアクセスキー
   - `AWS_REGION`: `ap-northeast-1`
   - `BUCKET_NAME`: S3バケット名（グローバルで一意）

3. mainブランチへのプッシュで自動的にTerraformデプロイが実行されます

## ファイル構成

```
.
├── main.tf                      # メインインフラストラクチャ定義
├── variables.tf                 # 変数定義
├── outputs.tf                   # 出力値定義
├── terraform.tfvars             # 変数値（gitignore対象）
├── .github/
│   └── workflows/
│       └── terraform.yml        # CI/CDワークフロー
├── cloudfront_s3_architecture.png  # アーキテクチャ図
└── CLAUDE.md                    # Claude Codeガイダンス
```

## よく使うコマンド

```bash
# コードをフォーマット
terraform fmt

# 設定を検証
terraform validate

# 変更内容をプレビュー
terraform plan

# 変更を適用
terraform apply

# 現在の状態を表示
terraform show

# 出力値を表示
terraform output

# インフラストラクチャを破棄
terraform destroy
```

## 注意事項

- CloudFrontディストリビューションのデプロイには15〜20分かかります
- S3へのコンテンツアップロード後、即座に更新を反映させるにはキャッシュ無効化が必要な場合があります
- `terraform.tfvars` には機密データが含まれる可能性があるため、バージョン管理から除外されています

## ライセンス

MIT License
