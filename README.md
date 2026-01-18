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

作成後、出力される `role_arn` を控えておきます（次で使用します）。

### 2. GitHub Secrets の設定

作成された IAM ロールの ARN を GitHub Secrets に登録します。

```bash
# Terraform の出力から Role ARN を取得して設定する場合
export ROLE_ARN=$(terraform output -raw role_arn)
gh secret set AWS_ROLE_ARN --body "$ROLE_ARN"
```

### 3. 動作確認

検証用のワークフローを手動実行します。

```bash
gh workflow run verify-oidc.yml
gh run list
```

成功すると、ワークフローログの `Verify Identity` ステップにて、Assume Role された ARN が表示されます。

## ディレクトリ構成

*   `terraform/`: AWS リソース定義 (OIDC Provider, IAM Role)
*   `.github/workflows/`: 検証用 GitHub Actions ワークフロー
