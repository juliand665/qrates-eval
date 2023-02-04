$7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"

if (-not (Test-Path -Path $7zipPath -PathType Leaf)) {
	throw "7 zip file '$7zipPath' not found"
}

Set-Alias Start-SevenZip $7zipPath

Get-ChildItem | ForEach-Object { #-Parallel {
	Push-Location $_.Name
	try {
		$folder = "database"
		$zip = "$folder.zip"
		if (Test-Path -Path "$zip" -PathType Leaf) {
			Write-Host "Skipping " + $_.Name
			return
		}
		Write-Host "Processing $name"
		# 7zip is way way faster than built-in compressor because it uses concurrency; makes smaller archives; and doesn't need to load it all into ram first
		Start-SevenZip a -mx=5 "$folder.zip" "$folder"
		Remove-Item -Path "$folder" -Recurse
	} finally {
		Pop-Location
	}
}
