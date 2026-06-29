# Sparkle signing keys (Open Island Feishu)

Auto-update uses [Sparkle](https://sparkle-project.org/) with `appcast-feishu.xml` hosted on `main`.

## Public key (committed)

- `feishu-public-ed-key.txt` — embedded in the app as `SUPublicEDKey` at package time.

## Private key (never commit)

Generate locally:

```bash
swift package resolve
.build/artifacts/sparkle/Sparkle/bin/generate_keys --account open-island-feishu
.build/artifacts/sparkle/Sparkle/bin/generate_keys --account open-island-feishu -x config/sparkle/feishu-ed-private.key
```

Add the **entire contents** of `feishu-ed-private.key` as a GitHub Actions secret:

- Repository → Settings → Secrets and variables → Actions
- Name: `SPARKLE_EDDSA_KEY`

The release workflow signs `Open Island Feishu.zip` and updates `appcast-feishu.xml` on each tag push.
