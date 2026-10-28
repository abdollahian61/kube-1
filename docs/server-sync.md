# Synchronizing real server files into this repository

The repository currently contains **conversation-derived copies/templates**. It is not a byte-for-byte export of the server.

To synchronize the actual files from `tst-jfrog`, use a local clone on that server. Review every diff before committing.

```bash
git clone https://github.com/abdollahian61/kube-1.git
cd kube-1
# Review differences against /home/abdollahian/eways-kubespray-custom/
# Never copy the venv, private keys, kubeconfig, passwords, tokens, or .env.
git status
git diff
```

Avoid blindly running `cp -a` or `git add -A` on a live server. Use `git diff --check` and scan for credentials before pushing. Inventory `hosts.yaml` is intentionally ignored; `hosts.yaml.example` is the publishable template.

The original custom repository may also include additional scripts not visible in the conversation. Those cannot be asserted as backed up here.
