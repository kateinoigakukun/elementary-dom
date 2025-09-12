OUTDIR=Public/lib/swiftle-node

set -ex
rm -rf $OUTDIR

swift package \
  --swift-sdk "${SWIFT_SDK_ID:-$(swiftc -print-target-info | jq -r '.swiftCompilerTag')_wasm}" \
  --enable-experimental-prebuilts \
  --allow-writing-to-package-directory \
  js -c release --output $OUTDIR --debug-info-format dwarf --no-optimize
