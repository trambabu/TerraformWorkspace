##############################################
# Script: reimport_and_delete_s3.ps1
# Purpose: Safely re-import & delete S3 buckets via Terraform
# Author: ChatGPT
##############################################

# --- Define bucket names here ---
$buckets = @(
    "tramfrontends3bucket",
    "tramordersservices3bucket",
    "tramuserservices3bucket"
)

Write-Host "`n=== Initializing Terraform ===`n" -ForegroundColor Cyan
terraform init

# --- Step 1: Remove old state entries ---
Write-Host "`n=== Cleaning old Terraform state entries ===`n" -ForegroundColor Yellow
foreach ($b in $buckets) {
    terraform state rm "aws_s3_bucket.buckets_to_delete[`"$b`"]" 2>$null
}

# --- Step 2: Import existing S3 buckets ---
Write-Host "`n=== Importing existing S3 buckets into Terraform state ===`n" -ForegroundColor Cyan
foreach ($b in $buckets) {
    terraform import "aws_s3_bucket.buckets_to_delete[`"$b`"]" $b
}

# --- Step 3: Verify ---
Write-Host "`n=== Current Terraform state entries ===`n" -ForegroundColor Green
terraform state list

# --- Step 4: Show destruction plan ---
Write-Host "`n=== Terraform Plan (Preview of what will be destroyed) ===`n" -ForegroundColor Yellow
terraform plan

# --- Step 5: Display buckets to be deleted ---
Write-Host "`nThe following S3 buckets are about to be deleted:" -ForegroundColor Red
foreach ($b in $buckets) {
    Write-Host " - $b" -ForegroundColor White
}

# --- Step 6: Ask for confirmation before deletion ---
$confirmation = Read-Host "`nDo you want to permanently delete these buckets? (yes/no)"
if ($confirmation -eq "yes") {
    Write-Host "`n=== Destroying imported S3 buckets... (This is PERMANENT) ===`n" -ForegroundColor Red
    terraform destroy -auto-approve
    Write-Host "`n=== ✅ All specified S3 buckets deleted successfully! ===`n" -ForegroundColor Green
} else {
    Write-Host "`n❌ Deletion canceled by user. No changes made.`n" -ForegroundColor Yellow
}
