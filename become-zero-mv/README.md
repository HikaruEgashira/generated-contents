# Become Zero MV

このリポジトリは、Remotion で制作した「Become Zero」ミュージックビデオのソースです。必要なファイルは `become-zero-mv/` ディレクトリにまとまっています。

## 使い始める

```bash
cd become-zero-mv
mise install
mise exec bun -- bun install
# direnv を使う場合はこのディレクトリで `direnv allow` を実行
```

Remotion 4 系と React 19 を利用しています。`mise` が Bun (1.2.21) を取得するため、Node.js を個別に用意する必要はありません。

## よく使うコマンド

- `mise exec bun -- bun run dev` – Remotion Studio を起動（プレビュー用）
- `mise exec bun -- bun run build` – 静的バンドルを生成
- `mise exec bun -- bun run lint` – ESLint と TypeScript チェックを実行
- `mise exec bun -- bun x remotion render` – `MyComp` をレンダリング（`--sequence` 等も同様）

## フォルダ概要

```
become-zero-mv/
├── public/      入力メディア
├── src/         コンポーネント群
├── package.json スクリプト・依存関係
└── ...
```
