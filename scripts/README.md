# Workflow Best Practices Validation

This directory contains scripts to validate that workflow files follow best practices for the dev-proxy-tools/actions repository.

## Scripts

### validate-workflow-practices.sh

This script validates that:
1. Only workflows in `.github/workflows/` use local actions (`./action-name`)
2. Only workflows in `.github/workflows/` use `actions/checkout`

The script uses a baseline file to grandfather existing violations while preventing new ones.

### Usage

```bash
./scripts/validate-workflow-practices.sh
```

### Exit Codes

- `0`: Success - no new violations found
- `1`: Failure - new violations found

### Baseline File

The `workflow-practices-baseline.txt` file contains existing violations that are grandfathered in. This allows the validation to prevent new violations without breaking existing functionality.

Format:
```
<file_path>:<violation_type>
```

Where `violation_type` can be:
- `checkout`: Uses `actions/checkout`
- `local_action`: Uses local actions (`./action-name`)

### GitHub Actions Workflow

The `.github/workflows/validate-workflow-practices.yml` workflow runs this validation on:
- Pull requests to `main`
- Pushes to `main`

This ensures that new code follows the established best practices while maintaining backward compatibility for existing workflows.