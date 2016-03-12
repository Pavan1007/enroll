require 'rails_helper'

describe "shared/_qle_progress.html.erb" do
  let(:plan) { FactoryGirl.build(:plan) }
  let(:enrollment) { double(id: 'hbx_id') }
  let(:person) { FactoryGirl.create(:person)}
  context "step 1" do
    before :each do
      assign :change_plan, "change"
      allow(person).to receive(:consumer_role).and_return(true)
      @person=person
      render 'shared/qle_progress', step: '1'
    end

    it "should have li option for Plan Selection" do
      expect(rendered).to have_selector("li", text: "Plan Selection")
    end

    it "should have li option for household" do
      expect(rendered).to have_selector("li", text: "Household")
    end

    it "should have 25% complete" do
      expect(rendered).to match /25%/
    end
  end

  context "step 3" do
    before :each do
      assign :change_plan, "change"
      assign :plan, plan
      assign :enrollment, enrollment
      allow(person).to receive(:consumer_role).and_return(false)
      @person = person
      render 'shared/qle_progress', step: '3'
    end

    it "should have 75% complete" do
      expect(rendered).to match /75%/
    end

    it "should have li option for household" do
      expect(rendered).to have_selector("li", text: "Household")
    end

    it "should have purchase button" do
      expect(rendered).to have_selector('a', text: 'Confirm')
    end

    it "should have previous option" do
      expect(rendered).to match /PREVIOUS/
    end

    it "should not have disabled link" do
      expect(rendered).not_to have_selector('a.disabled')
    end
  end

  context "step 3 Consumer" do
    before :each do
      assign :change_plan, "change"
      assign :plan, plan
      assign :enrollment, enrollment
      allow(person).to receive(:consumer_role).and_return(true)
      @person = person
      render 'shared/qle_progress', step: '3', kind: 'individual'
    end

    it "should have 75% complete" do
      expect(rendered).to match /75%/
    end

    it "should have li option for household" do
      expect(rendered).to have_selector("li", text: "Household")
    end

    it "should have purchase button" do
      expect(rendered).to have_selector('a', text: 'Confirm')
    end

    it "should have previous option" do
      expect(rendered).to match /PREVIOUS/
    end

    it "should have disabled link" do
      expect(rendered).to have_selector('a.disabled')
    end
  end

  context "waive coverage" do
    let(:hbx_enrollment) { HbxEnrollment.new }
    before :each do
      assign :market_kind, 'shop'
      assign :hbx_enrollment, hbx_enrollment
    end

    it "when hbx_enrollment is not active for employee" do
      render 'shared/qle_progress'
      expect(rendered).not_to have_selector('a', text: 'Waive Coverage')
    end

    it "when hbx_enrollment is active for employee" do
      allow(hbx_enrollment).to receive(:is_active_for_employee?).and_return true
      render 'shared/qle_progress'
      expect(rendered).to have_selector('a', text: 'Waive Coverage')
    end
  end
end
