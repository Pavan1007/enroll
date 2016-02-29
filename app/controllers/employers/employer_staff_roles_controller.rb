class Employers::EmployerStaffRolesController < Employers::EmployersController

  # Action to check employer profile access
  # See check_access_to_employer_profile
  before_action :check_access_to_employer_profile

  # Handles HTTP post
  #
  # Creates employer profile role for person
  def create

    dob = DateTime.strptime(params[:dob], '%m/%d/%Y').try(:to_date)
    employer_profile = EmployerProfile.find(params[:id])
    first_name = (params[:first_name] || '').strip
    last_name = (params[:last_name] || '').strip
    email = params[:email]
    @status, @result = Person.add_employer_staff_role(first_name, last_name, dob, email, employer_profile)
    flash[:error] = ('Role was not added because '  + @result) unless @status
    redirect_to edit_employers_employer_profile_path(employer_profile.organization)
  end
  # Handles HTTP delete
  #
  # id is the person_id
  # For this person find an employer_staff_role that match this employer_profile_id and mark the role inactive
  def destroy
    employer_profile_id = params[:id]
    employer_profile = EmployerProfile.find(employer_profile_id)
    staff_id = params[:staff_id]
    if Person.staff_for_employer(employer_profile).count <= 1
      flash[:error] = 'Please add another staff role before deleting this role'
    else
      @status, @result = Person.deactivate_employer_staff_role(staff_id, employer_profile_id)
      @status ? (flash[:notice] = 'Staff role was deleted') : (flash[:error] = ('Role was not deactivated because '  + @result))
    end
    redirect_to edit_employers_employer_profile_path(employer_profile.organization)
  end

  private
  # Check to see if current_user is authorized to access the submitted employer profile
  def check_access_to_employer_profile
    employer_profile = EmployerProfile.find(params[:id])
    policy = ::AccessPolicies::EmployerProfile.new(current_user)
    policy.authorize_edit(employer_profile, self)
  end

end



