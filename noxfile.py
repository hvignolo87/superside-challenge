import nox

PYTHON_VERSION = "3.10.12"
POETRY_VERSION = "1.6.1"


@nox.session(reuse_venv=True, python=PYTHON_VERSION)
def hooks(session: nox.Session) -> None:
    """
    Run all the pre-commit hooks in all the files.

    Parameters
    ----------
    session : nox.Session
        The nox session

    Returns
    -------
    None
    """
    session.install(f"poetry=={POETRY_VERSION}")
    session.run("poetry", "install", "--no-interaction", "--only", "dev")
    session.run("poetry", "run", "pre-commit", "install")

    session.run(
        "poetry",
        "run",
        "pre-commit",
        "run",
        "--hook-stage",
        "commit",
        "--show-diff-on-failure",
        "--all-files",
    )
