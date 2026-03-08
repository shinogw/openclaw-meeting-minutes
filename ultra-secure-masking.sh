#!/bin/bash
# OpenClaw議事録 - 超厳格マスキング処理

# 対象ファイル処理
process_file() {
    local file="$1"
    echo "🔒 厳格マスキング処理: $(basename "$file")"
    
    # 人名の完全マスキング
    sed -i.bak 's/小川真平/[CEO]/g' "$file"
    sed -i.bak 's/Ogawa Shimpei/[CEO]/g' "$file" 
    sed -i.bak 's/しんぺー/[CEO]/g' "$file"
    sed -i.bak 's/\baki\b/[PARTICIPANT]/g' "$file"
    sed -i.bak 's/小川/[CEO]/g' "$file"
    
    # 投資情報の完全マスキング
    sed -i.bak 's/BTC.*[0-9]\+\.[0-9]\+.*枚/BTC [REDACTED]枚/g' "$file"
    sed -i.bak 's/SOL.*[0-9]\+\.[0-9]\+.*枚/SOL [REDACTED]枚/g' "$file"
    sed -i.bak 's/HYPE.*[0-9]\+\.[0-9]\+/HYPE [REDACTED]/g' "$file"
    sed -i.bak 's/ZKP.*[0-9]\+,[0-9]\+/ZKP [REDACTED]/g' "$file"
    
    # 金額・数値の完全マスキング
    sed -i.bak 's/[0-9]\+万円/[REDACTED]万円/g' "$file"
    sed -i.bak 's/[0-9]\+億円/[REDACTED]億円/g' "$file"
    sed -i.bak 's/[0-9]\+千万円/[REDACTED]千万円/g' "$file"
    sed -i.bak 's/[0-9]\+\.[0-9]\+枚/[REDACTED]枚/g' "$file"
    sed -i.bak 's/\$[0-9,]\+/\$[REDACTED]/g' "$file"
    
    # 事業機密情報マスキング
    sed -i.bak 's/美容室向けAI自動化SaaS/美容室向け[BUSINESS]/g' "$file"
    sed -i.bak 's/バケーションレンタル事業/宿泊[BUSINESS]/g' "$file"
    sed -i.bak 's/投資助言業買収/[BUSINESS]買収/g' "$file"
    sed -i.bak 's/ファクタリング/[FINANCIAL_BUSINESS]/g' "$file"
    
    # 地名・場所の部分マスキング
    sed -i.bak 's/白馬/[LOCATION]/g' "$file"
    
    # IP・技術的機密
    sed -i.bak 's/46\.62\.253\.219/[IP_ADDRESS]/g' "$file"
    sed -i.bak 's/openclaw260228/[SERVER]/g' "$file"
    
    # メールアドレス・個人識別子
    sed -i.bak 's/[a-zA-Z0-9._%+-]\+@[a-zA-Z0-9.-]\+\.[a-zA-Z]{2,}/[EMAIL]/g' "$file"
    
    # 電話番号パターン
    sed -i.bak 's/[0-9]\{3\}-[0-9]\{4\}-[0-9]\{4\}/[PHONE]/g' "$file"
    sed -i.bak 's/[0-9]\{11\}/[PHONE]/g' "$file"
    
    # バックアップファイル削除
    rm -f "$file.bak"
}

# 全議事録ファイルを処理
find /Users/ogawashinpei/openclaw-public-meetings/daily -name "*.md" -type f | while read file; do
    process_file "$file"
done

echo "✅ 厳格マスキング処理完了"