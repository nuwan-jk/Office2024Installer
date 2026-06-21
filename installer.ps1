
# 1. Require Administrator Privileges and Hide PowerShell Window
$isWindowsPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin = $isWindowsPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    $args = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command `" `$w=(New-Object Net.WebClient);`$w.Encoding=[Text.Encoding]::UTF8;iex `$w.DownloadString('$HostedUrl') `""
    Start-Process -FilePath "powershell.exe" -ArgumentList $args -Verb runas -WindowStyle Hidden
    exit
} else {
    $code = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
    $win32 = Add-Type -MemberDefinition $code -name "Win32ShowWindow" -namespace Win32Functions -PassThru
    $win32::ShowWindow((Get-Process -Id $PID).MainWindowHandle, 0) | Out-Null
}

# 2. Load WPF Assemblies
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# 3. Define Fluent Design XAML UI
$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Microsoft Office 2024 LTSC Deployment" Width="750" SizeToContent="Height" MinHeight="500"
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize" Background="#F3F3F3" 
        FontFamily="Segoe UI Variable Text, Segoe UI, Nirmala UI, Iskoola Pota, sans-serif"
        UseLayoutRounding="True" SnapsToDevicePixels="True" 
        TextOptions.TextFormattingMode="Display" TextOptions.TextRenderingMode="ClearType"
        Icon="https://res-1.cdn.office.net/files/fabric-cdn-prod_20230815.002/assets/brand-icons/product/png/office_48x1.png">
    
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/> 
            <RowDefinition Height="*"/>    
            <RowDefinition Height="Auto"/> 
            <RowDefinition Height="Auto"/> 
        </Grid.RowDefinitions>

        <StackPanel Grid.Row="0" Margin="24,24,24,10" Orientation="Horizontal" VerticalAlignment="Top">
            <Image Source="https://res-1.cdn.office.net/files/fabric-cdn-prod_20230815.002/assets/brand-icons/product/png/office_48x1.png" Width="32" Height="32" Margin="0,0,15,0" RenderOptions.BitmapScalingMode="HighQuality"/>
            <TextBlock Text="Office 2024 LTSC Installer" FontSize="26" FontWeight="SemiBold" VerticalAlignment="Center" Foreground="#111111"/>
        </StackPanel>

        <Grid Grid.Row="1" Margin="24,10,24,15">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="1.2*"/>
            </Grid.ColumnDefinitions>

            <Border Grid.Column="0" Background="#FFFFFF" CornerRadius="8" BorderBrush="#E5E5E5" BorderThickness="1" Margin="0,0,10,0" Padding="20">
                <Border.Effect>
                    <DropShadowEffect Color="#000000" BlurRadius="8" ShadowDepth="2" Opacity="0.05"/>
                </Border.Effect>
                <StackPanel>
                    <TextBlock Text="Installation Settings" FontSize="16" FontWeight="SemiBold" Margin="0,0,0,20" Foreground="#242424"/>
                    <TextBlock Text="Architecture" Foreground="#616161" FontSize="12" Margin="0,0,0,8" FontWeight="Medium"/>
                    <RadioButton Name="rb64Bit" Content="64-bit (Recommended)" IsChecked="True" Margin="0,0,0,10" FontSize="14" Foreground="#242424"/>
                    <RadioButton Name="rb32Bit" Content="32-bit (x86)" Margin="0,0,0,25" FontSize="14" Foreground="#242424"/>
                    <TextBlock Text="Options" Foreground="#616161" FontSize="12" Margin="0,0,0,8" FontWeight="Medium"/>
                    <CheckBox Name="chkRemoveOld" Content="Remove old Office versions" IsChecked="True" Foreground="#C42B1C" FontWeight="Medium" FontSize="14"/>
                </StackPanel>
            </Border>

            <Border Grid.Column="1" Background="#FFFFFF" CornerRadius="8" BorderBrush="#E5E5E5" BorderThickness="1" Margin="10,0,0,0" Padding="20">
                <Border.Effect>
                    <DropShadowEffect Color="#000000" BlurRadius="8" ShadowDepth="2" Opacity="0.05"/>
                </Border.Effect>
                <StackPanel>
                    <TextBlock Text="Select Applications" FontSize="16" FontWeight="SemiBold" Margin="0,0,0,20" Foreground="#242424"/>
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <StackPanel Grid.Column="0">
                            <StackPanel Orientation="Horizontal" Margin="0,0,0,15"><Image Source="https://res-1.cdn.office.net/files/fabric-cdn-prod_20230815.002/assets/brand-icons/product/png/word_48x1.png" Width="24" Height="24" Margin="0,0,12,0"/><CheckBox Name="chkWord" Content="Word" IsChecked="True" VerticalAlignment="Center" FontSize="14"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,0,0,15"><Image Source="https://res-1.cdn.office.net/files/fabric-cdn-prod_20230815.002/assets/brand-icons/product/png/excel_48x1.png" Width="24" Height="24" Margin="0,0,12,0"/><CheckBox Name="chkExcel" Content="Excel" IsChecked="True" VerticalAlignment="Center" FontSize="14"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,0,0,15"><Image Source="https://res-1.cdn.office.net/files/fabric-cdn-prod_20230815.002/assets/brand-icons/product/png/powerpoint_48x1.png" Width="24" Height="24" Margin="0,0,12,0"/><CheckBox Name="chkPowerPoint" Content="PowerPoint" IsChecked="True" VerticalAlignment="Center" FontSize="14"/></StackPanel>
                        </StackPanel>
                        <StackPanel Grid.Column="1">
                            <StackPanel Orientation="Horizontal" Margin="0,0,0,15"><Image Source="https://res-1.cdn.office.net/files/fabric-cdn-prod_20230815.002/assets/brand-icons/product/png/outlook_48x1.png" Width="24" Height="24" Margin="0,0,12,0"/><CheckBox Name="chkOutlook" Content="Outlook" IsChecked="True" VerticalAlignment="Center" FontSize="14"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,0,0,15"><Image Source="https://res-1.cdn.office.net/files/fabric-cdn-prod_20230815.002/assets/brand-icons/product/png/access_48x1.png" Width="24" Height="24" Margin="0,0,12,0"/><CheckBox Name="chkAccess" Content="Access" IsChecked="True" VerticalAlignment="Center" FontSize="14"/></StackPanel>
                            <StackPanel Orientation="Horizontal" Margin="0,0,0,15">
                                <Viewbox Width="24" Height="24" Margin="0,0,12,0"><Canvas Width="1281.4" Height="1148.8"><Path Fill="#038387" Data="M887.2,104.9h341.3c29.2,0,52.9,23.7,52.9,52.9v833c0,29.2-23.7,52.9-52.9,52.9H887.2c-29.2,0-52.9-23.7-52.9-52.9v-833C834.4,128.6,858,104.9,887.2,104.9z"/><Path Fill="#038387" Data="M1050.6,1148.8H356.7c-30.8,0-55.8-24.5-55.8-54.7V861.6l439.3-95.7l366.1,95.7v232.5C1106.3,1124.3,1081.3,1148.8,1050.6,1148.8z"/><Path Fill="#37C6D0" Data="M1048.8,0H358.5c-31.8,0-57.6,25.4-57.5,56.6v517.8l414.9,47.9l390.5-47.9V56.6C1106.4,25.4,1080.6,0,1048.8,0z"/><Rectangle Fill="#1A9BA1" Canvas.Left="301" Canvas.Top="574.4" Width="805.4" Height="287.2"/><Path Fill="#038489" Data="M54.6,247.6h545.9c30.2,0,54.6,24.4,54.6,54.6v545.9c0,30.2-24.4,54.6-54.6,54.6H54.6C24.4,902.7,0,878.3,0,848.1V302.2C0,272.1,24.4,247.6,54.6,247.6z"/><Path Fill="#FFFFFF" Data="M332.7,396.9c34.4-2.3,68.4,7.9,95.8,28.8c23.1,21.3,35.3,51.9,33.2,83.3c0.4,21.9-5.3,43.4-16.4,62.3c-11.1,18.4-27.4,33.1-46.7,42.4c-21.9,10.5-45.9,15.7-70.2,15.1h-66.4v126.8h-68.1V396.9H332.7z M261.9,574h58.7c18.7,1.4,37.2-4.3,51.8-15.9c12.3-12.2,18.7-29.1,17.5-46.4c0-39.5-22.4-59.3-67.2-59.3h-60.8V574z"/></Canvas></Viewbox>
                                <CheckBox Name="chkPublisher" Content="Publisher" IsChecked="True" VerticalAlignment="Center" FontSize="14"/></StackPanel>
                        </StackPanel>
                    </Grid>
                </StackPanel>
            </Border>
        </Grid>

        <Expander Grid.Row="2" Header="🔑 ඇක්ටිවේට් කරගැනීමට අවශ්‍යද? (Need Activation?)" Margin="24,0,24,15" Background="White" BorderBrush="#E5E5E5" BorderThickness="1" Padding="5">
            <Grid Margin="10">
                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                <TextBlock Grid.Column="0" TextWrapping="Wrap" FontSize="13" Foreground="#333333" LineHeight="20" Margin="0,0,20,0">
                    මෙම මෘදුකාංගය Activate කරගැනීමට අවශ්‍ය නම්, දකුණු පස ඇති QR කේතය ස්කෑන් කර හෝ පහත ලින්ක් එක ක්ලික් කර ඔබගේ Daraz Order Number එක සමග අපට පණිවිඩයක් එවන්න.<LineBreak/><LineBreak/>
                    <Run Foreground="#555555">Need activation? Scan QR or click below to message us your order number.</Run>
                </TextBlock>
                <StackPanel Grid.Column="1" VerticalAlignment="Center">
                    <Image Source="https://api.qrserver.com/v1/create-qr-code/?size=120x120&amp;data=https://wa.me/94770123456" Width="80" Height="80" Margin="0,0,0,5"/>
                    <TextBlock Name="btnWhatsApp" Text="wa.me/94770123456" Cursor="Hand" Foreground="#005FB8" HorizontalAlignment="Center" FontSize="12" FontWeight="SemiBold"/>
                </StackPanel>
            </Grid>
        </Expander>

        <Border Grid.Row="3" Background="#FFFFFF" BorderBrush="#E5E5E5" BorderThickness="0,1,0,0" Padding="24,16">
            <Grid>
                <TextBlock Name="txtStatus" Text="Ready to deploy." VerticalAlignment="Center" Foreground="#616161" FontSize="14"/>
                <Button Name="btnInstall" Content="Start Installation" HorizontalAlignment="Right" Width="150" Height="36" Background="#005FB8" Foreground="White" FontWeight="SemiBold" Cursor="Hand"/>
            </Grid>
        </Border>
    </Grid>
</Window>
'@

# Read XAML
$reader = (New-Object System.Xml.XmlNodeReader ([xml]$xaml))
$Form = [Windows.Markup.XamlReader]::Load($reader)

# WhatsApp Click Action
$Form.FindName("btnWhatsApp").Add_MouseDown({ Start-Process "https://wa.me/94770123456" })

$Form.FindName("btnInstall").Add_Click({
    $btnInstall = $Form.FindName("btnInstall")
    $txtStatus = $Form.FindName("txtStatus")
    $btnInstall.IsEnabled = $false
    $txtStatus.Text = "Status: Preparing setup files..."
    
    $arch = if ($Form.FindName("rb64Bit").IsChecked) { "64" } else { "32" }
    $removeOld = $Form.FindName("chkRemoveOld").IsChecked
    $apps = @{"Word"=$Form.FindName("chkWord").IsChecked; "Excel"=$Form.FindName("chkExcel").IsChecked; "PowerPoint"=$Form.FindName("chkPowerPoint").IsChecked; "Outlook"=$Form.FindName("chkOutlook").IsChecked; "Access"=$Form.FindName("chkAccess").IsChecked; "Publisher"=$Form.FindName("chkPublisher").IsChecked}

    $workDir = "C:\Office2024Deploy"
    if (-not (Test-Path $workDir)) { New-Item -Path $workDir -ItemType Directory -Force | Out-Null }
    
    $xmlContent = "<Configuration>`n"
    if ($removeOld) { $xmlContent += "  <Remove All=`"TRUE`" />`n" }
    $xmlContent += "  <Add OfficeClientEdition=`"$arch`" Channel=`"PerpetualVL2024`">`n<Product ID=`"ProPlus2024Volume`">`n<Language ID=`"en-us`" />`n"
    foreach ($app in $apps.GetEnumerator()) { if (-not $app.Value) { $xmlContent += "      <ExcludeApp ID=`"$($app.Key)`" />`n" } }
    $xmlContent += "    </Product>`n  </Add>`n  <Display Level=`"Full`" AcceptEULA=`"TRUE`" />`n</Configuration>"
    Set-Content -Path "$workDir\config.xml" -Value $xmlContent -Encoding UTF8

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A5D4A7E/officedeploymenttool_17531-20046.exe" -OutFile "$workDir\odt.exe"
    Start-Process -FilePath "$workDir\odt.exe" -ArgumentList "/extract:`"$workDir`" /quiet" -Wait
    $process = Start-Process -FilePath "$workDir\setup.exe" -ArgumentList "/configure `"$workDir\config.xml`"" -WindowStyle Hidden -Wait -PassThru

    if ($process.ExitCode -eq 0) {
        [System.Windows.MessageBox]::Show("Microsoft Office 2024 LTSC Installation completed successfully!", "Success", 0, 64)
        $txtStatus.Text = "Status: Completed!"
    } else {
        [System.Windows.MessageBox]::Show("Installation finished with code $($process.ExitCode).", "Notice", 0, 48)
        $btnInstall.IsEnabled = $true
    }
})

$Form.ShowDialog() | Out-Null
