#!/bin/bash
# 緊急機密情報マスキング処理

TARGET_FILE="daily/meeting_2026-03-09__2026_03_08_17_28_PDT_に開始した会議___Gemini_によるメモ.md"

echo "🚨 緊急機密情報マスキング処理開始"
echo "対象ファイル: $TARGET_FILE"

# 人名の緊急マスキング
echo "🔒 人名マスキング..."
sed -i.bak 's/Ogawa Shimpei/[CEO]/g' "$TARGET_FILE"
sed -i.bak 's/小川真平/[CEO]/g' "$TARGET_FILE"
sed -i.bak 's/しんぺー/[CEO]/g' "$TARGET_FILE"
sed -i.bak 's/ジュンヤ/[EMPLOYEE_A]/g' "$TARGET_FILE"
sed -i.bak 's/ヒロキ/[EMPLOYEE_B]/g' "$TARGET_FILE"  
sed -i.bak 's/ミル/[EMPLOYEE_C]/g' "$TARGET_FILE"
sed -i.bak 's/KE U/[PARTICIPANT]/g' "$TARGET_FILE"
sed -i.bak 's/\bR（/[PARTICIPANT]（/g' "$TARGET_FILE"

# 金銭情報マスキング
echo "💰 金銭情報マスキング..."
sed -i.bak 's/20万円/[REDACTED]万円/g' "$TARGET_FILE"
sed -i.bak 's/[0-9]\+万円/[REDACTED]万円/g' "$TARGET_FILE"
sed -i.bak 's/[0-9]\+億円/[REDACTED]億円/g' "$TARGET_FILE"
sed -i.bak 's/[0-9]\+千万円/[REDACTED]千万円/g' "$TARGET_FILE"
sed -i.bak 's/手切れ金/[CONFIDENTIAL_PAYMENT]/g' "$TARGET_FILE"
sed -i.bak 's/退職金/[CONFIDENTIAL_PAYMENT]/g' "$TARGET_FILE"

# 場所・地名マスキング
echo "📍 地名マスキング..."
sed -i.bak 's/マレーシア/[OVERSEAS_LOCATION]/g' "$TARGET_FILE"
sed -i.bak 's/白馬/[LOCATION]/g' "$TARGET_FILE"

# 事業情報マスキング  
echo "🏢 事業情報マスキング..."
sed -i.bak 's/美容室向けAI自動化SaaS/美容室向け[BUSINESS]/g' "$TARGET_FILE"
sed -i.bak 's/バケーションレンタル事業/宿泊[BUSINESS]/g' "$TARGET_FILE"
sed -i.bak 's/投資助言業/投資[BUSINESS]/g' "$TARGET_FILE"
sed -i.bak 's/ファクタリング/[FINANCIAL_BUSINESS]/g' "$TARGET_FILE"

# 投資・暗号通貨情報マスキング
echo "💎 投資情報マスキング..."
sed -i.bak 's/BTC.*[0-9]\+\.[0-9]\+.*枚/BTC [REDACTED]枚/g' "$TARGET_FILE"
sed -i.bak 's/SOL.*[0-9]\+\.[0-9]\+.*枚/SOL [REDACTED]枚/g' "$TARGET_FILE"
sed -i.bak 's/HYPE.*[0-9]\+\.[0-9]\+/HYPE [REDACTED]/g' "$TARGET_FILE"
sed -i.bak 's/ZKP.*[0-9]\+,[0-9]\+/ZKP [REDACTED]/g' "$TARGET_FILE"

# 機密戦略情報マスキング
echo "🔐 戦略情報マスキング..."
sed -i.bak 's/関係解消/[CONFIDENTIAL_DECISION]/g' "$TARGET_FILE"
sed -i.bak 's/人事体制再編/[HR_RESTRUCTURING]/g' "$TARGET_FILE"
sed -i.bak 's/新人材採用/[HR_STRATEGY]/g' "$TARGET_FILE"

# IP・技術情報マスキング
echo "🖥️ 技術情報マスキング..."
sed -i.bak 's/46\.62\.253\.219/[IP_ADDRESS]/g' "$TARGET_FILE"
sed -i.bak 's/openclaw260228/[SERVER]/g' "$TARGET_FILE"

# バックアップ削除
rm -f "$TARGET_FILE.bak"

echo "✅ 緊急マスキング処理完了"
echo "📋 処理結果確認:"
head -20 "$TARGET_FILE"