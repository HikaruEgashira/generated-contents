# Become Zero MV

このリポジトリは Remotion で制作した「Become Zero」ミュージックビデオのプロジェクトです。`become-zero-mv/` 以下にアセットとソースコードをまとめており、映像のループやオーディオリアクティブな演出を実装しています。

## セットアップ

```bash
npm install
```

> 依存関係は Remotion 4 系と React 19 を利用しています。Node.js 18 以上を推奨します。

## 主なコマンド

| コマンド | 説明 |
| --- | --- |
| `npm run dev` | Remotion Studio を起動し、ブラウザでプレビューします。 |
| `npm run build` | 静的バンドルを生成します。Git では `build/` を無視しています。 |
| `npm run lint` | ESLint と TypeScript チェックを実行します。GPU 関連の警告が表示される場合があります。 |
| `npx remotion render` | `MyComp` をデフォルト設定でレンダリングします。必要に応じて `--sequence` や `--props` を追加してください。 |

## ディレクトリ構成

```
become-zero-mv/
├── public/            # 入力メディア (movie.mp4, becomezero.wav)
├── src/               # Remotion コンポーネント群
├── remotion.config.ts # レンダリング設定
├── package.json       # スクリプトと依存関係
└── ...
```

## 開発のヒント

- `src/Composition.tsx` の `durationInFrames` は元動画に合わせて 280 フレームに調整済みです。
- フィルターやブラーを多用しているため、低スペック環境では `@remotion/slow-css-property` 警告が出ることがあります。パフォーマンス重視ならフィルター強度を下げてください。
- オーディオ解析のサンプル数を減らす (`numberOfSamples`) とレンダリング負荷を抑えられます。

## ライセンスとクレジット

- Remotion のライセンスについては [公式リポジトリ](https://github.com/remotion-dev/remotion/blob/main/LICENSE.md) を参照してください。
- 楽曲および動画素材の権利者に配慮し、公開前に利用条件を確認してください。
