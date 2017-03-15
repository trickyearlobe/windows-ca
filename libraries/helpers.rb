
# Returns a hash of properties for each member of the Windows Group
def group_members(groupname)

  member_attributes = {}   # Empty Hash to hold our members attributes

  member_list = JSON.parse(
    powershell_out("Get-ADGroupMember -Identity #{groupname} -Recursive | ConvertTo-Json").stdout # Get the group membership
  )

  member_list.each do |m|
    member = JSON.parse(
      powershell_out(
        "Get-ADUser -Identity #{ m['objectGUID'] } -Properties EmailAddress | ConvertTo-Json" # Get the user details
      ).stdout
    )

    # Make sure we have an empty member object to copy values into
    member_attributes[member['SamAccountName']] = {}

    # Copy just the values we need
    %w( SamAccountName EmailAddress DistinguishedName UserPrincipalName Enabled ObjectGUID ).each do |param|
      member_attributes[member['SamAccountName']][param] = member[param]
    end

  end
  member_attributes
end
