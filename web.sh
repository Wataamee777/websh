#!/bin/sh

# =========================
# websh all-in-one script
# =========================

BASE="$HOME/websh"
SERVER="$BASE/server"
PUBLIC="$BASE/public"
LOG="$BASE/log"
RUNTIME="$BASE/runtime"
CERT="$BASE/cert"

CONFIG="$BASE/config.conf"
PIDFILE="$RUNTIME/pid"
STATE="$RUNTIME/state"

die() {
  echo "[ERROR] $1"
  exit 1
}

need() {
  command -v "$1" >/dev/null 2>&1 || die "$1 not found"
}

configured() {
  [ -f "$STATE" ]
}

# -------------------------
# help
# -------------------------
help() {
  echo "websh"
  echo ""
  echo "./websh.sh help"
  echo "./websh.sh config   (first time)"
  echo "./websh.sh start"
  echo "./websh.sh stop"
  echo "./websh.sh status"
}

# -------------------------
# config
# -------------------------
config() {
  echo "[*] Initializing websh..."

  need node
  need npm
  need openssl

  mkdir -p "$SERVER" "$PUBLIC" "$LOG" "$RUNTIME" "$CERT"

  # ---------- package.json ----------
  cat > "$BASE/package.json" <<'EOF'
{
  "type": "module",
  "dependencies": {
    "express": "^4.18.2",
    "basic-auth": "^2.0.1",
    "ws": "^8.13.0"
  }
}
EOF

  npm install --prefix "$BASE" >/dev/null || die "npm install failed"

  # ---------- config.conf ----------
  cat > "$CONFIG" <<'EOF'
auth-enable=true
auth-id=root
auth-pass=pass

bind=0.0.0.0
port=8080

https-enable=false
https-cert-path=cert/fullchain.pem
https-key-path=cert/privkey.pem
EOF

  # ---------- server.js ----------
  cat > "$SERVER/server.js" <<'EOF'
import fs from "fs";
import http from "http";
import https from "https";
import express from "express";
import basicAuth from "basic-auth";
import { WebSocketServer } from "ws";
import { spawn } from "child_process";
import path from "path";

const ROOT = path.resolve(new URL(".", import.meta.url).pathname, "..");
const CONF = path.join(ROOT, "..", "config.conf");

const cfg = {};
fs.readFileSync(CONF, "utf8").split("\n").forEach(l => {
  l = l.trim();
  if (!l || l.startsWith("#")) return;
  const [k, ...v] = l.split("=");
  cfg[k] = v.join("=");
});

const app = express();

app.use((req, res, next) => {
  if (cfg["auth-enable"] !== "true") return next();
  const u = basicAuth(req);
  if (!u || u.name !== cfg["auth-id"] || u.pass !== cfg["auth-pass"]) {
    res.set("WWW-Authenticate", 'Basic realm="websh"');
    return res.status(401).end();
  }
  next();
});

app.use(express.static(path.join(ROOT, "..", "public")));

const createServer = () => {
  if (cfg["https-enable"] === "true") {
    return https.createServer({
      cert: fs.readFileSync(cfg["https-cert-path"]),
      key: fs.readFileSync(cfg["https-key-path"])
    }, app);
  }
  return http.createServer(app);
};

const server = createServer();
const wss = new WebSocketServer({ server });

wss.on("connection", (ws, req) => {
  if (cfg["auth-enable"] === "true" && !req.headers.authorization) {
    ws.close(); return;
  }

  ws.on("message", msg => {
    const cmd = msg.toString().trim();
    if (!cmd) return;

    const p = spawn("sh", ["-c", cmd], { cwd: process.env.HOME });
    p.stdout.on("data", d => ws.send(d.toString()));
    p.stderr.on("data", d => ws.send(d.toString()));
    p.on("close", c => ws.send(`\n[exit ${c}]`));
  });
});

server.listen(cfg.port, cfg.bind, () => {
  console.log(`websh listening on ${cfg.bind}:${cfg.port}`);
});
EOF

  # ---------- index.html ----------
  cat > "$PUBLIC/index.html" <<'EOF'
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>websh</title>
<style>
body{background:#000;color:#0f0;font-family:monospace;margin:0}
#out{height:90vh;overflow:auto;padding:10px;white-space:pre-wrap}
#cmd{height:10vh;width:100%;background:#000;color:#0f0;border:none;font-size:16px}
</style>
</head>
<body>
<div id="out"></div>
<textarea id="cmd" placeholder="Enter=run / Shift+Enter=newline"></textarea>
<script>
const out = document.getElementById("out");
const cmd = document.getElementById("cmd");
const ws = new WebSocket((location.protocol==="https:"?"wss":"ws")+"://"+location.host);

ws.onmessage = e => {
  out.textContent += e.data;
  out.scrollTop = out.scrollHeight;
};

cmd.addEventListener("keydown", e => {
  if (e.key==="Enter" && !e.shiftKey) {
    e.preventDefault();
    ws.send(cmd.value);
    cmd.value="";
  }
});
</script>
</body>
</html>
EOF

  echo ok > "$STATE"
  echo "[OK] websh configured"
}

# -------------------------
start() {
  configured || die "Run ./websh.sh config first"
  [ -f "$PIDFILE" ] && die "Already running"

  node "$SERVER/server.js" &
  echo $! > "$PIDFILE"
  echo "[OK] started"
}

stop() {
  [ -f "$PIDFILE" ] || return
  kill "$(cat "$PIDFILE")"
  rm -f "$PIDFILE"
  echo "[OK] stopped"
}

status() {
  [ -f "$PIDFILE" ] && echo "running" || echo "stopped"
}

# -------------------------
case "$1" in
  help|"") help ;;
  config) config ;;
  start) start ;;
  stop) stop ;;
  status) status ;;
  *) die "unknown command" ;;
esac
