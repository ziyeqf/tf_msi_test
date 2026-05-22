ARG PROVIDER_REPO=https://github.com/ziyeqf/terraform-provider-azurerm.git
ARG PROVIDER_REF=msi_header
ARG TARGETOS=linux
ARG TARGETARCH=amd64

FROM golang:1.25-bookworm AS provider-builder

ARG PROVIDER_REPO
ARG PROVIDER_REF
ARG TARGETOS=linux
ARG TARGETARCH=amd64

WORKDIR /src

RUN git clone --depth 1 --branch "${PROVIDER_REF}" "${PROVIDER_REPO}" .

RUN CGO_ENABLED=0 GOOS="${TARGETOS}" GOARCH="${TARGETARCH}" \
    go build -mod=vendor -o /out/terraform-provider-azurerm .

FROM hashicorp/terraform:1.15.2

ENV TF_CLI_CONFIG_FILE=/opt/tf-runner/terraform.tfrc

USER root

RUN mkdir -p \
    /opt/tf-provider-dev/azurerm \
    /opt/tf-runner \
    /workspace

COPY --from=provider-builder /out/terraform-provider-azurerm /opt/tf-provider-dev/azurerm/terraform-provider-azurerm
COPY terraform.tfrc /opt/tf-runner/terraform.tfrc
COPY entrypoint.sh /usr/local/bin/tf-runner
COPY smoke/ /workspace/

RUN chmod +x \
    /opt/tf-provider-dev/azurerm/terraform-provider-azurerm \
    /usr/local/bin/tf-runner

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/tf-runner"]
