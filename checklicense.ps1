# Kịch bản kiểm tra tình trạng bản quyền Windows
# Sử dụng lớp CIM SoftwareLicensingProduct để truy vấn thông tin bản quyền hệ điều hành Windows hiện tại

$WindowsProduct = Get-CimInstance -ClassName SoftwareLicensingProduct |
    Where-Object { 
        $_.PartialProductKey -and 
        $_.Name -like "*Windows*" -and 
        $_.ApplicationID -eq "55c92734-d682-4d71-983e-d6ec3f16059f" 
    } |
    Select-Object -First 1

if (-not $WindowsProduct) {
    Write-Host "Không tìm thấy thông tin bản quyền Windows." -ForegroundColor Red
    return
}

# Ánh xạ trạng thái LicenseStatus sang mô tả có thể đọc được
$StatusMap = @{
    0 = "Chưa được cấp phép"
    1 = "Đã kích hoạt"
    2 = "Thời gian gia hạn ban đầu"
    3 = "Thời gian gia hạn bổ sung"
    4 = "Thời gian gia hạn không chính hãng"
    5 = "Chế độ thông báo"
    6 = "Thời gian gia hạn mở rộng"
}

$LicenseStatusText = if ($StatusMap.ContainsKey([int]$WindowsProduct.LicenseStatus)) {
    $StatusMap[[int]$WindowsProduct.LicenseStatus]
} else {
    "Không xác định (Mã: $($WindowsProduct.LicenseStatus))"
}

# Xây dựng đối tượng kết quả đầu ra
$Result = [PSCustomObject]@{
    "Tên sản phẩm"      = $WindowsProduct.Name
    "Mô tả"             = $WindowsProduct.Description
    "Trạng thái bản quyền" = $LicenseStatusText
    "Mã trạng thái"     = $WindowsProduct.LicenseStatus
    "Khóa sản phẩm một phần" = $WindowsProduct.PartialProductKey
    "Kênh khóa sản phẩm" = $WindowsProduct.ProductKeyChannel
    "Thời gian gia hạn còn lại (phút)" = $WindowsProduct.GracePeriodRemaining
}

$Result | Format-List