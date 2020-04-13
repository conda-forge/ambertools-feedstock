To run the full test suite:

* merge this `run_test.sh` with the one under `/recipe`
* move `yum_requirements.txt` to `/recipe`
* update the `test:` section in `meta.yaml`

```yaml
test:
  requires:
    - {{ compiler('fortran') }}
    - {{ compiler('c') }}
    - {{ compiler('cxx') }}
    - util-linux  # [linux64]
    ...
  source_files:
    - "*"
  ...
```