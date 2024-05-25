

```yml
nginx-sign-container:
  extends: .sign-container
  stage: build-and-scans
  variables:
    IMAGE_NAME: ${COMMON_NGINX_NAME}:${DOCKER_VERSION}
    DOCKER_REGISTRY: ${CI_REGISTRY}/${CI_PROJECT_NAMESPACE}/${CI_PROJECT_NAME}
    DIGESTFILE_NAME: ${NGINX_SOURCE_DIR}/digest
    COSIGN_PASSWORD: "cnxcp"
    SIGN_OPTS: "--annotations project=cnxcp --annotations purpose=nginx-proxy"
    SIGN_ATTESTATION_OPTS: "--attachment-tag-prefix nginx-registry-att-"
    SIGN_SBOM_OPTS: "--attachment-tag-prefix nginx-registry-sbom-"
  needs:
  - job: nginx-build
    artifacts: true

squid-sign-container:
  extends: .sign-container
  stage: build-and-scans
  variables:
    IMAGE_NAME: ${COMMON_SQUID_NAME}:${DOCKER_VERSION}
    DOCKER_REGISTRY: ${CI_REGISTRY}/${CI_PROJECT_NAMESPACE}/${CI_PROJECT_NAME}
    DIGESTFILE_NAME: ${SQUID_SOURCE_DIR}/digest
    COSIGN_PASSWORD: "cnxcp"
    SIGN_OPTS: "--annotations project=cnxcp --annotations purpose=squid-proxy"
    SIGN_ATTESTATION_OPTS: "--attachment-tag-prefix squid-registry-att-"
    SIGN_SBOM_OPTS: "--attachment-tag-prefix squid-registry-sbom-"
  needs:
  - job: squid-build
    artifacts: true

nginx-verify-container:
  stage: build-and-scans
  extends: .verify-container
  variables:
    IMAGE_VERSION: ${DOCKER_VERSION}
    IMAGE_NAME: ${COMMON_NGINX_NAME}
    DOCKER_REGISTRY: ${CI_REGISTRY}/${CI_PROJECT_NAMESPACE}/${CI_PROJECT_NAME}
    VERIFY_OPTS: "--annotations project=cnxcp --annotations purpose=nginx-proxy"
    VERIFY_ATTESTATION_OPTS: "--attachment-tag-prefix nginx-registry-att- --check-claims=false"
    VERIFY_SBOM_OPTS: "--attachment-tag-prefix nginx-registry-sbom-"
  needs:
  - job: nginx-build
    artifacts: true
  - job: nginx-sign-container
    artifacts: true

squid-verify-container:
  stage: build-and-scans
  extends: .verify-container
  variables:
    IMAGE_VERSION: ${DOCKER_VERSION}
    IMAGE_NAME: ${COMMON_SQUID_NAME}
    DOCKER_REGISTRY: ${CI_REGISTRY}/${CI_PROJECT_NAMESPACE}/${CI_PROJECT_NAME}
    VERIFY_OPTS: "--annotations project=cnxcp --annotations purpose=squid-proxy"
    VERIFY_ATTESTATION_OPTS: "--attachment-tag-prefix squid-registry-att- --check-claims=false"
    VERIFY_SBOM_OPTS: "--attachment-tag-prefix squid-registry-sbom-"
  needs:
  - job: squid-build
    artifacts: true
  - job: squid-sign-container
    artifacts: true
```
