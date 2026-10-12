#!/usr/bin/env python3
"""يولّد تسجيلات النطق بصوت Google Cloud Text-to-Speech العربي.

الخطوات:
  1. flutter test tool/export_speech_test.dart     # يكتب tool/speech_texts.json
  2. python3 tool/generate_audio.py --samples      # عينات لاختيار الصوت
  3. python3 tool/generate_audio.py --voice NAME   # كل التسجيلات + الفهرس

يقرأ المفتاح من متغير البيئة GOOGLE_TTS_API_KEY. التسجيلات تُحفظ في
assets/audio/ والفهرس في lib/services/audio_catalog.g.dart، ولا يُعاد توليد
تسجيل موجود إلا مع --force.
"""

import argparse
import base64
import hashlib
import json
import os
import sys
import urllib.error
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TEXTS = os.path.join(ROOT, "tool", "speech_texts.json")
AUDIO_DIR = os.path.join(ROOT, "assets", "audio")
CATALOG = os.path.join(ROOT, "lib", "services", "audio_catalog.g.dart")
SAMPLES_DIR = os.path.join(ROOT, "build", "voice_samples")
API = "https://texttospeech.googleapis.com/v1/text:synthesize?key="

# أصوات عربية مرشحة (الأحدث أولًا).
CANDIDATES = [
    "ar-XA-Chirp3-HD-Charon",
    "ar-XA-Chirp3-HD-Kore",
    "ar-XA-Wavenet-B",
    "ar-XA-Wavenet-A",
]
SAMPLE_TEXTS = [
    "الشَّمسُ مُشرقةٌ والقمرُ جميل",
    "بِالشَّمْس",
    "لِلَّحْن",
    "الْكِتاب",
]


def synthesize(key, text, voice, rate):
    body = {
        "input": {"text": text},
        "voice": {"languageCode": "ar-XA", "name": voice},
        "audioConfig": {"audioEncoding": "MP3", "speakingRate": rate},
    }
    req = urllib.request.Request(
        API + key,
        data=json.dumps(body).encode(),
        headers={"Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return base64.b64decode(json.load(r)["audioContent"])
    except urllib.error.HTTPError as e:
        sys.exit(f"خطأ من Google ({e.code}) للصوت {voice}: {e.read().decode()[:300]}")


def file_name(text):
    return hashlib.md5(text.encode()).hexdigest()[:12] + ".mp3"


def write_catalog(texts):
    lines = [
        "// ملف مولَّد بـ tool/generate_audio.py — لا تعدّله يدويًا.",
        "// النص المنطوق ← مسار التسجيل داخل assets.",
        "",
        "const Map<String, String> audioCatalog = {",
    ]
    for t in sorted(texts):
        if os.path.exists(os.path.join(AUDIO_DIR, file_name(t))):
            lines.append(f"  {json.dumps(t, ensure_ascii=False)}: 'audio/{file_name(t)}',")
    lines.append("};")
    with open(CATALOG, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--samples", action="store_true", help="عينات من كل صوت مرشح")
    ap.add_argument("--voice", default=CANDIDATES[0])
    ap.add_argument("--rate", type=float, default=0.9, help="سرعة النطق (1 = عادية)")
    ap.add_argument("--force", action="store_true", help="إعادة توليد الموجود")
    args = ap.parse_args()

    key = os.environ.get("GOOGLE_TTS_API_KEY")
    if not key:
        sys.exit("أضف المفتاح في متغير البيئة GOOGLE_TTS_API_KEY")

    if args.samples:
        os.makedirs(SAMPLES_DIR, exist_ok=True)
        for voice in CANDIDATES:
            audio = b"".join(synthesize(key, t, voice, args.rate) for t in SAMPLE_TEXTS)
            path = os.path.join(SAMPLES_DIR, f"{voice}.mp3")
            with open(path, "wb") as f:
                f.write(audio)
            print(path)
        return

    with open(TEXTS, encoding="utf-8") as f:
        texts = json.load(f)
    os.makedirs(AUDIO_DIR, exist_ok=True)
    made = 0
    for t in texts:
        path = os.path.join(AUDIO_DIR, file_name(t))
        if os.path.exists(path) and not args.force:
            continue
        with open(path, "wb") as f:
            f.write(synthesize(key, t, args.voice, args.rate))
        made += 1
    # تسجيلات لم تعد مستخدمة.
    wanted = {file_name(t) for t in texts}
    for name in os.listdir(AUDIO_DIR):
        if name.endswith(".mp3") and name not in wanted:
            os.remove(os.path.join(AUDIO_DIR, name))
    write_catalog(texts)
    print(f"{made} تسجيلًا جديدًا، والفهرس فيه {len(texts)} نصًا")


if __name__ == "__main__":
    main()
