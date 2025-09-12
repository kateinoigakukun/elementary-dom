OUTDIR=Public/lib/swiftle-node
SWIFT_BIN=/Users/katei/Library/Developer/Toolchains/swift-6.2-DEVELOPMENT-SNAPSHOT-2025-08-30-a.xctoolchain/usr/bin
SWIFT_SDK_ID=6.2-SNAPSHOT-2025-08-30-a-wasm32-unknown-wasip1

set -ex
rm -rf $OUTDIR

$SWIFT_BIN/swift package \
  --swift-sdk "${SWIFT_SDK_ID:-$(swiftc -print-target-info | jq -r '.swiftCompilerTag')_wasm}" \
  --enable-experimental-prebuilts \
  --allow-writing-to-package-directory \
  js -c release --output $OUTDIR --debug-info-format dwarf --no-optimize
