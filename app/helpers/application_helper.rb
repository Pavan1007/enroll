module ApplicationHelper

  def menu_tab_class(a_tab, current_tab)
    (a_tab == current_tab) ? raw(" class=\"active\"") : ""
  end

  def datepicker_control(f, field_name, options = {}, value = "")
    sanitized_field_name = field_name.to_s.sub(/\?$/,"")
    opts = options.dup
    obj_name = f.object_name
    obj_val = f.object.send(field_name.to_sym)
    current_value = obj_val.blank? ? value : obj_val.is_a?(DateTime) ? obj_val.strftime("%m/%d/%Y") : obj_val
    html_class_list = opts.delete(:class) { |k| "" }
    jq_tag_classes = (html_class_list.split(/\s+/) + ["jq-datepicker"]).join(" ")
    generated_field_name = "jq_datepicker_ignore_#{obj_name}[#{sanitized_field_name}]"
    provided_id = options[:id] || options["id"]
    generate_target_id = nil
    if !provided_id.blank?
      generated_target_id = "#{provided_id}_jq_datepicker_plain_field"
    end
    sanitized_object_name = "#{obj_name}_#{sanitized_field_name}".delete(']').tr('^-a-zA-Z0-9:.', "_")
    generated_target_id ||= "#{sanitized_object_name}_jq_datepicker_plain_field"
    capture do
      concat f.text_field(field_name, opts.merge(:class => html_class_list, :id => generated_target_id, :value=> obj_val.try(:to_s, :db)))
      concat text_field_tag(generated_field_name, current_value, opts.merge(:class => jq_tag_classes, :style => "display: none;", "data-submission-field" => "##{generated_target_id}"))
    end
  end

  def generate_breadcrumbs(breadcrumbs)
    html = "<ul class='breadcrumb'>".html_safe
    breadcrumbs.each_with_index do |breadcrumb, index|
      if breadcrumb[:path]
        html += "<li>".html_safe + link_to(breadcrumb[:name], breadcrumb[:path], data: breadcrumb[:data])
        html += "<span class='divider'></span>".html_safe if index < breadcrumbs.length-1
        html += "</li>".html_safe
      else
        html += "<li class='active #{breadcrumb[:class]}'>".html_safe + breadcrumb[:name]
        html += "<span class='divider'></span>".html_safe if index < breadcrumbs.length-1
        html += "</li>".html_safe
      end
    end
    html += "</ul>".html_safe
    return html
  end

  # Formats version information in HTML string for the referenced object instance
  def version_for_record(obj)
    ver  = "version: #{obj.version}" if obj.respond_to?('version')
    date = "updated: #{format_date(obj.updated_at)}" if obj.respond_to?('updated_at')
    who  = "by: #{obj.updated_by}"if obj.respond_to?('updated_by')
    [ver, date, who].reject(&:nil? || empty?).join(' | ')
  end

  def format_date(date_value)
    date_value.strftime("%m/%d/%Y") if date_value.respond_to?(:strftime)
  end

  def format_datetime(date_value)
    date_value.to_time.strftime("%m/%d/%Y %H:%M %Z %:z") if date_value.respond_to?(:strftime)
  end

  # Builds a Dropdown button
  def select_dropdown(input_id, list)
    return unless list.is_a? Array
    content_tag(:select, class: "form-control", id: input_id) do
      concat(content_tag :option, "Select", value: "")
      list.each do |item|
        if item.is_a? Array
          concat(content_tag :option, item[0], value: item[1])
        else
          concat(content_tag :option, item.humanize, value: item)
        end
      end
    end
  end

  # Formats first data row in a table indicating an empty set
  def table_empty_to_human
    content_tag(:tr, (content_tag(:td, "None given")))
  end

  def transaction_status_to_label(ed)
    if ed.open?
      content_tag(:span, "#{ed.aasm_state}", class: "label label-warning")
    elsif ed.assigned?
      content_tag(:span, "#{ed.aasm_state}", class: "label label-info")
    else
      content_tag(:span, "#{ed.aasm_state}", class: "label label-success")
    end
  end

  # Formats a full name into upper/lower case with last name wrapped in HTML <strong> tag
  def name_to_listing(person)
    given_name = [person.first_name, person.middle_name].reject(&:nil? || empty?).join(' ')
    sir_name  = content_tag(:strong, mixed_case(person.last_name))
    raw([mixed_case(given_name), sir_name, person.name_sfx].reject(&:nil? || empty?).join(' '))
  end

  # Formats each word in a string to capital first character and lower case for all other characters
  def mixed_case(str)
    (str.downcase.gsub(/\b\w/) {|first| first.upcase }) unless str.nil?
  end

  # Formats a boolean value into 'Yes' or 'No' string
  def boolean_to_human(test)
    test ? "Yes" : "No"
  end

  # Uses a boolean value to return an HTML checked/unchecked glyph
  def boolean_to_glyph(test)
    test ? content_tag(:span, "", class: "fui-checkbox-checked") : content_tag(:span, "", class: "fui-checkbox-unchecked")
  end

  # Formats a number into a 9-digit US Social Security Number string (nnn-nn-nnnn)
  def number_to_ssn(number)
    return unless number
    delimiter = "-"
    number.to_s.gsub!(/(\d{0,3})(\d{2})(\d{4})$/,"\\1#{delimiter}\\2#{delimiter}\\3")
  end

  # Formats a number into a US Social Security Number string (nnn-nn-nnnn), hiding all but last 4 digits
  def number_to_obscured_ssn(number)
    return unless number
    number_to_ssn(number)
    number.to_s.gsub!(/\w{3}-\w{2}/, '***-**')
  end

  # Formats a number into a nine-digit US Federal Entity Identification Number string (nn-nnnnnnn)
  def number_to_fein(number)
    return unless number
    delimiter = "-"
    number.to_s.gsub!(/(\d{0,2})(\d{7})$/,"\\1#{delimiter}\\2")
  end

  # Formats a number into a nine-digit US Federal Entity Identification Number string (nn-nnnnnn), hiding all but last 4 digits
  def number_to_obscured_fein(number)
    return unless number
    number[0,5] = "**-***"
    number
  end

  # Formats a string into HTML, concatenating it with a person glyph
  def prepend_glyph_to_name(name)
    content_tag(:span, raw("&nbsp;"), class: "glyphicon glyphicon-user") + name
  end

  # Formats a string into HTML, concatenating it with a male glyph
  def prepend_male_glyph_to_name(name)
    content_tag(:i, class: "fa fa-male") + name
  end

  # Formats a string into HTML, concatenating it with a female glyph
  def prepend_female_glyph_to_name(name)
    content_tag(:i, raw("&nbsp;"), class: "fa fa-female") + name
  end

  # Formats a string into HTML, concatenating it with a child glyph
  def prepend_child_glyph_to_name(name)
    content_tag(:i, raw("&nbsp;"), class: "fa fa-child") + name
  end

  # Formats a Font Awesome icon in HTML
  def prepend_fa_icon(fa_icon, str)
    content_tag(:i, raw("&nbsp;"), class: "fa fa-#{fa_icon}") + str
  end

  def active_menu_item(label, path, controller = nil)
    li_start = (params[:controller] == controller.to_s) ? "<li class=\"active\">" : "<li>"
    li_start + link_to(label, path) + "</li>"
  end

  def active_dropdown_classes(*args)
    args.map(&:to_s).include?(params[:controller].to_s) ? "dropdown active" : "dropdown"
  end

  def link_to_add_fields(name, f, association, classes='')
    new_object = f.object.send(association).klass.new
    id = new_object.object_id

    # TODO add ability to build nested attributes dynamically
    if f.object.send(association).klass == OfficeLocation
      new_object.build_address
      new_object.build_phone
    end

    fields = f.fields_for(association, new_object, fieldset: false, child_index: id) do |builder|
      render("shared/" + association.to_s.singularize + "_fields", f: builder)
    end
    link_to(content_tag(:span, raw("&nbsp;"), class: 'fui-plus-circle') + name,
            '#', class: "add_fields #{classes}", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def render_flash
    rendered = []
    flash.each do |type, messages|
      if messages.respond_to?(:each)
        messages.each do |m|
          rendered << render(:partial => 'layouts/flash', :locals => {:type => type, :message => m}) unless m.blank?
        end
      else
        rendered << render(:partial => 'layouts/flash', :locals => {:type => type, :message => messages}) unless messages.blank?
      end
    end
    rendered.join('').html_safe
  end

  def dd_value(val)
    val.blank? ? "&nbsp;" : val
  end

  def sortable(column, title = nil)
    fui = params[:direction] == "desc" ? "down" : "up"
    title ||= column.titleize
    css_class = (column == sort_column) ? "fui-triangle-#{fui}-small" : nil
    direction = (column == params[:sort] && params[:direction] == "desc") ? "asc" : "desc"
    ((link_to title, params.merge(:sort => column, :direction => direction, :page => nil) ) + content_tag(:sort, raw("&nbsp;"), class: css_class))
  end

  def extract_phone_number(phones, type)
    phone = phones.select{|phone| phone.kind == type}
    if phone.present?
      phone = phone.first
      phone = phone.area_code.present? ? "#{phone.area_code} #{phone.number}" : nil
    else
      phone = nil
    end
    return phone
  end

# the following methods are used when we are embedding devise signin and signup pages in views other than devise.
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def get_dependents(family, person)
    members_list = []
    family_members = family.family_members
    family_members.each {|f| members_list << f.person } if family_members.present?
    return members_list
  end

  def generate_relationship_benefits(obj)
    return nil unless obj.class == BenefitGroup
    if obj.relationship_benefits.present?
      obj.relationship_benefits
    else
      obj.simple_benefit_list(nil, nil, nil)
    end
  end

  def add_progress_class(element_number, step)
    if element_number < step
      'complete'
    elsif element_number == step
      'active'
    end
  end

  def user_full_name
    if signed_in?
      current_user.person.try(:full_name) ? current_user.person.full_name : current_user.email
    end
  end

  def retrieve_show_path(provider, message)
    case(provider.model_name.name)
    when "Person"
      insured_inbox_path(provider, message_id: message.id)
    when "EmployerProfile"
      employers_inbox_path(provider, message_id: message.id)
    when "BrokerAgencyProfile"
      broker_agencies_inbox_path(provider, message_id: message.id)
    when "HbxProfile"
      exchanges_inbox_path(provider, message_id: message.id)
    end
  end

  def retrieve_inbox_path(provider, folder: 'inbox')
    case(provider.model_name.name)

    when "EmployerProfile"
      inbox_employers_employer_profiles_path(id: provider.id, folder: folder)
    when "HbxProfile"
      inbox_exchanges_hbx_profile_path(provider, folder: folder)
    when "BrokerAgencyProfile"
      broker_agencies_profile_inbox_path(profile_id: provider.id, folder: folder)
    when "Person"
      inbox_insured_families_path(profile_id: provider.id, folder: folder)
    end
  end

  def can_register_new_account
    # Do this once we have invites working:
    # !params[:invitation_id].blank?
    true
  end

  def portal_display_name(controller)
    if current_user.nil?
      "Welcome to the District's Health Insurance Marketplace"
    elsif current_user.try(:has_hbx_staff_role?)
      "#{image_tag 'icons/icon-exchange-admin.png'} &nbsp; I'm HBX Staff".html_safe
    elsif current_user.try(:has_broker_agency_staff_role?) && current_user.person.broker_role
      link_to "#{image_tag 'icons/icon-expert.png'} &nbsp; I'm a Broker".html_safe,
      broker_agencies_profile_path(id: current_user.person.broker_role.broker_agency_profile_id)
    elsif current_user.try(:person).try(:csr_role) && current_user.person.csr_role.cac
      link_to "#{image_tag 'icons/icon-expert.png'} &nbsp; I'm a Certified Applicant Counselor".html_safe,
      home_exchanges_agents_path
    elsif current_user.try(:person).try(:csr_role) && !current_user.person.csr_role.cac
      link_to "#{image_tag 'icons/icon-expert.png'} &nbsp; I'm a Customer Service Representative".html_safe,
      home_exchanges_agents_path
    elsif current_user.try(:person).try(:assister_role)
      link_to "#{image_tag 'icons/icon-expert.png'} &nbsp; I'm an In Person Assister".html_safe,
      home_exchanges_agents_path
    elsif (controller_path.include?("insured") && current_user.try(:has_insured_role?)) ||
      (["employee_roles", "consumer_roles"].include?(controller))
      "#{image_tag 'icons/icon-individual.png'} &nbsp; I'm an Insured".html_safe
    elsif current_user.try(:has_broker_agency_staff_role?)
      "#{image_tag 'icons/icon-expert.png'} &nbsp; I'm a Broker".html_safe
    elsif current_user.try(:has_employer_staff_role?)
      "#{image_tag 'icons/icon-business-owner.png'} &nbsp; I'm an Employer".html_safe
    else
      "Welcome to the District's Health Insurance Marketplace"
    end
  end

  def override_backlink
    link=''
    if current_user.try(:has_hbx_staff_role?)
      link = link_to 'HBX Portal', exchanges_hbx_profile_path(id: 1)
    elsif current_user.try(:has_broker_agency_staff_role?)
      link = link_to 'Broker Agency Portal',broker_agencies_profile_path(id: current_user.person.broker_role.broker_agency_profile_id)
    end
    return link
  end

  def display_carrier_logo(carrier_name, options = {:width => 50})
    if carrier_name.present?
      image_tag("logo/carrier/#{carrier_name.parameterize.underscore}.jpg", width: options[:width]) # Displays carrier logo (Delta Dental => delta_dental.jpg)
    end
  end

  def dob_in_words(age, dob)
    return age if age > 0
    time_ago_in_words(dob)
  end

  def date_col_name_for_broker_roaster
    if controller_name == 'applicants'
      case @status
      when 'active'
        'Accepted Date'
      when 'broker_agency_terminated'
        'Terminated Date'
      when 'broker_agency_declined'
        'Declined Date'
      else
      end
    else
      case @status
      when 'applicant'
        'Submitted Date'
      when 'certified'
        'Certified Date'
      when 'decertified'
        'Decertified Date'
      when 'denied'
        'Denied Date'
      else
      end
    end
  end

  def relationship_options(dependent, referer)
    relationships = referer.include?("consumer_role_id") ?
      BenefitEligibilityElementGroup::INDIVIDUAL_MARKET_RELATIONSHIP_CATEGORY_KINDS :
      PersonRelationship::Relationships
    options_for_select(relationships.map{|r| [r.to_s.humanize, r.to_s] }, selected: dependent.try(:relationship))
  end

  def enrollment_progress_bar(plan_year, p_min, options = {:minimum => true})
    progress_bar_width = 0
    progress_bar_class = ''
    return if plan_year.nil?

    eligible = plan_year.eligible_to_enroll_count
    enrolled = plan_year.total_enrolled_count
    non_owner = plan_year.non_business_owner_enrollment_count
    covered = plan_year.covered_count
    waived = plan_year.waived_count
    p_min = 0 if p_min.nil?

    unless eligible.zero?
      condition = (eligible <= 2) ? ((enrolled > (eligible - 1)) && (non_owner > 0)) : ((enrolled >= p_min) && (non_owner > 0))
      condition = false if covered == 0 && waived > 0
      progress_bar_class = condition ? 'progress-bar-success' : 'progress-bar-danger'
      progress_bar_width = (enrolled * 100)/eligible
    end

    content_tag(:div, class: 'progress-wrapper') do
      content_tag(:div, class: 'progress') do
        concat(content_tag(:div, class: "progress-bar #{progress_bar_class}", style: "width: #{progress_bar_width}%;", role: 'progressbar', aria: {valuenow: "#{enrolled}", valuemin: "0", valuemax: "#{eligible}"}, data: {value: "#{enrolled}"}) do
          concat content_tag(:span, '', class: 'sr-only')
        end)

        if eligible > 1
          concat content_tag(:small, enrolled, class: 'progress-current', style: "left: #{progress_bar_width - 2}%;")
        end

        if eligible > 2
          eligible_text = (options[:minimum] == false) ? "#{p_min}<br>(Minimum)" : "&nbsp;#{p_min}&nbsp;"
          concat content_tag(:p, eligible_text.html_safe, class: 'divider-progress', data: {value: "#{p_min}"})
        end

        concat(content_tag(:div, class: 'progress-val') do
          concat content_tag(:strong, '0', class: 'pull-left') if (options[:minimum] == false)
          concat content_tag(:strong, (options[:minimum] == false) ? eligible : '', data: {value: "#{eligible}"}, class: 'pull-right')
        end)
      end
    end
  end

  def is_readonly(object)
    return false if current_user.roles.include?("hbx_staff") # can edit, employer census roster
    return true if object.try(:employee_role_linked?)  # cannot edit, employer census roster
    return !(object.new_record? or object.try(:eligible?)) # employer census roster
  end

  def calculate_participation_minimum
    if @current_plan_year.present?
      return 0 if @current_plan_year.eligible_to_enroll_count == 0
      return ((@current_plan_year.eligible_to_enroll_count * 2 / 3) + 0.999).to_i
    end
  end

  def notice_eligible_enrolles(notice)
    notice.enrollments.inject([]) do |enrollees, enrollment|
      enrollees += enrollment.enrollees
    end.uniq
  end

  def calculate_age_by_dob(dob)
    now = Date.today
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def ethnicity_collection
    [
      ["White", "Black or African American", "Asian Indian", "Chinese" ],
      ["Filipino", "Japanese", "Korean", "Vietnamese", "Other Asian"],
      ["Native Hawaiian", "Samoan", "Guamanian or Chamorro", ],
      ["Other Pacific Islander", "American Indian or Alaskan Native", "Other"]
    ].inject([]){ |sets, ethnicities|
      sets << ethnicities.map{|e| OpenStruct.new({name: e, value: e})}
    }
  end

  def latino_collection
    [
      ["Mexican", "Mexican American"],
      ["Chicano/a", "Puerto Rican"],
      ["Cuban", "Other"]
    ].inject([]){ |sets, ethnicities|
      sets << ethnicities.map{|e| OpenStruct.new({name: e, value: e})}
    }
  end

  def is_under_open_enrollment?
    HbxProfile.current_hbx.under_open_enrollment?
  end

  def ivl_enrollment_effective_date
    HbxProfile.current_hbx.benefit_sponsorship.earliest_effective_date
  end

  def find_document(consumer_role, subject)
    subject_doc = consumer_role.vlp_documents.detect do |documents|
      documents.subject.eql?(subject)
    end

    subject_doc || consumer_role.vlp_documents.build({subject:subject})
  end

  def parse_ethnicity(value)
    return "" unless value.present?
    value = value.select{|a| a.present? }  if value.present?
    value.present? ? value.join(", ") : ""
  end

  def incarceration_cannot_purchase(family_member)
    pronoun = family_member.try(:gender)=='male' ? ' he ':' she '
    name=family_member.try(:first_name) || ''
    result = "Since " + name + " is currently incarcerated," + pronoun + "is not eligible to purchase a plan on DC Health Link.<br/> Other family members may still be eligible to enroll. <br/>Please call us at 1-855-532-5465 to learn about other health insurance options for " + name
  end
end
