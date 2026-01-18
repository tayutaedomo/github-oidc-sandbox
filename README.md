# GitHub Actions AWS OIDC Verification

GitHub Actions と AWS の OpenID Connect (OIDC) 認証を検証するためのサンドボックスプロジェクトです。
Terraform を使用して AWS リソースを管理し、GitHub Actions からパスワードレスで AWS にアクセスします。

## 事前準備

以下のツールが必要です。

*   AWS CLI
*   Terraform
*   GitHub CLI (`gh`)

## セットアップ手順

### 1. AWS リソースの作成 (Terraform)

Terraform を使用して OIDC プロバイダーと IAM ロールを作成します。

```bash
cd terraform

# 変数ファイルの作成
# aws_profile には使用する AWS CLI のプロファイル名を指定してください
echo 'aws_profile = "default"' > terraform.tfvars

# 初期化と適用
terraform init
terraform apply
```

作成後、以下の出力値を控えておきます。

*   `role_arn`: IAM ロール ARN
*   `bucket_name`: 検証用 S3 バケット名

### 2. GitHub Secrets / Variables の設定

Terraform の出力値を使用して、GitHub Actions の環境設定を行います。

#### Secrets (機密情報)
IAM ロールの ARN を登録します。

```bash
export ROLE_ARN=$(terraform output -raw role_arn)
gh secret set AWS_ROLE_ARN --body "$ROLE_ARN"
```

#### Variables (環境変数)
S3 バケット名を登録します。

```bash
export BUCKET_NAME=$(terraform output -raw bucket_name)
gh variable set AWS_BUCKET_NAME --body "$BUCKET_NAME"
```

### 3. 動作確認

検証用のワークフローを手動実行します。

#### OIDC 認証確認

```bash
gh workflow run verify-oidc.yml
gh run list
```

成功すると `aws sts get-caller-identity` が実行されます。

#### S3 アクセス確認

```bash
gh workflow run verify-s3.yml
gh run list
```

成功すると、作成した空の S3 バケットに対して `aws s3 ls` が実行されます。

## ディレクトリ構成

*   `terraform/`: AWS リソース定義 (OIDC Provider, IAM Role)
*   `.github/workflows/`: 検証用 GitHub Actions ワークフロー
