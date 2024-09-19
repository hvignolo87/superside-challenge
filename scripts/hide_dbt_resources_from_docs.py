import json
from pathlib import Path
from typing import Any, Dict, Tuple, Union

import click


@click.command()
@click.option(
    "--dbt-project-dir",
    "-d",
    type=str,
    required=False,
    help="The path to the dbt project directory",
)
@click.option(
    "--exclude-macro",
    "-e",
    multiple=True,
    type=str,
    required=False,
    help="The name of the macro to exclude from hiding in the docs",
)
def hide_dbt_resources_from_docs(
    dbt_project_dir: Union[str, None],
    exclude_macro: Tuple[str],
):
    """
    Hides DBT resources from the docs by changing its docs.show
    config in the manifest.json file

    dbt doesn't hide some resources from the docs:
    https://github.com/dbt-labs/dbt-core/issues/8061

    This is a workaround for that issue https://dbtips.substack.com/p/dbtips-digest-1
    """
    dbt_project_path = Path.cwd() if not dbt_project_dir else Path(dbt_project_dir)
    manifest_path = dbt_project_path / "target" / "manifest.json"

    if not manifest_path.is_file():
        raise FileNotFoundError(f"Manifest file not found at {manifest_path}")

    data: Dict[str, Any]
    with open(manifest_path, "r", encoding="utf-8") as manifest:
        data = json.loads(manifest.read())

    # need to do this here because dbt_project.yml don't support macro resource
    for macro in data["macros"]:
        if not exclude_macro or macro not in exclude_macro:
            data["macros"][macro]["docs"].update({"show": False})

    # the sources can't be hidden in the docs, this is an issue with dbt
    # https://github.com/dbt-labs/dbt-core/issues/8061#issuecomment-1863292897
    # for source in data["sources"]:
    #     data["sources"][source]["config"]["docs"].update({"show": False})
    #     data["sources"][source]["unrendered_config"]["docs"].update({"show": False})

    with open(manifest_path, "w", encoding="utf-8") as manifest:
        json.dump(data, manifest, indent=None, separators=(",", ":"))


if __name__ == "__main__":
    hide_dbt_resources_from_docs()
