#!/usr/bin/env python3
"""
機密議事録監視・アラートシステム
再発防止のためのリアルタイム監視
"""

import os
import re
import json
import time
import requests
from datetime import datetime
import subprocess

class ConfidentialMonitor:
    def __init__(self):
        self.repo_path = "/Users/ogawashinpei/openclaw-public-meetings"
        self.daily_path = f"{self.repo_path}/daily"
        self.log_file = f"{self.repo_path}/monitor-log.json"
        
        # 機密パターン定義
        self.confidential_patterns = {
            "names": [
                r"Ogawa Shimpei", r"小川真平", r"しんぺー",
                r"ジュンヤ", r"ヒロキ", r"ミル"
            ],
            "financial": [
                r"\d+万円", r"\d+億円", r"手切れ金", r"退職金",
                r"BTC.*\d+\.\d+.*枚", r"SOL.*\d+\.\d+.*枚"
            ],
            "strategic": [
                r"関係解消", r"人事再編", r"戦略会議", r"機密情報",
                r"対立", r"解雇", r"派遣決定", r"内部.*問題"
            ],
            "dates": [
                r"meeting_2026-03-09", r"2026-03-09"
            ]
        }
        
        # Discord Webhook URL（環境変数から）
        self.webhook_url = os.getenv('DISCORD_WEBHOOK_URL')
    
    def scan_files(self):
        """議事録ファイルスキャン実行"""
        print(f"🔍 機密スキャン開始: {datetime.now()}")
        
        scan_results = {
            "timestamp": datetime.now().isoformat(),
            "total_files": 0,
            "confidential_files": [],
            "clean_files": [],
            "deleted_files": []
        }
        
        if not os.path.exists(self.daily_path):
            print("❌ daily/ ディレクトリが存在しません")
            return scan_results
        
        # ファイルスキャン
        for filename in os.listdir(self.daily_path):
            if filename.endswith('.md'):
                scan_results["total_files"] += 1
                file_path = os.path.join(self.daily_path, filename)
                
                confidential_info = self.check_confidential(file_path, filename)
                
                if confidential_info["is_confidential"]:
                    scan_results["confidential_files"].append({
                        "filename": filename,
                        "issues": confidential_info["issues"],
                        "severity": confidential_info["severity"]
                    })
                    
                    # 高リスクファイルは即座削除
                    if confidential_info["severity"] == "CRITICAL":
                        self.delete_file(file_path, filename)
                        scan_results["deleted_files"].append(filename)
                        
                else:
                    scan_results["clean_files"].append(filename)
        
        # 結果保存
        self.save_scan_results(scan_results)
        
        # アラート送信
        if scan_results["confidential_files"] or scan_results["deleted_files"]:
            self.send_alert(scan_results)
        
        return scan_results
    
    def check_confidential(self, file_path, filename):
        """ファイルの機密性チェック"""
        result = {
            "is_confidential": False,
            "issues": [],
            "severity": "LOW"
        }
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # パターンマッチング
            for category, patterns in self.confidential_patterns.items():
                for pattern in patterns:
                    matches = re.findall(pattern, content, re.IGNORECASE)
                    if matches:
                        result["is_confidential"] = True
                        result["issues"].append({
                            "category": category,
                            "pattern": pattern,
                            "matches": len(matches),
                            "examples": matches[:3]  # 最初の3例のみ
                        })
                        
                        # 重要度判定
                        if category in ["names", "financial"]:
                            result["severity"] = "CRITICAL"
                        elif category == "strategic":
                            result["severity"] = "HIGH"
                        elif category == "dates" and "2026-03-09" in filename:
                            result["severity"] = "CRITICAL"
                            
        except Exception as e:
            print(f"❌ ファイル読み込みエラー: {filename} - {e}")
            
        return result
    
    def delete_file(self, file_path, filename):
        """機密ファイル削除"""
        try:
            os.remove(file_path)
            print(f"🗑️  CRITICAL削除: {filename}")
            
            # Git操作
            os.chdir(self.repo_path)
            subprocess.run(['git', 'add', '-A'], check=True)
            subprocess.run([
                'git', 'commit', '-m', 
                f'🛡️ 自動機密削除: {filename} - {datetime.now().strftime("%Y-%m-%d %H:%M")}'
            ], check=True)
            subprocess.run(['git', 'push', 'origin', 'main'], check=True)
            
            print(f"✅ Git削除完了: {filename}")
            
        except Exception as e:
            print(f"❌ 削除エラー: {filename} - {e}")
    
    def save_scan_results(self, results):
        """スキャン結果保存"""
        try:
            # 既存ログ読み込み
            history = []
            if os.path.exists(self.log_file):
                with open(self.log_file, 'r') as f:
                    history = json.load(f)
            
            # 新しい結果追加（最大100件まで保持）
            history.append(results)
            if len(history) > 100:
                history = history[-100:]
            
            # 保存
            with open(self.log_file, 'w') as f:
                json.dump(history, f, indent=2, ensure_ascii=False)
                
        except Exception as e:
            print(f"❌ ログ保存エラー: {e}")
    
    def send_alert(self, scan_results):
        """Discord アラート送信"""
        if not self.webhook_url:
            print("⚠️  Discord Webhook URL未設定 - アラート送信スキップ")
            return
        
        # アラートメッセージ生成
        embed = {
            "title": "🚨 機密議事録検出アラート",
            "color": 0xFF0000,  # 赤色
            "timestamp": datetime.now().isoformat(),
            "fields": []
        }
        
        if scan_results["deleted_files"]:
            embed["fields"].append({
                "name": "🗑️ 自動削除済み",
                "value": f"{len(scan_results['deleted_files'])}件\n" + 
                        "\n".join([f"• {f}" for f in scan_results["deleted_files"][:5]]),
                "inline": False
            })
        
        if scan_results["confidential_files"]:
            critical_files = [f for f in scan_results["confidential_files"] 
                            if f["severity"] == "CRITICAL"]
            if critical_files:
                embed["fields"].append({
                    "name": "⚠️ 要確認（高リスク）",
                    "value": f"{len(critical_files)}件要手動確認",
                    "inline": True
                })
        
        embed["fields"].append({
            "name": "📊 スキャン結果",
            "value": f"総ファイル: {scan_results['total_files']}\n" +
                    f"クリーン: {len(scan_results['clean_files'])}\n" +
                    f"要注意: {len(scan_results['confidential_files'])}",
            "inline": True
        })
        
        try:
            payload = {
                "content": "<@432449127935246337> 機密議事録検出",
                "embeds": [embed]
            }
            
            response = requests.post(self.webhook_url, json=payload, timeout=10)
            if response.status_code == 204:
                print("✅ Discord アラート送信完了")
            else:
                print(f"❌ Discord アラート送信失敗: {response.status_code}")
                
        except Exception as e:
            print(f"❌ Discord アラート送信エラー: {e}")
    
    def run_monitoring(self, interval=300):
        """継続監視実行（5分間隔）"""
        print(f"🛡️ 機密監視システム開始 - {interval}秒間隔")
        
        while True:
            try:
                results = self.scan_files()
                
                print(f"📊 スキャン完了: "
                      f"総数{results['total_files']} "
                      f"機密{len(results['confidential_files'])} "
                      f"削除{len(results['deleted_files'])}")
                
                time.sleep(interval)
                
            except KeyboardInterrupt:
                print("\n🛑 監視停止")
                break
            except Exception as e:
                print(f"❌ 監視エラー: {e}")
                time.sleep(60)  # エラー時は1分待機

def main():
    monitor = ConfidentialMonitor()
    
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == "scan":
        # 単発スキャン
        results = monitor.scan_files()
        print(json.dumps(results, indent=2, ensure_ascii=False))
    else:
        # 継続監視
        monitor.run_monitoring()

if __name__ == "__main__":
    main()