FROM python:3.6 as base
LABEL maintainer="Espoir Murhabazi<espoir.mur [] gmail>"


# Never prompt the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONUNBUFFERED=1 \
    PORT=8080 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"\
    PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH" \
    NLTK_DATA=/usr/share/nltk_data


FROM base AS python-deps
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        build-essential

# Install Poetry - respects $POETRY_VERSION & $POETRY_HOME
ENV POETRY_VERSION=1.1.7
RUN curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python

# We copy our Python requirements here to cache them
# and install only runtime deps using poetry
WORKDIR $PYSETUP_PATH
COPY ./poetry.lock ./pyproject.toml ./
RUN poetry install --no-dev  # respects

## downolods nltk data
RUN python -m spacy download fr_core_news_sm -d ${NLTK_DATA}
RUN python -m spacy download fr
RUN python -m nltk.downloader -d ${NLTK_DATA} stopwords



FROM base AS runtime
# copy nltk data
COPY --from=python-deps  ${NLTK_DATA}  ${NLTK_DATA}
COPY --from=python-deps $POETRY_HOME $POETRY_HOME
COPY --from=python-deps $PYSETUP_PATH $PYSETUP_PATH


RUN useradd --create-home es.py
ENV WORKING_DIR=/home/es.py
COPY . ${WORKING_DIR}
WORKDIR ${WORKING_DIR}
USER es.py
EXPOSE 8080 5555 8793


