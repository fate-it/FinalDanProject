"""Small HTTP backend for the EKS / Argo CD exercise (standard library only)."""

import json
import os
import signal
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if urlsplit(self.path).path == "/":
            status = 200
            payload = {
                "status": "ok",
                "version": os.getenv("APP_VERSION", "local"),
                "pod_ip": os.getenv("POD_IP") or self.connection.getsockname()[0],
            }
        else:
            status = 404
            payload = {"error": "not found"}

        body = (json.dumps(payload) + "\n").encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


def main():
    port = int(os.getenv("PORT", "8000"))

    def stop(_signum, _frame):
        raise SystemExit(0)

    signal.signal(signal.SIGTERM, stop)
    with ThreadingHTTPServer(("0.0.0.0", port), Handler) as server:
        print(f"Listening on 0.0.0.0:{port}", flush=True)
        server.serve_forever()


if __name__ == "__main__":
    main()
