To run the full test suite:

* move `run_test.sh` and `yum_requirements.txt` to `/recipe`
* add these two lines to `test:` section in `meta.yaml`

```
source_files:
  - "*"
```