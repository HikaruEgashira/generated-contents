#!/usr/bin/env nu
# プロジェクトジェネレーター
# 使い方: ./scripts/create-project.nu <音源ファイル> <動画ファイル> <出力ディレクトリ>

def main [audio_file: string, video_file: string, output_dir: string] {
  # ファイルの存在確認
  if not ($audio_file | path exists) {
    error make {msg: $"エラー: 音源ファイルが見つかりません: ($audio_file)"}
  }

  if not ($video_file | path exists) {
    error make {msg: $"エラー: 動画ファイルが見つかりません: ($video_file)"}
  }

  # 出力ディレクトリの確認
  if ($output_dir | path exists) {
    error make {msg: $"エラー: 出力ディレクトリが既に存在します: ($output_dir)"}
  }

  print $"📦 プロジェクトを作成中: ($output_dir)"

  # 現在のプロジェクト構造の場所を特定
  let script_dir = $env.CURRENT_FILE | path dirname
  let project_root = $script_dir | path join ".." | path expand

  # プロジェクトのスケルトンを作成
  mkdir ($output_dir | path join "src")
  mkdir ($output_dir | path join "public")

  # 必要なファイルのみコピー
  let files = [
    "package.json"
    "tsconfig.json"
    "remotion.config.ts"
    "eslint.config.mjs"
    "postcss.config.mjs"
    ".prettierrc"
    ".gitignore"
    ".mise.toml"
    "README.md"
  ]

  for file in $files {
    let src = $project_root | path join $file
    let dst = $output_dir | path join $file
    if ($src | path exists) {
      cp $src $dst
    }
  }

  # .envrcをコピー（存在すれば）
  let envrc = $project_root | path join ".envrc"
  if ($envrc | path exists) {
    cp $envrc ($output_dir | path join ".envrc")
  }

  # src配下の必要なファイルをコピー
  let src_files = ["index.ts" "index.css"]
  for file in $src_files {
    let src = $project_root | path join "src" $file
    let dst = $output_dir | path join "src" $file
    if ($src | path exists) {
      cp $src $dst
    }
  }

  print "🎵 音源を処理中..."
  # 音源をWAVに変換
  let audio_output = $output_dir | path join "public" "audio.wav"
  ffmpeg -i $audio_file -ar 44100 -ac 2 $audio_output -y
    | complete
    | if $in.exit_code != 0 {
        error make {msg: $"音源の変換に失敗: ($in.stderr)"}
      }

  print "🎬 動画を処理中..."
  # 動画情報を取得
  let video_info = (
    ffprobe -v error -select_streams v:0
      -show_entries stream=width,height,r_frame_rate,duration
      -of json $video_file
    | complete
    | if $in.exit_code != 0 {
        error make {msg: $"動画情報の取得に失敗: ($in.stderr)"}
      } else {
        $in.stdout | from json
      }
  )

  let stream = $video_info.streams.0
  let width = $stream.width
  let height = $stream.height
  let fps_raw = $stream.r_frame_rate
  let video_duration = $stream.duration | into float

  # FPS計算
  let fps = if ($fps_raw | str contains "/") {
    let parts = $fps_raw | split row "/"
    let numerator = $parts.0 | into float
    let denominator = $parts.1 | into float
    $numerator / $denominator | math round
  } else {
    $fps_raw | into float | math round
  }

  # 音源の長さを取得
  let audio_info = (
    ffprobe -v error -show_entries format=duration -of json $audio_file
    | complete
    | if $in.exit_code != 0 {
        error make {msg: $"音源情報の取得に失敗: ($in.stderr)"}
      } else {
        $in.stdout | from json
      }
  )

  let audio_duration = $audio_info.format.duration | into float

  # 短い方を使用
  let duration = if $audio_duration < $video_duration { $audio_duration } else { $video_duration }
  let duration_in_frames = $duration * $fps | math round
  let video_duration_in_frames = $video_duration * $fps | math round

  # 動画をコピー
  let video_output = $output_dir | path join "public" "video.mp4"
  cp $video_file $video_output

  print "✍️  設定ファイルを生成中..."

  # Root.tsx を生成
  let root_content = $"import \"./index.css\";
import { Composition } from \"remotion\";
import { MyComposition } from \"./Composition\";

export const RemotionRoot: React.FC = \(\) => {
  return \(
    <>
      <Composition
        id=\"MyComp\"
        component={MyComposition}
        durationInFrames={($duration_in_frames)}
        fps={($fps)}
        width={($width)}
        height={($height)}
      />
    </>
  \);
};
"

  $root_content | save -f ($output_dir | path join "src" "Root.tsx")

  # Composition.tsx を生成
  let composition_content = $"import { Video, Audio, Loop, staticFile } from \"remotion\";

export const MyComposition = \(\) => {
  return \(
    <div style={{ position: \"relative\", width: \"100%\", height: \"100%\", backgroundColor: \"black\" }}>
      <Loop durationInFrames={($video_duration_in_frames)}>
        <Video
          src={staticFile\(\"video.mp4\"\)}
          volume={0}
        />
      </Loop>
      <Audio src={staticFile\(\"audio.wav\"\)} />
    </div>
  \);
};
"

  $composition_content | save -f ($output_dir | path join "src" "Composition.tsx")

  print $"✅ プロジェクト作成完了: ($output_dir)"
  print ""
  print "設定情報:"
  print $"  - 解像度: ($width)x($height)"
  print $"  - FPS: ($fps)"
  print $"  - 尺: ($duration)秒 \(($duration_in_frames)フレーム\)"
  print $"  - 動画ループ: ($video_duration_in_frames)フレーム"
  print ""
  print "次のステップ:"
  print $"  1. cd ($output_dir)"
  print "  2. mise exec bun -- bun install"
  print "  3. mise exec bun -- bun run dev"
}
