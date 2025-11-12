# safe_delete_s3_buckets.ps1
# Safely delete selected S3 buckets with confirmation and logging
# Works on Windows PowerShell or PowerShell Core

$logFile = "safe_delete_log.txt"
Write-Host "🪶 Logging actions to $logFile" -ForegroundColor Cyan
"==== S3 Bucket Deletion Run: $(Get-Date) ====" | Out-File -FilePath $logFile -Encoding UTF8

Write-Host "🔍 Fetching all S3 buckets..." -ForegroundColor Cyan
$buckets = aws s3api list-buckets --query "Buckets[].Name" --output text

if (-not $buckets) {
    Write-Host "✅ No S3 buckets found." -ForegroundColor Green
    "No S3 buckets found." | Out-File -FilePath $logFile -Append
    exit
}

$bucketsArray = $buckets -split "\s+"
Write-Host "`nFound the following buckets:" -ForegroundColor Yellow
foreach ($b in $bucketsArray) {
    Write-Host " - $b"
}

foreach ($b in $bucketsArray) {
    $response = Read-Host "`nDo you want to delete bucket '${b}'? (yes/no)"
    if ($response -ne "yes") {
        Write-Host "⏭️ Skipping ${b}" -ForegroundColor Cyan
        "Skipped: ${b}" | Out-File -FilePath $logFile -Append
        continue
    }

    Write-Host "🚨 Deleting bucket: ${b}" -ForegroundColor Red
    "Deleting bucket: ${b}" | Out-File -FilePath $logFile -Append

    # Empty the bucket
    Write-Host "   → Emptying bucket contents..."
    try {
        $versions = aws s3api list-object-versions --bucket ${b} --output json
        if ($versions -and $versions.Trim() -ne "") {
            aws s3api delete-objects --bucket ${b} --delete (aws s3api list-object-versions --bucket ${b} --query "{Objects: Versions[].{Key:Key,VersionId:VersionId}}" --output json) 2>$null
            aws s3api delete-objects --bucket ${b} --delete (aws s3api list-object-versions --bucket ${b} --query "{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}" --output json) 2>$null
            Write-Host "   ✓ Bucket emptied successfully."
            "Emptied: ${b}" | Out-File -FilePath $logFile -Append
        } else {
            Write-Host "   ⚠️ Bucket is already empty or has no versions."
            "Already empty: ${b}" | Out-File -FilePath $logFile -Append
        }
    }
    catch {
        Write-Host "   ⚠️ Warning: Failed to fully empty ${b} or it might already be empty."
        "Warning: Could not empty ${b}" | Out-File -FilePath $logFile -Append
    }

    # Delete the bucket
    try {
        aws s3api delete-bucket --bucket ${b}
        Write-Host "   🗑️ Deleted ${b} successfully." -ForegroundColor Green
        "Deleted: ${b}" | Out-File -FilePath $logFile -Append
    }
    catch {
        Write-Host "   ❌ Failed to delete ${b}: $($_.Exception.Message)" -ForegroundColor Red
        "Failed to delete ${b}: $($_.Exception.Message)" | Out-File -FilePath $logFile -Append
    }
}

Write-Host "`n🧾 Remaining S3 buckets:" -ForegroundColor Cyan
$remaining = aws s3api list-buckets --query "Buckets[].Name" --output text
Write-Host $remaining
"`nRemaining buckets:`n$remaining" | Out-File -FilePath $logFile -Append

Write-Host "`n✅ Script finished. Log saved to $logFile" -ForegroundColor Green
"==== End of Run: $(Get-Date) ====`n" | Out-File -FilePath $logFile -Append