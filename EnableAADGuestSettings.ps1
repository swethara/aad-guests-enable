
#!/usr/bin/env pwsh
#requires -Version 5.1
<#
Purpose:
  Enable AAD Guests for a Viva Engage (Yammer) network:
    network[aad_guests_enabled]=true

API:
  PUT https://www.yammer.com/api/v1/networks/<nid>?network[aad_guests_enabled]=true

Usage:
  ./aad-guests-enable.ps1 "<AAD_ACCESS_TOKEN>" "<NETWORK_ID>"

Notes:
  - Enables only (true). No disable operation here.
  - Uses query string; no request body.
#>

param(
  [Parameter(Mandatory = $true)]
  [string]$Token,

  [Parameter(Mandatory = $true)]
  [string]$NetworkId
)

# --- Config ---
$BaseUrl    = 'https://www.yammer.com'
$BasePath   = '/api/v1/networks/'
$Method     = 'PUT'
$TimeoutSec = 60

# --- Pre-flight validation (correct .NET call) ---
if ([string]::IsNullOrWhiteSpace($Token)) {
  Write-Error "Token was empty."
  exit 2
}
if ([string]::IsNullOrWhiteSpace($NetworkId)) {
  Write-Error "NetworkId was empty."
  exit 2
}

# --- Build request ---
$key   = 'network[aad_guests_enabled]'
$value = 'true'  # <-- enable only

$encodedKey   = [System.Uri]::EscapeDataString($key)    # network%5Baad_guests_enabled%5D
$encodedValue = [System.Uri]::EscapeDataString($value)  # true
$query        = "$encodedKey=$encodedValue"

# Final URL: https://www.yammer.com/api/v1/networks/<nid>?network%5Baad_guests_enabled%5D=true
$Url = "{0}{1}{2}?{3}" -f $BaseUrl, $BasePath, $NetworkId, $query

$Headers = @{
  Authorization = "Bearer $Token"
  Accept        = 'application/json'
}

# --- Execute request ---
try {
  # No body needed; avoid forcing JSON content type
  $resp = Invoke-WebRequest -Uri $Url -Method $Method -Headers $Headers `
          -TimeoutSec $TimeoutSec -ErrorAction Stop

  if ($resp.Content) {
    $resp.Content | Write-Output
  } else {
    Write-Output ("{""status"":{0}}" -f [int]$resp.StatusCode)
  }
  exit 0
}
catch {
  $ex = $_.Exception
  $status = $null; $desc = $null; $body = $null

  if ($ex.Response -is [System.Net.HttpWebResponse]) {
    $status = [int]$ex.Response.StatusCode
    $desc   = $ex.Response.StatusDescription
    try {
      $stream = $ex.Response.GetResponseStream()
      if ($stream) { $reader = [System.IO.StreamReader]::new($stream); $body = $reader.ReadToEnd() }
    } catch {}
  }

  Write-Host "❌ HTTP call failed:" -ForegroundColor Red
  [ordered]@{
    method             = $Method
    url                = $Url
    status             = $status
    status_description = $desc
    response_body      = $body
    exception_type     = $ex.GetType().FullName
    exception_message  = $ex.Message
  } | ConvertTo-Json -Depth 10 | Write-Host

  if ($status) { Write-Error ("Request failed (HTTP {0} {1})" -f $status, $desc) }
  else { Write-Error "Request failed (no HTTP response received)" }
  exit 1
}
