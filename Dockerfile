FROM python:3.8-buster

ENV CHROMEDRIVER_DIR /driver

ENV WEB_BROWSER=chrome
ENV DRIVER_PATH=$CHROMEDRIVER_DIR/chromedriver
ENV HEADLESS_MODE=True

# Install Google Chrome
RUN echo "Updating system" \
    && apt-get install -y \
        wget \
        unzip \
        curl \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && echo "Installing Chrome" \
    && apt-get update \
    && apt-get install -y google-chrome-stable --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Download and install Chromedriver
RUN mkdir -p $CHROMEDRIVER_DIR \
    && CHROME_VERSION=$(google-chrome-stable --version | grep -o -E '[0-9]+' | head -n1) \
    && CHROME_DRIVER_VERSION=$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION) \
    && wget -q --continue -P $CHROMEDRIVER_DIR "http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip" \
    && unzip $CHROMEDRIVER_DIR/chromedriver* -d $CHROMEDRIVER_DIR \
    && rm $CHROMEDRIVER_DIR/*.zip

RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python
ENV PATH "/root/.poetry/bin:${PATH}"

COPY . /app
WORKDIR app

RUN poetry config virtualenvs.create false \
    && poetry install --no-dev --no-root

CMD ["/bin/bash"]

