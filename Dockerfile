ARG PROVIDER_REPO=https://github.com/ziyeqf/terraform-provider-azurerm.git
ARG PROVIDER_REF=msi_header
ARG PROVIDER_VERSION=0.0.0
ARG TARGETOS=linux
ARG TARGETARCH=amd64

FROM golang:1.25-bookworm AS provider-builder

ARG PROVIDER_REPO
ARG PROVIDER_REF
ARG PROVIDER_VERSION=0.0.0
ARG TARGETOS=linux
ARG TARGETARCH=amd64

WORKDIR /src

RUN git clone --depth 1 --branch "${PROVIDER_REF}" "${PROVIDER_REPO}" .

RUN CGO_ENABLED=0 GOOS="${TARGETOS}" GOARCH="${TARGETARCH}" \
    go build -mod=vendor \
      -ldflags="-s -w -X github.com/hashicorp/terraform-provider-azurerm/version.ProviderVersion=${PROVIDER_VERSION}" \
      -o /out/terraform-provider-azurerm .

FROM hashicorp/terraform:1.15.2

ARG PROVIDER_VERSION=0.0.0

ENV TF_CLI_CONFIG_FILE=/opt/tf-runner/terraform.tfrc

USER root

RUN mkdir -p \
    /opt/tf-runner \
    /opt/tf-provider-mirror/registry.terraform.io/hashicorp/azurerm/${PROVIDER_VERSION}/linux_amd64 \
    /workspace

COPY --from=provider-builder /out/terraform-provider-azurerm /opt/tf-provider-mirror/registry.terraform.io/hashicorp/azurerm/${PROVIDER_VERSION}/linux_amd64/terraform-provider-azurerm_v${PROVIDER_VERSION}
COPY terraform.tfrc /opt/tf-runner/terraform.tfrc
COPY entrypoint.sh /usr/local/bin/tf-runner
COPY smoke/ /workspace/

RUN chmod +x \
    /opt/tf-provider-mirror/registry.terraform.io/hashicorp/azurerm/${PROVIDER_VERSION}/linux_amd64/terraform-provider-azurerm_v${PROVIDER_VERSION} \
    /usr/local/bin/tf-runner

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/tf-runner"]
CMD ["plan", "-input=false"]
