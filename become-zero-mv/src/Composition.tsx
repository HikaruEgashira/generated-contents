import { Video, Audio, Loop, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import { useAudioData, visualizeAudio } from "@remotion/media-utils";

export const MyComposition = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // 音声データを取得
  const audioData = useAudioData(staticFile("becomezero.wav"));

  // 音声の振幅を可視化（低音域でビート検出）
  const visualization = audioData
    ? visualizeAudio({
        fps,
        frame,
        audioData,
        numberOfSamples: 256,
      })
    : new Array(256).fill(0);

  // 低音域（スネア・キック）の平均振幅を計算
  const bassRange = visualization.slice(0, 20);
  const bassAverage = bassRange.reduce((a, b) => a + b, 0) / bassRange.length;

  // 閾値を超えたらビート検出（閾値を下げて感度を上げる）
  const isBeat = bassAverage > 0.05;

  // フラッシュの色をビビットカラーでローテーション（光として強調）
  const colors = [
    "#FF00FF",    // マゼンタ
    "#00FF00",    // グリーン
    "#00FFFF",    // シアン
    "#FF0066",    // ピンク
    "#9900FF",    // バイオレット
  ];

  const colorIndex = Math.floor(frame / 18) % colors.length;
  const flashIntensity = isBeat ? bassAverage * 1.2 : 0;

  // グリッチエフェクト（音の強さに応じて発生）
  const isGlitch = bassAverage > 0.2;
  const glitchOffset = isGlitch ? (bassAverage - 0.2) * 30 - 5 : 0;
  const rgbSplit = bassAverage > 0.1 ? bassAverage * 8 : 0;

  // モーションブラー効果（音の強さに応じて）
  const motionBlur = bassAverage > 0.08 ? bassAverage * 5 : 0;

  // レンズフレア効果（強いビート時）
  const isFlare = bassAverage > 0.15;
  const flareIntensity = isFlare ? (bassAverage - 0.15) * 3 : 0;

  return (
    <div style={{ position: "relative", width: "100%", height: "100%", backgroundColor: "black" }}>
      <Loop durationInFrames={280}>
        <Video
          src={staticFile("movie.mp4")}
          volume={0}
          style={{
            transform: isGlitch ? `translate(${glitchOffset}px, ${glitchOffset}px)` : "none",
            filter: `drop-shadow(${rgbSplit}px 0 0 red) drop-shadow(-${rgbSplit}px 0 0 cyan) blur(${motionBlur}px) sepia(0.1) contrast(1.15) brightness(0.95) saturate(1.1)`,
          }}
        />
      </Loop>

      {/* カラーグレーディング: ティールアンドオレンジ */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "100%",
          height: "100%",
          background: "linear-gradient(180deg, rgba(0, 100, 150, 0.08) 0%, rgba(255, 140, 0, 0.06) 100%)",
          mixBlendMode: "overlay",
          pointerEvents: "none",
        }}
      />
      {/* ビネット効果 */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "100%",
          height: "100%",
          background: "radial-gradient(ellipse at center, transparent 20%, rgba(0,0,0,0.9) 100%)",
          pointerEvents: "none",
        }}
      />

      {/* ビビットフラッシュエフェクト（光として強調） */}
      {isBeat && (
        <div
          style={{
            position: "absolute",
            top: 0,
            left: 0,
            width: "100%",
            height: "100%",
            backgroundColor: colors[colorIndex],
            opacity: flashIntensity,
            mixBlendMode: "screen",
            pointerEvents: "none",
            boxShadow: `inset 0 0 150px ${colors[colorIndex]}`,
          }}
        />
      )}

      {/* レンズフレアエフェクト */}
      {isFlare && (
        <>
          <div
            style={{
              position: "absolute",
              top: "50%",
              left: "50%",
              width: "200px",
              height: "200px",
              transform: "translate(-50%, -50%)",
              borderRadius: "50%",
              background: `radial-gradient(circle, ${colors[colorIndex]} 0%, transparent 70%)`,
              opacity: flareIntensity,
              pointerEvents: "none",
              filter: "blur(20px)",
            }}
          />
          <div
            style={{
              position: "absolute",
              top: "30%",
              left: "70%",
              width: "100px",
              height: "100px",
              borderRadius: "50%",
              background: `radial-gradient(circle, ${colors[colorIndex]} 0%, transparent 70%)`,
              opacity: flareIntensity * 0.6,
              pointerEvents: "none",
              filter: "blur(15px)",
            }}
          />
          <div
            style={{
              position: "absolute",
              top: "70%",
              left: "30%",
              width: "80px",
              height: "80px",
              borderRadius: "50%",
              background: `radial-gradient(circle, ${colors[colorIndex]} 0%, transparent 70%)`,
              opacity: flareIntensity * 0.5,
              pointerEvents: "none",
              filter: "blur(10px)",
            }}
          />
        </>
      )}

      {/* シネマティックアスペクト比（2.39:1の黒帯） */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "100%",
          height: "12%",
          backgroundColor: "black",
          pointerEvents: "none",
          zIndex: 1000,
        }}
      />
      <div
        style={{
          position: "absolute",
          bottom: 0,
          left: 0,
          width: "100%",
          height: "12%",
          backgroundColor: "black",
          pointerEvents: "none",
          zIndex: 1000,
        }}
      />

      <Audio src={staticFile("becomezero.wav")} />
    </div>
  );
};
