OUTDIR=Public/lib/swiftle-node
# SWIFT_BIN=/Users/katei/Library/Developer/Toolchains/swift-6.2-DEVELOPMENT-SNAPSHOT-2025-08-30-a.xctoolchain/usr/bin
# SWIFT_SDK_ID=6.2-SNAPSHOT-2025-08-30-a-wasm32-unknown-wasip1
SWIFT_BIN=$(dirname "$(swiftly run which swiftc +main-snapshot-2025-08-27)")
SWIFT_SDK_ID=DEVELOPMENT-SNAPSHOT-2025-08-27-a-wasm32-unknown-wasip1

set -ex
rm -rf $OUTDIR

$SWIFT_BIN/swift package \
  --swift-sdk "${SWIFT_SDK_ID:-$(swiftc -print-target-info | jq -r '.swiftCompilerTag')_wasm}" \
  --sanitize address \
  -Xlinker /home/katei/ghq/work.katei.dev/swift-source/build/Ninja-RelWithDebInfoAssert/wasmllvmruntimelibs-linux-x86_64/wasm32-wasip1/compiler-rt/lib/wasip1/libclang_rt.asan-wasm32.a \
  -Xlinker --global-base=268435456 -Xlinker --max-memory=2147483648 -Xlinker --stack-first \
  --enable-experimental-prebuilts \
  --allow-writing-to-package-directory \
  js -c release --output $OUTDIR --debug-info-format dwarf --no-optimize
