OUTDIR=Public/lib/swiftle

set -ex
rm -rf $OUTDIR

swift package \
  --swift-sdk "${SWIFT_SDK_ID:-$(swiftc -print-target-info | jq -r '.swiftCompilerTag')_wasm}" \
  --enable-experimental-prebuilts \
  --allow-writing-to-package-directory \
  js -c release --output $OUTDIR --use-cdn --debug-info-format name
