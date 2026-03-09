#!/bin/bash
# 機密議事録自動削除システム（再発防止）

REPO_PATH="/Users/ogawashinpei/openclaw-public-meetings"
LOG_FILE="$REPO_PATH/deletion-log.txt"

cd "$REPO_PATH"

echo "🔍 機密議事録スキャン開始: $(date)" | tee -a "$LOG_FILE"

# 削除すべき日付・パターン定義
DELETION_PATTERNS=(
    "meeting_2026-03-09*"
    "*人事*"
    "*戦略会議*"
    "*機密*"
    "*内部*"
    "*対立*"
    "*解雇*"
    "*退職金*"
    "*手切れ金*"
)

DELETED_COUNT=0
TOTAL_FILES=$(find daily/ -name "*.md" | wc -l)

echo "📊 議事録ファイル総数: $TOTAL_FILES" | tee -a "$LOG_FILE"

# パターンマッチング削除
for pattern in "${DELETION_PATTERNS[@]}"; do
    echo "🔍 パターン検索: $pattern" | tee -a "$LOG_FILE"
    
    for file in daily/$pattern; do
        if [[ -f "$file" ]]; then
            echo "🗑️  削除実行: $(basename "$file")" | tee -a "$LOG_FILE"
            rm -f "$file"
            ((DELETED_COUNT++))
        fi
    done
done

# 内容ベース削除（機密キーワード）
echo "🔍 内容ベース機密検索..." | tee -a "$LOG_FILE"

CONFIDENTIAL_KEYWORDS=(
    "Ogawa Shimpei"
    "小川真平"
    "ジュンヤ"
    "ヒロキ"
    "ミル"
    "関係解消"
    "人事再編"
    "手切れ金"
    "退職金"
    "20万円"
    "マレーシア派遣"
)

find daily/ -name "*.md" -type f | while read file; do
    FOUND_CONFIDENTIAL=false
    
    for keyword in "${CONFIDENTIAL_KEYWORDS[@]}"; do
        if grep -q "$keyword" "$file" 2>/dev/null; then
            echo "🚨 機密情報検出: $(basename "$file") - キーワード: $keyword" | tee -a "$LOG_FILE"
            FOUND_CONFIDENTIAL=true
            break
        fi
    done
    
    if [ "$FOUND_CONFIDENTIAL" = true ]; then
        echo "🗑️  機密ファイル削除: $(basename "$file")" | tee -a "$LOG_FILE"
        rm -f "$file"
        ((DELETED_COUNT++))
    fi
done

# Git操作（ファイル削除があった場合）
if [ $DELETED_COUNT -gt 0 ]; then
    echo "📝 Git操作実行: $DELETED_COUNT 件削除" | tee -a "$LOG_FILE"
    
    git add -A
    git commit -m "🛡️ 自動機密削除: ${DELETED_COUNT}件除去 - $(date +%Y-%m-%d_%H:%M)"
    git push origin main
    
    echo "✅ Git push完了" | tee -a "$LOG_FILE"
else
    echo "✅ 削除対象なし - クリーンな状態" | tee -a "$LOG_FILE"
fi

# 最終状況報告
FINAL_COUNT=$(find daily/ -name "*.md" | wc -l)
echo "📊 最終結果:" | tee -a "$LOG_FILE"
echo "   削除ファイル数: $DELETED_COUNT" | tee -a "$LOG_FILE"
echo "   残存ファイル数: $FINAL_COUNT" | tee -a "$LOG_FILE"
echo "🔍 機密スキャン完了: $(date)" | tee -a "$LOG_FILE"
echo "===========================================" | tee -a "$LOG_FILE"