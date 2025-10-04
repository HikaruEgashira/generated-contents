# Become Zero MV

このリポジトリは、Remotion で制作した「Become Zero」ミュージックビデオのソースです。必要なファイルは `become-zero-mv/` ディレクトリにまとまっています。

## 使い始める

```bash
cd become-zero-mv
npm install
```

Remotion 4 系と React 19 を利用しているため、Node.js 18 以上を推奨します。

## よく使うコマンド

- `npm run dev` – Remotion Studio を起動（プレビュー用）
- `npm run build` – 静的バンドルを生成
- `npm run lint` – ESLint と TypeScript チェックを実行
- `npx remotion render` – `MyComp` をレンダリング

## フォルダ概要

```
become-zero-mv/
├── public/      入力メディア
├── src/         コンポーネント群
├── package.json スクリプト・依存関係
└── ...
```
