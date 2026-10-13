#!/usr/bin/env python3
"""يولّد تسجيلات النطق بصوت عربي عالي الجودة.

المصدر الافتراضي: Gemini (مفتاح مجاني من aistudio.google.com/apikey) في
متغير البيئة GEMINI_API_KEY. البديل: Google Cloud Text-to-Speech بالمفتاح
GOOGLE_TTS_API_KEY (يحتاج حساب فوترة).

الخطوات:
  1. flutter test tool/export_speech_test.dart     # يكتب tool/speech_texts.json
  2. python3 tool/generate_audio.py --samples      # عينات لاختيار الصوت
  3. python3 tool/generate_audio.py --voice NAME   # كل التسجيلات + الفهرس

التسجيلات تُحفظ في
assets/audio/ والفهرس في lib/services/audio_catalog.g.dart، ولا يُعاد توليد
تسجيل موجود إلا مع --force.
"""

import argparse
import array
import base64
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TEXTS = os.path.join(ROOT, "tool", "speech_texts.json")
AUDIO_DIR = os.path.join(ROOT, "assets", "audio")
CATALOG = os.path.join(ROOT, "lib", "services", "audio_catalog.g.dart")
SAMPLES_DIR = os.path.join(ROOT, "build", "voice_samples")
API = "https://texttospeech.googleapis.com/v1/text:synthesize?key="

GEMINI_API = "https://generativelanguage.googleapis.com/v1beta/models/{}:generateContent?key="
# لكل نموذج حدّ يومي مجاني مستقل (نحو ١٠ طلبات).
GEMINI_MODEL = "gemini-3.8-flash-tts"
# أصوات Gemini المرشحة (تتحدث العربية كلها). نرسل النص وحده بلا تعليمات،
# لأن النماذج الأحدث تقرأ التعليمات بصوت مسموع.
GEMINI_VOICES = ["Kore", "Charon", "Aoede", "Orus"]

# أصوات Google Cloud المرشحة (الأحدث أولًا).
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


def synthesize_gemini(key, text, voice, rate, model=GEMINI_MODEL):
    """Gemini يعيد PCM خامًا (24kHz)، فنحوّله إلى MP3 بـ ffmpeg."""
    return to_mp3(gemini_pcm(key, text, voice, model), rate)


def gemini_pcm(key, text, voice, model=GEMINI_MODEL):
    body = {
        "contents": [{"parts": [{"text": text}]}],
        "generationConfig": {
            "responseModalities": ["AUDIO"],
            "speechConfig": {
                "voiceConfig": {"prebuiltVoiceConfig": {"voiceName": voice}}
            },
        },
    }
    req = urllib.request.Request(
        GEMINI_API.format(model) + key,
        data=json.dumps(body).encode(),
        headers={"Content-Type": "application/json"},
    )
    for attempt in range(10):
        try:
            with urllib.request.urlopen(req, timeout=120) as r:
                cand = json.load(r)["candidates"][0]
            # أحيانًا يعود الرد بلا صوت (finishReason: OTHER)، فنعيد المحاولة.
            if "content" not in cand and attempt < 9:
                time.sleep(5)
                continue
            pcm = base64.b64decode(cand["content"]["parts"][0]["inlineData"]["data"])
            break
        except urllib.error.HTTPError as e:
            err = e.read().decode()
            # الحد المجاني لعدد الطلبات في الدقيقة: ننتظر المدة التي يطلبها الخادم ثم نعيد.
            # وقد يرفض أحيانًا بحجة أنه «حاول توليد نص»، وتنجح الإعادة غالبًا.
            retry = e.code in (429, 500, 503) or "generate text" in err
            if retry and attempt < 9:
                if "PerDay" in err:
                    sys.exit(f"انتهى الحد اليومي المجاني لـ Gemini: {err[:300]}")
                m = re.search(r'"retryDelay": "(\d+)', err)
                time.sleep(int(m.group(1)) + 2 if m else min(60, 8 * (attempt + 1)))
                continue
            sys.exit(f"خطأ من Gemini ({e.code}): {err[:300]}")
    return pcm


def to_mp3(pcm, rate):
    with tempfile.NamedTemporaryFile(suffix=".pcm") as raw:
        raw.write(pcm)
        raw.flush()
        tempo = [] if abs(rate - 1) < 0.01 else ["-filter:a", f"atempo={rate}"]
        out = subprocess.run(
            ["ffmpeg", "-v", "error", "-f", "s16le", "-ar", "24000", "-ac", "1",
             "-i", raw.name, *tempo, "-b:a", "64k", "-f", "mp3", "-"],
            check=True, capture_output=True,
        )
    return out.stdout


RATE_HZ = 24000
FRAME = RATE_HZ // 50  # إطار ٢٠ ملّي ثانية


def split_pcm(pcm, count):
    """يقطع تسجيلًا فيه عدة نصوص عند أطول (count-1) فترات صمت.

    يعيد القطع مرتبة، أو None إن لم تكن الفواصل واضحة."""
    samples = array.array("h", pcm)
    frames = [
        max((abs(x) for x in samples[i:i + FRAME]), default=0)
        for i in range(0, len(samples), FRAME)
    ]
    loud = [f > 600 for f in frames]
    if True not in loud:
        return None
    first = loud.index(True)
    last = len(loud) - 1 - loud[::-1].index(True)
    gaps, start = [], None  # (الطول، البداية، النهاية) بالإطارات
    for i in range(first, last + 1):
        if not loud[i] and start is None:
            start = i
        elif loud[i] and start is not None:
            gaps.append((i - start, start, i))
            start = None
    if len(gaps) < count - 1:
        return None
    gaps.sort(reverse=True)
    cuts = sorted(gaps[:count - 1], key=lambda g: g[1])
    # الفاصل بين النصوص يجب أن يكون أطول بوضوح من أي وقفة داخل نص.
    if count > 1 and cuts and min(g[0] for g in cuts) < 15:
        return None
    if len(gaps) >= count and gaps[count - 1][0] * 1.3 > gaps[count - 2][0]:
        return None
    pad = 5  # ١٠٠ ملّي ثانية من الصمت حول كل مقطع
    bounds = [first] + [x for g in cuts for x in (g[1], g[2])] + [last + 1]
    pieces = []
    for a, b in zip(bounds[::2], bounds[1::2]):
        a, b = max(0, a - pad), min(len(frames), b + pad)
        pieces.append(samples[a * FRAME:b * FRAME].tobytes())
    return pieces


def plausible(pieces, texts):
    """طول كل مقطع يتناسب مع طول نصه، وإلا فالقطع خاطئ."""
    per_char = [len(p) / 2 / RATE_HZ / max(1, len(t)) for p, t in zip(pieces, texts)]
    mid = sorted(per_char)[len(per_char) // 2]
    return all(mid / 2.2 < x < mid * 2.2 for x in per_char)


def multi_sentence(text):
    """نص فيه أكثر من جملة أو وقفة (فاصلة، نقطة، نقطتان) أو طويل."""
    return bool(re.search(r"[.،:؟!]", text.rstrip(".،:؟! "))) or len(text) > 60


def generate_batch(key, texts, voice, rate):
    """يولّد عدة نصوص بطلب واحد ثم يقطعها، ويقسم الدفعة إن فشل القطع."""
    if len(texts) == 1:
        return [synthesize_gemini(key, texts[0], voice, rate)]
    joined = "\n\n".join(t.rstrip(".،؟!") + "." for t in texts)
    for _ in range(2):
        pieces = split_pcm(gemini_pcm(key, joined, voice), len(texts))
        if pieces and plausible(pieces, texts):
            return [to_mp3(p, rate) for p in pieces]
    half = len(texts) // 2
    print(f"  تعذّر قطع دفعة من {len(texts)} نصوص، تُقسم نصفين")
    return (generate_batch(key, texts[:half], voice, rate)
            + generate_batch(key, texts[half:], voice, rate))


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
    ap.add_argument("--voice", default=None, help="اسم الصوت (الافتراضي أول المرشحين)")
    ap.add_argument("--rate", type=float, default=0.9, help="سرعة النطق (1 = عادية)")
    ap.add_argument("--force", action="store_true", help="إعادة توليد الموجود")
    ap.add_argument("--batch", type=int, default=30, help="عدد النصوص في الطلب الواحد (Gemini)")
    args = ap.parse_args()

    if os.environ.get("GEMINI_API_KEY"):
        key, voices, say = os.environ["GEMINI_API_KEY"], GEMINI_VOICES, synthesize_gemini
    elif os.environ.get("GOOGLE_TTS_API_KEY"):
        key, voices, say = os.environ["GOOGLE_TTS_API_KEY"], CANDIDATES, synthesize
    else:
        sys.exit("أضف المفتاح في متغير البيئة GEMINI_API_KEY (أو GOOGLE_TTS_API_KEY)")
    voice = args.voice or voices[0]

    if args.samples:
        os.makedirs(SAMPLES_DIR, exist_ok=True)
        for voice in voices:
            path = os.path.join(SAMPLES_DIR, f"{voice}.mp3")
            if os.path.exists(path) and not args.force:
                continue
            # طلب واحد لكل صوت توفيرًا للحد المجاني.
            audio = say(key, ".\n\n".join(SAMPLE_TEXTS) + ".", voice, args.rate)
            with open(path, "wb") as f:
                f.write(audio)
            print(path)
        return

    with open(TEXTS, encoding="utf-8") as f:
        texts = json.load(f)
    os.makedirs(AUDIO_DIR, exist_ok=True)
    todo = [t for t in texts
            if args.force or not os.path.exists(os.path.join(AUDIO_DIR, file_name(t)))]
    # الحد اليومي المجاني لـ Gemini صغير، فنجمع عدة نصوص في الطلب الواحد.
    size = args.batch if say is synthesize_gemini else 1
    # النصوص ذات الجمل المتعددة فيها وقفات طويلة تُفسد القطع، فتُولَّد وحدها.
    solo = [t for t in todo if size > 1 and multi_sentence(t)]
    rest = [t for t in todo if t not in solo]
    groups = [rest[i:i + size] for i in range(0, len(rest), size)] + [
        [t] for t in solo
    ]
    made = 0
    for group in groups:
        audios = (generate_batch(key, group, voice, args.rate) if len(group) > 1
                  else [say(key, group[0], voice, args.rate)])
        for t, audio in zip(group, audios):
            with open(os.path.join(AUDIO_DIR, file_name(t)), "wb") as f:
                f.write(audio)
        made += len(group)
        print(f"{made}/{len(todo)}", flush=True)
    # تسجيلات لم تعد مستخدمة.
    wanted = {file_name(t) for t in texts}
    for name in os.listdir(AUDIO_DIR):
        if name.endswith(".mp3") and name not in wanted:
            os.remove(os.path.join(AUDIO_DIR, name))
    write_catalog(texts)
    print(f"{made} تسجيلًا جديدًا، والفهرس فيه {len(texts)} نصًا")


if __name__ == "__main__":
    main()
