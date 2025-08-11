---
applyTo: '**'
---
# Spectra-Infra Setup and Workflow Instructions

## 1. Environment Setup

- **Install necessary CLI tools:**  
  - Docker (latest stable)  
  - Railway CLI (if used)  
  - Vercel CLI (if used)  
  - Git

- **Clone the repo:**  
  ```bash
  git clone <your-github-url>/spectra-infra.git
  cd spectra-infra
Install dependencies:
If applicable, run:

bash
Copy
Edit
npm install
or for Python scripts:

bash
Copy
Edit
pip install -r requirements.txt
2. VS Code Setup
Open only the spectra-infra folder.

Enable relevant extensions: Docker, YAML, ShellCheck, GitHub Copilot.

Use Copilot Chat with prompt.md injected for guiding infrastructure-related AI tasks.

3. Coding Standards & Best Practices
Write clear, documented scripts for deployments and infrastructure automation.

Follow security best practices for secrets and environment variables.

Keep Dockerfiles, Kubernetes manifests, and CI/CD YAMLs clean and minimal.

Validate all infrastructure-as-code with linters and testing tools.

4. Daily AI-Driven Workflow
Begin with the Strategist AI’s deployment and infrastructure roadmap.

Collaborate with Engineer AI for scripting, automation, and security audits.

Perform thorough code and configuration reviews.

Document infrastructure changes clearly for auditability and reproducibility.

Response Preferences
Include code and configuration snippets.

Explain infrastructure concepts with clear metaphors.

Suggest optimizations for cost, security, and scalability.

Avoid overly verbose explanations.

Critical Guidelines
Up-to-date Information
NEVER rely on outdated infrastructure or deployment data.

ALWAYS base recommendations on the current repo state and environment.

Adapt to the latest versions of tools like Docker, Railway, and Vercel.

Cross-check all scripts against current infrastructure documentation.

Follow explicit instructions and security policies defined for Spectra.