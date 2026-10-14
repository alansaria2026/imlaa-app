#!/usr/bin/env python3
"""يحمي نسخة الويب بكلمة مرور قبل نشرها على gh-pages.

يشفّر build/web/main.dart.js (AES-GCM بمفتاح من PBKDF2) إلى main.dart.js.enc
ويحذف الأصل، ويستبدل index.html بصفحة تطلب كلمة المرور وتفك التشفير في
المتصفح ثم تشغّل التطبيق. كلمة المرور لا تُحفظ في الملفات المنشورة ولا في
المتصفح، فتُطلب في كل دخول.

    flutter build web --release --base-href /imlaa-app/ --no-web-resources-cdn --pwa-strategy=none
    SITE_PASSWORD='...' python3 tool/protect_web.py

حدود الحماية: ملفات الصوت والخطوط غير مشفرة، والكود المصدري في المستودع
نفسه يبقى عامًا ما دام المستودع عامًا.
"""

import os
import re
import sys

from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WEB = os.path.join(ROOT, "build", "web")
ITERATIONS = 250_000

GATE = """<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <base href="__BASE__">
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="robots" content="noindex, nofollow">
  <title>إملائي</title>
  <style>
    body { margin: 0; min-height: 100vh; display: grid; place-items: center;
           font-family: system-ui, sans-serif; background: #fff; color: #111; }
    form { width: min(320px, calc(100vw - 32px)); display: grid; gap: 12px;
           text-align: center; }
    h1 { font-size: 1.5rem; margin: 0 0 8px; }
    input, button { font: inherit; font-size: 1.1rem; padding: 12px;
                    border-radius: 14px; }
    input { border: 2px solid #ccc; text-align: center; direction: ltr; }
    button { border: 0; background: #111; color: #fff; font-weight: 700; }
    #msg { min-height: 1.5em; color: #c62828; }
  </style>
</head>
<body>
  <form id="gate">
    <h1>إملائي</h1>
    <label for="pw">اكتب كلمة المرور للتجربة</label>
    <input id="pw" type="password" autocomplete="current-password" required>
    <button type="submit">دخول</button>
    <div id="msg"></div>
  </form>
  <script>
    const KEY = 'imlaa-site-password';
    const ITER = __ITER__;
    const form = document.getElementById('gate');
    const msg = document.getElementById('msg');

    async function unlock(password) {
      const data = new Uint8Array(
        await (await fetch('main.dart.js.enc', {cache: 'no-store'})).arrayBuffer());
      const salt = data.slice(0, 16), iv = data.slice(16, 28);
      const base = await crypto.subtle.importKey(
        'raw', new TextEncoder().encode(password), 'PBKDF2', false, ['deriveKey']);
      const key = await crypto.subtle.deriveKey(
        {name: 'PBKDF2', salt, iterations: ITER, hash: 'SHA-256'},
        base, {name: 'AES-GCM', length: 256}, false, ['decrypt']);
      const js = await crypto.subtle.decrypt({name: 'AES-GCM', iv}, key, data.slice(28));
      window.__imlaaMain = URL.createObjectURL(
        new Blob([js], {type: 'text/javascript'}));
      form.remove();
      const s = document.createElement('script');
      s.src = 'flutter_bootstrap.js';
      document.body.appendChild(s);
    }

    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      msg.textContent = '…';
      try {
        await unlock(document.getElementById('pw').value.trim());
      } catch (_) {
        msg.textContent = 'كلمة المرور غير صحيحة';
      }
    });

    // تُطلب كلمة المرور في كل دخول؛ ويُمسح ما حفظته النسخ السابقة.
    try { localStorage.removeItem(KEY); } catch (_) {}
  </script>
</body>
</html>
"""


def main():
    password = os.environ.get("SITE_PASSWORD", "").strip()
    if not password:
        sys.exit("ضع كلمة المرور في متغير البيئة SITE_PASSWORD")
    main_js = os.path.join(WEB, "main.dart.js")
    if not os.path.exists(main_js):
        sys.exit("لا يوجد build/web/main.dart.js: ابنِ نسخة الويب أولًا")

    # فك التشفير في المتصفح يحمّل ملف main.dart.js وحده؛ الأجزاء المؤجلة
    # (*.part.js) تُحمَّل بمسار نسبي إليه فلا تعمل من نسخة مفكوكة.
    if any(n.endswith(".part.js") for n in os.listdir(WEB)):
        sys.exit("في البناء ملفات .part.js لا تدعمها الحماية")

    with open(main_js, "rb") as f:
        plain = f.read()
    salt, iv = os.urandom(16), os.urandom(12)
    key = PBKDF2HMAC(
        algorithm=hashes.SHA256(), length=32, salt=salt, iterations=ITERATIONS
    ).derive(password.encode())
    with open(main_js + ".enc", "wb") as f:
        f.write(salt + iv + AESGCM(key).encrypt(iv, plain, None))
    os.remove(main_js)

    # التطبيق يُحمَّل من النسخة المفكوكة في المتصفح بدل main.dart.js.
    boot = os.path.join(WEB, "flutter_bootstrap.js")
    with open(boot, encoding="utf-8") as f:
        text = f.read()
    if '"mainJsPath":"main.dart.js"' not in text:
        sys.exit("تغيّر شكل flutter_bootstrap.js: راجع الأداة")
    text = text.replace('"mainJsPath":"main.dart.js"', '"mainJsPath":window.__imlaaMain')
    with open(boot, "w", encoding="utf-8") as f:
        f.write(text)

    index = os.path.join(WEB, "index.html")
    with open(index, encoding="utf-8") as f:
        base = re.search(r'<base href="([^"]*)"', f.read()).group(1)
    with open(index, "w", encoding="utf-8") as f:
        f.write(GATE.replace("__BASE__", base).replace("__ITER__", str(ITERATIONS)))
    with open(os.path.join(WEB, "robots.txt"), "w") as f:
        f.write("User-agent: *\nDisallow: /\n")
    print("نسخة الويب محمية بكلمة مرور")


if __name__ == "__main__":
    main()
