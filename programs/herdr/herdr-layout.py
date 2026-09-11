import json
import os
import random
import socket
import sys
import time

USAGE = """usage: herdr-layout <even|FRACTION>

  even       space every side-by-side split evenly (tmux: select-layout even-horizontal)
  FRACTION   give the focused pane that share of its side-by-side split, absolute rather than
             incremental, so repeating the key is idempotent (0.7 = tmux: resize-pane -x 70%)
"""


def call(socket_path, tab_id, method, params):
    if tab_id:
        params = dict(params, tab_id=tab_id)
    request_id = f"herdr-layout:{int(time.time() * 1000)}:{random.randrange(1000000):06d}"
    client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    client.settimeout(2.0)
    try:
        client.connect(socket_path)
        client.sendall((json.dumps({"id": request_id, "method": method, "params": params}) + "\n").encode())
        buffer = b""
        while not buffer.endswith(b"\n"):
            chunk = client.recv(65536)
            if not chunk:
                break
            buffer += chunk
    except OSError as failure:
        raise SystemExit(f"herdr-layout: cannot reach herdr at {socket_path}: {failure}")
    finally:
        client.close()

    response = json.loads(buffer.decode().splitlines()[0])
    if "error" in response:
        error = response["error"]
        raise SystemExit(f"herdr-layout: {error.get('message', error)}")
    return response["result"]["layout"]


def leaf_count(node):
    if node["type"] == "pane":
        return 1
    return leaf_count(node["first"]) + leaf_count(node["second"])


def path_to_pane(node, pane_id, path=()):
    if node["type"] == "pane":
        return path if node.get("pane_id") == pane_id else None
    for take_second, branch in ((False, "first"), (True, "second")):
        found = path_to_pane(node[branch], pane_id, path + (take_second,))
        if found is not None:
            return found
    return None


def side_by_side_splits(node, path=()):
    if node["type"] != "split":
        return
    if node["direction"] == "right":
        yield path, node
    yield from side_by_side_splits(node["first"], path + (False,))
    yield from side_by_side_splits(node["second"], path + (True,))


# The split owning the focused pane's width is the last side-by-side one on the way down to it.
def controlling_split(root, path):
    node, owner = root, None
    for depth, take_second in enumerate(path):
        if node["direction"] == "right":
            owner = (path[:depth], take_second)
        node = node["second" if take_second else "first"]
    return owner


def split_at(root, path):
    node = root
    for take_second in path:
        node = node["second" if take_second else "first"]
    return node


def main():
    requested = sys.argv[1] if len(sys.argv) > 1 else ""
    if requested in ("", "-h", "--help"):
        print(USAGE)
        return 0

    fraction = None
    if requested != "even":
        try:
            fraction = float(requested)
        except ValueError:
            raise SystemExit(f"herdr-layout: expected 'even' or a fraction, got {requested!r}")
        if not 0.0 < fraction < 1.0:
            raise SystemExit(f"herdr-layout: fraction must sit between 0 and 1, got {fraction}")

    socket_path = os.environ.get("HERDR_SOCKET_PATH")
    if not socket_path:
        raise SystemExit("herdr-layout: no HERDR_SOCKET_PATH — run this inside herdr")
    tab_id = os.environ.get("HERDR_ACTIVE_TAB_ID") or None

    layout = call(socket_path, tab_id, "layout.export", {})

    if fraction is None:
        # Outermost first, so each ratio lands on a tree the earlier ones have already settled.
        for path, split in sorted(side_by_side_splits(layout["root"]), key=lambda entry: len(entry[0])):
            ratio = leaf_count(split["first"]) / leaf_count(split)
            call(socket_path, tab_id, "layout.set_split_ratio", {"path": list(path), "ratio": ratio})
        return 0

    focused_path = path_to_pane(layout["root"], layout["focused_pane_id"])
    if focused_path is None:
        return 0
    owner = controlling_split(layout["root"], focused_path)
    if owner is None:
        return 0

    split_path, focused_is_second = owner
    target = 1.0 - fraction if focused_is_second else fraction
    settled = call(socket_path, tab_id, "layout.set_split_ratio", {"path": list(split_path), "ratio": target})

    # The boolean path encoding is undocumented; complain rather than leave a stranger split resized.
    landed = split_at(settled["root"], split_path)
    if landed["type"] != "split" or abs(landed["ratio"] - target) > 0.01:
        raise SystemExit("herdr-layout: ratio did not land on the expected split — path encoding differs")
    return 0


if __name__ == "__main__":
    sys.exit(main())
