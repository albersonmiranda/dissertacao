# Pre-built Dev Container Image for R. More info: https://github.com/rocker-org/devcontainer-images/pkgs/container/devcontainer%2Ftidyverse
# Available R version: 4, 4.1, 4.0
ARG VARIANT="4.3"
FROM ghcr.io/rocker-org/devcontainer/r-ver:${VARIANT}

RUN install2.r --error --skipinstalled -n -1 \
        mlr3verse \
        fabletools \
        feasts \
        fable \
        dplyr \
        pacman \
        janitor \
        glmnet \
        ranger \
        xgboost \
        DiceKriging \
        e1071 \
        lightgbm \
    && rm -rf /tmp/downloaded_packages

# Install Python packages
COPY requirements.txt /tmp/pip-tmp/
RUN python3 -m pip --disable-pip-version-check --no-cache-dir install -r /tmp/pip-tmp/requirements.txt