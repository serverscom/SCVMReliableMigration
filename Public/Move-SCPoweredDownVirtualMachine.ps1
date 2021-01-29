function Move-SCPoweredDownVirtualMachine {
    #Requires -Version 3.0
    #Requires -Modules virtualmachinemanager

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [Microsoft.SystemCenter.VirtualMachineManager.VM]$VM,
        [Parameter(Mandatory)]
        [Microsoft.SystemCenter.VirtualMachineManager.Host]$VMHost,
        [Parameter(Mandatory)]
        [string]$Path
    )

    $ErrorActionPreference = 'Stop'

    Write-Debug -Message ('ENTER {0}' -f $MyInvocation.MyCommand.Name)

    try {
        Write-Debug -Message ('ENTER TRY {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('$VM: ''{0}''' -f $VM.Name)
        Write-Debug -Message ('$VMHost: ''{0}''' -f [string]$VMHost)
        Write-Debug -Message ('$Path = ''{0}''' -f $Path)

        Write-Debug -Message '$SourceVMHost = $VM.VMHost'
        $SourceVMHost = $VM.VMHost
        Write-Debug -Message ('$SourceVMHost: ''{0}''' -f [string]$SourceVMHost)
        Write-Debug -Message '$DestinationVMHost = $VMHost'
        $DestinationVMHost = $VMHost
        Write-Debug -Message ('$DestinationVMHost: ''{0}''' -f [string]$DestinationVMHost)

        Write-Debug -Message 'if ($SourceVMHost -ne $DestinationVMHost)'
        if ($SourceVMHost -ne $DestinationVMHost) {
            Write-Debug -Message 'Get-SCVirtualMachineHVNetworkAdapterExtendedAcl -VM $VM'
            $HVACL = Get-SCVirtualMachineHVNetworkAdapterExtendedAcl -VM $VM
            Write-Debug -Message ('$HVACL: ''{0}''' -f [string]$HVACL)
            Write-Debug -Message ('$HVACL.Count: {0}' -f $HVACL.Count)

            Write-Debug -Message '$VMNetworkAdapter = $VM.VirtualNetworkAdapters[0]'
            $VMNetworkAdapter = $VM.VirtualNetworkAdapters[0] # For now the function supports only one network adapter
            Write-Debug -Message ('$VMNetworkAdapter: ''{0}''' -f [string]$VMNetworkAdapter)
            Write-Debug -Message 'if ($VMNetworkAdapter)'
            if ($VMNetworkAdapter) {
                Write-Debug -Message '$VMNetwork = $VMNetworkAdapter.VMNetwork'
                $VMNetwork = $VMNetworkAdapter.VMNetwork
                Write-Debug -Message ('$VMNetwork: ''{0}''' -f [string]$VMNetwork)

                Write-Debug -Message '$JobGroupId = ([guid]::NewGuid()).Guid'
                $JobGroupId = ([guid]::NewGuid()).Guid
                Write-Debug -Message ('$JobGroupId = ''{0}''' -f $JobGroupId)

                Write-Debug -Message ('$SetSCVirtualNetworkAdapterArguments = @{{VirtualNetworkAdapter = $VMNetworkAdapter, JobGroup = ''{0}''}}' -f $JobGroupId)
                $SetSCVirtualNetworkAdapterArguments = @{
                    VirtualNetworkAdapter = $VMNetworkAdapter
                    JobGroup              = $JobGroupId
                }
                Write-Debug -Message ('$SetSCVirtualNetworkAdapterArguments: ''{0}''' -f ($SetSCVirtualNetworkAdapterArguments | Out-String))

                Write-Debug -Message ('$VMNetworkAdapter.VLanEnabled: ''{0}''' -f [string]$VMNetworkAdapter.VLanEnabled)
                Write-Debug -Message 'if ($VMNetworkAdapter.VLanEnabled)'
                if ($VMNetworkAdapter.VLanEnabled) {
                    Write-Debug -Message '$VLanID = $VMNetworkAdapter.VLanID'
                    $VLanID = $VMNetworkAdapter.VLanID
                    Write-Debug -Message ('$VLanID = {0}' -f [string]$VLanID)

                    Write-Debug -Message '$SetSCVirtualNetworkAdapterArguments.Add(''VLanEnabled'', $true)'
                    $SetSCVirtualNetworkAdapterArguments.Add('VLanEnabled', $true)
                    Write-Debug -Message ('$SetSCVirtualNetworkAdapterArguments.Add(''VLanID'', {0})' -f $VLanID)
                    $SetSCVirtualNetworkAdapterArguments.Add('VLanID', $VLanID)
                }
                Write-Debug -Message ('$SetSCVirtualNetworkAdapterArguments: ''{0}''' -f ($SetSCVirtualNetworkAdapterArguments | Out-String))

                Write-Debug -Message ('$VMNetwork: ''{0}''' -f [string]$VMNetwork)
                Write-Debug -Message ('$VMNetwork.Name: ''{0}''' -f $VMNetwork.Name)
                Write-Debug -Message ('$VMNetwork.ID: ''{0}''' -f $VMNetwork.ID)
                Write-Debug -Message 'if ($VMNetwork)'
                if ($VMNetwork) {
                    Write-Debug -Message '$SetSCVirtualNetworkAdapterArguments.Add(''VMNetwork'', $VMNetwork)'
                    $SetSCVirtualNetworkAdapterArguments.Add('VMNetwork', $VMNetwork)
                }
                Write-Debug -Message ('$SetSCVirtualNetworkAdapterArguments: ''{0}''' -f ($SetSCVirtualNetworkAdapterArguments | Out-String))

                Write-Debug -Message '$VirtualNetwork = $VMNetworkAdapter.VirtualNetwork'
                $VirtualNetwork = $VMNetworkAdapter.VirtualNetwork
                Write-Debug -Message ('$VirtualNetwork = ''{0}''' -f $VirtualNetwork)
                Write-Debug -Message 'if ($VirtualNetwork)'
                if ($VirtualNetwork) {
                    Write-Debug -Message '$SetSCVirtualNetworkAdapterArguments.Add(''VirtualNetwork'', $VirtualNetwork)'
                    $SetSCVirtualNetworkAdapterArguments.Add('VirtualNetwork', $VirtualNetwork)
                }
                Write-Debug -Message ('$SetSCVirtualNetworkAdapterArguments: ''{0}''' -f ($SetSCVirtualNetworkAdapterArguments | Out-String))

                Write-Debug -Message '$null = Set-SCVirtualNetworkAdapter @SetSCVirtualNetworkAdapterArguments'
                $null = Set-SCVirtualNetworkAdapter @SetSCVirtualNetworkAdapterArguments
            }

            Write-Debug -Message 'Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost)'
            Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost)

            Write-Debug -Message ('$VM.VMHost: ''{0}''' -f [string]$VM.VMHost)
            Write-Debug -Message 'if ($VM.VMHost -ne $DestinationVMHost)'
            if ($VM.VMHost -ne $DestinationVMHost) {
                # Better safe than sorry

                Write-Verbose -Message ('Moving a powered-down VM {0} from {1} to {2}' -f $VM.Name, $VM.VMHost.Name, $DestinationVMHost.Name)
                try {
                    Write-Debug -Message ('$null = Move-SCVirtualMachine -VM $VM -VMHost $DestinationVMHost -Path ''{0}'' -JobGroup ''{1}''' -f $Path, $JobGroupId)
                    $null = Move-SCVirtualMachine -VM $VM -VMHost $DestinationVMHost -Path $Path -JobGroup $JobGroupId
                }
                catch {
                    Write-Debug -Message 'Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost)'
                    Read-SCVMHosts -VMHost ($SourceVMHost, $DestinationVMHost)
                    Write-Debug -Message '$null = Read-SCVirtualMachine -VM $SCVM'
                    $null = Read-SCVirtualMachine -VM $SCVM
                    Write-Debug -Message ('$VM.VMHost: {0}' -f [string]$VM.VMHost)
                    Write-Debug -Message ('$DestinationVMHost: {0}' -f [string]$DestinationVMHost)
                    Write-Debug -Message 'if ($VM.VMHost -eq $DestinationVMHost)'
                    if ($VM.VMHost -eq $DestinationVMHost) {
                        Write-Debug -Message 'continue'
                        continue
                    }
                    else {
                        Write-Debug -Message ($_)
                        Write-Debug -Message ('Exception.HResult: {0}' -f $_.Exception.HResult)
                        Write-Debug -Message ('{0}: Throw $_' -f $MyInvocation.MyCommand.Name)
                        throw $_
                    }
                }

                Write-Debug -Message ('$HVACL: ''{0}''' -f [string]$HVACL)
                Write-Debug -Message 'if ($HVACL)'
                if ($HVACL) {
                    Write-Debug -Message 'Get-SCVirtualMachineHVNetworkAdapterExtendedAcl -VM $VM'
                    $MovedHVACL = Get-SCVirtualMachineHVNetworkAdapterExtendedAcl -VM $VM
                    Write-Debug -Message ('$MovedHVACL.Count: {0}' -f $MovedHVACL.Count)
                    foreach ($ACL in $HVACL) {
                        Write-Debug -Message ('ACL: Action={0}, Direction={1}, LocalIPAddress={2}, RemoteIPAddress={3}, LocalPort={4}, RemotePort={5}, Protocol={6}, Weight={7}, Stateful={8}, IsolationID={9}, IdleSessionTimeout={10}' -f $ACL.Action, $ACL.Direction, $ACL.LocalIPAddress, $ACL.RemoteIPAddress, $ACL.LocalPort, $ACL.RemotePort, $ACL.Protocol, $ACL.Weight, $ACL.Stateful, $ACL.IsolationID, $ACL.IdleSessionTimeout)

                        Write-Debug -Message ('$MovedHVACL: ''{0}''' -f [string]$MovedHVACL)
                        Write-Debug -Message 'if ($MovedHVACL -notcontains $ACL)'
                        if ($MovedHVACL -notcontains $ACL) {
                            Write-Debug -Message ('$AddVMNetworkAdapterExtendedAclSplat = @{{VMName=''{0}''; Action=''{1}''; Direction=''{2}''; LocalIPAddress=''{3}''; RemoteIPAddress=''{4}''; LocalPort=''{5}''; RemotePort=''{6}''; Protocol=''{7}''; Weight=''{8}''; Stateful=''{9}''; IsolationID=''{10}''}}' -f $VM.Name, $ACL.Action, $ACL.Direction, $ACL.LocalIPAddress, $ACL.RemoteIPAddress, $ACL.LocalPort, $ACL.RemotePort, $ACL.Protocol, $ACL.Weight, $ACL.Stateful, $ACL.IsolationID)
                            $AddVMNetworkAdapterExtendedAclSplat = @{
                                VMName          = $VM.Name
                                Action          = $ACL.Action
                                Direction       = $ACL.Direction
                                LocalIPAddress  = $ACL.LocalIPAddress
                                RemoteIPAddress = $ACL.RemoteIPAddress
                                LocalPort       = $ACL.LocalPort
                                RemotePort      = $ACL.RemotePort
                                Protocol        = $ACL.Protocol
                                Weight          = $ACL.Weight
                                Stateful        = $ACL.Stateful
                                IsolationID     = $ACL.IsolationID
                            }

                            Write-Debug -Message ('$ACL.Stateful: ''{0}''' -f [string]$ACL.Stateful)
                            Write-Debug -Message 'if ($ACL.Stateful)'
                            if ($ACL.Stateful) {
                                Write-Debug -Message ('$AddVMNetworkAdapterExtendedAclSplat += @{{IdleSessionTimeout = {0}}}' -f $ACL.IdleSessionTimeout)
                                $AddVMNetworkAdapterExtendedAclSplat += @{
                                    IdleSessionTimeout = $ACL.IdleSessionTimeout
                                }
                            }
                            Write-Debug -Message ('$null = Invoke-Command -ComputerName ''{0}'' -ScriptBlock {{$Splat = $using:AddVMNetworkAdapterExtendedAclSplat; Add-VMNetworkAdapterExtendedAcl @Splat}}' -f $DestinationVMHost.Name)
                            $null = Invoke-Command -ComputerName $DestinationVMHost.Name -ScriptBlock {
                                $Splat = $using:AddVMNetworkAdapterExtendedAclSplat
                                Add-VMNetworkAdapterExtendedAcl @Splat
                            }
                        }
                    }
                }
            }
        }
        else {
            $Message = 'Source ({0}) and destination ({1}) servers are the same' -f $SourceVMHost, $DestinationVMHost
            $PSCmdlet.ThrowTerminatingError((New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList ((New-Object -TypeName 'System.ArgumentException' -ArgumentList $Message), 'ArgumentException', [System.Management.Automation.ErrorCategory]::InvalidArgument, $null)))
        }

        Write-Debug -Message ('EXIT TRY {0}' -f $MyInvocation.MyCommand.Name)
    }
    catch {
        Write-Debug -Message ('ENTER CATCH {0}' -f $MyInvocation.MyCommand.Name)

        Write-Debug -Message ('{0}: Throw $_' -f $MyInvocation.MyCommand.Name)
        throw $_

        Write-Debug -Message ('EXIT CATCH {0}' -f $MyInvocation.MyCommand.Name)
    }

    Write-Debug -Message ('EXIT {0}' -f $MyInvocation.MyCommand.Name)
}