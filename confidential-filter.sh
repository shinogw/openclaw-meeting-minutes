#!/bin/bash
# 機密議事録フィルタリング（公開対象外判定）

check_confidentiality() {
    local file="$1"
    local filename=$(basename "$file")
    
    # 機密キーワードパターンチェック
    CONFIDENTIAL_PATTERNS=(
        "人事.*再編"
        "関係解消"
        "手切れ金"
        "退職金"
        "解雇"
        "派遣決定"
        "対立"
        "外部リスク"
        "戦略会議"
        "人事決定"
        "事業体制検討"
        "機密情報注意"
        "経営戦略"
        "労務"
        "内部.*問題"
        "チーム.*対立"
        "メンバー.*解消"
    )
    
    echo "🔍 機密性チェック: $(basename "$file")"
    
    for pattern in "${CONFIDENTIAL_PATTERNS[@]}"; do
        if grep -q "$pattern" "$file" 2>/dev/null; then
            echo "❌ 機密パターン検出: $pattern"
            echo "🚨 このファイルは公開対象外です"
            return 1  # 機密ファイル（公開不可）
        fi
    done
    
    # ファイル名でのチェック
    if [[ "$filename" =~ 人事|戦略|機密|内部|対立|解消 ]]; then
        echo "❌ ファイル名に機密キーワード含有"
        echo "🚨 このファイルは公開対象外です"
        return 1
    fi
    
    echo "✅ 公開可能ファイルです"
    return 0  # 公開可能
}

# 使用例
if [ "$1" ]; then
    check_confidentiality "$1"
    exit $?
fi