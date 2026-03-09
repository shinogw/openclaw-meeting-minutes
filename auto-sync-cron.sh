#!/bin/bash
# OpenClaw議事録自動同期（cron用） - 強化版再発防止システム統合

cd /Users/ogawashinpei/openclaw-public-meetings

echo "🚀 議事録自動同期開始: $(date)"

# 🛡️ Step 1: 事前機密スキャン・削除
echo "🛡️ 事前機密スキャン実行..."
python3 confidential-monitor.py scan

# 🔄 Step 2: プライベートリポジトリから新しい議事録をコピー
echo "📁 プライベートリポジトリ同期中..."
rsync -av --exclude="archive/" /Users/ogawashinpei/.openclaw/workspace/company-knowledge/Operations/meetings/daily/ ./daily/

# 🚨 Step 3: 機密議事録フィルタリング・マスキング処理
find ./daily -name "*.md" -type f -newer .last-sync 2>/dev/null | while read file; do
    echo "🔍 議事録処理: $(basename "$file")"
    
    # 強化機密性チェック
    if ! ./confidential-filter.sh "$file"; then
        echo "🚨 機密議事録検出: $(basename "$file") - 公開リポジトリから削除"
        rm -f "$file"
        continue
    fi
    
    # 2026-03-09系統の特別チェック
    if [[ "$(basename "$file")" =~ 2026-03-09 ]]; then
        echo "🚨 2026-03-09パターン検出: $(basename "$file") - 強制削除"
        rm -f "$file"
        continue
    fi
    
    echo "✅ 公開可能 - マスキング処理実行: $(basename "$file")"
    
    # 🚨 緊急追加: 人名の厳格マスキング
    sed -i.bak 's/Ogawa Shimpei/[CEO]/g' "$file"
    sed -i.bak 's/小川真平/[CEO]/g' "$file"
    sed -i.bak 's/しんぺー/[CEO]/g' "$file"
    sed -i.bak 's/ジュンヤ/[EMPLOYEE_A]/g' "$file"
    sed -i.bak 's/ヒロキ/[EMPLOYEE_B]/g' "$file"  
    sed -i.bak 's/ミル/[EMPLOYEE_C]/g' "$file"
    sed -i.bak 's/KE U/[PARTICIPANT]/g' "$file"
    sed -i.bak 's/\bR（/[PARTICIPANT]（/g' "$file"
    
    # 投資情報マスキング
    sed -i.bak 's/BTC.*[0-9]\+\.[0-9]\+.*枚/BTC [REDACTED]枚/g' "$file"
    sed -i.bak 's/SOL.*[0-9]\+\.[0-9]\+.*枚/SOL [REDACTED]枚/g' "$file" 
    sed -i.bak 's/HYPE.*[0-9]\+\.[0-9]\+/HYPE [REDACTED]/g' "$file"
    sed -i.bak 's/ZKP.*[0-9]\+,[0-9]\+/ZKP [REDACTED]/g' "$file"
    
    # 金額マスキング
    sed -i.bak 's/20万円/[REDACTED]万円/g' "$file"
    sed -i.bak 's/[0-9]\+万円/[REDACTED]万円/g' "$file"
    sed -i.bak 's/[0-9]\+億円/[REDACTED]億円/g' "$file"
    
    # 🚨 機密戦略情報マスキング
    sed -i.bak 's/手切れ金/[CONFIDENTIAL_PAYMENT]/g' "$file"
    sed -i.bak 's/退職金/[CONFIDENTIAL_PAYMENT]/g' "$file"
    sed -i.bak 's/関係解消/[CONFIDENTIAL_DECISION]/g' "$file"
    sed -i.bak 's/人事体制再編/[HR_RESTRUCTURING]/g' "$file"
    sed -i.bak 's/新人材採用/[HR_STRATEGY]/g' "$file"
    
    # 地名・場所マスキング
    sed -i.bak 's/マレーシア/[OVERSEAS_LOCATION]/g' "$file"
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

# 🛡️ Step 5: 事後機密スキャン・最終確認
echo "🔍 事後機密スキャン実行..."
python3 confidential-monitor.py scan

# 🗑️ Step 6: 緊急削除スクリプト実行
echo "🗑️ 緊急削除チェック実行..."
./auto-delete-confidential.sh

echo "🛡️ 再発防止システム完全実行済み: $(date)"