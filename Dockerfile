FROM erlang:27 AS build
COPY --from=ghcr.io/gleam-lang/gleam:v1.13.0-erlang /bin/gleam /bin/gleam
COPY . /app/

WORKDIR /app/
RUN gleam build
RUN gleam export erlang-shipment
WORKDIR /

FROM erlang:27

RUN \
  addgroup --system webapp && \
  adduser --system webapp --ingroup webapp

USER webapp

COPY --from=build /app/build/erlang-shipment /app
COPY domains.txt /app/domains.txt

WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
EXPOSE 3000

CMD ["run", "serve"]

