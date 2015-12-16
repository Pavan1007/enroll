require 'rails_helper'

RSpec.describe BrokerAgencies::ProfilesController do
  let(:broker_agency_profile_id) { "abecreded" }
  let!(:broker_agency) { FactoryGirl.create(:broker_agency) }
  let(:broker_agency_profile) { broker_agency.broker_agency_profile }

  describe "GET new" do
    let(:user) { double("user", last_portal_visited: "test.com")}
    let(:person) { double("person")}

    it "should render the new template" do
      allow(user).to receive(:has_broker_agency_staff_role?).and_return(false)
      allow(user).to receive(:has_broker_role?).and_return(false)
      allow(user).to receive(:last_portal_visited=).and_return("true")
      allow(user).to receive(:save).and_return(true)
      sign_in(user)
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET show" do

    before(:each) do
      sign_in(user)
      get :show, id: broker_agency_profile.id
    end

    context "user without broker agency staff role" do
      let(:user) { FactoryGirl.create(:user) }

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "should render the show template" do
        expect(response).to render_template("show")
      end
    end

    context "user with broker agency staff role" do
      let(:user) { FactoryGirl.create(:user, person: person) }
      let(:person) { FactoryGirl.create(:person) }
      let(:broker_agency_staff_role) { double(BrokerAgencyStaffRole, broker_agency_profile: broker_agency_profile) }

      before do
        sign_in(user)
        allow(user).to receive(:has_broker_agency_staff_role?).and_return(true)
        allow(person).to receive(:broker_agency_staff_roles).and_return([broker_agency_staff_role])
        get :show, id: broker_agency_profile.id
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "should render the show template" do
        expect(response).to render_template("show")
      end

    end
  end

  describe "GET edit" do
    let(:user) { double(has_broker_role?: true)}

    before :each do
      sign_in user
      get :edit, id: broker_agency_profile.id
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "should render the edit template" do
      expect(response).to render_template("edit")
    end
  end

  describe "patch update" do
    let(:user) { double(has_broker_role?: true)}
    #let(:org) { double }
    let(:org) { double("Organization", id: "test") }

    before :each do
      sign_in user
      #allow(Forms::BrokerAgencyProfile).to receive(:find).and_return(org)
      allow(Organization).to receive(:find).and_return(org)
      allow(controller).to receive(:sanitize_broker_profile_params).and_return(true)
    end

    it "should success with valid params" do
      allow(org).to receive(:update_attributes).and_return(true)
      #post :update, id: broker_agency_profile.id, organization: {}
      #expect(response).to have_http_status(:redirect)
      #expect(flash[:notice]).to eq "Successfully Update Broker Agency Profile"
    end

    it "should failed with invalid params" do
      allow(org).to receive(:update_attributes).and_return(false)
      #post :update, id: broker_agency_profile.id, organization: {}
      #expect(response).to render_template("edit")
      #expect(response).to have_http_status(:redirect)
      #expect(flash[:error]).to eq "Failed to Update Broker Agency Profile"
    end
  end

  describe "GET index" do
    let(:user) { double("user", :has_hbx_staff_role? => true, :has_broker_agency_staff_role? => false)}
    let(:person) { double("person")}
    let(:hbx_staff_role) { double("hbx_staff_role")}
    let(:hbx_profile) { double("hbx_profile")}

    before :each do
      allow(user).to receive(:has_hbx_staff_role?).and_return(true)
      allow(user).to receive(:has_broker_role?).and_return(false)
      allow(user).to receive(:person).and_return(person)
      allow(person).to receive(:hbx_staff_role).and_return(hbx_staff_role)
      allow(hbx_staff_role).to receive(:hbx_profile).and_return(hbx_profile)
      sign_in(user)
      get :index
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "renders the 'index' template" do
      expect(response).to render_template("index")
    end
  end

  describe "CREATE post" do
    let(:user){ double(:save => double("user")) }
    let(:person){ double(:broker_agency_contact => double("test")) }
    let(:broker_agency_profile){ double("test") }
    let(:form){double("test", :broker_agency_profile => broker_agency_profile)}
    let(:organization) {double("organization")}
    context "when no broker role" do
      before(:each) do
        allow(user).to receive(:has_broker_agency_staff_role?).and_return(false)
        allow(user).to receive(:has_broker_role?).and_return(false)
        allow(user).to receive(:person).and_return(person)
        allow(user).to receive(:person).and_return(person)
        sign_in(user)
        allow(Forms::BrokerAgencyProfile).to receive(:new).and_return(form)
      end

      it "returns http status" do
        allow(form).to receive(:save).and_return(true)
        post :create, organization: {}
        expect(response).to have_http_status(:redirect)
      end

      it "should render new template when invalid params" do
        allow(form).to receive(:save).and_return(false)
        post :create, organization: {}
        expect(response).to render_template("new")
      end
    end

  end

  describe "REDIRECT to my account if broker role present" do
    let(:user) { double("user", :has_hbx_staff_role? => true, :has_employer_staff_role? => false)}
    let(:hbx_staff_role) { double("hbx_staff_role")}
    let(:hbx_profile) { double("hbx_profile")}
    let(:person){double(:broker_agency_staff_roles => [double(:broker_agency_profile_id => 5)]) }

    it "should redirect to myaccount" do
      allow(user).to receive(:has_hbx_staff_role?).and_return(true)
      allow(user).to receive(:person).and_return(person)
      allow(person).to receive(:hbx_staff_role).and_return(hbx_staff_role)
      allow(hbx_staff_role).to receive(:hbx_profile).and_return(hbx_profile)
      allow(user).to receive(:has_broker_agency_staff_role?).and_return(true)
      allow(user).to receive(:person).and_return(person)
      sign_in(user)
      get :new
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "get employers" do
    let(:broker_role) {FactoryGirl.build(:broker_role)}
    let(:person) {double("person", broker_role: broker_role)}
    let(:user) { double("user", :has_hbx_staff_role? => true, :has_employer_staff_role? => false)}
    let(:organization) {FactoryGirl.create(:organization)}
    let(:broker_agency_profile) { FactoryGirl.create(:broker_agency_profile, organization: organization) }

    it "should get organizations for employers where broker_agency_account is active" do
      allow(user).to receive(:has_broker_agency_staff_role?).and_return(true)
      sign_in user
      xhr :get, :employers, id: broker_agency_profile.id, format: :js
      expect(response).to have_http_status(:success)
      orgs = Organization.where({"employer_profile.broker_agency_accounts"=>{:$elemMatch=>{:is_active=>true, :broker_agency_profile_id=>broker_agency_profile.id}}})
      expect(assigns(:orgs)).to eq orgs
    end

    it "should get organizations for employers where writing_agent is active" do
      allow(user).to receive(:has_broker_agency_staff_role?).and_return(false)
      allow(user).to receive(:has_hbx_staff_role?).and_return(false)
      allow(user).to receive(:person).and_return(person)
      sign_in user
      xhr :get, :employers, id: broker_agency_profile.id, format: :js
      expect(response).to have_http_status(:success)
      orgs = Organization.where({"employer_profile.broker_agency_accounts"=>{:$elemMatch=>{:is_active=>true, :writing_agent_id=> broker_role.id }}})
      expect(assigns(:orgs)).to eq orgs
    end
  end
end
