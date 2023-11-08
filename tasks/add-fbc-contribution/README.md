# add-fbc-contribution

Task to create a internalrequest to add fbc contributions to index images

## Parameters

| Name           | Description                                                               | Optional | Default value        |
|----------------|---------------------------------------------------------------------------|----------|----------------------|
| snapshotPath   | Path to the JSON string of the mapped Snapshot spec in the data workspace | Yes      | snapshot_spec.json   |
| dataPath       | Path to the JSON string of the merged data to use in the data workspace   | Yes      | data.json            |
| requestTimeout | InternalRequest timeout                                                   | Yes      | 180                  |
| binaryImage    | binaryImage value updated by update-ocp-tag task                          | No       |                      |
| fromIndex      | fromIndex value updated by update-ocp-tag task                            | No       |                      |