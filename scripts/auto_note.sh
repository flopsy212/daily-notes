#!/usr/bin/env bash
set -euo pipefail

# ===== 設定 =====
: "${TZ:=Asia/Tokyo}"               # JST基準
TARGET_FILE="${TARGET_FILE:-notes/english-study.md}"
mkdir -p "$(dirname "$TARGET_FILE")"

# ===== 日付・曜日計算（JST）=====
# %u → 1=Mon ... 7=Sun
DOW=$(TZ=$TZ date +%u)
NOW_DATE=$(TZ=$TZ date +"%Y-%m-%d")
NOW_TIME=$(TZ=$TZ date +"%H:%M:%S %Z")

# ===== コミット回数ルール =====
commit_count=0
if [[ "$DOW" -eq 6 || "$DOW" -eq 7 ]]; then
  # 土日：基本15回以上、たまに10回程度
  # 20%の確率で10〜12回、80%の確率で15〜25回
  roll=$((RANDOM % 100))
  if (( roll < 20 )); then
    commit_count=$(( 10 + RANDOM % 3 ))     # 10..12
  else
    commit_count=$(( 15 + RANDOM % 11 ))    # 15..25
  fi
else
  # 平日：70%の確率で0〜3回、30%の確率で5~10回
  roll=$((RANDOM % 100))
  if (( roll < 70 )); then
    commit_count=$(( 0 + RANDOM % 4 ))       # 0..3
  else
    commit_count=$(( 5 + RANDOM % 6 ))    # 5..10
fi

echo "JST: $NOW_DATE ($NOW_TIME) / DOW=$DOW → commit_count=$commit_count"

# ===== コミット作成 =====
# 1回のワークフロー実行で commit_count 回だけ連続コミットする
for ((i=1; i<=commit_count; i++)); do
  stamp=$(TZ=$TZ date +"%Y-%m-%d %H:%M:%S %Z")
  # 追記内容は“英語学習ノート”の1行メモ（適当に編集OK）
  echo "- [$stamp] auto note $i/$commit_count: studied 5 min." >> "$TARGET_FILE"

  git add "$TARGET_FILE"
  git commit -m "auto: note $NOW_DATE ($i/$commit_count)"

  # 1〜5秒のランダム待機（コミット時刻に揺らぎ）
  sleep $((1 + RANDOM % 5))
done
