param (
	[Parameter(Mandatory = $true)][string]$workspace_path
)

scp $workspace_path/rust-corpus.zip julian@pmserver.inf.ethz.ch:workspace/
ssh julian@pmserver.inf.ethz.ch -t './server_process.sh'
scp julian@pmserver.inf.ethz.ch:workspace/database.zip $workspace_path/
mkdir -p $workspace_path/reports/resolved-calls
scp julian@pmserver.inf.ethz.ch:workspace/reports/resolved-calls/all_calls.csv $workspace_path/reports/resolved-calls/
scp julian@pmserver.inf.ethz.ch:workspace/reports/resolved-calls/cross_crate_calls.csv $workspace_path/reports/resolved-calls/
