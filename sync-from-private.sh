#!/bin/bash
# プライベートリポジトリから議事録を安全にコピー・公開

PRIVATE_PATH="/Users/ogawashinpei/.openclaw/workspace/company-knowledge/Operations/meetings"
PUBLIC_PATH="/Users/ogawashinpei/openclaw-public-meetings"

echo "🔄 議事録同期開始..."

# 新しい議事録をコピー
rsync -av --exclude="archive/" "$PRIVATE_PATH/daily/" "$PUBLIC_PATH/daily/"

# 機密情報マスキング
find "$PUBLIC_PATH/daily" -name "*.md" -type f | while read file; do
    echo "マスキング処理: $(basename "$file")"
    
    # 投資情報マスキング
    sed -i.bak 's/BTC.*[0-9]\+\.[0-9]\+.*枚/BTC [REDACTED]枚/g' "$file"
    sed -i.bak 's/SOL.*[0-9]\+\.[0-9]\+.*枚/SOL [REDACTED]枚/g' "$file" 
    sed -i.bak 's/HYPE.*[0-9]\+\.[0-9]\+/HYPE [REDACTED]/g' "$file"
    sed -i.bak 's/ZKP.*[0-9]\+,[0-9]\+/ZKP [REDACTED]/g' "$file"
    
    # 金額マスキング
    sed -i.bak 's/[0-9]\+万円/[REDACTED]万円/g' "$file"
    sed -i.bak 's/[0-9]\+億円/[REDACTED]億円/g' "$file"
    sed -i.bak 's/[0-9]\+千万円/[REDACTED]千万円/g' "$file"
    
    # 個人情報マスキング（念のため）
    sed -i.bak 's/小川真平/[CEO]/g' "$file"
    
    # バックアップファイル削除
    rm -f "$file.bak"
done

# Git commit & push
cd "$PUBLIC_PATH"
git add .
git commit -m "📝 議事録自動更新: $(date +%Y-%m-%d)"
git push origin main

echo "✅ パブリック議事録更新完了"
