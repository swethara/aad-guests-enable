
Disclaimer:
The script is unsupported by the Microsoft Support (CSS). It is expected that users understand how to read the script, go through and execute the script to enable the guest AAD settings for their viva engage network.  


# AAD Guests Enable Script (Viva Engage)

This PowerShell script enables the AAD Guests setting for a Viva Engage (Yammer) network.

## Usage

```pwsh
./aad-guests-enable.ps1 "<AAD_ACCESS_TOKEN>" "<NETWORK_ID>"


API:
PUT https://www.yammer.com/api/v1/networks/<nid>?network[aad_guests_enabled]=true
Notes:

Enables only (true); no disable option.
Requires Viva Engage admin permissions.


The script requires token and network ID as input.

Token: A string containing a valid Entra token with Global Admin privileges. Token should be obtained from the Global admin privilege.
Network ID: Unique ID of the network.
