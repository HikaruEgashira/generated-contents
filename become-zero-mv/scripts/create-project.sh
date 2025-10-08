#!/usr/bin/env bash
set -euo pipefail

# プロジェクトジェネレーター
# 使い方: ./scripts/create-project.sh <音源ファイル> <動画ファイル> <出力ディレクトリ>

if [ $# -ne 3 ]; then
  echo "使い方: $0 <音源ファイル> <動画ファイル> <出力ディレクトリ>"
  echo "例: $0 audio.mp3 video.mp4 ../my-new-mv"
  exit 1
fi

AUDIO_FILE="$1"
VIDEO_FILE="$2"
OUTPUT_DIR="$3"

# ファイルの存在確認
if [ ! -f "$AUDIO_FILE" ]; then
  echo "エラー: 音源ファイルが見つかりません: $AUDIO_FILE"
  exit 1
fi

if [ ! -f "$VIDEO_FILE" ]; then
  echo "エラー: 動画ファイルが見つかりません: $VIDEO_FILE"
  exit 1
fi

# 出力ディレクトリの作成
if [ -d "$OUTPUT_DIR" ]; then
  echo "エラー: 出力ディレクトリが既に存在します: $OUTPUT_DIR"
  exit 1
fi

echo "📦 プロジェクトを作成中: $OUTPUT_DIR"

# 現在のプロジェクト構造の場所を特定
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# プロジェクトのスケルトンを作成
mkdir -p "$OUTPUT_DIR"/{src,public}

# 必要なファイルのみコピー
cp "$PROJECT_ROOT/package.json" "$OUTPUT_DIR/"
cp "$PROJECT_ROOT/tsconfig.json" "$OUTPUT_DIR/"
cp "$PROJECT_ROOT/remotion.config.ts" "$OUTPUT_DIR/"
cp "$PROJECT_ROOT/eslint.config.mjs" "$OUTPUT_DIR/"
cp "$PROJECT_ROOT/postcss.config.mjs" "$OUTPUT_DIR/"
cp "$PROJECT_ROOT/.prettierrc" "$OUTPUT_DIR/"
cp "$PROJECT_ROOT/.gitignore" "$OUTPUT_DIR/"
cp "$PROJECT_ROOT/.mise.toml" "$OUTPUT_DIR/"
cp "$PROJECT_ROOT/.envrc" "$OUTPUT_DIR/" 2>/dev/null || true
cp "$PROJECT_ROOT/README.md" "$OUTPUT_DIR/"

# src配下の必要なファイルをコピー（後で上書きするので index.ts と index.css のみ）
cp "$PROJECT_ROOT/src/index.ts" "$OUTPUT_DIR/src/"
cp "$PROJECT_ROOT/src/index.css" "$OUTPUT_DIR/src/" 2>/dev/null || true

echo "🎵 音源を処理中..."
# 音源をWAVに変換（Remotionとの互換性のため）
ffmpeg -i "$AUDIO_FILE" -ar 44100 -ac 2 "$OUTPUT_DIR/public/audio.wav" -y

echo "🎬 動画を処理中..."
# 動画情報を取得
VIDEO_INFO=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height,r_frame_rate,duration -of json "$VIDEO_FILE")
WIDTH=$(echo "$VIDEO_INFO" | jq -r '.streams[0].width')
HEIGHT=$(echo "$VIDEO_INFO" | jq -r '.streams[0].height')
FPS_RAW=$(echo "$VIDEO_INFO" | jq -r '.streams[0].r_frame_rate')
VIDEO_DURATION=$(echo "$VIDEO_INFO" | jq -r '.streams[0].duration')

# FPS計算（分数形式の場合）
if [[ "$FPS_RAW" == *"/"* ]]; then
  FPS=$(echo "$FPS_RAW" | awk -F'/' '{printf "%.0f", $1/$2}')
else
  FPS=$(echo "$FPS_RAW" | awk '{printf "%.0f", $1}')
fi

# 音源の長さを取得
AUDIO_INFO=$(ffprobe -v error -show_entries format=duration -of json "$AUDIO_FILE")
AUDIO_DURATION=$(echo "$AUDIO_INFO" | jq -r '.format.duration')

# 短い方を使用
if (( $(echo "$AUDIO_DURATION < $VIDEO_DURATION" | bc -l) )); then
  DURATION=$AUDIO_DURATION
else
  DURATION=$VIDEO_DURATION
fi

# フレーム数計算
DURATION_IN_FRAMES=$(echo "$DURATION * $FPS" | bc | awk '{printf "%.0f", $1}')
VIDEO_DURATION_IN_FRAMES=$(echo "$VIDEO_DURATION * $FPS" | bc | awk '{printf "%.0f", $1}')

# 動画をコピー（必要に応じて再エンコード）
cp "$VIDEO_FILE" "$OUTPUT_DIR/public/video.mp4"

echo "✍️  設定ファイルを生成中..."
# Root.tsx を更新
cat > "$OUTPUT_DIR/src/Root.tsx" <<EOF
import "./index.css";
import { Composition } from "remotion";
import { MyComposition } from "./Composition";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="MyComp"
        component={MyComposition}
        durationInFrames={$DURATION_IN_FRAMES}
        fps={$FPS}
        width={$WIDTH}
        height={$HEIGHT}
      />
    </>
  );
};
EOF

# Composition.tsx を更新（エフェクトなし）
cat > "$OUTPUT_DIR/src/Composition.tsx" <<EOF
import { Video, Audio, Loop, staticFile } from "remotion";

export const MyComposition = () => {
  return (
    <div style={{ position: "relative", width: "100%", height: "100%", backgroundColor: "black" }}>
      <Loop durationInFrames={$VIDEO_DURATION_IN_FRAMES}>
        <Video
          src={staticFile("video.mp4")}
          volume={0}
        />
      </Loop>
      <Audio src={staticFile("audio.wav")} />
    </div>
  );
};
EOF

echo "✅ プロジェクト作成完了: $OUTPUT_DIR"
echo ""
echo "設定情報:"
echo "  - 解像度: ${WIDTH}x${HEIGHT}"
echo "  - FPS: $FPS"
echo "  - 尺: ${DURATION}秒 (${DURATION_IN_FRAMES}フレーム)"
echo "  - 動画ループ: ${VIDEO_DURATION_IN_FRAMES}フレーム"
echo ""
echo "次のステップ:"
echo "  1. cd $OUTPUT_DIR"
echo "  2. mise exec bun -- bun install"
echo "  3. mise exec bun -- bun run dev"
