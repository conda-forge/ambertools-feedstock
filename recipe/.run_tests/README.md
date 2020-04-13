To run the full test suite:

* merge this `run_test.sh` with the one under `/recipe`
* move `yum_requirements.txt` to `/recipe`
* add these two lines to `test:` section in `meta.yaml`

```
source_files:
  - "*"
```