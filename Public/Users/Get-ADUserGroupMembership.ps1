function Get-ADUserGroupMembership
{
            param(
                [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
                [String[]]$UserName,
                [string]$Server = $env:USERDNSDOMAIN
            )
            begin {
                # introduce two lookup hashtables. First will contain cached AD groups,
                # second will contain user groups. We will reuse it for each user.
                # format: Key = group distinguished name, Value = ADGroup object
                $ADGroupCache = @{}
                $UserGroups = @{}
                # define recursive function to recursively process groups.
                function __findPath ([string]$currentGroup) {
                    Write-Verbose "Processing group: $currentGroup"
                    # we must do processing only if the group is not already processed.
                    # otherwise we will get an infinity loop
                    if (!$UserGroups.ContainsKey($currentGroup)) {
                        # retrieve group object, either, from cache (if is already cached)
                        # or from Active Directory
                        $groupObject = if ($ADGroupCache.ContainsKey($currentGroup)) {
                            Write-Verbose "Found group in cache: $currentGroup"
                            $ADGroupCache[$currentGroup]
                        } else {
                            Write-Verbose "Group: $currentGroup is not presented in cache. Retrieve and cache."
                            $g = Get-ADGroup -Identity $currentGroup -Property "MemberOf" -server $Server   
                            # immediately add group to local cache:
                            $ADGroupCache.Add($g.DistinguishedName, $g)
                            $g
                        }
                        # add current group to user groups
                        $UserGroups.Add($currentGroup, $groupObject)
                        Write-Verbose "Member of: $currentGroup"
                        foreach ($p in $groupObject.MemberOf) {
                            __findPath $p
                        }
                    } else {Write-Verbose "Closed walk or duplicate on '$currentGroup'. Skipping."}
                }
            }
            process {
                foreach ($user in $UserName) {
                    Write-Verbose "========== $user =========="
                    # clear group membership prior to each user processing
                    $UserObject = Get-ADUser -Identity $user -Property "MemberOf" -server $Server
                    $UserObject.MemberOf | ForEach-Object {__findPath $_}
                    New-Object psobject -Property @{
                        UserName = $UserObject.Name;
                        MemberOf = $UserGroups.Values | % {$_}; # groups are added in no particular order
                    }
                    $UserGroups.Clear()
                }
            }
        }
}
