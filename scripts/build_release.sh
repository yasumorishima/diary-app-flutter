#!/bin/bash
# Build the signed release AAB from this repository and check it (.github/workflows/release.yml).
# Ported from the private daily-diary (release/build_release.sh) on 2026-11-26, because that
# repository's Actions minutes run out; the steps and the checks are the same.
# Needs env: KEYSTORE_BASE64 STORE_PASSWORD KEY_PASSWORD KEY_ALIAS
# (Secrets of the "production" environment). Run from the repository root.
# Fails (exit 1) if the AAB still carries AdMob (ads were removed in 1.0.44) or is not signed by the upload key.
set -euo pipefail

if [ -z "${KEYSTORE_BASE64:-}" ] || [ -z "${KEY_ALIAS:-}" ]; then
  echo "::error::署名の Secrets が見えない"; exit 1
fi
cleanup() { rm -f android/app/upload-keystore.jks android/key.properties "$RUNNER_TEMP/sig.p7b"; }
trap cleanup EXIT
printf '%s' "$KEYSTORE_BASE64" | base64 --decode > android/app/upload-keystore.jks
{
  echo "storePassword=$STORE_PASSWORD"
  echo "keyPassword=$KEY_PASSWORD"
  echo "keyAlias=$KEY_ALIAS"
  echo "storeFile=upload-keystore.jks"
} > android/key.properties

flutter build appbundle --release

aab=build/app/outputs/bundle/release/app-release.aab
test -s "$aab" || { echo "::error::AAB ができていない"; exit 1; }
echo "AAB $(du -h "$aab" | cut -f1)"

# 1. no AdMob left: no AdMob app id in the manifest, no ad unit id in the Dart code
bt="$RUNNER_TEMP/bundletool.jar"
curl -fsSL -o "$bt" https://github.com/google/bundletool/releases/download/1.18.1/bundletool-all-1.18.1.jar
echo "675786493983787ffa11550bdb7c0715679a44e1643f3ff980a529e9c822595c  $bt" | sha256sum -c --quiet \
  || { echo "::error::bundletool の sha256 が違う"; exit 1; }
manifest=$(java -jar "$bt" dump manifest --bundle="$aab")
[ -n "$manifest" ] || { echo "::error::AAB のマニフェストが読めない"; exit 1; }
if grep -q "com.google.android.gms.ads" <<<"$manifest"; then
  echo "::error::AAB のマニフェストに AdMob（com.google.android.gms.ads）が残っている"; exit 1
fi
so=$(unzip -p "$aab" base/lib/arm64-v8a/libapp.so | strings -n 20 || true)
[ -n "$so" ] || { echo "::error::AAB に base/lib/arm64-v8a/libapp.so が無い"; exit 1; }
if grep -q "ca-app-pub-" <<<"$so"; then
  echo "::error::libapp.so に AdMob の ID（ca-app-pub-）が残っている"; exit 1
fi
echo "AdMob: マニフェストにも Dart のコードにも残っていない"

# 2. signed by the upload key
out=$(jarsigner -verify -certs "$aab" 2>&1) || { echo "$out" | tail -5; echo "::error::jarsigner -verify が失敗"; exit 1; }
grep -q "jar verified" <<<"$out" || { echo "$out" | tail -5; echo "::error::署名が検証されない"; exit 1; }
want=$(keytool -list -v -keystore android/app/upload-keystore.jks -storepass "$STORE_PASSWORD" -alias "$KEY_ALIAS" \
       | grep -m1 'SHA256:' | awk '{print $2}' || true)
unzip -p "$aab" 'META-INF/*.RSA' 'META-INF/*.EC' 'META-INF/*.DSA' 2>/dev/null > "$RUNNER_TEMP/sig.p7b" || true
got=$(keytool -printcert -file "$RUNNER_TEMP/sig.p7b" | grep -m1 'SHA256:' | awk '{print $2}' || true)
if [ -z "$want" ] || [ -z "$got" ]; then echo "::error::証明書の指紋が取れない"; exit 1; fi
[ "$want" = "$got" ] || { echo "::error::AAB の署名者がアップロード鍵と違う"; exit 1; }
echo "署名者はアップロード鍵（SHA-256 ${got:0:8}…）"
echo "aab=$aab" >> "$GITHUB_OUTPUT"
