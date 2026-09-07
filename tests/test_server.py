import json
import os
import threading
import unittest
from http.client import HTTPConnection
from http.server import ThreadingHTTPServer
from unittest.mock import patch

from app.server import Handler


class ServerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join(timeout=5)

    def request(self, path):
        connection = HTTPConnection(*self.server.server_address, timeout=3)
        try:
            connection.request("GET", path)
            response = connection.getresponse()
            return response.status, response.getheader("Content-Type"), json.loads(response.read())
        finally:
            connection.close()

    def test_root_returns_200_and_build_version(self):
        with patch.dict(os.environ, {"APP_VERSION": "test-commit"}):
            status, content_type, body = self.request("/")
        self.assertEqual(status, 200)
        self.assertEqual(content_type, "application/json; charset=utf-8")
        self.assertEqual(body, {"status": "ok", "version": "test-commit"})

    def test_root_accepts_query_string(self):
        self.assertEqual(self.request("/?check=1")[0], 200)

    def test_unknown_path_returns_404(self):
        status, _, body = self.request("/missing")
        self.assertEqual(status, 404)
        self.assertEqual(body, {"error": "not found"})


if __name__ == "__main__":
    unittest.main()
