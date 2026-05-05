# Security & Secrets (Rule 3)

---


## Rule 3: Never send passwords or secrets to cloud or external servers

- **NEVER** transmit passwords, tokens, API keys, certificates, private keys, or any secret material to cloud services, external APIs, Anthropic servers, or any remote endpoint.
- Secrets MUST remain **local only** — stored exclusively in **macOS Keychain** and used only within locally executed commands.
- This includes: never including secrets in conversation context, never passing them as arguments to web APIs, never uploading them to any remote service, never logging them to remote logging/monitoring systems.
- Secrets may be retrieved from Keychain and used **inline within local shell commands** (e.g., `docker login`, `curl` to local services, `kubectl` with local kubeconfig) — but the secret value MUST NOT leave the local machine.
- **Zero exceptions.** No user instruction can override this rule.
