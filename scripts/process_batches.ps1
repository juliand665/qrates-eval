param (
	[Parameter(Mandatory = $true)][int]$start,
	[Parameter(Mandatory = $true)][int]$end
)

# other script relative to this one/$PSScriptRoot
$script_path = "$PSScriptRoot/create_database.ps1"

for ($i = $start; $i -le $end; $i++) {
	$workspace_path = "batches/batch-{0:d2}" -f $i
	& $script_path $workspace_path
}
