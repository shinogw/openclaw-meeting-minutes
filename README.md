# OpenClaw Meeting Minutes (Public)

## 概要
しんぺーのOpenClaw議事録システムが自動生成した会議記録です。

## 特徴
- Google Meet自動文字起こし
- Gemini AI構造化処理
- 完全自動GitHub保存
- 事業文脈理解・アクションアイテム抽出

## 構造
```
daily/                    # 日次議事録
weekly/                   # 週次戦略会議
archive/                  # 過去の議事録
README.md                 # このファイル
```

## 自動化システム
1. Google Meet会議終了
2. Google Drive文字起こし自動保存
3. Google Apps Script 5分間隔監視
4. Webhook → Gemini構造化
5. GitHub自動保存・Memory格納

## データプライバシー
- 機密情報は自動マスキング処理済み
- 投資詳細・財務情報・個人情報は除外
- 公開可能な戦略・技術・プロジェクト情報のみ

---
*Powered by OpenClaw AI Agent System*
*自動更新: 毎日*
