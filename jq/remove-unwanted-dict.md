

```bash
#!/bin/bash

NEXUS_IQ_QUALITY_CONTROL="true"

# Define the file name and the 
FILE_NAME="demo.json"

# Define comma-separated list of CVE IDs
NEXUS_FALSE_POSITIVE_CASES_ID="CVE-2024-30171"

# Remove the white-list case ids implementations
if [[ ! -z "${NEXUS_FALSE_POSITIVE_CASES_ID}" ]]; then
    remove_vulnerabilities() {
        for case in $(echo "${NEXUS_FALSE_POSITIVE_CASES_ID}" | tr "," "\n"); do
            jq --arg id "$case" '.vulnerabilities |= map(select(.id != $id))' "${FILE_NAME}" > tmp.$$.json && mv tmp.$$.json "${FILE_NAME}"
        done
    }
    remove_vulnerabilities
    echo "Removed false positive vulnerabilities with IDs: ${NEXUS_FALSE_POSITIVE_CASES_ID}"
    
    # Calculate vuln_count only if there are false positive vulnerabilities to remove

    if [[ $(jq '.vulnerabilities | length' "${FILE_NAME}") -gt 0 ]]; then
        echo "Vulnerabilities detected by NexusIQ Scan, and the state of NexusIQ quality control is enforced."
        exit 1
    else
        echo "NexusIQ Scan detected no vulnerabilities."
    fi
else
    echo "No false positive vulnerabilities to remove."
fi

```

demo.json file

```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.4",
  "serialNumber": "urn:uuid:5b834733-1eb7-4dbf-9ada-2b8dd0042604",
  "version": 1,
  "vulnerabilities": [
    {
      "id": "CVE-2024-30171",
      "source": {
        "name": "NVD",
        "url": "http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2024-30171"
      },
      "ratings": [
        {
          "source": {
            "name": "NVD"
          },
          "score": 5.9,
          "severity": "high",
          "method": "other",
          "vector": "CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:N/A:N"
        }
      ],
      "cwes": [
        208
      ],
      "affects": [
        {
          "ref": "3406cadf-8b41-44b6-af05-5186dd50632b"
        }
      ]
    },
    {
      "id": "CVE-2024-30172",
      "source": {
        "name": "NVD",
        "url": "http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2024-30171"
      },
      "ratings": [
        {
          "source": {
            "name": "NVD"
          },
          "score": 5.9,
          "severity": "high",
          "method": "other",
          "vector": "CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:N/A:N"
        }
      ],
      "cwes": [
        208
      ],
      "affects": [
        {
          "ref": "3406cadf-8b41-44b6-af05-5186dd50632b"
        }
      ]
    },
    {
      "id": "CVE-2024-3017",
      "source": {
        "name": "NVD",
        "url": "http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2024-30171"
      },
      "ratings": [
        {
          "source": {
            "name": "NVD"
          },
          "score": 5.9,
          "severity": "high",
          "method": "other",
          "vector": "CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:N/A:N"
        }
      ],
      "cwes": [
        208
      ],
      "affects": [
        {
          "ref": "3406cadf-8b41-44b6-af05-5186dd50632b"
        }
      ]
    }
  ]
}

```
