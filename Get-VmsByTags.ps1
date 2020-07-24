$vms=Get-AzVM #This compiles a list of all VMs in the Subscription, add -ResourceGroupName "ResourceGroupName" to only return VMs in that RG

foreach ($vm in $vms) 
{ 
    If ($vm.Tags.Sched) #"Sched" is the TagName
        { 
            if ($vm.Tags.Sched -eq "1200") #"Sched" is the TagName "1200" is the TagValue
            { 
            $vm.Name+ " Tag set to 1200" #Action on the VM

            } 
        } 
}
