#!/bin/bash
# OpenClaw議事録自動同期（cron用）

cd /Users/ogawashinpei/openclaw-public-meetings

# プライベートリポジトリから新しい議事録をコピー
rsync -av --exclude="archive/" /Users/ogawashinpei/.openclaw/workspace/company-knowledge/Operations/meetings/daily/ ./daily/

# 機密情報マスキング
find ./daily -name "*.md" -type f -newer .last-sync 2>/dev/null | while read file; do
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
    
    # 人名マスキング（プライバシー保護）
    sed -i.bak 's/小川真平/[CEO]/g' "$file"
    
    # バックアップファイル削除
    rm -f "$file.bak"
done

# 変更があればcommit & push
if [[ -n $(git status --porcelain) ]]; then
    git add .
    git commit -m "📝 議事録自動更新: $(date +%Y-%m-%d_%H:%M)"
    git push origin main
    echo "✅ 議事録自動公開完了: $(date)"
else
    echo "ℹ️  新しい議事録なし: $(date)"
fi

# 最終同期時刻記録
touch .last-sync