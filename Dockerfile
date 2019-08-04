FROM justarchi/archisteamfarm:master

RUN apt-get update \
 && apt-get install -y jq sed zsh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY asf-fast-mode.zsh .
COPY docker-run.zsh .

ENTRYPOINT [ "sh" ]
CMD [ "./docker-run.zsh" ]
