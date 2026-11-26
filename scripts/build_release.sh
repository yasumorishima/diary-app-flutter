#!/bin/bash
# Build the signed release AAB from this repository and check it (.github/workflows/release.yml).
# Ported from the private daily-diary (release/build_release.sh) on 2026-11-26, because that
# repository's Actions minutes run out; the steps and the checks are the same.
# Needs env: KEYSTORE_BASE64 STORE_PASSWORD KEY_PASSWORD KEY_ALIAS ADMOB_APP_ID ADMOB_BANNER_ANDROID
# (Secrets of the "production" environment). Run from the repository root.
# Fails (exit 1) unless the AAB carries the production AdMob IDs and is signed by the upload key.
set -euo pipefail

# ADMOB_APP_ID, ADMOB_BANNER_ANDROID: not secret (they are in the published app), but kept out of
# the public source so that others do not copy them into their apps. Never echo them whole.
: "${ADMOB_APP_ID:?::error::ADMOB_APP_ID が見えない}" "${ADMOB_BANNER_ANDROID:?::error::ADMOB_BANNER_ANDROID が見えない}"
case "$ADMOB_APP_ID" in ca-app-pub-[0-9]*~[0-9]*) ;; *) echo "::error::ADMOB_APP_ID の形が想定外"; exit 1;; esac
case "$ADMOB_BANNER_ANDROID" in ca-app-pub-[0-9]*/[0-9]*) ;; *) echo "::error::ADMOB_BANNER_ANDROID の形が想定外"; exit 1;; esac
TEST_PUB=3940256099942544   # Google's test publisher id
case "$ADMOB_APP_ID$ADMOB_BANNER_ANDROID" in *"$TEST_PUB"*) echo "::error::ADMOB_* にテスト用 ID が入っている"; exit 1;; esac

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

ORG_GRADLE_PROJECT_admobAppId="$ADMOB_APP_ID" \
  flutter build appbundle --release --dart-define=ADMOB_BANNER_ANDROID="$ADMOB_BANNER_ANDROID"

aab=build/app/outputs/bundle/release/app-release.aab
test -s "$aab" || { echo "::error::AAB ができていない"; exit 1; }
echo "AAB $(du -h "$aab" | cut -f1)"

# 1. the manifest carries the production AdMob app id
bt="$RUNNER_TEMP/bundletool.jar"
curl -fsSL -o "$bt" https://github.com/google/bundletool/releases/download/1.18.1/bundletool-all-1.18.1.jar
echo "675786493983787ffa11550bdb7c0715679a44e1643f3ff980a529e9c822595c  $bt" | sha256sum -c --quiet \
  || { echo "::error::bundletool の sha256 が違う"; exit 1; }
got_app=$(java -jar "$bt" dump manifest --bundle="$aab" \
  --xpath="/manifest/application/meta-data[@android:name='com.google.android.gms.ads.APPLICATION_ID']/@android:value" || true)
if [ "$got_app" != "$ADMOB_APP_ID" ]; then
  echo "::error::AAB の AdMob アプリ ID が本番と違う（ログが公開なので値は出さない）"; exit 1
fi
# 2. the Dart code carries the production banner id and no test id
so=$(unzip -p "$aab" base/lib/arm64-v8a/libapp.so | strings -n 20 || true)
[ -n "$so" ] || { echo "::error::AAB に base/lib/arm64-v8a/libapp.so が無い"; exit 1; }
grep -qF "$ADMOB_BANNER_ANDROID" <<<"$so" || { echo "::error::libapp.so に本番のバナー ID が無い"; exit 1; }
# 検出の仕組みが効いている証拠として、見つかったテスト用 ID（iOS 用は残ってよい）を出す
echo "libapp.so のテスト用 ID: $(grep -o "ca-app-pub-$TEST_PUB/[0-9]*" <<<"$so" | sort -u | tr '\n' ' ')"
if grep -q "ca-app-pub-$TEST_PUB" <<<"$so"; then
  # iOS のテスト用 ID（adMobBannerIdIOS）だけは残ってよい
  bad=$(grep -o "ca-app-pub-$TEST_PUB/[0-9]*" <<<"$so" | grep -v "/2934735716" || true)
  [ -z "$bad" ] || { echo "::error::libapp.so に Android のテスト用 ID が残っている: $bad"; exit 1; }
fi
echo "AdMob: 本番のアプリ ID とバナー ID が入っている"

# 3. signed by the upload key
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
