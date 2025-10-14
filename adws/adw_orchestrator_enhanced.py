#!/usr/bin/env python3
"""
ADW Enhanced Orchestrator

Supports multiple trigger modes:
1. Direct CLI execution (semi-automatic mode)
2. Webhook triggers from GitHub/external systems
3. Hook triggers from Claude Code post-tool-use hooks

Features:
- Configurable phase chains
- Flexible automation options
- PID tracking and session management
- Webhook server for remote triggers
- Hook integration

Usage:
    # Direct mode (semi-automatic)
    python adws/adw_orchestrator_enhanced.py run <adw_id> --chain post_build

    # Webhook server mode
    python adws/adw_orchestrator_enhanced.py serve

    # Hook mode (called from hooks)
    python adws/adw_orchestrator_enhanced.py hook <adw_id> --event build_complete
"""

import argparse
import hashlib
import hmac
import json
import os
import signal
import subprocess
import sys
import threading
import time
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from typing import Dict, List, Optional

try:
    import requests
    REQUESTS_AVAILABLE = True
except ImportError:
    REQUESTS_AVAILABLE = False


class OrchestratorConfig:
    """Load and manage orchestrator configuration"""

    def __init__(self, config_path: Optional[Path] = None):
        if config_path is None:
            config_path = Path(__file__).parent / 'adw_orchestrator_config.json'

        self.config_path = config_path
        self.config = self._load_config()

    def _load_config(self) -> dict:
        """Load configuration from JSON file"""
        if not self.config_path.exists():
            print(f"⚠️  Config not found: {self.config_path}")
            return self._default_config()

        with open(self.config_path) as f:
            return json.load(f)

    def _default_config(self) -> dict:
        """Return default configuration"""
        return {
            "webhook": {"enabled": False, "port": 8765},
            "phase_chains": {
                "post_build": {"phases": ["test", "review", "pr"]}
            },
            "phase_config": {},
            "automation": {"auto_chain_on_success": True}
        }

    def get_chain(self, chain_name: str) -> Optional[Dict]:
        """Get phase chain configuration"""
        return self.config.get('phase_chains', {}).get(chain_name)

    def get_phase_config(self, phase: str) -> Optional[Dict]:
        """Get phase configuration"""
        return self.config.get('phase_config', {}).get(phase)

    def find_chain_for_event(self, event: str) -> Optional[str]:
        """Find chain name that handles this event"""
        for chain_name, chain_config in self.config.get('phase_chains', {}).items():
            if isinstance(chain_config, dict):
                trigger_events = chain_config.get('trigger_events', [])
                if event in trigger_events:
                    return chain_name
        return None


class ADWOrchestrator:
    """Enhanced orchestrator with flexible phase chaining"""

    def __init__(self, adw_id: str, config: OrchestratorConfig):
        self.adw_id = adw_id
        self.config = config
        self.base_dir = Path.cwd()
        self.agents_dir = self.base_dir / 'agents' / adw_id
        self.orchestrator_dir = self.agents_dir / 'orchestrator'
        self.orchestrator_dir.mkdir(parents=True, exist_ok=True)

        self.log_file = self.orchestrator_dir / 'orchestrator.log'
        self.pid_file = self.orchestrator_dir / 'session_pids.json'
        self.status_file = self.orchestrator_dir / 'orchestration_status.json'

        # Load state
        self.state = self._load_state()
        self.issue_number = self.state.get('issue_number')
        self.repo = self._get_repo_info()

        # Active processes
        self.processes: Dict[str, subprocess.Popen] = {}

    def _load_state(self) -> dict:
        """Load ADW state file"""
        state_file = self.agents_dir / 'adw_state.json'
        if not state_file.exists():
            # State might not exist yet for plan phase
            return {}

        with open(state_file) as f:
            return json.load(f)

    def _get_repo_info(self) -> Optional[str]:
        """Get GitHub repo in format owner/repo"""
        try:
            result = subprocess.run(
                ['git', 'remote', 'get-url', 'origin'],
                capture_output=True,
                text=True,
                check=True
            )
            url = result.stdout.strip()

            if 'github.com' in url:
                if url.startswith('https://'):
                    parts = url.replace('https://github.com/', '').replace('.git', '').split('/')
                elif url.startswith('git@'):
                    parts = url.replace('git@github.com:', '').replace('.git', '').split('/')
                else:
                    return None

                if len(parts) >= 2:
                    return f"{parts[0]}/{parts[1]}"

            return None
        except Exception:
            return None

    def log(self, message: str):
        """Log message to both console and file"""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        log_message = f"[{timestamp}] {message}"

        if self.config.config.get('logging', {}).get('console_output', True):
            print(log_message)

        if self.config.config.get('logging', {}).get('file_logging', True):
            with open(self.log_file, 'a') as f:
                f.write(log_message + '\n')

    def save_pid(self, phase: str, pid: int, command: str):
        """Save process ID for tracking"""
        pids = {}
        if self.pid_file.exists():
            with open(self.pid_file) as f:
                pids = json.load(f)

        pids[phase] = {
            'pid': pid,
            'started_at': datetime.now().isoformat(),
            'command': command
        }

        with open(self.pid_file, 'w') as f:
            json.dump(pids, f, indent=2)

    def update_status(self, phase: str, status: str, details: Optional[str] = None):
        """Update orchestration status"""
        status_data = {}
        if self.status_file.exists():
            with open(self.status_file) as f:
                status_data = json.load(f)

        if 'phases' not in status_data:
            status_data['phases'] = {}

        status_data['phases'][phase] = {
            'status': status,
            'updated_at': datetime.now().isoformat(),
            'details': details
        }
        status_data['current_phase'] = phase
        status_data['adw_id'] = self.adw_id

        with open(self.status_file, 'w') as f:
            json.dump(status_data, f, indent=2)

    def start_claude_session(self, phase: str) -> subprocess.Popen:
        """Start a Claude Code session for the given phase"""
        phase_config = self.config.get_phase_config(phase)
        if not phase_config:
            raise ValueError(f"Unknown phase: {phase}")

        command = phase_config['command']
        requires_adw_id = phase_config.get('requires_adw_id', True)

        # Build command
        if requires_adw_id:
            cmd = ['claude', command, self.adw_id]
        else:
            cmd = ['claude', command]

        self.log(f"🚀 Starting {phase} phase: {' '.join(cmd)}")

        # Start process
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            cwd=self.base_dir
        )

        self.processes[phase] = process
        self.save_pid(phase, process.pid, ' '.join(cmd))
        self.update_status(phase, 'running', f'PID: {process.pid}')

        return process

    def check_issue_comment(self, marker: str, max_age_minutes: int = 10) -> bool:
        """Check if expected completion marker appears in recent issue comments"""
        if not REQUESTS_AVAILABLE:
            self.log("⚠️  requests library not available, skipping comment verification")
            return True

        if not self.repo or not self.issue_number:
            return True  # Can't verify

        if not self.config.config.get('automation', {}).get('comment_verification_enabled', True):
            return True  # Verification disabled

        try:
            gh_token = os.environ.get('GITHUB_TOKEN')
            if not gh_token:
                return True

            url = f"https://api.github.com/repos/{self.repo}/issues/{self.issue_number}/comments"
            headers = {
                'Authorization': f'token {gh_token}',
                'Accept': 'application/vnd.github.v3+json'
            }

            response = requests.get(url, headers=headers)
            response.raise_for_status()

            comments = response.json()
            cutoff_time = datetime.now().timestamp() - (max_age_minutes * 60)

            for comment in reversed(comments[-5:]):
                created_at = datetime.fromisoformat(comment['created_at'].replace('Z', '+00:00'))
                if created_at.timestamp() < cutoff_time:
                    continue

                if marker in comment['body']:
                    self.log(f"✅ Found completion marker: {marker}")
                    return True

            self.log(f"⚠️  Completion marker not found: {marker}")
            return False

        except Exception as e:
            self.log(f"⚠️  Error checking comments: {e}")
            return True

    def wait_for_completion(self, process: subprocess.Popen, phase: str) -> bool:
        """Wait for process to complete and verify"""
        self.log(f"⏳ Waiting for {phase} phase (PID: {process.pid})")

        return_code = process.wait()

        if return_code != 0:
            stderr = process.stderr.read() if process.stderr else ""
            self.log(f"❌ {phase} failed (exit code {return_code})")
            if stderr:
                self.log(f"   Error: {stderr[:500]}")
            self.update_status(phase, 'failed', f'Exit code: {return_code}')
            return False

        self.log(f"✓ {phase} process completed")

        # Verify via issue comment
        phase_config = self.config.get_phase_config(phase)
        if phase_config and phase_config.get('completion_marker'):
            time.sleep(2)  # Give GitHub API time
            marker = phase_config['completion_marker']
            if self.check_issue_comment(marker):
                self.update_status(phase, 'completed')
            else:
                self.update_status(phase, 'completed_unverified')
        else:
            self.update_status(phase, 'completed')

        return True

    def run_phase_chain(self, chain_name: str) -> bool:
        """Run a chain of phases"""
        chain_config = self.config.get_chain(chain_name)
        if not chain_config:
            self.log(f"❌ Unknown chain: {chain_name}")
            return False

        phases = chain_config.get('phases', [])
        if not phases:
            self.log(f"❌ No phases in chain: {chain_name}")
            return False

        self.log(f"{'='*60}")
        self.log(f"ADW Orchestration: {chain_name}")
        self.log(f"ADW ID: {self.adw_id}")
        self.log(f"Phases: {' → '.join(phases)}")
        if self.issue_number and self.repo:
            self.log(f"Issue: #{self.issue_number} ({self.repo})")
        self.log(f"{'='*60}")

        for i, phase in enumerate(phases):
            self.log(f"\n[{i+1}/{len(phases)}] Starting phase: {phase}")

            # Start session
            try:
                process = self.start_claude_session(phase)
            except Exception as e:
                self.log(f"❌ Failed to start {phase}: {e}")
                return False

            # Wait for completion
            success = self.wait_for_completion(process, phase)

            if not success:
                if self.config.config.get('automation', {}).get('stop_on_failure', True):
                    self.log(f"❌ Stopping due to {phase} failure")
                    return False
                else:
                    self.log(f"⚠️  {phase} failed but continuing...")

            # Cleanup process reference
            if phase in self.processes:
                del self.processes[phase]

            # Pause before next phase
            if i < len(phases) - 1:
                pause = self.config.config.get('automation', {}).get('pause_between_phases_seconds', 3)
                if pause > 0:
                    self.log(f"⏸️  Pausing {pause}s before next phase...")
                    time.sleep(pause)

        self.log(f"\n{'='*60}")
        self.log(f"✅ Chain '{chain_name}' complete!")
        self.log(f"{'='*60}")
        return True

    def cleanup(self):
        """Clean up any running processes"""
        for phase, process in self.processes.items():
            if process.poll() is None:  # Still running
                self.log(f"🧹 Terminating {phase} (PID: {process.pid})")
                process.terminate()
                try:
                    process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    process.kill()


class WebhookHandler(BaseHTTPRequestHandler):
    """HTTP handler for webhook requests"""

    orchestrator_config: OrchestratorConfig = None
    active_orchestrations: Dict[str, threading.Thread] = {}

    def log_message(self, format, *args):
        """Override to use custom logging"""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        message = f"[{timestamp}] {format % args}"
        print(message)

    def do_POST(self):
        """Handle POST webhook requests"""
        if self.path != '/webhook':
            self.send_error(404, "Not Found")
            return

        # Verify secret if configured
        config = self.orchestrator_config.config.get('webhook', {})
        secret = config.get('secret')

        if secret and secret != 'change-me-in-production':
            signature = self.headers.get('X-Hub-Signature-256', '')
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length)

            if not self._verify_signature(body, signature, secret):
                self.send_error(403, "Invalid signature")
                return
        else:
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length)

        # Parse payload
        try:
            payload = json.loads(body)
        except json.JSONDecodeError:
            self.send_error(400, "Invalid JSON")
            return

        # Extract event and ADW ID
        event = payload.get('event')
        adw_id = payload.get('adw_id')
        chain_name = payload.get('chain')

        if not event or not adw_id:
            self.send_error(400, "Missing event or adw_id")
            return

        # Find chain for event
        if not chain_name:
            chain_name = self.orchestrator_config.find_chain_for_event(event)

        if not chain_name:
            self.send_error(400, f"No chain configured for event: {event}")
            return

        # Start orchestration in background thread
        thread = threading.Thread(
            target=self._run_orchestration,
            args=(adw_id, chain_name),
            daemon=True
        )
        thread.start()

        self.active_orchestrations[adw_id] = thread

        # Send response
        self.send_response(202)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()

        response = {
            'status': 'accepted',
            'adw_id': adw_id,
            'chain': chain_name,
            'message': f'Orchestration started for {adw_id}'
        }
        self.wfile.write(json.dumps(response).encode())

    def _verify_signature(self, body: bytes, signature: str, secret: str) -> bool:
        """Verify GitHub webhook signature"""
        if not signature.startswith('sha256='):
            return False

        expected_sig = 'sha256=' + hmac.new(
            secret.encode(),
            body,
            hashlib.sha256
        ).hexdigest()

        return hmac.compare_digest(signature, expected_sig)

    def _run_orchestration(self, adw_id: str, chain_name: str):
        """Run orchestration in background"""
        try:
            orchestrator = ADWOrchestrator(adw_id, self.orchestrator_config)
            orchestrator.run_phase_chain(chain_name)
        except Exception as e:
            print(f"❌ Orchestration failed for {adw_id}: {e}")
            import traceback
            traceback.print_exc()


def serve_webhooks(config: OrchestratorConfig):
    """Start webhook server"""
    webhook_config = config.config.get('webhook', {})
    host = webhook_config.get('host', '0.0.0.0')
    port = webhook_config.get('port', 8765)

    WebhookHandler.orchestrator_config = config

    server = HTTPServer((host, port), WebhookHandler)

    print(f"{'='*60}")
    print(f"ADW Orchestrator Webhook Server")
    print(f"Listening on {host}:{port}")
    print(f"{'='*60}")
    print(f"\nWebhook endpoint: http://{host}:{port}/webhook")
    print(f"\nExample curl:")
    print(f'curl -X POST http://localhost:{port}/webhook \\')
    print(f'  -H "Content-Type: application/json" \\')
    print(f'  -d \'{{"event": "build_complete", "adw_id": "57ee23f4"}}\'')
    print(f"\nPress Ctrl+C to stop\n")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n\n🛑 Shutting down webhook server...")
        server.shutdown()


def main():
    parser = argparse.ArgumentParser(
        description='ADW Enhanced Orchestrator with webhook and hook support'
    )

    subparsers = parser.add_subparsers(dest='mode', help='Operation mode')

    # Direct run mode
    run_parser = subparsers.add_parser('run', help='Run orchestration directly')
    run_parser.add_argument('adw_id', help='ADW ID (8-char hex)')
    run_parser.add_argument('--chain', default='post_build', help='Chain name to run')
    run_parser.add_argument('--config', help='Path to config file')

    # Webhook server mode
    serve_parser = subparsers.add_parser('serve', help='Start webhook server')
    serve_parser.add_argument('--config', help='Path to config file')

    # Hook mode (called from Claude Code hooks)
    hook_parser = subparsers.add_parser('hook', help='Trigger from hook')
    hook_parser.add_argument('adw_id', help='ADW ID (8-char hex)')
    hook_parser.add_argument('--event', required=True, help='Event name (e.g., build_complete)')
    hook_parser.add_argument('--config', help='Path to config file')

    args = parser.parse_args()

    if not args.mode:
        parser.print_help()
        sys.exit(1)

    # Load config
    config_path = Path(args.config) if hasattr(args, 'config') and args.config else None
    config = OrchestratorConfig(config_path)

    if args.mode == 'run':
        # Direct run mode (semi-automatic)
        orchestrator = ADWOrchestrator(args.adw_id, config)
        try:
            success = orchestrator.run_phase_chain(args.chain)
            sys.exit(0 if success else 1)
        except KeyboardInterrupt:
            orchestrator.log("\n⚠️  Interrupted by user")
            orchestrator.cleanup()
            sys.exit(130)
        except Exception as e:
            orchestrator.log(f"❌ Failed: {e}")
            import traceback
            orchestrator.log(traceback.format_exc())
            orchestrator.cleanup()
            sys.exit(1)

    elif args.mode == 'serve':
        # Webhook server mode
        if not config.config.get('webhook', {}).get('enabled', False):
            print("❌ Webhook server is disabled in config")
            sys.exit(1)
        serve_webhooks(config)

    elif args.mode == 'hook':
        # Hook trigger mode
        if not config.config.get('automation', {}).get('hooks_enabled', False):
            print("❌ Hooks are disabled in config")
            sys.exit(1)

        # Find chain for this event
        chain_name = config.find_chain_for_event(args.event)
        if not chain_name:
            print(f"❌ No chain configured for event: {args.event}")
            sys.exit(1)

        orchestrator = ADWOrchestrator(args.adw_id, config)
        try:
            success = orchestrator.run_phase_chain(chain_name)
            sys.exit(0 if success else 1)
        except Exception as e:
            orchestrator.log(f"❌ Failed: {e}")
            sys.exit(1)


if __name__ == '__main__':
    main()
