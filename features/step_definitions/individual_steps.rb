When(/^\w+ visits? the Insured portal during open enrollment$/) do
  visit "/"
  click_link 'Consumer/Family Portal'
  FactoryGirl.create(:hbx_profile, :open_enrollment_coverage_period, :ivl_2015_benefit_package)
  FactoryGirl.create(:qualifying_life_event_kind, market_kind: "individual") #pull out for sep
  Caches::PlanDetails.load_record_cache!
  screenshot("individual_start")
end

And(/Individual asks how to make an email account$/) do

  @browser.button(class: /interaction-click-control-create-account/).wait_until_present
  @browser.a(text: /Don't have an email account?/).fire_event("onclick")
  @browser.element(class: /modal/).wait_until_present
  @browser.element(class: /interaction-click-control-×/).fire_event("onclick")
end

Then(/Individual creates HBX account$/) do
  click_button 'Create account'

  fill_in "user[email]", :with => (@u.email :email)
  fill_in "user[password]", :with => "aA1!aA1!aA1!"
  fill_in "user[password_confirmation]", :with => "aA1!aA1!aA1!"
  screenshot("create_account")
  click_button "Create account"
end

And(/user should see your information page$/) do
  expect(page).to have_content("CONTINUE")
  click_link "CONTINUE"
end

When(/user goes to register as an individual$/) do
  fill_in 'person[first_name]', :with => (@u.first_name :first_name)
  fill_in 'person[last_name]', :with => (@u.last_name :last_name)
  fill_in 'jq_datepicker_ignore_person[dob]', :with => (@u.adult_dob :adult_dob)
  fill_in 'person[ssn]', :with => (@u.ssn :ssn)
  find(:xpath, '//label[@for="radio_male"]').click

  screenshot("register")
  find('.interaction-click-control-continue').click
end

When(/^\w+ clicks? on continue button$/) do
  click_link "Continue"
end

Then(/^user should see heading labeled personal information/) do
  expect(page).to have_content("Personal Information")
end

Then(/Individual should click on Individual market for plan shopping/) do
  expect(page).to have_button("CONTINUE")
  click_button "CONTINUE"
end

Then(/Individual should see a form to enter personal information$/) do
  find(:xpath, '//label[@for="person_us_citizen_true"]').click
  find(:xpath, '//label[@for="person_naturalized_citizen_false"]').click
  find(:xpath, '//label[@for="indian_tribe_member_no"]').click

  find(:xpath, '//label[@for="radio_incarcerated_no"]').click

  fill_in "person_addresses_attributes_0_address_1", :with => "4900 USAA BLVD"
  fill_in "person_addresses_attributes_0_address_2", :with => "212"
  fill_in "person_addresses_attributes_0_city", :with=> "Washington"
  find(:xpath, "//p[@class='label'][contains(., 'SELECT STATE')]").click
  find(:xpath, '//*[@id="address_info"]/div/div[3]/div[2]/div/div[3]/div/ul/li[10]').click
  fill_in "person[addresses_attributes][0][zip]", :with => "20002"
  fill_in "person[phones_attributes][0][full_phone_number]", :with => "9999999999"
  screenshot("personal_form")
end

When(/Individual clicks on Save and Exit/) do
  find(:xpath, '//*[@id="new_person_wrapper"]/div/div[2]/ul[2]/li[2]/a').trigger('click') #overlapping li element wat?
end

Then (/Individual resumes enrollment/) do
  visit '/'
  click_link 'Consumer/Family Portal'
end

Then (/Individual sees previously saved address/) do
  expect(page).to have_field('ADDRESS LINE 1 *', with: '4900 USAA BLVD')
  click_button "CONTINUE"
end

Then(/Individual agrees to the privacy agreeement/) do
  expect(page).to have_content('Authorization and Consent')
  find(:xpath, '//label[@for="agreement_agree"]').click
  click_link "Continue"
end

Then(/^\w+ should see identity verification page and clicks on submit/) do
  expect(page).to have_content('Verify Identity')
  find(:xpath, '//label[@for="interactive_verification_questions_attributes_0_response_id_a"]').click
  find(:xpath, '//label[@for="interactive_verification_questions_attributes_1_response_id_c"]').click
  screenshot("identify_verification")
  click_button "Submit"
  screenshot("override")
  click_link "Please click here once you have contacted the exchange and have been told to proceed."
end

Then(/\w+ should see the dependents form/) do
  expect(page).to have_content('Add Member')
  screenshot("dependents")
end

And(/Individual clicks on add member button/) do
  find(:xpath, '//*[@id="dependent_buttons"]/div/a').click
  expect(page).to have_content('Lives with primary subscriber')

  fill_in "dependent[first_name]", :with => @u.first_name
  fill_in "dependent[last_name]", :with => @u.last_name
  fill_in "jq_datepicker_ignore_dependent[dob]", :with => @u.adult_dob
  fill_in "dependent[ssn]", :with => @u.ssn
  find(:xpath, "//p[@class='label'][contains(., 'RELATION *')]").click
  find(:xpath, '//*[@id="new_dependent"]/div[1]/div[3]/div[4]/div/div/div[3]/div/ul/li[3]').click
  find(:xpath, '//label[@for="radio_female"]').click
  find(:xpath, '//label[@for="dependent_us_citizen_true"]').click
  find(:xpath, '//label[@for="dependent_naturalized_citizen_false"]').click
  find(:xpath, '//label[@for="indian_tribe_member_no"]').click
  find(:xpath, '//label[@for="radio_incarcerated_no"]').click

  screenshot("add_member")
  click_button "Confirm Member"
end

And(/Individual again clicks on add member button/) do
  find(:xpath, '//*[@id="dependent_buttons"]/div/a').click
  expect(page).to have_content('Lives with primary subscriber')

  fill_in "dependent[first_name]", :with => @u.first_name
  fill_in "dependent[last_name]", :with => @u.last_name
  fill_in "jq_datepicker_ignore_dependent[dob]", :with => '01/15/2013'
  fill_in "dependent[ssn]", :with => @u.ssn
  find(:xpath, "//p[@class='label'][contains(., 'RELATION *')]").click
  find(:xpath, '//*[@id="new_dependent"]/div[1]/div[3]/div[4]/div/div/div[3]/div/ul/li[4]').click
  find(:xpath, '//label[@for="radio_female"]').click
  find(:xpath, '//label[@for="dependent_us_citizen_true"]').click
  find(:xpath, '//label[@for="dependent_naturalized_citizen_false"]').click
  find(:xpath, '//label[@for="indian_tribe_member_no"]').click
  find(:xpath, '//label[@for="radio_incarcerated_no"]').click

  click_button "Confirm Member"
end


And(/I click on continue button on household info form/) do
  click_link "Continue"
end

And(/I click on continue button on group selection page/) do
  #TODO This some group selection nonsense
  click_link "Continue" #Get
  click_button "CONTINUE" #Post
  #Goes off the see the wizard at /I select three plans to compare/ for now
end

And(/I select a plan on plan shopping page/) do
   screenshot("plan_shopping")
   find(:xpath, '//*[@id="plans"]/div[1]/div/div[5]/div[3]/a[1]').click
end

And(/I click on purchase button on confirmation page/) do
  find('.interaction-choice-control-value-terms-check-thank-you').click
  fill_in 'first_name_thank_you', :with => (@u.find :first_name)
  fill_in 'last_name_thank_you', :with => (@u.find :last_name)
  screenshot("purchase")
  click_link "Confirm"
end

And(/I click on continue button to go to the individual home page/) do
  click_link "GO TO MY ACCOUNT"
end

And(/I should see the individual home page/) do
  expect(page).to have_content "My DC Health Link"
  screenshot("my_account")
  # something funky about these tabs in JS
  # click_link "Documents"
  # click_link "Manage Family"
  # click_link "My DC Health Link"
end

And(/I click to see my Secure Purchase Confirmation/) do
  wait_and_confirm_text /Messages/
  @browser.link(text: /Messages/).click
  wait_and_confirm_text /Your Secure Enrollment Confirmation/
end

When(/^I visit the Insured portal$/) do
  visit "/"
  click_link 'Consumer/Family Portal'
end

Then(/Second user creates an individual account$/) do
  @browser.button(class: /interaction-click-control-create-account/).wait_until_present
  @browser.text_field(class: /interaction-field-control-user-email/).set(@u.email :email2)
  @browser.text_field(class: /interaction-field-control-user-password/).set("aA1!aA1!aA1!")
  @browser.text_field(class: /interaction-field-control-user-password-confirmation/).set("aA1!aA1!aA1!")
  screenshot("create_account")
  scroll_then_click(@browser.input(value: "Create account"))
end

Then(/^Second user goes to register as individual/) do
  step "user should see your information page"
  step "user goes to register as an individual"
  @browser.text_field(class: /interaction-field-control-person-first-name/).set("Second")
  @browser.text_field(class: /interaction-field-control-person-ssn/).set(@u.ssn :ssn2)
end

Then(/^Second user should see a form to enter personal information$/) do
  step "Individual should see a form to enter personal information"
  @browser.text_field(class: /interaction-field-control-person-emails-attributes-0-address/).set(@u.email :email2)
end

Then(/Second user asks for help$/) do
  @browser.divs(text: /Help me sign up/).last.click
  wait_and_confirm_text /Options/
  click_when_present(@browser.a(class: /interaction-click-control-help-from-a-customer-service-representative/))
  @browser.text_field(class: /interaction-field-control-help-first-name/).set("Sherry")
  @browser.text_field(class: /interaction-field-control-help-last-name/).set("Buckner")
  screenshot("help_from_a_csr")
  @browser.div(id: 'search_for_plan_shopping_help').click
  @browser.button(class: 'close').click
end

And(/^.+ clicks? the continue button$/i) do
  click_when_present(@browser.a(text: /continue/i))
end

Then(/^.+ sees the Verify Identity Consent page/)  do
  wait_and_confirm_text(/Verify Identity/)
end

When(/^CSR accesses the HBX portal$/) do
  @browser.goto("http://localhost:3000/")
  @browser.a(text: /hbx portal/i).wait_until_present
  @browser.a(text: /hbx portal/i).click
  wait_and_confirm_text(/Sign In Existing Account/)
  click_when_present(@browser.link(class: /interaction-click-control-sign-in-existing-account/))
  sleep 2
  @browser.text_field(class: /interaction-field-control-user-email/).wait_until_present
  @browser.text_field(class: /interaction-field-control-user-email/).set("sherry.buckner@dc.gov")
  @browser.text_field(class: /interaction-field-control-user-password/).set("aA1!aA1!aA1!")
  @browser.element(class: /interaction-click-control-sign-in/).click
  sleep 1

end

Then(/CSR should see the Agent Portal/) do
  wait_and_confirm_text /a Trained Expert/
end

Then(/CSR opens the most recent Please Contact Message/) do
  wait_and_confirm_text /Please contact/
  sleep 1
  tr=@browser.trs(text: /Please contact/).last
  scroll_then_click(tr.a(text: /show/i))
end

Then(/CSR clicks on Resume Application via phone/) do
  wait_and_confirm_text /Assist Customer/
  @browser.a(text: /Assist Customer/).fire_event('onclick')
end

When(/I click on the header link to return to CSR page/) do
  wait_and_confirm_text /Trained/
  @browser.a(text: /I'm a Trained Expert/i).click
end

Then(/CSR clicks on New Consumer Paper Application/) do
  click_when_present(@browser.a(text: /New Consumer Paper Application/i))
end

Then(/CSR starts a new enrollment/) do
  wait_and_confirm_text /Personal Information/
  wait_and_confirm_text /15% Complete/
end

Then(/^click continue again$/) do
  wait_and_confirm_text /continue/i
  sleep(1)
  scroll_then_click(@browser.a(text: /continue/i))
end

Given(/^\w+ visits the Employee portal$/) do
  visit '/'
  click_link 'Employee Portal'
  screenshot("start")
  click_button 'Create account'
end

Then(/^(\w+) creates a new account$/) do |person|
  find('.interaction-click-control-create-account').click
  fill_in 'user[email]', with: (@u.email 'email' + person)
  fill_in 'user[password]', with: "aA1!aA1!aA1!"
  fill_in 'user[password_confirmation]', with: "aA1!aA1!aA1!"
  click_button 'Create account'
end

When(/^\w+ clicks continue$/) do
  find('.interaction-click-control-continue').click
end

When(/^\w+ selects Company match for (\w+)$/) do |company|
  expect(page).to have_content(company)
  find('#btn-continue').click
end

When(/^\w+ sees the (.*) page$/) do |title|
  expect(page).to have_content(title)
end

When(/^\w+ visits the Consumer portal$/i) do
  step "I visit the Insured portal"
end

When(/^(\w+) signs in$/) do |person|
  click_link 'Sign In Existing Account'
  fill_in 'user[email]', with: (@u.find 'email' + person)
  find('#user_email').set(@u.find 'email' + person)
  fill_in 'user[password]', with: "aA1!aA1!aA1!"
  click_button 'Sign in'
end

Given(/^Company Tronics is created with benefits$/) do
  step "I visit the Employer portal"
  step "Tronics creates an HBX account"
  step "Tronics should see a successful sign up message"
  step "I should click on employer portal"
  step "Tronics creates a new employer profile"
  step "Tronics creates and publishes a plan year"
  step "Tronics should see a published success message without employee"
end

Then(/^(\w+) enters person search data$/) do |insured|
  step "#{insured} sees the Personal Information page"
  person = people[insured]
  fill_in "person[first_name]", with: person[:first_name]
  fill_in "person[last_name]", with: person[:last_name]
  fill_in "jq_datepicker_ignore_person[dob]", with: person[:dob]
  fill_in "person[ssn]", with: person[:ssn]
  find(:xpath, '//label[@for="radio_female"]').click
  click_button 'CONTINUE'
end

Then(/^\w+ continues$/) do
  find('.interaction-click-control-continue').click
end

Then(/^\w+ continues again$/) do
  find('.interaction-click-control-continue').click
end

Then(/^\w+ enters demographic information$/) do
  step "Individual should see a form to enter personal information"
  fill_in 'person[emails_attributes][0][address]', with: "user#{rand(1000)}@example.com"
end

And(/^\w+ is an Employee$/) do
  wait_and_confirm_text /Employer/i
end

And(/^\w+ is a Consumer$/) do
  wait_and_confirm_text /Verify Identity/i
end

And(/(\w+) clicks on the purchase button on the confirmation page/) do |insured|
  person = people[insured]
  click_when_present(@browser.checkbox(class: /interaction-choice-control-value-terms-check-thank-you/))
  @browser.text_field(class: /interaction-field-control-first-name-thank-you/).set(person[:first_name])
  @browser.text_field(class: /interaction-field-control-last-name-thank-you/).set(person[:last_name])
  screenshot("purchase")
  click_when_present(@browser.a(text: /confirm/i))
end


Then(/^Aptc user create consumer role account$/) do
  @browser.button(class: /interaction-click-control-create-account/).wait_until_present
  @browser.text_field(class: /interaction-field-control-user-email/).set("aptc@dclink.com")
  @browser.text_field(class: /interaction-field-control-user-password/).set("aA1!aA1!aA1!")
  @browser.text_field(class: /interaction-field-control-user-password-confirmation/).set("aA1!aA1!aA1!")
  screenshot("aptc_create_account")
  scroll_then_click(@browser.input(value: "Create account"))
end

Then(/^Aptc user goes to register as individual/) do
  step "user should see your information page"
  step "user goes to register as an individual"
  @browser.text_field(class: /interaction-field-control-person-first-name/).set("Aptc")
  @browser.text_field(class: /interaction-field-control-person-ssn/).set(@u.ssn :ssn3)
  screenshot("aptc_register")

end

Then(/^Aptc user should see a form to enter personal information$/) do
  step "Individual should see a form to enter personal information"
  @browser.text_field(class: /interaction-field-control-person-emails-attributes-0-address/).set("aptc@dclink.com")
  screenshot("aptc_personal")
end

Then(/^Prepare taxhousehold info for aptc user$/) do
  person = User.find_by(email: 'aptc@dclink.com').person
  household = person.primary_family.latest_household

  start_on = TimeKeeper.date_of_record + 3.months

  if household.tax_households.blank?
    household.tax_households.create(is_eligibility_determined: TimeKeeper.date_of_record, allocated_aptc: 100, effective_starting_on: start_on, submitted_at: TimeKeeper.date_of_record)
    fm_id = person.primary_family.family_members.last.id
    household.tax_households.last.tax_household_members.create(applicant_id: fm_id, is_ia_eligible: true, is_medicaid_chip_eligible: true, is_subscriber: true)
    household.tax_households.last.eligibility_determinations.create(max_aptc: 80, determined_on: Time.now, csr_percent_as_integer: 40)
  end

  screenshot("aptc_householdinfo")
end

And(/Aptc user set elected amount and select plan/) do
  @browser.text_field(id: /elected_aptc/).wait_until_present
  @browser.text_field(id: "elected_aptc").set("20")

  click_when_present(@browser.a(text: /Select Plan/))
  screenshot("aptc_setamount")
end

Then(/Aptc user should see aptc amount and click on confirm button on thanyou page/) do
  click_when_present(@browser.checkbox(class: /interaction-choice-control-value-terms-check-thank-you/))
  expect(@browser.td(text: "$20.00").visible?).to be_truthy
  @browser.checkbox(id: "terms_check_thank_you").set(true)
  @browser.text_field(class: /interaction-field-control-first-name-thank-you/).set("Aptc")
  @browser.text_field(class: /interaction-field-control-last-name-thank-you/).set(@u.find :last_name1)
  screenshot("aptc_purchase")
  click_when_present(@browser.a(text: /confirm/i))
end

Then(/Aptc user should see aptc amount on receipt page/) do
  @browser.h1(text: /Enrollment Submitted/).wait_until_present
  expect(@browser.td(text: "$20.00").visible?).to be_truthy
  screenshot("aptc_receipt")

end

Then(/Aptc user should see aptc amount on individual home page/) do
  @browser.h1(text: /My DC Health Link/).wait_until_present
  expect(@browser.strong(text: "$20.00").visible?).to be_truthy
  expect(@browser.label(text: /APTC AMOUNT/).visible?).to be_truthy
  screenshot("aptc_ivl_home")

end
