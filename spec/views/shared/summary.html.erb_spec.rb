require 'rails_helper'

describe "shared/_summary.html.erb" do
  let(:aws_env) { ENV['AWS_ENV'] || "local" }
  let(:person){ instance_double("Person") }
  let(:family) { instance_double("Family") }
  let(:mock_carrier_profile) { instance_double("CarrierProfile", :dba => "a carrier name", :legal_name => "name") }
  let(:mock_hbx_enrollment) { instance_double("HbxEnrollment", :hbx_enrollment_members => [], :id => "3241251524", :shopping? => true, plan: mock_plan, coverage_kind: 'health') }
  let(:mock_plan) { double("Plan",
      :name => "A Plan Name",
      :carrier_profile_id => "a carrier profile id",
      :carrier_profile => mock_carrier_profile,
      :metal_level => "Silver",
      :plan_type => "A plan type",
      :nationwide => true,
      :deductible => 0,
      :total_premium => 0,
      :total_employer_contribution => 0,
      :total_employee_cost => 0,
      :ehb => 0.988,
      :id => "1234234234",
      :sbc_file => "THE SBC FILE.PDF",
      :can_use_aptc? => true,
      :sbc_document => Document.new({title: 'sbc_file_name', subject: "SBC",
                                     :identifier=>"urn:openhbx:terms:v1:file_storage:s3:bucket:dchbx-enroll-sbc-#{aws_env}#7816ce0f-a138-42d5-89c5-25c5a3408b82"})
      ) }
  let(:mock_qhp_cost_share_variance) { instance_double("Products::QhpCostShareVariance", :qhp_service_visits => []) }

  before :each do
    Caches::MongoidCache.release(CarrierProfile)
    allow(person).to receive(:primary_family).and_return(family)
    allow(family).to receive(:enrolled_hbx_enrollments).and_return([mock_hbx_enrollment])
    assign :person, person
    assign :plan, mock_plan
    assign :hbx_enrollment, mock_hbx_enrollment
    render "shared/summary", :qhp => mock_qhp_cost_share_variance
  end

  it "should have a link to download the sbc pdf" do
    expect(rendered).to have_selector("a[href='#{root_path + "document/download/dchbx-enroll-sbc-local/7816ce0f-a138-42d5-89c5-25c5a3408b82?content_type=application/pdf&filename=APlanName.pdf&disposition=inline"}']")
  end

  it "should have a label 'Summary of Benefits and Coverage (SBC)'" do
    expect(rendered).to include('Summary of Benefits and Coverage')
  end

  it "should not have 'having a baby'" do
    expect(rendered).not_to have_selector("h4", text: "Having a Baby")
  end

  it "should not have 'managing type diabetes'" do
    expect(rendered).not_to have_selector("h4", text: "Managing Type 2 Diabetes")
  end
end
