"""Edytor polskich tekstów Hit5 (tools/teksty/README.md).

Lokalnie:    py -3 tools/teksty/serwer.py   (otwiera http://localhost:8765)
Na serwerze: TEKSTY_HOST=0.0.0.0 TEKSTY_PASSWORD=... python3 tools/teksty/serwer.py

Zapis zmienia tylko app/lib/l10n/app_pl.arb (kopia zapasowa trafia do
tools/teksty/kopie/); znaczniki „sprawdzone” idą do tools/teksty/sprawdzone.json.
"""

import base64
import datetime
import hmac
import json
import mimetypes
import os
import re
import shutil
import sys
import threading
import webbrowser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import unquote, urlparse

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
APP = os.path.join(REPO, 'app')
PL = os.path.join(APP, 'lib', 'l10n', 'app_pl.arb')
EN = os.path.join(APP, 'lib', 'l10n', 'app_en.arb')
ASSETS = os.path.join(APP, 'assets')
BACKUPS = os.path.join(HERE, 'kopie')
CHECKED = os.path.join(HERE, 'sprawdzone.json')
PORT = int(os.environ.get('TEKSTY_PORT', os.environ.get('PORT', '8765')))
HOST = os.environ.get('TEKSTY_HOST', '127.0.0.1')
# Hasło (dowolna nazwa użytkownika). Bez niego serwer słucha tylko lokalnie.
PASSWORD = os.environ.get('TEKSTY_PASSWORD', '')

# Ten sam wzorzec co app/test/l10n_test.dart: nazwy argumentów, bez treści gałęzi.
PLACEHOLDER = re.compile(r'(?<![=\w])\{(\w+)(?=[,}])')
LOCK = threading.Lock()
_backed_up = False


def load(path):
    with open(path, encoding='utf8') as f:
        return json.load(f)


def placeholders(s):
    return set(PLACEHOLDER.findall(s))


def braces_ok(s):
    depth = 0
    for ch in s:
        if ch == '{':
            depth += 1
        elif ch == '}':
            depth -= 1
            if depth < 0:
                return False
    return depth == 0


def save(changes):
    """changes: {key: {"old": str, "new": str}} -> (saved, problems)."""
    global _backed_up
    with LOCK:
        pl = load(PL)
        en = load(EN)
        problems = {}
        apply = {}
        for key, ch in changes.items():
            new = ch.get('new')
            if key.startswith('@') or key not in pl or not isinstance(new, str):
                problems[key] = 'Nieznany klucz.'
                continue
            if pl[key] != ch.get('old'):
                problems[key] = ('Ktoś zmienił ten tekst w pliku w międzyczasie. '
                                 'Odśwież stronę i spróbuj jeszcze raz.')
                continue
            if not braces_ok(new):
                problems[key] = 'Nawiasy { } się nie domykają.'
                continue
            want = placeholders(en.get(key, pl[key]))
            got = placeholders(new)
            if want != got:
                miss = ', '.join('{%s}' % p for p in sorted(want - got))
                extra = ', '.join('{%s}' % p for p in sorted(got - want))
                msg = []
                if miss:
                    msg.append('brakuje: ' + miss)
                if extra:
                    msg.append('nieznane: ' + extra)
                problems[key] = 'Zmienne się nie zgadzają (' + '; '.join(msg) + ').'
                continue
            apply[key] = new
        if apply:
            if not _backed_up:
                os.makedirs(BACKUPS, exist_ok=True)
                stamp = datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
                shutil.copy2(PL, os.path.join(BACKUPS, f'app_pl_{stamp}.arb'))
                _backed_up = True
            for k, v in apply.items():
                pl[k] = v
            data = (json.dumps(pl, ensure_ascii=False, indent=2) + '\n').encode('utf8')
            tmp = PL + '.tmp'
            with open(tmp, 'wb') as f:
                f.write(data)
            os.replace(tmp, PL)
        return sorted(apply), problems


def load_checked():
    try:
        with open(CHECKED, encoding='utf8') as f:
            return json.load(f)
    except (OSError, ValueError):
        return {}


def save_checked(changes):
    """changes: {key: true/false} -> cały stan."""
    with LOCK:
        data = load_checked()
        for k, v in changes.items():
            if v:
                data[k] = datetime.datetime.now().strftime('%Y-%m-%d %H:%M')
            else:
                data.pop(k, None)
        tmp = CHECKED + '.tmp'
        with open(tmp, 'w', encoding='utf8') as f:
            json.dump(data, f, ensure_ascii=False, indent=1, sort_keys=True)
        os.replace(tmp, CHECKED)
        return data


class Handler(BaseHTTPRequestHandler):
    def authorized(self):
        if not PASSWORD:
            return True
        head = self.headers.get('Authorization', '')
        if head.startswith('Basic '):
            try:
                _, _, given = base64.b64decode(head[6:]).decode('utf8').partition(':')
            except (ValueError, UnicodeDecodeError):
                given = ''
            if hmac.compare_digest(given.encode('utf8'), PASSWORD.encode('utf8')):
                return True
        self.send_response(401)
        self.send_header('WWW-Authenticate', 'Basic realm="Hit5 teksty", charset="UTF-8"')
        self.send_header('Content-Length', '0')
        self.end_headers()
        return False

    def log_message(self, fmt, *args):
        if '/api/' in (self.path or ''):
            sys.stderr.write('%s\n' % (fmt % args))

    def send(self, code, body, ctype='application/json; charset=utf-8'):
        if isinstance(body, (dict, list)):
            body = json.dumps(body, ensure_ascii=False).encode('utf8')
        elif isinstance(body, str):
            body = body.encode('utf8')
        self.send_response(code)
        self.send_header('Content-Type', ctype)
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Cache-Control', 'no-store')
        self.end_headers()
        self.wfile.write(body)

    def file(self, root, rel):
        path = os.path.normpath(os.path.join(root, rel))
        if not path.startswith(os.path.normpath(root) + os.sep) or not os.path.isfile(path):
            return self.send(404, {'error': 'not found'})
        ctype = mimetypes.guess_type(path)[0] or 'application/octet-stream'
        if ctype.startswith('text/') or ctype.endswith('javascript'):
            ctype += '; charset=utf-8'
        with open(path, 'rb') as f:
            self.send(200, f.read(), ctype)

    def do_GET(self):
        if not self.authorized():
            return
        url = unquote(urlparse(self.path).path)
        if url == '/api/data':
            pl = load(PL)
            en = load(EN)
            return self.send(200, {
                'order': [k for k in pl if not k.startswith('@')],
                'pl': {k: v for k, v in pl.items() if not k.startswith('@')},
                'en': {k: v for k, v in en.items() if not k.startswith('@')},
                'file': os.path.relpath(PL, REPO).replace(os.sep, '/'),
            })
        if url == '/api/checked':
            return self.send(200, load_checked())
        if url.startswith('/assets/'):
            return self.file(ASSETS, url[len('/assets/'):])
        if url == '/':
            url = '/index.html'
        return self.file(HERE, url.lstrip('/'))

    def do_POST(self):
        if not self.authorized():
            return
        path = urlparse(self.path).path
        if path not in ('/api/save', '/api/checked'):
            return self.send(404, {'error': 'not found'})
        # Tylko z tej strony (chroni przed zapisem z innych kart przeglądarki).
        origin = self.headers.get('Origin', '')
        if origin and urlparse(origin).netloc != self.headers.get('Host', ''):
            return self.send(403, {'error': 'forbidden'})
        try:
            n = int(self.headers.get('Content-Length', '0'))
            body = json.loads(self.rfile.read(n).decode('utf8'))
            if path == '/api/checked':
                return self.send(200, save_checked(body.get('changes', {})))
            saved, problems = save(body.get('changes', {}))
        except Exception as e:  # noqa: BLE001
            return self.send(500, {'error': str(e)})
        return self.send(200, {'saved': saved, 'problems': problems})


def main():
    local = HOST in ('127.0.0.1', 'localhost', '::1')
    if not local and not PASSWORD:
        sys.exit('Poza localhost ustaw hasło: TEKSTY_PASSWORD=... (inaczej każdy '
                 'w sieci mógłby zmieniać teksty gry).')
    server = ThreadingHTTPServer((HOST, PORT), Handler)
    url = f'http://{"localhost" if local else HOST}:{PORT}/'
    print(f'Edytor tekstów Hit5: {url}' + ('' if local else '  (z hasłem)'))
    print(f'Zapisuje do: {PL}')
    print('Zatrzymaj: Ctrl+C')
    if local and '--no-browser' not in sys.argv:
        threading.Timer(0.6, lambda: webbrowser.open(url)).start()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == '__main__':
    main()
