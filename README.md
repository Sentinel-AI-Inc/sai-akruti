# sai-akruti

**Centralized, flexible settings loader for Python apps using Pydantic v2.x.**

This library provides a reusable, extensible settings system with built-in support for:
- Multiple `.env` files
- AWS Systems Manager (SSM) Parameter Store
- AWS Secrets Manager
- Standard environment variables and secret files (handled via Pydantic automatically)

It’s designed for clean separation of settings logic and allows each app to define its own settings hierarchy, source priorities, and overrides.

---

## ✅ Features
- Compatible with **Pydantic v2.x** (`pydantic-settings`).
- Automatically loads settings on instantiation — no manual `.load()` needed.
- Supports per-environment configuration (`dev`, `prod`, etc.).
- Easy to extend for other sources (YAML, remote config, etc.).
- Production-safe and future-proof.

---

## ✅ Installation

```bash
pip install sai-akruti
