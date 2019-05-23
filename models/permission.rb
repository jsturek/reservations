require 'active_record'

class Permission < ActiveRecord::Base
	SUPER_USER = 1
	MANAGE_USERS = 2
	MANAGE_RESOURCES = 3
	MANAGE_EMAILS = 4
	MANAGE_SPACE_HOURS = 5
	MANAGE_EVENTS = 6
	SEE_AGENDA = 7
end