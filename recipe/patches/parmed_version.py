# Handcrafted _version.py to fix
# https://github.com/conda-forge/ambertools-feedstock/issues/35

import json
import sys

version_json = """
{
 "date": "2020-02-26T10:02:00+0100",
 "dirty": false,
 "error": null,
 "full-revisionid": "aa15556ab201b53f99cf36394470c341526b69ed",
 "version": "3.2.0+27"
}
"""  # END VERSION_JSON


def get_versions():
    return json.loads(version_json)
