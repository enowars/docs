#!/bin/bash
SERVICES=(
  "1,servicename1,2000"
  "2,servicename2,2001"
)

ip="127.0.0.1"

cat << EOF > /services/EnoEngine/ctf.json
{
  "title": "TESTCTF",
  "flagValidityInRounds": 10,
  "checkedRoundsPerRound": 3,
  "roundLengthInSeconds": 60,
  "dnsSuffix": ".domain.com",
  "teamSubnetBytesLength": 16,
  "flagSigningKey": "flagsigningkey",
  "encoding": "Legacy",
  "teams": [
    {
      "id": 1,
      "name": "Team 1",
      "address": "$ip",
      "teamSubnet": "::ffff:10.0.0.8",
      "countryFlagUrl": "US",
      "active": true
    },
    {
      "id": 2,
      "name": "Team 2",
      "address": "$ip",
      "teamSubnet": "::ffff:10.0.0.8",
      "countryFlagUrl": "US",
      "active": true
    },
    {
      "id": 3,
      "name": "Team 3",
      "address": "$ip",
      "teamSubnet": "::ffff:10.0.0.8",
      "countryFlagUrl": "US",
      "active": true
    }
  ],
    "services": [
EOF


for dataRow in "${SERVICES[@]}"; do
    while IFS=',' read -r id name port; do
        cat << EOF >> /services/EnoEngine/ctf.json
{
        "id": $id,
        "name": "$name",
        "flagsPerRoundMultiplier": 1,
        "noisesPerRoundMultiplier": 1,
        "havocsPerRoundMultiplier": 1,
        "weightFactor": 1,
        "checkers": ["http://$ip:$port"]
    },
EOF
    done <<< "$dataRow"
done



cat << EOF >> /services/EnoEngine/ctf.json
]
}
EOF
