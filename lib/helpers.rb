def windows_group_members(groupname)

  # Empty Hash to hold our members attributes
  member_attributes = {}

  # Get list of users in the group
  member_list = JSON.parse(
    powershell_out("Get-ADGroupMember -Identity #{groupname} -Recursive | ConvertTo-Json").stdout
  )

  # For each user, get the important attributes
  member_list.each do |m|
    member = JSON.parse(powershell_out("Get-ADUser -Identity #{g['objectGUID']} -Properties * | ConvertTo-Json").stdout)
    %w( EmailAddress Name ).each do |param|
      member_attributes[member['Name']][param] = member[param]
    end
  end
  member_attributes
end
