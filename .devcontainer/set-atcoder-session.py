#!/usr/bin/env python3
"""ブラウザから取得した REVEL_SESSION を oj と acc の両方に書き込む。

AtCoder のログインに Cloudflare のチェックが入り `oj login` / `acc login` が
通らないとき用。同じ REVEL_SESSION Cookie を、

  - oj  : ~/.local/share/online-judge-tools/cookie.jar   (LWPCookieJar 形式)
  - acc : ~/.config/atcoder-cli-nodejs/session.json       ({"cookies":["name=value",...]})

の両方に流し込む。どちらも標準ライブラリだけで扱える。

取得方法:
    1. 普段のブラウザで AtCoder にログイン(Cloudflare を通過しておく)
    2. DevTools → Application/Storage → Cookies → https://atcoder.jp
    3. REVEL_SESSION の Value をコピー

使い方(コンテナ内):
    uv run --no-project .devcontainer/set-atcoder-session.py
    # 実行後、プロンプトに REVEL_SESSION の値を貼り付ける
    # (標準ライブラリのみ使用。uv が持っている Python がそのまま使われる)
    # 引数でも渡せる: ... set-atcoder-session.py '<値>'

確認:
    oj login --check https://atcoder.jp/
"""
import datetime
import http.cookiejar
import json
import os
import sys
from pathlib import Path

TTL_DAYS = 30


def update_oj(value: str) -> Path:
    """oj の cookie.jar (LWPCookieJar) に REVEL_SESSION を書き込む。"""
    data_home = os.environ.get("XDG_DATA_HOME") or str(Path.home() / ".local" / "share")
    path = Path(data_home) / "online-judge-tools" / "cookie.jar"
    path.parent.mkdir(parents=True, exist_ok=True)

    jar = http.cookiejar.LWPCookieJar(str(path))
    if path.exists():
        jar.load(ignore_discard=True, ignore_expires=True)

    cookie = http.cookiejar.Cookie(
        version=0,
        name="REVEL_SESSION",
        value=value,
        port=None,
        port_specified=False,
        domain="atcoder.jp",
        domain_specified=True,
        domain_initial_dot=False,
        path="/",
        path_specified=True,
        secure=True,
        expires=int(datetime.datetime.now().timestamp()) + 60 * 60 * 24 * TTL_DAYS,
        discard=False,
        comment=None,
        comment_url=None,
        rest={"HttpOnly": None},
    )
    jar.set_cookie(cookie)
    jar.save(ignore_discard=True, ignore_expires=True)
    return path


def update_acc(value: str) -> Path:
    """acc の session.json に REVEL_SESSION を書き込む。

    形式は {"cookies": ["name=value", ...]} という Cookie 文字列の配列。
    REVEL_SESSION= で始まる要素を差し替え(無ければ追加)、他 Cookie は残す。
    """
    config_home = os.environ.get("XDG_CONFIG_HOME") or str(Path.home() / ".config")
    path = Path(config_home) / "atcoder-cli-nodejs" / "session.json"
    path.parent.mkdir(parents=True, exist_ok=True)

    if path.exists():
        data = json.loads(path.read_text())
    else:
        data = {"cookies": []}
    cookies = data.setdefault("cookies", [])

    entry = f"REVEL_SESSION={value}"
    for i, c in enumerate(cookies):
        if isinstance(c, str) and c.startswith("REVEL_SESSION="):
            cookies[i] = entry
            break
    else:
        cookies.append(entry)

    path.write_text(json.dumps(data, indent=4))
    return path


def main() -> None:
    if len(sys.argv) > 1:
        value = sys.argv[1].strip()
    else:
        # 引数無しなら対話入力(シェル履歴に秘密を残さない)
        value = input("paste REVEL_SESSION value: ").strip()
    if not value:
        sys.exit("error: REVEL_SESSION value is empty")

    oj_path = update_oj(value)
    acc_path = update_acc(value)
    print(f"wrote REVEL_SESSION to {oj_path}")
    print(f"wrote REVEL_SESSION to {acc_path}")
    print("verify with: oj login --check https://atcoder.jp/")


if __name__ == "__main__":
    main()
