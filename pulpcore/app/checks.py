from pathlib import Path

from django.conf import settings
from django.core.checks import Error as CheckError, Warning as CheckWarning, register


@register(deploy=True)
def secret_key_check(app_configs, **kwargs):
    messages = []
    if getattr(settings, "SECRET_KEY", "SECRET") == "SECRET":
        messages.append(
            CheckError(
                "SECRET_KEY is a required setting but it was not configured. It does not "
                "come pre-configured by the installation and it should be set to a unique, "
                "unpredictable value.",
                id="pulpcore.E001",
            )
        )
    return messages


@register(deploy=True)
def storage_paths(app_configs, **kwargs):
    warnings = []

    if settings.STORAGES["default"]["BACKEND"] == "pulpcore.app.models.storage.FileSystem":
        try:
            media_root_dev = Path(settings.MEDIA_ROOT).stat().st_dev
        except OSError:
            media_root_dev = None
            warnings.append(
                CheckWarning(
                    "Your MEDIA_ROOT setting points to a path that does not exist.",
                    id="pulpcore.W001",
                )
            )

        try:
            working_dir_dev = Path(settings.WORKING_DIRECTORY).stat().st_dev
        except OSError:
            working_dir_dev = None
            warnings.append(
                CheckWarning(
                    "Your WORKING_DIRECTORY setting points to a path that does not exist.",
                    id="pulpcore.W002",
                )
            )

        if media_root_dev and media_root_dev != working_dir_dev:
            warnings.append(
                CheckWarning(
                    "MEDIA_ROOT and WORKING_DIRECTORY are on different filesystems. "
                    "It is highly recommended that these live on the same filesystem",
                    id="pulpcore.W003",
                )
            )

    return warnings
