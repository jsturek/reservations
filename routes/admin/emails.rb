require 'models/user'

get '/admin/email/?' do
	erb :'admin/emails', :layout => :fixed
end

get '/admin/email/send/?' do
	users = User.all

	erb :'admin/send_email', :layout => :fixed, :locals => {
		:users => users
	}
end

post '/admin/email/send/?' do
	users_to_send_to = []

	# compile the list based on what was checked
	if params.checked?('send_to_all_non_admins')
		users = User.where(:service_space_id => SS_ID, :is_admin => false).all
		users_to_send_to += users
	end
	if params.checked?('send_to_all_users')
		users = User.where(:service_space_id => SS_ID).all
		users_to_send_to += users
	end
	if params.checked?('send_to_all_students')
		users = User.where(:service_space_id => SS_ID, :university_status => ['UNL Undergrad','UNL Grad','Other Student']).all
		users_to_send_to += users
	end
	if params.checked?('send_to_all_facstaff')
		users = User.where(:service_space_id => SS_ID, :university_status => ['UNL Staff','UNL Faculty','Emeritus UNL Faculty']).all
		users_to_send_to += users
	end
	if params.checked?('send_to_specific_user')
		user = User.find_by(:service_space_id => SS_ID, :id => params[:specific_user])
		users_to_send_to << user unless user.nil?
	end

	# compact and uniqify the list
	users_to_send_to = users_to_send_to.compact.uniq do |user|
		user.id
	end

	# correctly choose how to send
	if users_to_send_to.count == 1
		Emailer.mail(users_to_send_to[0].email, params[:subject], params[:body])
		output = users_to_send_to[0].full_name
	elsif users_to_send_to.count > 1
		bcc = users_to_send_to.map(&:email).join(',')
		Emailer.mail('', params[:subject], params[:body], bcc)
		output = "#{users_to_send_to.count} users"
	else
		flash :error, 'No Users Selected', 'This email was not sent to any users'
		redirect back
	end

	flash :success, 'Email sent', "Your email was sent to #{output}."
	redirect '/admin/email/'
end