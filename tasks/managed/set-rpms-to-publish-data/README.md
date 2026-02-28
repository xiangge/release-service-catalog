# set-rpms-to-publish-data

Updates the snapshot with RPMs to publish data for each component.

The task:
- pulls RPM files from each component's OCI artifact
- parses NEVRA (Name-Epoch-Version-Release-Arch) from RPM headers
- writes the RPMs that need publishing under `.components[].rpmsToPublish`
- removes components with an empty `.rpmsToPublish` list
- overwrites the snapshot file in-place

## Parameters

| Name                    | Description                                                                                                                | Optional | Default value                |
|-------------------------|----------------------------------------------------------------------------------------------------------------------------|----------|------------------------------|
| snapshotPath            | Path to the JSON Snapshot spec in the data workspace                                                                       | No       | -                            |
| DEFAULT_EXCLUDES        | comma-delimited list of file patterns to exclude from consideration                                                        | Yes      | -debuginfo-, -debugsource-   |
| DEFAULT_ARCHITECTURES   | Comma-delimited list of default architectures to use for noarch RPMs when no arch-specific RPMs are found                  | Yes      | x86_64,aarch64,s390x,ppc64le |
| ociStorage              | The OCI repository where the Trusted Artifacts are stored                                                                  | Yes      | empty                        |
| ociArtifactExpiresAfter | Expiration date for the trusted artifacts created in the OCI repository. An empty string means the artifacts do not expire | Yes      | 1d                           |
| trustedArtifactsDebug   | Flag to enable debug logging in trusted artifacts. Set to a non-empty string to enable                                     | Yes      | ""                           |
| orasOptions             | oras options to pass to Trusted Artifacts calls                                                                            | Yes      | ""                           |
| sourceDataArtifact      | Location of trusted artifacts to be used to populate data directory                                                        | Yes      | ""                           |
| dataDir                 | The location where data will be stored                                                                                     | Yes      | /var/workdir/release         |
| taskGitUrl              | The url to the git repo where the release-service-catalog tasks and stepactions to be used are stored                      | No       | -                            |
| taskGitRevision         | The revision in the taskGitUrl repo to be used                                                                             | No       | -                            |
| caTrustConfigMapName    | The name of the ConfigMap to read CA bundle data from                                                                      | Yes      | trusted-ca                   |
| caTrustConfigMapKey     | The name of the key in the ConfigMap that contains the CA bundle data                                                      | Yes      | ca-bundle.crt                |
